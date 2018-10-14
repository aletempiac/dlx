library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

entity round is
  port (a : in std_logic_vector(27 downto 0);
        s : out std_logic_vector(22 downto 0));
end entity;

architecture behav of round is

begin

  s <= (a(26 downto 4) + '1') when (a(3 downto 0)>="1000") else a(26 downto 4);

end architecture;
