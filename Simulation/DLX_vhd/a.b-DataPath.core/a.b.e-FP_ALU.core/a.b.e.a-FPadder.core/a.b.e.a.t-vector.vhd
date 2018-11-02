library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity vector is
  port (nsign : in std_logic;
        exponent : in std_logic_vector(7 downto 0);
        mantissa : in std_logic_vector(22 downto 0);
        vector : out std_logic_vector(31 downto 0));
end entity;

architecture Behav of vector is

begin

  vector(31)<=nsign;
  vector(30 downto 23)<=exponent;
  vector(22 downto 0)<=mantissa;

end architecture;
