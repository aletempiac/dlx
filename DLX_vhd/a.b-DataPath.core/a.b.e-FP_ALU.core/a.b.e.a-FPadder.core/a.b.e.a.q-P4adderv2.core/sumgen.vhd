library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity sumgen is 
	generic (N_blocks :	 integer:=8);
		
	Port (	A:	In	std_logic_vector(N_blocks*4-1 downto 0);
		B:	In	std_logic_vector(N_blocks*4-1 downto 0);
		Ci:	In	std_logic_vector(N_blocks-1 downto 0);
		S:	Out	std_logic_vector(N_blocks*4-1 downto 0));
end sumgen; 

architecture STRUCTURAL of sumgen is

  component CSB
  port (
	A,B: In std_logic_vector (3 downto 0);
	Ci: In std_logic;
	S: Out std_logic_vector (3 downto 0));
  end component;

begin
  
  SUMGEN_0: for I in 0 to N_blocks-1 generate
    CSBI : CSB 
	  Port Map (A((I+1)*4-1 downto I*4), B((I+1)*4-1 downto I*4), Ci(i), S((I+1)*4-1 downto I*4)); 
  end generate;

end STRUCTURAL;

configuration CFG_SUMGEN_STRUCTURAL of sumgen is
  for STRUCTURAL 
	for SUMGEN_0
		for all : CSB
			use configuration WORK.CFG_CSB_STRUCTURAL;
		end for;
	end for;
  end for;
end CFG_SUMGEN_STRUCTURAL;
