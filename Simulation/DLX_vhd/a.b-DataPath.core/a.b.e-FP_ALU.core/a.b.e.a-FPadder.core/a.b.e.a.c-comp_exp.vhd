library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

entity comp_exp is
  port (a : in std_logic_vector(36 downto 0);
        b : in std_logic_vector(36 downto 0);
        sa : out std_logic;
        sb : out std_logic;
        expo : out std_logic_vector(7 downto 0);
        ma : out std_logic_vector(27 downto 0);
        mb : out std_logic_vector(27 downto 0);
        diffexp : out std_logic_vector(4 downto 0);
        comp : out std_logic);
end entity;

architecture behav of comp_exp is

  signal e_a, e_b : std_logic_vector(7 downto 0);     --Exp A and B
  signal m_a, m_b : std_logic_vector(27 downto 0);    --Mantissa A and B

  signal diff : std_logic_vector(7 downto 0);
  signal cmp : std_logic;

begin

  sa <= a(36);
  sb <= b(36);
  e_a <= a(35 downto 28);
  e_b <= b(35 downto 28);
  m_a <= a(27 downto 0);
  m_b <= b(27 downto 0);

  --Exp comparison
  cmp<='1' when ((e_a>e_b) or m_b(0)='1') else
       '0' when (e_a<e_b) else
       '1' when (m_a>=m_b) else
       '0';

  comp<=cmp;

  expo<=e_a when cmp='1' else
        e_b;

  diff<=e_a-e_b when (cmp='1' and m_b(0)='0') else
        e_b-e_a when cmp='0' else
        e_a+e_b;

  diffexp<="11100" when (diff>X"1B") else
           diff(4 downto 0);

  ma<=m_a when cmp='1' else     --the greater one
      m_b;

  mb<=m_b when cmp='1' else     --the one to be shifted
      m_a;

end architecture;
