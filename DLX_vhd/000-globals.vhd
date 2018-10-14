library ieee;
use ieee.std_logic_1164.all;

package myTypes is

	type aluOp is (
		 ADDS, SUBS, ANDS, ORS, XORS, SLLS, SRLS, SRAS, SEQS, SNES,
		 SLTS, SGTS, SLES, SGES, SLTUS, SGTUS, SLEUS, SGEUS, NOP);


-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size

-- R-Type instruction -> FUNC field
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

-- Change the values of the instructions coding as you want, depending also on the type of control unit choosen

end myTypes;
