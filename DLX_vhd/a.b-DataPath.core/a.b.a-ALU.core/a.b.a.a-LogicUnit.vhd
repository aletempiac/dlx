library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity logicunit is
  --fixed for 32
  Port( A       : in std_logic_vector(31 downto 0);
        B       : in std_logic_vector(31 downto 0);
        SEL     : in std_logic_vector(2 downto 0); --s3-s2-s1
        LU_OUT  : out std_logic_vector(31 downto 0));
end logicunit;

--it implements a modified version of T2 logic unit
--for AND SEL<="100", for OR SEL<="111", FOR XOR SEL<="011"

architecture Behavioral of logicunit is

  signal notA, notB : std_logic_vector(31 downto 0);
  signal l1, l2, l3 : std_logic_vector(31 downto 0);

  begin

    notA <= not(A);
    notB <= not(B);

    prc_l1: process(notA, B, SEL)
    begin
      for i in 0 to 31 loop
        l1(i)<=not(notA(i) and B(i) and SEL(0));
      end loop;
    end process;

    prc_l2: process(A, notB, SEL)
    begin
      for i in 0 to 31 loop
        l2(i)<=not(A(i) and notB(i) and SEL(1));
      end loop;
    end process;

    prc_l3: process(A, B, SEL)
    begin
      for i in 0 to 31 loop
        l3(i)<=not(A(i) and B(i) and SEL(2));
      end loop;
    end process;

    LU_OUT <= not(l1 and l2 and l3);

end architecture Behavioral;
