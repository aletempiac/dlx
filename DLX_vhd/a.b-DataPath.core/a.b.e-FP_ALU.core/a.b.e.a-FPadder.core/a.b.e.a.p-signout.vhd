library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity signout is
  port (sa : in std_logic;
        sb : in std_logic;
        a : in std_logic_vector(27 downto 0);
        b : in std_logic_vector(27 downto 0);
        sub_add : in std_logic;                   --1 for Sub, 0 for Add
        comp : in std_logic;
        aout : out std_logic_vector(27 downto 0);
        bout : out std_logic_vector(27 downto 0);
        sub_add_out : out std_logic;
        sout : out std_logic);
end entity;

architecture behav of signout is

  signal sb_aux : std_logic;
  signal aaux, baux : std_logic_vector(27 downto 0);

begin

  sb_aux <= sb xor sub_add;

  sout <= sa when comp='1' else sb_aux;

  sub_add_out<= '1' when sa/=sb_aux else '0';

  aaux <= a when comp='1' else b;

  baux <= b when comp='1' else a;

  process(sa, sb_aux, aaux, baux)
  begin
    if (sa='1' and sb_aux='0') then
      aout<=baux;
      bout<=aaux;
    else
      aout<=aaux;
      bout<=baux;
    end if;
  end process;

end architecture;
