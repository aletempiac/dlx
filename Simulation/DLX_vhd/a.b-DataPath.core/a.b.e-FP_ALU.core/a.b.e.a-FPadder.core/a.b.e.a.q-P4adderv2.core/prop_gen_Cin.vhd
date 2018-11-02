library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity prop_gen_Cin is
	port (a	: in std_logic;
	      b : in std_logic;
				cin : in std_logic;
	      prop : out std_logic;
	      gen : out std_logic);
end prop_gen_Cin;

architecture Behavioral of prop_gen_Cin is

begin
	prop<=a xor b;
	gen<=(a and b) or (cin and (a xor b));
end Behavioral;
