library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.myTypes.all;
use ieee.std_logic_unsigned.all;

entity datapath is
	generic (NUMBIT: integer:= 32;
				ADDRESS_WIDTH_RF : integer := 5;
				ADDRESS_WIDTH_DM : integer := 5);
	port(	CLK 					: in std_logic;
				RST 					: in std_logic;
				--Inputs
				INP1 					: in std_logic_vector(NUMBIT-1 downto 0);		--immediate 1 (NPC)
				INP2 					: in std_logic_vector((NUMBIT/2)-1 downto 0);		--immediate 2
				IMM26					: in std_logic_vector(25 downto 0);							--immediate JUMP istruction
				RS1 					: in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);	--address source1 RF
				RS2 					: in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);	--address source2 RF
				RD 						: in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);	--address destination RF
				--Inputs Control
				-- ID
				REGF_LATCH_EN      : in std_logic;  -- Register File Latch Enable
		    RegA_LATCH_EN      : in std_logic;  -- Register A Latch Enable
		    RegB_LATCH_EN      : in std_logic;  -- Register B Latch Enable
		    RegIMM_LATCH_EN    : in std_logic;  -- Immediate Register Latch Enable
		    RegRD1_LATCH_EN    : in std_logic;  -- Register RD1 Latch Enable
				SIGN_UNSIGN			 	: in std_logic;	-- Signed/unsigned  operations (1/0)
				RFR1_EN						 : in std_logic;		-- Read Enable Port1 RF
				RFR2_EN						 : in std_logic;		-- Read Enable Port2 RF
				MUX_IMM_SEL				: in std_logic;
				JUMP							 : in std_logic;  -- 1 for jump, does not consider conditions
				JUMP_EN           : in std_logic;  -- JUMP Enable Signal for PC input MUX
				EQ_COND 	 				 : in std_logic;  -- Branch if (not) Equal to Zero
				MUXA_SEL           : in std_logic;  -- MUX-A sel
				-- EX
				MUXB_SEL         	 : in std_logic;  -- MUX-B Sel
				RALUOUT_LATCH_EN    	 : in std_logic;  -- ALU Output Register Enable
				REGME_LATCH_EN		 : in std_logic;	 -- Register ME Latch Enable
				RegRD2_LATCH_EN  	 : in std_logic;  -- Register RD2 Latch Enable
				--ALU
				ALU_OPCODE         : in aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
				-- MEM
				--DRAM_EN						: in std_logic;	 -- Data Ram Enable
				--DRAM_RE           : in std_logic;  -- Data RAM Read Enable
				--DRAM_WE           : in std_logic;  -- Data RAM Write Enable
				ADDR_DRAM					: out std_logic_vector (ADDRESS_WIDTH_DM - 1 downto 0);
				DATAIN_DRAM				: out std_logic_vector (NUMBIT - 1 downto 0);
				DATAOUT_DRAM			: in std_logic_vector (NUMBIT - 1 downto 0);
				LMD_LATCH_EN      : in std_logic;  -- LMD Register Latch Enable
				RALUOUT2_LATCH_EN : in std_logic;  -- ALU Output Register Enable
				RegRD3_LATCH_EN 	: in std_logic;  -- RD3 Register Latch Enable
				RPCplus8_LATCH_EN : in std_logic;  -- PCplus8 Register Latch Enable
				-- WB Control signals
				WB_MUX_SEL        : in std_logic;  -- Write Back MUX Sel
				RF_WE             : in std_logic;  -- Register File Write Enable
				ROUT_LATCH_EN			: in std_logic;  -- Out register Latch Enable
				JandL								: in std_logic;	 -- Jump&Link signal to control MUXs in input to RegFile
				--Outputs
				BRANCH_CTRL_SIG		: out std_logic;
				BRANCH_ALU_OUT		: out std_logic_vector(NUMBIT-1 downto 0);
				Data_out				: out std_logic_vector(NUMBIT-1 downto 0);
				--Forwarding Unit
				REGWRITE_XM        : in std_logic; -- Indicate a write back in register file, to use by Forwarding unit
		    REGWRITE_MW        : in std_logic -- Indicate a write back in register file, to use by Forwarding unit
				);
end datapath;

architecture Struct of datapath is

component MUX21
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		SEL:	In	std_logic;
		Y:	Out	std_logic);
end component;

component MUX21_GENERIC
	Generic (N: integer:= 4);
	Port (	A:	In	std_logic_vector(N-1 downto 0) ;
		B:	In	std_logic_vector(N-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(N-1 downto 0));
end component;

component FlipFlop
	port (clk : in std_logic;
			en : in std_logic;	--active low
			rst : in std_logic;	--active low
			d : in std_logic;
			q : out std_logic);
end component;

component reg
	generic (NUMBIT : integer :=32);
	port (clk : in std_logic;
			en : in std_logic;
			rst : in std_logic;	--active low
			d : in std_logic_vector(NUMBIT-1 downto 0);
			q : out std_logic_vector(NUMBIT-1 downto 0));
end component;

component register_file
 generic( NUMBIT : integer := 32;
			 BITADDR : integer := 5);
 port (CLK:		IN std_logic;
 			RESET: 	IN std_logic;
	 		ENABLE: 	IN std_logic;
	 		RD1: 		IN std_logic;
	 		RD2: 		IN std_logic;
			WR: 		IN std_logic;
	 		ADD_WR: 	IN std_logic_vector(BITADDR-1 downto 0);
	 		ADD_RD1: 	IN std_logic_vector(BITADDR-1 downto 0);
	 		ADD_RD2: 	IN std_logic_vector(BITADDR-1 downto 0);
	 		DATAIN: 	IN std_logic_vector(NUMBIT-1 downto 0);
			OUT1: 		OUT std_logic_vector(NUMBIT-1 downto 0);
	 		OUT2: 		OUT std_logic_vector(NUMBIT-1 downto 0));
end component;

component alu is
  Generic(NUMBIT : integer :=32);
  Port( DATA1       : in std_logic_vector(NUMBIT-1 downto 0);
        DATA2       : in std_logic_vector(NUMBIT-1 downto 0);
        FUNC  : in aluOp;
        OUTALU : out std_logic_vector(NUMBIT-1 downto 0));
end component;

component signExtend
  generic (NUMBIT_in : integer := 16;
           NUMBIT_out : integer := 32);
  port (
    in_s :     in std_logic_vector(NUMBIT_in-1 downto 0);
    sign_unsign :    in std_logic;                          --1 for sign, 0 for unsign
    out_s :  out std_logic_vector (NUMBIT_out-1 downto 0));
end component;

component BranchMgmt
  generic(NUMBIT : integer := 32);
  port( Rin : in std_logic_vector(NUMBIT-1 downto 0);
        Cond : in std_logic;    --1 for BEQZ, 0 for BNEZ
				Jump : in std_logic;    --1 for jump, ->output always 1
        Branch : out std_logic);
end component;

component ForwardingUnit is
  generic (NUMBIT : integer := 32;
	 				 ADDRESS_WIDTH_RF : integer := 5);
	 port (
	   CLK : in std_logic;
	   RST : in std_logic; --active low
	   RS1 : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
	   RS2 : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
	   RD_XM  : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
	   RD_MW  : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
	   REGWRITE_XM : in std_logic;
	   REGWRITE_MW : in std_logic;
	   ForwardA : out std_logic_vector (1 downto 0);
	   forwardB : out std_logic_vector (1 downto 0);
	   ForwardC : out std_logic;
	   ForwardD : out std_logic_vector(1 downto 0));
end component;

component P4addersub
	Generic(N : integer :=32);
	Port(A : in std_logic_vector(N-1 downto 0);
			 B : in std_logic_vector(N-1 downto 0);
			 sub_add : in std_logic;
			 Y : out std_logic_vector(N-1 downto 0);
			 Cout : out std_logic);
end component;


---DECODE
signal RA_IN, RB_IN : std_logic_vector(NUMBIT-1 downto 0);
signal RA_OUT, RB_OUT, RIMM1_OUT, RIMM2_OUT :  std_logic_vector(NUMBIT-1 downto 0);
signal RD1_OUT : std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
signal SIGNEXT_IMP2, SIGNEXT_IMM26: std_logic_vector(NUMBIT-1 downto 0);
signal MUX_IMM_OUT : std_logic_vector(NUMBIT-1 downto 0);
signal MUXA_OUT : std_logic_vector(NUMBIT-1 downto 0);
signal IMM_DIVby4 : std_logic_vector(NUMBIT-1 downto 0);
signal DUMMY_COUT : std_logic;
--EXECUTE
signal MUXB_OUT, ALU_OUT : std_logic_vector(NUMBIT-1 downto 0);
signal RME_OUT, RALUOUT_OUT : std_logic_vector(NUMBIT-1 downto 0);
signal RD2_OUT : std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
signal BRANCH_T_NT, RBRANCH_OUT : std_logic;
signal RPCplus8_OUT : std_logic_vector(NUMBIT-1 downto 0);
signal ALU_inputA, ALU_inputB : std_logic_vector (NUMBIT - 1 downto 0);
--MEMORY
signal LMD_OUT, RALUOUT2_OUT : std_logic_vector(NUMBIT-1 downto 0);
signal RD3_OUT : std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
--WRITE BACK
signal MUXC_OUT : std_logic_vector(NUMBIT-1 downto 0);
signal Out_s 		: std_logic_vector(NUMBIT-1 downto 0);
signal MUX_WRaddr_OUT : std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
signal MUX_WRdata_OUT : std_logic_vector(NUMBIT-1 downto 0);
--Forwarding unit
signal ForwardA, forwardB, ForwardD : std_logic_vector(1 downto 0);
signal ForwardC : std_logic;
signal MUX_FORWARD_MEM_OUT : std_logic_vector(NUMBIT - 1 downto 0);
signal MUX_FORWARDING_BRANCH_OUT : std_logic_vector(NUMBIT - 1 downto 0);

begin

------------------------------DECODE----------------------------------------------
	reg_file_0: register_file generic map	(NUMBIT=>NUMBIT, BITADDR=>ADDRESS_WIDTH_RF)
							port map (CLK=>CLK,
												RESET=>RST,
												ENABLE=>REGF_LATCH_EN,
												RD1=>RFR1_EN,
												RD2=>RFR2_EN,
												WR=>RF_WE,
												ADD_WR=>MUX_WRaddr_OUT,
												ADD_RD1=>RS1,
												ADD_RD2=>RS2,
												DATAIN=>MUX_WRdata_OUT,
												OUT1=>RA_IN,
												OUT2=>RB_IN);

		signExtend_0: signExtend generic map(NUMBIT_in => 16, NUMBIT_out => NUMBIT)
									port map (INP2, SIGN_UNSIGN, SIGNEXT_IMP2);

		--IMM26_to_24 <= IMM26(25 downto 2);	--branch address divided by 4
		signExtend_1: signExtend generic map(NUMBIT_in => 26, NUMBIT_out => NUMBIT)
									port map (IMM26, '1', SIGNEXT_IMM26);

		mux_IMM: MUX21_GENERIC generic map (N=>NUMBIT)
						 port map (SIGNEXT_IMP2, SIGNEXT_IMM26, MUX_IMM_SEL, MUX_IMM_OUT);

		reg_in1: reg generic map(NUMBIT=>NUMBIT)
						 port map (CLK, RegIMM_LATCH_EN, RST, INP1, RIMM1_OUT);
		reg_A: reg generic map(NUMBIT=>NUMBIT)
		 				 port map (CLK, RegA_LATCH_EN, RST, RA_IN, RA_OUT);
		reg_B: reg generic map(NUMBIT=>NUMBIT)
	 				 	 port map (CLK, RegB_LATCH_EN, RST, RB_IN, RB_OUT);
		reg_in2: reg generic map(NUMBIT=>NUMBIT)
			 			 port map (CLK, RegIMM_LATCH_EN, RST, MUX_IMM_OUT, RIMM2_OUT);
		reg_RD1: reg generic map(NUMBIT=>ADDRESS_WIDTH_RF)
						 port map (CLK, RegRD1_LATCH_EN, RST, RD, RD1_OUT);

		BranchMgmt_0: BranchMgmt generic map (NUMBIT=>NUMBIT)
 								port map (MUX_FORWARDING_BRANCH_OUT, EQ_COND, JUMP, BRANCH_T_NT);
		mux_BRANCH: MUX21 port map (BRANCH_T_NT, '0', JUMP_EN, BRANCH_CTRL_SIG);
		mux_A: MUX21_GENERIC generic map (N=>NUMBIT)
						 port map (INP1, MUX_FORWARDING_BRANCH_OUT, MUXA_SEL, MUXA_OUT);

		P4adder_branching: P4addersub generic map (N => NUMBIT)
											 port map (MUXA_OUT, IMM_DIVby4, '0', BRANCH_ALU_OUT, DUMMY_COUT);

		IMM_DIVby4 <= MUX_IMM_OUT(NUMBIT-1) & MUX_IMM_OUT(NUMBIT-1) & MUX_IMM_OUT(NUMBIT - 1 downto 2);
		--BRANCH_ALU_OUT <= MUXA_OUT + IMM_DIVby4;  --to be improved with a real adder

		MUX_FORWARDING_BRANCH: process (RA_IN, RALUOUT_OUT, MUXC_OUT, ForwardD)
		begin
			case ForwardD is
				when "00" => MUX_FORWARDING_BRANCH_OUT <= RA_IN;
				when "01" => MUX_FORWARDING_BRANCH_OUT <= MUXC_OUT;
				when "10" => MUX_FORWARDING_BRANCH_OUT <= RALUOUT_OUT;
				when others => MUX_FORWARDING_BRANCH_OUT <= (others => '0');
			end case;
		end process MUX_FORWARDING_BRANCH;

------------------------------EXECUTE-----------------------------------------
  mux_B: MUX21_GENERIC generic map (N=>NUMBIT)
				 port map (ALU_inputB, RIMM2_OUT, MUXB_SEL, MUXB_OUT);

	alu_0: alu generic map (NUMBIT=>NUMBIT)
				 port map (ALU_inputA, MUXB_OUT, ALU_OPCODE, ALU_OUT);

	reg_ALUOUT: reg generic map(NUMBIT=>NUMBIT)
	 				 		port map (CLK, RALUOUT_LATCH_EN, RST, ALU_OUT, RALUOUT_OUT);
	reg_ME: reg generic map(NUMBIT=>NUMBIT)
	 			 	port map (CLK, REGME_LATCH_EN, RST, RB_OUT, RME_OUT);
	reg_RD2: reg generic map(NUMBIT=>ADDRESS_WIDTH_RF)
	 		 	 	 port map (CLK, RegRD2_LATCH_EN, RST, RD1_OUT, RD2_OUT);

	MUX_ALU_INPUTA : process (RA_OUT, RALUOUT_OUT, MUXC_OUT, ForwardA)
		begin
			case ForwardA is
				when "00" => ALU_inputA <= RA_OUT;
				when "01" => ALU_inputA <= MUXC_Out;
				when "10" => ALU_inputA <= RALUOUT_OUT;
				when others => ALU_inputA <= (others => '0');
			end case;
	end process MUX_ALU_INPUTA;

	MUX_ALU_INPUTB : process (RB_OUT, RALUOUT_OUT, MUXC_OUT, ForwardB)
		begin
			case ForwardB is
				when "00" => ALU_inputB <= RB_OUT;
				when "01" => ALU_inputB <= MUXC_Out;
				when "10" => ALU_inputB <= RALUOUT_OUT;
				when others => ALU_inputB <= (others => '0');
			end case;
	end process MUX_ALU_INPUTB;


-------------------------------MEMORY-----------------------------------------
	reg_LMD: reg generic map(NUMBIT=>NUMBIT)
					 port map (CLK, LMD_LATCH_EN, RST, DATAOUT_DRAM, LMD_OUT);
	reg_ALUOUT2: reg generic map(NUMBIT=>NUMBIT)
					 port map (CLK, RALUOUT2_LATCH_EN, RST, RALUOUT_OUT, RALUOUT2_OUT);
	reg_RD3: reg generic map(NUMBIT=>ADDRESS_WIDTH_RF)
				 	 port map (CLK, RegRD3_LATCH_EN, RST, RD2_OUT, RD3_OUT);
	PCplus8: reg generic map (NUMBIT=>NUMBIT)
				 port map (CLK, RPCplus8_LATCH_EN, RST, RIMM1_OUT, RPCplus8_OUT);

	MUX_FORWARD_MEM: MUX21_GENERIC generic map (N=>NUMBIT)
									 port map (MUXC_OUT, RME_OUT, ForwardC, MUX_FORWARD_MEM_OUT);

	ADDR_DRAM <= RALUOUT_OUT(ADDRESS_WIDTH_DM-1 downto 0);
	DATAIN_DRAM <= MUX_FORWARD_MEM_OUT;


-----------------------WRITE BACK---------------------------------------------
	mux_C: MUX21_GENERIC generic map (N=>NUMBIT)
				 port map (LMD_OUT, RALUOUT2_OUT, WB_MUX_SEL ,MUXC_Out);
  reg_OUT: reg generic map(NUMBIT=>NUMBIT)
			 	   port map (CLK, ROUT_LATCH_EN, RST, MUXC_OUT, Out_s);
	mux_WRaddr: MUX21_GENERIC generic map (N=>ADDRESS_WIDTH_RF)
							port map ("11111", RD3_OUT, JandL, MUX_WRaddr_OUT);
	mux_WRdata: MUX21_GENERIC generic map (N=>NUMBIT)
							port map (RPCplus8_OUT, MUXC_OUT, JandL, MUX_WRdata_OUT);

	Data_out <= Out_s;


	---------------------FORWARDING---------------------------------------------
		FORWARDING_UNIT_0: ForwardingUnit generic map (NUMBIT => NUMBIT, ADDRESS_WIDTH_RF => ADDRESS_WIDTH_RF)
											 port map (
											 CLK => CLK,
											 RST => RST,
											 RS1 => RS1,
											 RS2 => RS2,
											 RD_XM => RD2_OUT,
									     RD_MW => RD3_OUT,
									     REGWRITE_XM => REGWRITE_XM,
									     REGWRITE_MW => REGWRITE_MW,
									     ForwardA => ForwardA,
									     ForwardB => ForwardB,
											 ForwardC => ForwardC,
											 ForwardD => ForwardD);

end Struct;
