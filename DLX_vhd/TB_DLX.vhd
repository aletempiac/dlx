library ieee;
use ieee.std_logic_1164.all;

entity TB_DLX is
end entity;

architecture testbench of TB_DLX is

component DLX
  generic (
    IR_SIZE      : integer := 32;       -- Instruction Register Size
    PC_SIZE      : integer := 32;        -- Program Counter Size
    ADDRESS_WIDTH_DM : integer := 5     -- Address Width DRAM
    );       -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    Clk : in std_logic;
    Rst : in std_logic;                -- Active Low
    DataOut : out std_logic_vector(31 downto 0));
end component;

signal Clk : std_logic := '0';
signal Rst : std_logic := '0';
signal DataOut : std_logic_vector(31 downto 0);

constant Clk_period : time := 20 ns;

begin

  DLX_0: DLX port map (Clk, Rst, DataOut);

  Clk_P: Process
  begin
    Clk <= '0';
    wait for Clk_period/2;
    Clk <= '1';
    wait for Clk_period/2;
  end process;

  stimuli: Process
  begin
    Rst <= '0';
    wait for 10*Clk_period;
    Rst <= '1';
    wait;
  end process;


end testbench;
