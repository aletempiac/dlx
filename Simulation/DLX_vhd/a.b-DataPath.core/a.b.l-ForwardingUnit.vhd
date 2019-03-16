library IEEE;
use IEEE.std_logic_1164.all;

entity ForwardingUnit is
  generic (NUMBIT : integer := 32;
           ADDRESS_WIDTH_RF : integer := 5);
  port (
    CLK : in std_logic;
    RST : in std_logic; --active low
    RS1 : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
    RS2 : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
    RD_XM  : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
    RD_MW  : in std_logic_vector(ADDRESS_WIDTH_RF - 1 downto 0);
    REGWRITE_XM : in std_logic;
    REGWRITE_MW : in std_logic;
    ForwardA : out std_logic_vector (1 downto 0);
    forwardB : out std_logic_vector (1 downto 0);
    ForwardC : out std_logic;
    ForwardD : out std_logic_vector(1 downto 0));
end entity;

architecture beh of ForwardingUnit is

  signal RS1_DX, RS1_XM : std_logic_vector (ADDRESS_WIDTH_RF -1 downto 0);
  signal RS2_DX, RS2_XM : std_logic_vector (ADDRESS_WIDTH_RF -1 downto 0);
  constant R0_ADDR : std_logic_vector(ADDRESS_WIDTH_RF -1 downto 0) := (others => '0');

begin

    SOURCE_ADDR_REG: PROCESS (CLK, RST, RS1, RS2)
    begin

      if (clk'event and clk='1') then
        if (rst = '0') then
          RS1_DX <= (others => '0');
          RS2_DX <= (others => '0');
        else
          RS1_DX <= RS1;
          RS2_DX <= RS2;
          RS1_XM <= RS1_DX;
          RS2_XM <= RS2_DX;
        end if;
      end if;

    end process;


    FORWARDA_GEN: PROCESS (RS1_DX, RD_XM, RD_MW, REGWRITE_XM, REGWRITE_MW)  --forwarding of operand A of ALU
    begin
      ForwardA <= "00";

      if (REGWRITE_XM = '1') then
        if (RS1_DX = RD_XM) and (RS1_DX /= R0_ADDR) then
          ForwardA <= "10";
        end if;
      end if;

      if (REGWRITE_MW = '1') then
        if ((RS1_DX = RD_MW) and (RS1_DX /= R0_ADDR) and ((RS1_DX /= RD_XM) or (REGWRITE_XM = '0'))) then
            ForwardA <= "01";
        end if;
      end if;

    end process FORWARDA_GEN;


    FORWARDB_GEN: PROCESS (RS2_DX, RD_XM, RD_MW, REGWRITE_XM, REGWRITE_MW) --forwarding of operand B of ALU
    begin
      forwardB <= "00";

      if (REGWRITE_XM = '1') then
        if (RS2_DX = RD_XM) and (RS2_DX /= R0_ADDR) then
          ForwardB <= "10";
        end if;
      end if;

      if (REGWRITE_MW = '1') then
        if ((RS2_DX = RD_MW) and (RS2_DX /= R0_ADDR) and ((RS2_DX /= RD_XM) or (REGWRITE_XM = '0'))) then
            ForwardB <= "01";
        end if;
      end if;

    end process FORWARDB_GEN;


    FORWARDC_GEN: PROCESS (RS2_XM, RD_MW, REGWRITE_MW)  -- forwarding for stores
    begin
      ForwardC <= '0';
      if (REGWRITE_MW = '1') then
        if (RS2_XM = RD_MW) and (RS2_XM /= R0_ADDR) then
          ForwardC <= '1';
        end if;
      end if;

    end process FORWARDC_GEN;


    FORWARDD_GEN: PROCESS (RS1, RD_XM, RD_MW, REGWRITE_XM, REGWRITE_MW)  --forwarding for branching
    begin
      ForwardD <= "00";
      if (REGWRITE_XM = '1') then
        if (RS1 = RD_XM) and (RS1 /= R0_ADDR) then
          ForwardD <= "10";
        end if;
      end if;

      if (REGWRITE_MW = '1') then
        if ((RS1 = RD_MW) and (RS1 /= R0_ADDR) and ((RS1 /= RD_XM) or (REGWRITE_XM ='0'))) then
          ForwardD <= "01";
        end if;
      end if;

    end process FORWARDD_GEN;


end beh;
