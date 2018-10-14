library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FlipFlop is
	port (clk : in std_logic;
			en : in std_logic;	--active low
			rst : in std_logic;	--active low
			d : in std_logic;
			q : out std_logic);
end FlipFlop;

architecture Behavioral of FlipFlop is

begin

	process(clk)
	begin
		if(clk='1' and clk'event) then
			if(rst='0') then
				q<='0';
			elsif(en='1') then
				q<=d;
			end if;
		end if;
	end process;

end Behavioral;
