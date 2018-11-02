library ieee;
use ieee.std_logic_1164.all;

entity PG is
	port (	pi : in std_logic;
	      	gi : in std_logic;
	      	pj : in std_logic;
		gj : in std_logic;
		pout : out std_logic;
		gout : out std_logic);
end PG;

architecture behav of PG is
begin
	pout <= pi and pj; 
	gout <= gi or (pi and gj); 
end behav;
