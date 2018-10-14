library ieee;
use ieee.std_logic_1164.all;

entity prop_gen is
	port (a	: in std_logic;
	      b : in std_logic;
	      prop : out std_logic;
	      gen : out std_logic);
end prop_gen;

architecture behav of prop_gen is
begin
	prop<=a xor b;
	gen<=a and b;
end behav;
	      
