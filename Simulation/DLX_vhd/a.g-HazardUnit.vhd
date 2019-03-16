library IEEE;
use IEEE.std_logic_1164.all;
use work.myTypes.all;

entity HazardUnit is
  generic (NUMBIT : integer := 32;
           ADDRESS_WIDTH_RF : integer := 5;
           OP_CODE_SIZE     : integer := 6);  -- Op Code Size
  port (
    CLK : in std_logic;
    RST : in std_logic; --active Low
    RS1 : in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
    RS2 : in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
    REGWRITE_DX : in std_logic;
    MEMREAD_DX : in std_logic;
    RD : in std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);
    OPCODE : in std_logic_vector(OP_CODE_SIZE-1 downto 0);
    STALL : out std_logic
  );
end entity;

architecture beh of HazardUnit is

  signal RD_DX, RD_XM : std_logic_vector(ADDRESS_WIDTH_RF-1 downto 0);

begin

RD_register: process (RD, CLK, RST)
begin

  if (CLK = '1' and clk'event) then
    if (RST = '0') then
      RD_DX <= (others => '0');
    else
      RD_DX <= RD;
    end if;
  end if;

end process;

Stall_GEN: process (MEMREAD_DX, REGWRITE_DX, RD_DX, RS1, RS2, OPCODE)
begin

  STALL <= '0';
  if (MEMREAD_DX = '1') then
    if (RD_DX = RS1) or (RD_DX = RS2) then
      STALL <= '1';
    end if;
  end if;

  if (REGWRITE_DX = '1') then
    if (OPCODE = ITYPE_BNEZ) or (OPCODE = ITYPE_BEQZ) then
      if (RD_DX = RS1) then
        STALL <= '1';
      end if;
    end if;
  end if;

end process;




end architecture;
