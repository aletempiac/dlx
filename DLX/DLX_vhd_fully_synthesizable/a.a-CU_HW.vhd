library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity dlx_cu is
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
    STALL              : in  std_logic;
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
    JandL							 : out std_logic;	 -- Jump&Link signal to control MUXs in input to RegFile

    -- FOR FORWARDING Unit
    REGWRITE_DX        : out std_logic; -- Indicate a write back in register file, to use by Forwarding unit
    REGWRITE_XM        : out std_logic; -- Indicate a write back in register file, to use by Forwarding unit
    REGWRITE_MW        : out std_logic; -- Indicate a write back in register file, to use by Forwarding unit
    MEMREAD_DX         : out std_logic); -- Indicate a Read from memory, to use by hazard Unit

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is

  constant RTYPE_SLL 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";
  constant RTYPE_SRL 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";
  constant RTYPE_SRA 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";
  constant RTYPE_ADD			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100000";
  constant RTYPE_ADDU 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100001";
  constant RTYPE_SUB 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100010";
  constant RTYPE_SUBU 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100011";
  constant RTYPE_AND 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100100";
  constant RTYPE_OR  			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100101";
  constant RTYPE_XOR 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100110";
  constant RTYPE_SEQ 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101000";
  constant RTYPE_SNE 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101001";
  constant RTYPE_SLT 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101010";
  constant RTYPE_SGT 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101011";
  constant RTYPE_SLE 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101100";
  constant RTYPE_SGE 			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101101";
  constant RTYPE_MOVI2S 	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110000";
  constant RTYPE_MOVS2I 	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110001";
  constant RTYPE_MOVF 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110010";
  constant RTYPE_MOVD 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110011";
  constant RTYPE_MOVFP2I  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110100";
  constant RTYPE_MOVI2FP 	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110101";
  constant RTYPE_MOVI2T 	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110110";
  constant RTYPE_MOVT2I 	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110111";
  constant RTYPE_SLTU			: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111010";
  constant RTYPE_SGTU 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111011";
  constant RTYPE_SLEU 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111100";
  constant RTYPE_SGEU 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111101";


-- R-Type instruction -> OPCODE field
  constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation
  constant RFPTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";

-- I-Type instruction -> OPCODE field
  constant JTYPE_J   	 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";    -- J TARGET
  constant JTYPE_JAL   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";    -- JAL TARGET

  constant ITYPE_BEQZ  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";    -- BEQZ RS, TARGET
  constant ITYPE_BNEZ  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";    -- BNEZ RS, TARGET
  constant ITYPE_BFPT  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";
  constant ITYPE_BFPF  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";
  constant ITYPE_ADDI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";    -- ADDI RS,RD,INP
  constant ITYPE_ADDUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";    -- ADDUI RS,RD,INP
  constant ITYPE_SUBI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";    -- SUBI RS,RD,INP
  constant ITYPE_SUBUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";    -- SUBUI RS,RD,INP
  constant ITYPE_ANDI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";    -- ANDI RS,RD,INP
  constant ITYPE_ORI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";    -- ORI RS,RD,INP
  constant ITYPE_XORI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";    -- XORI RS,RD,INP
  constant ITYPE_LHI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001111";		-- LHI RD,INP
  constant ITYPE_RFE   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010000";    -- RFE RD,INP
  constant ITYPE_TRAP  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010001";    -- TRAP INP
  constant ITYPE_JR    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010010";    -- JR RS
  constant ITYPE_JALR  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010011";    -- LHI RD,INP
  constant ITYPE_SLLI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010100";    -- SLLI RD, RS, INP
  constant ITYPE_NOP   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010101";    -- NOP
  constant ITYPE_SRLI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010110";    -- SRLI RD,RS,INP
  constant ITYPE_SRAI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010111";    -- SRAI RD,INP
  constant ITYPE_SEQI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011000";    -- LHI RD,INP
  constant ITYPE_SNEI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011001";    -- LHI RD,INP
  constant ITYPE_SLTI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011010";    -- LHI RD,INP
  constant ITYPE_SGTI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011011";    -- LHI RD,INP
  constant ITYPE_SLEI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011100";    -- LHI RD,INP
  constant ITYPE_SGEI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011101";    -- LHI RD,INP

  constant ITYPE_LB    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100000";    -- LHI RD,INP
  constant ITYPE_LH    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001";    -- LHI RD,INP
  constant ITYPE_LW    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100011";    -- LHI RD,INP
  constant ITYPE_LBU   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100100";    -- LHI RD,INP
  constant ITYPE_LHU   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100101";    -- LHI RD,INP
  constant ITYPE_LF    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100110";    -- LHI RD,INP
  constant ITYPE_LD    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100111";    -- LHI RD,INP
  constant ITYPE_SB    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101000";    -- LHI RD,INP
  constant ITYPE_SH    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101001";    -- LHI RD,INP
  constant ITYPE_SW    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101011";    -- LHI RD,INP
  constant ITYPE_SF    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101110";    -- LHI RD,INP
  constant ITYPE_SD    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101111";    -- LHI RD,INP
  constant ITYPE_ITLB  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111000";    -- LHI RD,INP
  constant ITYPE_SLTUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111010";    -- LHI RD,INP
  constant ITYPE_SGTUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111011";    -- LHI RD,INP
  constant ITYPE_SLEUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111100";    -- LHI RD,INP
  constant ITYPE_SGEUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111101";    -- LHI RD,INP

  signal IR_opcode : std_logic_vector(6 -1 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(11 -1 downto 0);   -- Func part of IR when Rtype
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem

  signal IR_LATCH_EN_i : std_logic;
  signal NPC_LATCH_EN_i : std_logic;
  signal REGF_LATCH_EN_i : std_logic;

  -- control word is shifted to the correct stage
  signal cw3 : std_logic_vector(CW_SIZE - 1 - 13 downto 0); -- third stage
  signal cw4 : std_logic_vector(CW_SIZE - 1 - 17 downto 0); -- fourth stage
  signal cw5 : std_logic_vector(CW_SIZE - 1 - 25 downto 0); -- fifth stage

  signal aluOpcode_i: aluOp := NOP; -- ALUOP defined in package
  signal aluOpcode3: aluOp := NOP;



begin  -- dlx_cu_rtl

  IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
  IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

  -- stage one control signals
  IR_LATCH_EN     <= IR_LATCH_EN_i;
  NPC_LATCH_EN    <= NPC_LATCH_EN_i;
  PC_LATCH_EN     <= cw(CW_SIZE - 25);

  -- stage two control signals
  I_R_TYPE        <= cw(CW_SIZE - 1);
  REGF_LATCH_EN   <= REGF_LATCH_EN_i;
  RegA_LATCH_EN   <= cw(CW_SIZE - 4);
  RegB_LATCH_EN   <= cw(CW_SIZE - 5);
  RegIMM_LATCH_EN <= cw(CW_SIZE - 6);
  RegRD1_LATCH_EN <= cw(CW_SIZE - 7);
  SIGN_UNSIGN     <= cw(CW_SIZE - 8);
  RFR1_EN         <= cw(CW_SIZE - 2);
  RFR2_EN         <= cw(CW_SIZE - 3);
  MUX_IMM_SEL     <= cw(CW_SIZE - 9);
  JUMP            <= cw(CW_SIZE - 10);
  JUMP_EN         <= cw(CW_SIZE - 11);
  EQ_COND         <= cw(CW_SIZE - 12);
  MUXA_SEL        <= cw(CW_SIZE - 13);

  -- stage three control signals
  MUXB_SEL        <= cw3(CW_SIZE - 14);
  ALU_OUTREG_EN   <= cw3(CW_SIZE - 16);
  REGME_LATCH_EN  <= cw3(CW_SIZE - 15);
  RegRD2_LATCH_EN <= cw3(CW_SIZE - 17);

  -- stage four control signals
  RPCplus8_LATCH_EN <= cw4(CW_SIZE - 18);
  DRAM_EN         <= cw4(CW_SIZE - 19);
  DRAM_RE         <= cw4(CW_SIZE - 20);
  DRAM_WE         <= cw4(CW_SIZE - 21);
  LMD_LATCH_EN    <= cw4(CW_SIZE - 22);
  RALUOUT2_LATCH_EN <= cw4(CW_SIZE - 23);
  RegRD3_LATCH_EN <= cw4(CW_SIZE - 24);
  --PC_LATCH_EN     <= cw4(CW_SIZE - 25);

  -- stage five control signals
  WB_MUX_SEL      <= cw5(CW_SIZE - 26);
  RF_WE           <= cw5(CW_SIZE - 27);
  ROUT_LATCH_EN   <= cw5(CW_SIZE - 28);
  JandL           <= cw5(CW_SIZE - 29);

  --to Forwarding Unit
  REGWRITE_XM <= cw4(CW_SIZE - 27);
  REGWRITE_MW <= cw5(CW_SIZE - 27);

  --to hazard unit
  REGWRITE_DX <= cw3(CW_SIZE - 27);
  MEMREAD_DX <= cw3(CW_SIZE - 20);

  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '0' then                   -- asynchronous reset (active low)
      cw3 <= "0000"&"00000001"&"0000";--(others => '0');
      cw4 <= "00000001"&"0000";--(others => '0');
      cw5 <= "0000";--(others => '0');

      aluOpcode3 <= NOP;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      cw3 <= cw(CW_SIZE - 1 - 13 downto 0);
      cw4 <= cw3(CW_SIZE - 1 - 17 downto 0);
      cw5 <= cw4(CW_SIZE - 1 - 25 downto 0);

      aluOpcode3 <= aluOpcode_i;
    end if;
  end process CW_PIPE;

  ALU_OPCODE <= aluOpcode3;

  -- Process to generate Control Word from OPCODE
  CW_Gen: process(IR_opcode, RST, IR_func, Flush_BTB, STALL)
  begin
    if (RST = '1') then
      IR_LATCH_EN_i <= '1';
      NPC_LATCH_EN_i <= '1';
      REGF_LATCH_EN_i <= '1';
      if (STALL = '1') then
        CW <= "0000000000000" & "0000" & "00000000" & "0000";
        IR_LATCH_EN_i <= '0';
        NPC_LATCH_EN_i <= '0';
      elsif (Flush_BTB = '0') then --if not misspredicted branch -> normal exe
        case IR_opcode is
          when RTYPE =>   CW <= "0111111110000" & "1011" & "00000111" & "0100";-- R TYPE
            case IR_func is
              when RTYPE_ADDU => CW(21) <= '0'; --SET FOR UNSIGNED OPERATION
              when RTYPE_SUBU => CW(21) <= '0';
              when RTYPE_SLTU => CW(21) <= '0';
              when RTYPE_SGTU => CW(21) <= '0';
              when RTYPE_SLEU => CW(21) <= '0';
              when RTYPE_SGEU => CW(21) <= '0';
              when others => CW(21) <= '1';
            end case;
          when RFPTYPE =>       CW <= (others => '0'); --to be implemented
          when JTYPE_J =>       CW <= "1000010101101" & "0000" & "00000001" & "0000";
          when JTYPE_JAL =>     CW <= "1000010101101" & "0000" & "10000001" & "0101";
          when ITYPE_BEQZ =>    CW <= "1101010110111" & "0000" & "00000001" & "0000";
          when ITYPE_BNEZ =>    CW <= "1101010110101" & "0000" & "00000001" & "0000";
          when ITYPE_BFPT =>    CW <= (others => '0'); --to be implemented
          when ITYPE_BFPF =>    CW <= (others => '0'); --to be implemented
          when ITYPE_ADDI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_ADDUI =>   CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_SUBI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_SUBUI =>   CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_ANDI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_ORI =>     CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_XORI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_LHI =>     CW <= (others => '0'); --to be implemented
          when ITYPE_RFE =>     CW <= (others => '0'); --to be implemented
          when ITYPE_TRAP =>    CW <= (others => '0'); --to be implemented
          when ITYPE_JR =>      CW <= "1101010011100" & "0010" & "00000001" & "0000";
          when ITYPE_JALR =>    CW <= "1101010011100" & "0010" & "10000001" & "0101";
          when ITYPE_SLLI =>    CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_NOP =>     CW <= "1000010000000" & "0000" & "00000001" & "0000"; -- NOP
          when ITYPE_SRLI =>    CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_SRAI =>    CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_SEQI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_SNEI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_SLTI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_SGTI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_SLEI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_SGEI =>    CW <= "1101011110000" & "0011" & "00000111" & "0100";
          when ITYPE_LB =>      CW <= (others => '0'); --to be implemented
          when ITYPE_LH =>      CW <= (others => '0'); --to be implemented
          when ITYPE_LW =>      CW <= "1101011110000" & "0111" & "01101011" & "1100";
          when ITYPE_LBU =>     CW <= (others => '0'); --to be implemented
          when ITYPE_LHU =>     CW <= (others => '0'); --to be implemented
          when ITYPE_LF =>      CW <= (others => '0'); --to be implemented
          when ITYPE_LD =>      CW <= (others => '0'); --to be implemented
          when ITYPE_SB =>      CW <= (others => '0'); --to be implemented
          when ITYPE_SH =>      CW <= (others => '0'); --to be implemented
          when ITYPE_SW =>      CW <= "1111110110000" & "0110" & "01010001" & "0000";
          when ITYPE_SF =>      CW <= (others => '0'); --to be implemented
          when ITYPE_SD =>      CW <= (others => '0'); --to be implemented
          when ITYPE_ITLB =>    CW <= (others => '0'); --to be implemented
          when ITYPE_SLTUI =>   CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_SGTUI =>   CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_SLEUI =>   CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when ITYPE_SGEUI =>   CW <= "1101011010000" & "0011" & "00000111" & "0100";
          when others =>        CW <= (others => '0');
        end case;
      else
        CW <= "0000000000000" & "0000" & "00000001" & "0000"; --if misspredicted branch -> flush cw
      end if;
    else
      IR_LATCH_EN_i <= '0';
      NPC_LATCH_EN_i <= '0';
      REGF_LATCH_EN_i <= '0';
      CW <= "0000000000000" & "0000" & "00000001" & "0000";
    end if;
  end process;


  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
   ALU_OP_CODE_P : process (IR_opcode, IR_func)
   begin  -- process ALU_OP_CODE_P
	  case IR_opcode is
  	        -- case of R type requires analysis of FUNC
  		when RTYPE =>
        case IR_func is
          when RTYPE_SLL => aluOpcode_i <= SLLS;
          when RTYPE_SRL => aluOpcode_i <= SRLS;
          when RTYPE_SRA => aluOpcode_i <= SRAS ;
          when RTYPE_ADD => aluOpcode_i <= ADDS;
          when RTYPE_ADDU => aluOpcode_i <= ADDS;
          when RTYPE_SUB => aluOpcode_i <= SUBS;
          when RTYPE_SUBU => aluOpcode_i <= SUBS;
          when RTYPE_AND => aluOpcode_i <= ANDS;
          when RTYPE_OR => aluOpcode_i <= ORS;
          when RTYPE_XOR => aluOpcode_i <= XORS;
          when RTYPE_SEQ => aluOpcode_i <= SEQS;
          when RTYPE_SNE => aluOpcode_i <= SNES;
          when RTYPE_SLT => aluOpcode_i <= SLTS;
          when RTYPE_SGT => aluOpcode_i <= SGTS;
          when RTYPE_SLE => aluOpcode_i <= SLES;
          when RTYPE_SGE => aluOpcode_i <= SGES;
          when RTYPE_SLTU => aluOpcode_i <= SLTUS;
          when RTYPE_SGTU => aluOpcode_i <= SGTUS;
          when RTYPE_SLEU => aluOpcode_i <= SLEUS;
          when RTYPE_SGEU => aluOpcode_i <= SGEUS;
          when others => aluOpcode_i <= NOP;
        end case;
  		when RFPTYPE =>     aluOpcode_i <= NOP; --to be implemented
      when JTYPE_J =>     aluOpcode_i <= NOP;
      when JTYPE_JAL =>   aluOpcode_i <= NOP;
      when ITYPE_BEQZ =>  aluOpcode_i <= NOP;
      when ITYPE_BNEZ =>  aluOpcode_i <= NOP;
      when ITYPE_BFPT =>  aluOpcode_i <= NOP; --to be implemented
      when ITYPE_BFPF =>  aluOpcode_i <= NOP; --to be implemented
      when ITYPE_ADDI =>  aluOpcode_i <= ADDS;
      when ITYPE_ADDUI => aluOpcode_i <= ADDS;
      when ITYPE_SUBI =>  aluOpcode_i <= SUBS;
      when ITYPE_SUBUI => aluOpcode_i <= SUBS;
      when ITYPE_ANDI =>  aluOpcode_i <= ANDS;
      when ITYPE_ORI =>   aluOpcode_i <= ORS;
      when ITYPE_XORI =>  aluOpcode_i <= XORS;
      when ITYPE_LHI =>   aluOpcode_i <= NOP; --to be implemented
      when ITYPE_RFE =>   aluOpcode_i <= NOP; --to be implemented
      when ITYPE_TRAP =>  aluOpcode_i <= NOP; --to be implemented
      when ITYPE_JR =>    aluOpcode_i <= NOP;
      when ITYPE_JALR =>  aluOpcode_i <= NOP;
      when ITYPE_SLLI =>  aluOpcode_i <= SLLS;
      when ITYPE_NOP =>   aluOpcode_i <= NOP;
      when ITYPE_SRLI =>  aluOpcode_i <= SRLS;
      when ITYPE_SRAI =>  aluOpcode_i <= SRAS;
      when ITYPE_SEQI =>  aluOpcode_i <= SEQS;
      when ITYPE_SNEI =>  aluOpcode_i <= SNES;
      when ITYPE_SLTI =>  aluOpcode_i <= SLTS;
      when ITYPE_SGTI =>  aluOpcode_i <= SGTS;
      when ITYPE_SLEI =>  aluOpcode_i <= SLES;
      when ITYPE_SGEI =>  aluOpcode_i <= SGES;
      when ITYPE_LB =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_LH =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_LW =>    aluOpcode_i <= ADDS;
      when ITYPE_LBU =>   aluOpcode_i <= NOP; --to be implemented
      when ITYPE_LHU =>   aluOpcode_i <= NOP; --to be implemented
      when ITYPE_LF =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_LD =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_SB =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_SH =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_SW =>    aluOpcode_i <= ADDS;
      when ITYPE_SF =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_SD =>    aluOpcode_i <= NOP; --to be implemented
      when ITYPE_ITLB =>  aluOpcode_i <= NOP; --to be implemented
      when ITYPE_SLTUI => aluOpcode_i <= SLTUS;
      when ITYPE_SGTUI => aluOpcode_i <= SGTUS;
      when ITYPE_SLEUI => aluOpcode_i <= SLEUS;
      when ITYPE_SGEUI => aluOpcode_i <= SGEUS;
  		when others => aluOpcode_i <= NOP;
	 end case;
	end process ALU_OP_CODE_P;

end dlx_cu_hw;
