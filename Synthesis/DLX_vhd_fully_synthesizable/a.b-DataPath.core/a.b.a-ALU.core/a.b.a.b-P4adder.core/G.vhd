library ieee;
use ieee.std_logic_1164.all;

entity G is
	port (pi,gi : in std_logic;
	      gj : in std_logic;
	      gout : out std_logic);
end G;

architecture behav of G is
begin
	gout <= gi or (pi and gj); 
end behav;
