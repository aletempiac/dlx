library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.myTypes.all;

entity DLX is
  generic (
    IR_SIZE      : integer := 32;       -- Instruction Register Size
    PC_SIZE      : integer := 32;        -- Program Counter Size
    ADDRESS_WIDTH_DM : integer := 5     -- Address Width DRAM
    );       -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    Clk : in std_logic;
    Rst : in std_logic;                -- Active Low
    DataOut : out std_logic_vector(31 downto 0));
end DLX;

architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------

  --Instruction Ram
  component IRAM
--     generic (
--       RAM_DEPTH : integer;
--       I_SIZE    : integer);
    port (
      Rst  : in  std_logic;
      Addr : in  std_logic_vector(PC_SIZE - 1 downto 0);
      Dout : out std_logic_vector(IR_SIZE - 1 downto 0));
  end component;

  component data_memory
   generic( NUMBIT : integer := 32;
  			    BITADDR : integer := 32;
            SIZE : integer := 5);
   port (	CLK: 		IN std_logic;
         	RESET: 	IN std_logic;
  	 		  ENABLE: 	IN std_logic;
  	 		  RD: 		IN std_logic;
  			  WR: 		IN std_logic;
  	 		  ADDR: 	IN std_logic_vector(BITADDR-1 downto 0);
  	 		  DATAIN: 	IN std_logic_vector(NUMBIT-1 downto 0);
  	 		  DATAOUT: 		OUT std_logic_vector(NUMBIT-1 downto 0));
  end component;

  component datapath
  	generic (NUMBIT: integer:= 32;
  				ADDRESS_WIDTH_RF : integer := 5;
          ADDRESS_WIDTH_DM : integer := 5);
  	port(	CLK 					: in std_logic;
  				RST 					: in std_logic;
  				--Inputs
  				INP1 					: in std_logic_vector(NUMBIT-1 downto 0);		--immediate 1
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
  				SIGN_UNSIGN			 : in std_logic;	-- Signed/unsigned operations (1/0)
  				RFR1_EN						 : in std_logic;		-- Read Enable Port1 RF
  				RFR2_EN						 : in std_logic;		-- Read Enable Port2 RF
          MUX_IMM_SEL				: in std_logic;
          JUMP               : in std_logic;
  				JUMP_EN           : in std_logic;  -- JUMP Enable Signal for PC input MUX
  				EQ_COND 	         : in std_logic;  -- Branch if (not) Equal to Zero
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
  				RALUOUT2_LATCH_EN   : in std_logic;  -- ALU Output Register Enable
  				RegRD3_LATCH_EN 	: in std_logic;  -- RD3 Register Latch Enable
          RPCplus8_LATCH_EN : in std_logic;  -- PCplus8 Register Latch Enable
  				--PC_LATCH_EN       : in std_logic;  -- Program Counte Latch Enable
  				-- WB Control signals
  				WB_MUX_SEL        : in std_logic;  -- Write Back MUX Sel
  				RF_WE             : in std_logic;  -- Register File Write Enable
  				ROUT_LATCH_EN			: in STD_LOGIC;  -- Out register Latch Enable
				  JandL								: in std_logic;	 -- Jump&Link signal to control MUXs in input to RegFile
  				--Outputs
          BRANCH_CTRL_SIG		: out std_logic;
  				BRANCH_ALU_OUT		: out std_logic_vector(NUMBIT-1 downto 0);
  				Data_out			   	: out std_logic_vector(NUMBIT-1 downto 0);
          --Forwarding Unit
  				REGWRITE_XM        : in std_logic; -- Indicate a write back in register file, to use by Forwarding unit
  		    REGWRITE_MW        : in std_logic -- Indicate a write back in register file, to use by Forwarding unit
  				);
  end component;

  for DP_I : datapath use configuration work.CFG_DataPath_Struct;

  -- Control Unit
  component dlx_cu
    generic (
      FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
      OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
      -- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
      IR_SIZE            :     integer := 32;  -- Instruction Register Size
      CW_SIZE            :     integer := 29);  -- Control Word Size
    port (
      Clk                : in  std_logic;  -- Clock
      Rst                : in  std_logic;  -- Reset:Active-Low
      Flush_BTB          : in  std_logic;  --Flushes the decode when BTB predicts wrong
      STALL              : IN std_logic;
      -- Instruction Register
      IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);

      -- IF Control Signal
      IR_LATCH_EN        : out std_logic;  -- Instruction Register Latch Enable
      NPC_LATCH_EN       : out std_logic;  -- NextProgramCounter Register Latch Enable
      I_R_type           : out std_logic;  -- wheter instruction is I or R type (1/0)

      -- ID Control Signals
      REGF_LATCH_EN      : out std_logic;  -- Register File Enable
      RegA_LATCH_EN      : out std_logic;  -- Register A Latch Enable
      RegB_LATCH_EN      : out std_logic;  -- Register B Latch Enable
      RegIMM_LATCH_EN    : out std_logic;  -- Immediate Register Latch Enable
      RegRD1_LATCH_EN    : out std_logic;  -- Register RD1 Latch Enable
      SIGN_UNSIGN        : out std_logic;  -- Signed or Unsigned operation (1/0)
      RFR1_EN            : out std_logic;  -- Register File Read1 enable
      RFR2_EN            : out std_logic;  -- Register File read2 enable
      MUX_IMM_SEL        : out std_logic;  -- Immediate selection mux signal
      JUMP               : out std_logic;   -- 1 for jump, does not consider condition
      JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
      EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero
      MUXA_SEL           : out std_logic;  -- MUX-A sel
      -- EX Control Signals
      MUXB_SEL           : out std_logic;  -- MUX-B Sel
      ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
      REGME_LATCH_EN     : out std_logic;  -- Register ME latch enable
      RegRD2_LATCH_EN    : out std_logic;  -- Register RD2 latch enable
      -- ALU Operation Code
      ALU_OPCODE         : out aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

      -- MEM Control Signals
      DRAM_EN            : out std_logic;  -- DRAM enable
      DRAM_RE            : out std_logic;  -- DRAM write enable
      DRAM_WE            : out std_logic;  -- Data RAM Write Enable
      LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
      RALUOUT2_LATCH_EN  : out std_logic;  -- Register ALUOUT2 latch enable
      RegRD3_LATCH_EN    : out std_logic;  -- Register RD3 latch enable
      PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable
      RPCplus8_LATCH_EN  : out std_logic;  -- PCplus8 Register Latch Enable

      -- WB Control signals
      WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
      RF_WE              : out std_logic;  -- Register File Write Enable
      ROUT_LATCH_EN      : out std_logic; -- Register OUT latch enable
      JandL								 : out std_logic; -- Jump&Link signal to control MUXs in input to RegFile
      --Forwarding Unit
      REGWRITE_DX        : out std_logic; -- Indicate a write back in register file, to use by Forwarding unit
      REGWRITE_XM        : out std_logic; -- Indicate a write back in register file, to use by Forwarding unit
      REGWRITE_MW        : out std_logic; -- Indicate a write back in register file, to use by Forwarding unit
      MEMREAD_DX         : out std_logic -- Indicate a Read from memory, to use by hazard Unit
      );
  end component;

  component BTB
    generic ( PC_SIZE : integer := 32;
              BTBSIZE : integer := 5);    --SIZE=2**BTBSIZE
    port (Reset : in std_logic; --active low
          Clk : in std_logic;
          Enable : in std_logic;
          --RD : in std_logic;
          PC_read : in std_logic_vector(PC_SIZE-1 downto 0);    --PC to be searched in LUT
          WR : in std_logic;
          PC_write : in std_logic_vector(PC_SIZE-1 downto 0);   --PC to be added to BTB
          SetT_NT : in std_logic;                               --Set PC to Taken or not Taken optional
          Set_target : in std_logic_vector(PC_SIZE-1 downto 0); --Next PC target in case of Taken
          OUT_PC_target : out std_logic_vector(PC_SIZE-1 downto 0);
          OUTT_NT : out std_logic;
          prevT_NT: out std_logic);
  end component;

  component HazardUnit
    generic (NUMBIT : integer := 32;
             ADDRESS_WIDTH_RF : integer := 5;
             OP_CODE_SIZE     : integer := 6);  -- Op Code Size
    port (
      CLK : in std_logic;
      RST : in std_logic; --active Low
      RS1 : in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
      RS2 : in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
      REGWRITE_DX : in std_logic;
      MEMREAD_DX : in std_logic;
      RD : in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
      OPCODE : in std_logic_vector(OP_CODE_SIZE-1 downto 0);
      STALL : out std_logic
    );
  end component;

  component NPC_logic
    generic (PC_SIZE : integer := 32);
    port (Flush_BTB : in std_logic;
          BRANCH_CTRL_SIG : in std_logic;
          OUTT_NT_i : in std_logic;
          PC_next : in std_logic_vector(PC_SIZE-1 downto 0);
          BRANCH_ALU_OUT : in std_logic_vector(PC_SIZE-1 downto 0);
          OUT_PC_target_i : in std_logic_vector(PC_SIZE-1 downto 0);
          NPC : in std_logic_vector(PC_SIZE-1 downto 0);
          PC_BUS : out std_logic_vector(PC_SIZE-1 downto 0));
  end component;

  component MUX21_GENERIC
  	Generic (N: integer:= 4);
  	Port (	A:	In	std_logic_vector(N-1 downto 0) ;
  		B:	In	std_logic_vector(N-1 downto 0);
  		SEL:	In	std_logic;
  		Y:	Out	std_logic_vector(N-1 downto 0));
  end component;



  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------

  -- Instruction Register (IR) and Program Counter (PC) declaration
  signal IR  : std_logic_vector(IR_SIZE - 1 downto 0);
  signal PC  : std_logic_vector(PC_SIZE - 1 downto 0);
  signal NPC,PC_next : std_logic_vector(PC_SIZE - 1 downto 0);

  -- Instruction Ram Bus signals
  signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);

  -- Datapath Bus signals
  signal PC_BUS : std_logic_vector(PC_SIZE -1 downto 0);
  signal INP2 : std_logic_vector(IR_SIZE/2-1 downto 0);
  signal IMM26 : std_logic_vector(25 downto 0);
  signal RS1, RS2, RD : std_logic_vector (4 downto 0);
  signal BRANCH_CTRL_SIG : std_logic;
  signal BRANCH_ALU_OUT : std_logic_vector(IR_SIZE-1 downto 0);

  -- Control Unit Bus signals
  signal IR_LATCH_EN_i : std_logic;
  signal NPC_LATCH_EN_i : std_logic;
  signal RegRF_LATCH_EN_i : std_logic;
  signal RegA_LATCH_EN_i : std_logic;
  signal RegB_LATCH_EN_i : std_logic;
  signal RegIMM_LATCH_EN_i : std_logic;
  signal RegRD1_LATCH_EN_i : std_logic;
  signal SIGN_UNSIGN_i : std_logic;
  signal RFR1_EN_i : std_logic;
  signal RFR2_EN_i : std_logic;
  signal MUX_IMM_SEL_i :std_logic;
  signal EQ_COND_i : std_logic;
  signal JUMP_i : std_logic;
  signal JUMP_EN_i : std_logic;
  signal MUXA_SEL_i : std_logic;
  signal ALU_OPCODE_i : aluOp;
  signal DRAM_EN_i : std_logic;
  signal DRAM_RE_i : std_logic;
  signal MUXB_SEL_i : std_logic;
  signal ALU_OUTREG_EN_i : std_logic;
  signal REGME_LATCH_EN_i : std_logic;
  signal RegRD2_LATCH_EN_i : std_logic;
  signal DRAM_WE_i : std_logic;
  signal LMD_LATCH_EN_i : std_logic;
  signal RALUOUT2_LATCH_EN_i : std_logic;
  signal RegRD3_LATCH_EN_i : std_logic;
  signal PC_LATCH_EN_i : std_logic;
  signal WB_MUX_SEL_i : std_logic;
  signal RF_WE_i : std_logic;
  signal ROUT_LATCH_EN_i : std_logic;
  signal I_R_TYPE_i : std_logic;
  signal RPCplus8_LATCH_EN_i : std_logic;
  signal JandL_i : std_logic;
  signal REGWRITE_DX_i : std_logic;
  signal REGWRITE_XM_i : std_logic;
  signal REGWRITE_MW_i : std_logic;
  signal Flush_BTB_i : std_logic;
  signal STALL_i : std_logic;
  signal MEMREAD_DX_i : std_logic;
  --BTB signals
  signal OUTT_NT_i : std_logic;
  signal OUT_PC_target_i : std_logic_vector(PC_SIZE-1 downto 0);
  signal prevT_NT_i : std_logic;
  signal Flush_BTB : std_logic;

  -- Data Ram Bus signals
  signal ADDR_DRAM_i : std_logic_vector(ADDRESS_WIDTH_DM - 1 downto 0);
  signal DATAIN_DRAM_i : std_logic_vector(IR_SIZE - 1 downto 0);
  signal DATAOUT_DRAM_i : std_logic_vector(IR_SIZE - 1 downto 0);

  begin  -- DLX

    INP2 <= IR(IR_SIZE/2-1 downto 0);
    IMM26 <= IR(25 downto 0);
    RS1 <= IR(25 downto 21);
    RS2 <= IR(20 downto 16);
    RD <= IR(20 downto 16) when I_R_type_i = '1' else IR(15 downto 11);


    Flush_BTB <= (prevT_NT_i and (not Flush_BTB_i)) xor BRANCH_CTRL_SIG; --when 1 a misspredicted branch happened

    Flush_BTB_p: process(Clk, Rst, Flush_BTB)
    begin
      if Rst = '0' then                   -- asynchronous reset (active low)
        Flush_BTB_i <= '0';
      elsif Clk'event and Clk = '1' then  -- rising clock edge
        Flush_BTB_i <= Flush_BTB;
      end if;
    end process;

    -- purpose: Instruction Register Process
    -- type   : sequential
    -- inputs : Clk, Rst, IRam_DOut, IR_LATCH_EN_i
    -- outputs: IR_IN_i
    IR_P: process (Clk, Rst)
    begin  -- process IR_P
      if Rst = '0' then                 -- asynchronous reset (active low)
        IR <= (others => '0');
      elsif Clk'event and Clk = '1' then  -- rising clock edge
        if (IR_LATCH_EN_i = '1') then
          IR <= IRam_DOut;
        end if;
      end if;
    end process IR_P;


    -- purpose: Program Counter Process
    -- type   : sequential
    -- inputs : Clk, Rst, PC_BUS
    -- outputs: IRam_Addr
    PC_P: process (Clk, Rst)
    begin  -- process PC_P
      if (Rst = '0') then                 -- asynchronous reset (active low)
        PC <= (others => '0');
      elsif (Clk'event and Clk = '1') then  -- rising clock edge
        if (PC_LATCH_EN_i = '1') then
          PC <= PC_BUS;
        end if;
      end if;
    end process PC_P;

    -- purpose: Next Program Counter Process
    -- type   : sequential
    -- inputs : Clk, Rst, PC
    -- outputs: INP1
    NPC_P: process (Clk, Rst)
    begin
      if (Rst = '0') then                 -- asynchronous reset (active low)
        NPC <= (others => '0');
      elsif (Clk'event and Clk = '1') then  -- rising clock edge
        if (NPC_LATCH_EN_i = '1') then
          NPC <= PC_next;
        end if;
      end if;
    end process NPC_P;

    PC_next <= PC + 1;

    --Unit that decides the next PC based on BTB prediction
    NPC_logic_0: NPC_logic generic map (PC_SIZE => PC_SIZE)
                port map (Flush_BTB => Flush_BTB,
                          BRANCH_CTRL_SIG => BRANCH_CTRL_SIG,
                          OUTT_NT_i => OUTT_NT_i,
                          PC_next => PC_next,
                          BRANCH_ALU_OUT => BRANCH_ALU_OUT,
                          OUT_PC_target_i => OUT_PC_target_i,
                          NPC => NPC,
                          PC_BUS => PC_BUS);


    -- Control Unit Instantiation
    CU_I: dlx_cu
          port map (
              Clk             => Clk,
              Rst             => Rst,
              Flush_BTB       => Flush_BTB_i,
              STALL           => STALL_i,
              --Fetch
              IR_IN           => IR,
              IR_LATCH_EN     => IR_LATCH_EN_i,
              NPC_LATCH_EN    => NPC_LATCH_EN_i,
              --Decode
              I_R_TYPE        => I_R_TYPE_i,
              REGF_LATCH_EN   => RegRF_LATCH_EN_i,
              RegA_LATCH_EN   => RegA_LATCH_EN_i,
              RegB_LATCH_EN   => RegB_LATCH_EN_i,
              RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
              RegRD1_LATCH_EN => RegRD1_LATCH_EN_i,
              SIGN_UNSIGN     => SIGN_UNSIGN_i,
              RFR1_EN         => RFR1_EN_i,
              RFR2_EN         => RFR2_EN_i,
              MUX_IMM_SEL     => MUX_IMM_SEL_i,
              JUMP            => JUMP_i,
              JUMP_EN         => JUMP_EN_i,
              EQ_COND         => EQ_COND_i,
              MUXA_SEL      => MUXA_SEL_i,
              --Execute
              MUXB_SEL        => MUXB_SEL_i,
              ALU_OUTREG_EN   => ALU_OUTREG_EN_i,
              REGME_LATCH_EN  => REGME_LATCH_EN_i,
              RegRD2_LATCH_EN => RegRD2_LATCH_EN_i,
              ALU_OPCODE      => ALU_OPCODE_i,
              --Memory
              DRAM_EN         => DRAM_EN_i,
              DRAM_RE         => DRAM_RE_i,
              DRAM_WE         => DRAM_WE_i,
              LMD_LATCH_EN    => LMD_LATCH_EN_i,
              RALUOUT2_LATCH_EN => RALUOUT2_LATCH_EN_i,
              RegRD3_LATCH_EN => RegRD3_LATCH_EN_i,
              PC_LATCH_EN     => PC_LATCH_EN_i,
              RPCplus8_LATCH_EN => RPCplus8_LATCH_EN_i,
              --Write-Back
              WB_MUX_SEL      => WB_MUX_SEL_i,
              RF_WE           => RF_WE_i,
              ROUT_LATCH_EN   => ROUT_LATCH_EN_i,
              JandL           => JandL_i,
              --Forwarding
              REGWRITE_DX     => REGWRITE_DX_i,
              REGWRITE_XM     => REGWRITE_XM_i,
              REGWRITE_MW     => REGWRITE_MW_i,
              --Hazard Unit
              MEMREAD_DX      => MEMREAD_DX_i
              );

    -- Datapath Instantiation
    DP_I: datapath generic map (NUMBIT => IR_SIZE, ADDRESS_WIDTH_RF => 5, ADDRESS_WIDTH_DM => 5)
          port map( CLK                => Clk,
             				RST                => Rst,
                    --IF
                    INP1 	             => NPC,
             				INP2               => INP2,
                    IMM26              => IMM26,
             				RS1                => RS1,
             				RS2                => RS2,
             				RD                 => RD,
             				--Inputs Control
             				-- ID
             				REGF_LATCH_EN      => RegRF_LATCH_EN_i,
             		    RegA_LATCH_EN      => RegA_LATCH_EN_i,
             		    RegB_LATCH_EN      => RegB_LATCH_EN_i,
             		    RegIMM_LATCH_EN    => RegIMM_LATCH_EN_i,
             		    RegRD1_LATCH_EN    => RegRD1_LATCH_EN_i,
             				SIGN_UNSIGN        => SIGN_UNSIGN_i,
             				RFR1_EN            => RFR1_EN_i,
             				RFR2_EN            => RFR2_EN_i,
                    MUX_IMM_SEL        => MUX_IMM_SEL_i,
                    JUMP               => JUMP_i,
             				JUMP_EN            => JUMP_EN_i,
             				EQ_COND            => EQ_COND_i,
                    MUXA_SEL           => MUXA_SEL_i,
             				-- EX
             				MUXB_SEL           => MUXB_SEL_i,
             				RALUOUT_LATCH_EN   => ALU_OUTREG_EN_i,
             				REGME_LATCH_EN     => REGME_LATCH_EN_i,
             				RegRD2_LATCH_EN    => RegRD2_LATCH_EN_i,
             				--ALU
             				ALU_OPCODE         => ALU_OPCODE_i,  --: in aluOp choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
             				-- MEM
                    ADDR_DRAM					 => ADDR_DRAM_i,
            				DATAIN_DRAM				 => DATAIN_DRAM_i,
            				DATAOUT_DRAM			 => DATAOUT_DRAM_i,
             				LMD_LATCH_EN       => LMD_LATCH_EN_i,
             				RALUOUT2_LATCH_EN  => RALUOUT2_LATCH_EN_i,
             				RegRD3_LATCH_EN    => RegRD3_LATCH_EN_i,
                    RPCplus8_LATCH_EN  => RPCplus8_LATCH_EN_i,
             				-- WB Control signals
             				WB_MUX_SEL         => WB_MUX_SEL_i,
             				RF_WE              => RF_WE_i,
             				ROUT_LATCH_EN      => ROUT_LATCH_EN_i,
                    JandL                => JandL_i,
             				--Outputs
                    BRANCH_CTRL_SIG    => BRANCH_CTRL_SIG,
            				BRANCH_ALU_OUT     => BRANCH_ALU_OUT,
             				Data_out           => DataOut,
                    --Forwarding
                    REGWRITE_XM     => REGWRITE_XM_i,
                    REGWRITE_MW     => REGWRITE_MW_i
             				);


    BTB_0 : BTB generic map (PC_SIZE => PC_SIZE, BTBSIZE=>5)
            port map(Reset => Rst,
                  Clk => Clk,
                  Enable => '1',
                  --RD =>
                  PC_read => PC_next,   --PC to be searched in LUT
                  WR => JUMP_EN_i,
                  PC_write => NPC, --PC to be added to BTB
                  SetT_NT => BRANCH_CTRL_SIG, --Set PC to Taken or not Taken optional
                  Set_target => BRANCH_ALU_OUT,--Next PC target in case of Taken
                  OUT_PC_target => OUT_PC_target_i,
                  OUTT_NT  => OUTT_NT_i,
                  prevT_NT => prevT_NT_i);


    HU_0 : HazardUnit  generic map(NUMBIT => IR_SIZE, ADDRESS_WIDTH_RF => 5)
           port map(CLK => Clk,
                RST => Rst,
                RS1 => RS1,
                RS2 => RS2,
                REGWRITE_DX => REGWRITE_DX_i,
                MEMREAD_DX => MEMREAD_DX_i,
                RD => RS2,
                OPCODE => IR(IR_SIZE-1 downto IR_SIZE-6),
                STALL => STALL_i);


    -- Instruction Ram Instantiation
    IRAM_I: IRAM
      port map (
          Rst  => Rst,
          Addr => PC,
          Dout => IRam_DOut);


    -- Data Ram Instantiation
    data_memory_0: data_memory generic map (NUMBIT=>IR_SIZE, BITADDR=>ADDRESS_WIDTH_DM, SIZE=>5)
  								 port map (CLK=>CLK,
  	 												RESET=>RST,
  	 												ENABLE=>DRAM_EN_i,
  	 												RD=>DRAM_RE_i,
  	 												WR=>DRAM_WE_i,
  	 												ADDR=>ADDR_DRAM_i,
  	 												DATAIN=>DATAIN_DRAM_i,
  	 												DATAOUT=>DATAOUT_DRAM_i);


end dlx_rtl;
