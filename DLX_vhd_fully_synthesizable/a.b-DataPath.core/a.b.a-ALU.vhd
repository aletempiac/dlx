library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.myTypes.all;

entity alu is
  Generic(NUMBIT : integer :=32);
  Port( DATA1       : in std_logic_vector(NUMBIT-1 downto 0);
        DATA2       : in std_logic_vector(NUMBIT-1 downto 0);
        FUNC        : in aluOp;
        OUTALU      : out std_logic_vector(NUMBIT-1 downto 0));
end alu;

architecture STRUCT of alu is

  component P4addersub
  	Generic(N : integer :=32);
  	Port(A : in std_logic_vector(N-1 downto 0);
  	     B : in std_logic_vector(N-1 downto 0);
  	     sub_add : in std_logic;
  	     Y : out std_logic_vector(N-1 downto 0);
  	     Cout : out std_logic);
  end component;

  component logicunit
    Port( A       : in std_logic_vector(31 downto 0);
          B       : in std_logic_vector(31 downto 0);
          SEL     : in std_logic_vector(2 downto 0); --s3-s2-s1
          LU_OUT  : out std_logic_vector(31 downto 0));
  end component;

  component ComparatorUnit
    port (A_MSB : in std_logic;
          B_MSB : in std_logic;
          SUBIN : in std_logic_vector(31 downto 0);
          COUT : in std_logic;
          SIGN_UNSIGN : in std_logic;
          OP : in integer range 0 to 5;
          CU_OUT : out std_logic_vector(31 downto 0));
  end component;

  component shifter is
    port (R : in std_logic_vector(31 downto 0);
          Offset : in std_logic_vector(4 downto 0);
          Conf : in integer range 0 to 2; --0 for SLL, 1 for SRL, 2 for SRA
          Shift_OUT : out std_logic_vector(31 downto 0));
  end component;

--Adder_subtractor signals
signal sub_add : std_logic;
signal OUT_adder : std_logic_vector(NUMBIT-1 downto 0);
signal Adder_Cout : std_logic;
--Logic unit signals
signal Sel : std_logic_vector(2 downto 0);
signal LU_out : std_logic_vector(NUMBIT-1 downto 0);
--Comparator unit signals
signal sign_unsign : std_logic;
signal Comp_OP : integer range 0 to 5;
signal CU_OUT : std_logic_vector(NUMBIT-1 downto 0);
--Shifter signals
signal Offset : std_logic_vector(4 downto 0);
signal Conf : integer range 0 to 2;
signal SHIFT_OUT : std_logic_vector(NUMBIT-1 downto 0);

  begin

    P_ALU: process (FUNC, OUT_adder, LU_OUT, CU_OUT, SHIFT_OUT)
    begin
      sub_add <= '-';
      Sel <= "---";
      Conf <= 0;
      Comp_OP <= 0;
      sign_unsign <= '-';
      sub_add <= '-';

      case FUNC is
        when ADDS =>  sub_add <= '0';
                      OUTALU <= OUT_adder;
        when SUBS =>  sub_add <= '1';
                      OUTALU <= OUT_adder;
        when ANDS =>  Sel <= "100";
                      OUTALU <= LU_out;
        when ORS =>   Sel <= "111";
                      OUTALU <= LU_out;
        when XORS =>  Sel <= "011";
                      OUTALU <= LU_out;
        when SLLS =>  Conf <= 0;
                      OUTALU <= SHIFT_OUT;
        when SRLS =>  Conf <= 1;
                      OUTALU <= SHIFT_OUT;
        when SRAS =>  Conf <= 2;
                      OUTALU <= SHIFT_OUT;
        when SEQS =>  Comp_OP <= 0;
                      sign_unsign <= '0';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SNES =>  Comp_OP <= 1;
                      sign_unsign <= '0';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SLTS =>  Comp_OP <= 2;
                      sign_unsign <= '1';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SGTS =>  Comp_OP <= 3;
                      sign_unsign <= '1';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SLES =>  Comp_OP <= 4;
                      sign_unsign <= '1';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SGES =>  Comp_OP <= 5;
                      sign_unsign <= '1';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SLTUS => Comp_OP <= 2;
                      sign_unsign <= '0';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SGTUS =>  Comp_OP <= 3;
                      sign_unsign <= '0';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SLEUS => Comp_OP <= 4;
                      sign_unsign <= '0';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when SGEUS => Comp_OP <= 5;
                      sign_unsign <= '0';
                      sub_add <= '1';
                      OUTALU <= CU_OUT;
        when others => OUTALU <= (others=>'0');
      end case;
    end process;

    P4addersub_0: P4addersub generic map(N => NUMBIT)
              port map(DATA1, DATA2, sub_add, OUT_adder, Adder_Cout);

    logicunit_0: logicunit port map(DATA1, DATA2, Sel, LU_out);

    ComparatorUnit_0: ComparatorUnit port map(DATA1(31), DATA2(31), OUT_adder,
                                      Adder_Cout, sign_unsign, Comp_OP, CU_OUT);

    Offset <= DATA2(4 downto 0);
    shifter_0: shifter port map(DATA1, Offset, Conf, SHIFT_OUT);

end architecture STRUCT;
