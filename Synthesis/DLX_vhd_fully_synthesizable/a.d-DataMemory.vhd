library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;
use WORK.all;

entity data_memory is
 generic( NUMBIT : integer := 32;
			    BITADDR : integer := 32;
          SIZE : integer := 5);
 port (	CLK: 		IN std_logic;
       	RESET: 	IN std_logic; --active low
	 		  ENABLE: 	IN std_logic;
	 		  RD: 		IN std_logic;
			  WR: 		IN std_logic;
	 		  ADDR: 	IN std_logic_vector(BITADDR-1 downto 0);
	 		  DATAIN: 	IN std_logic_vector(NUMBIT-1 downto 0);
	 		  DATAOUT: 		OUT std_logic_vector(NUMBIT-1 downto 0));
end data_memory;

architecture Behavioral of data_memory is

  subtype REG_ADDR is natural range 0 to (2**SIZE)-1; -- using natural type
  type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NUMBIT-1 downto 0);
  signal REGISTERS : REG_ARRAY;

begin

  write_p: process(CLK, RESET)
  begin
    if(RESET='0') then
      REGISTERS<=(others=>(others=>'0'));
    elsif(CLK='1' and CLK'event) then
      if (ENABLE='1' and WR='1') then
        REGISTERS(to_integer(unsigned(ADDR(SIZE-1 downto 0))))<=DATAIN;
      end if;
    end if;
  end process;


  read_p: process(ENABLE, RD, ADDR, REGISTERS)
  begin
    if(RESET='0') then
      DATAOUT<=(others=>'0');
    elsif(RD='1' and ENABLE='1') then
      DATAOUT<=REGISTERS(to_integer(unsigned(ADDR(SIZE-1 downto 0))));
    end if;
  end process;

end architecture;
