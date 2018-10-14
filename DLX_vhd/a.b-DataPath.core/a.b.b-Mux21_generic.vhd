library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21_GENERIC is
	Generic (N: integer:= 4);
	Port (	A:	In	std_logic_vector(N-1 downto 0) ;
		B:	In	std_logic_vector(N-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(N-1 downto 0));
end MUX21_GENERIC;


architecture BEHAVIORAL_1 of MUX21_GENERIC is

begin
	Y <= A when SEL='1' else B ; -- processo implicito

end BEHAVIORAL_1;


configuration CFG_MUX21_GEN_BEHAVIORAL of MUX21_GENERIC is
	for BEHAVIORAL_1
	end for;
end CFG_MUX21_GEN_BEHAVIORAL;