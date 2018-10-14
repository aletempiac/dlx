library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;
use WORK.all;

entity register_file is
 generic( NUMBIT : integer := 32;
			 BITADDR : integer := 5);		--32 regs
 port(CLK:    IN std_logic;
      RESET: 	IN std_logic;  --active low
	 		ENABLE: 	IN std_logic;
	 		RD1: 		IN std_logic;
	 		RD2: 		IN std_logic;
			WR: 		IN std_logic;
	 		ADD_WR: 	IN std_logic_vector(BITADDR-1 downto 0);
	 		ADD_RD1: 	IN std_logic_vector(BITADDR-1 downto 0);
	 		ADD_RD2: 	IN std_logic_vector(BITADDR-1 downto 0);
	 		DATAIN: 	IN std_logic_vector(NUMBIT-1 downto 0);
			OUT1: 		OUT std_logic_vector(NUMBIT-1 downto 0);
	 		OUT2: 		OUT std_logic_vector(NUMBIT-1 downto 0));
end register_file;

architecture A of register_file is

        -- suggested structures
  subtype REG_ADDR is natural range 0 to (2**BITADDR)-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NUMBIT-1 downto 0);
	signal REGISTERS : REG_ARRAY;
  constant R0_addr : std_logic_vector(BITADDR-1 downto 0):=(others=>'0');


begin

  write_process: process(RESET, ENABLE, WR, ADD_WR, DATAIN)
  begin
    if (RESET='0') then
      REGISTERS<=(others=>(others=>'0'));
    elsif(WR='1' and ENABLE='1') then
      if (ADD_WR/=R0_addr) then   --R0 READ-ONLY
        REGISTERS(to_integer(unsigned(ADD_WR)))<=DATAIN;
      end if;
	  end if;
  end process;

  read1_process: process(ENABLE, RD1, ADD_RD1, REGISTERS)
  begin
    if (ENABLE='1') then
      if (RD1='1') then
        OUT1<=REGISTERS(to_integer(unsigned(ADD_RD1)));
      end if;
    end if;
  end process;

  read2_process: process(ENABLE, RD2, ADD_RD2, REGISTERS)
  begin
    if (ENABLE='1') then
      if (RD2='1') then
        OUT2<=REGISTERS(to_integer(unsigned(ADD_RD2)));
      end if;
    end if;
  end process;

end A;


configuration CFG_RF_BEH of register_file is
  for A
  end for;
end configuration;
