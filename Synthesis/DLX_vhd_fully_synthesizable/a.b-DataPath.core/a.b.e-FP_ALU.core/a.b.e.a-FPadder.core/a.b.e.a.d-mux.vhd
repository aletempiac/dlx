library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity MUX is
  port (a : in std_logic;
        b : in std_logic;
        sel : in std_logic;
        z : out std_logic);
end entity;

architecture behav of MUX is

begin

  z<=a when sel='1' else b;

end architecture;
