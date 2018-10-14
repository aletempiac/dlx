library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity muxFPadder is
  port (n1 : in std_logic_vector(31 downto 0); --adder number
        n2 : in std_logic_vector(31 downto 0); --ncase number
        sel : in std_logic;
        res : out std_logic_vector(31 downto 0));
end entity;

architecture Behav of muxFPadder is

begin

  res <= n1 when sel='1' else n2;

end architecture;
