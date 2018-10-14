library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		SEL:	In	std_logic;
		Y:	Out	std_logic);
end MUX21;


architecture BEHAVIORAL_1 of MUX21 is

begin
	Y <= A when SEL='1' else B ; -- processo implicito

end BEHAVIORAL_1;


configuration CFG_MUX21_BEHAVIORAL of MUX21 is
	for BEHAVIORAL_1
	end for;
end CFG_MUX21_BEHAVIORAL;
