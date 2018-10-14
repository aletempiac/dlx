library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity n_subn is
  port (a : in std_logic_vector(36 downto 0);
        b : in std_logic_vector(36 downto 0);
        comp : out std_logic;
        sa : out std_logic;
        sb : out std_logic;
        expo : out std_logic_vector(7 downto 0);
        ma : out std_logic_vector(27 downto 0);
        mb : out std_logic_vector(27 downto 0));
end entity;

architecture behav of n_subn is

  signal m_a, m_b : std_logic_vector(27 downto 0);    --Mantissa A and B
  signal cmp : std_logic;

  begin

  sa <= a(36);
  sb <= b(36);
  m_a <= a(27 downto 0);
  m_b <= b(27 downto 0);

  --Exp comparison
  cmp<='1' when (m_a>=m_b) else '0';

  comp<=cmp;

  expo<=a(35 downto 28);

  ma<=m_a when cmp='1' else     --the greater one
      m_b;

  mb<=m_b when cmp='1' else     --the one to be shifted
      m_a;

end architecture;
