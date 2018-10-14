library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
	generic (NUMBIT: integer :=32);
	port (clk : in std_logic;
			en : in std_logic;
			rst : in std_logic;	--active low
			d : in std_logic_vector(NUMBIT-1 downto 0);
			q : out std_logic_vector(NUMBIT-1 downto 0));
end reg;

architecture Behavioral of reg is

begin

	process(clk)
	begin
		if(clk='1' and clk'event) then
			if(rst='0') then
				q<=(others=>'0');
			elsif(en='1') then
				q<=d;
			end if;
		end if;
	end process;

end Behavioral;
