library ieee;
use ieee.std_logic_1164.all;

entity TB_DLX is
end entity;

architecture testbench of TB_DLX is

component DLX is
    generic (
      IR_SIZE      : integer := 32;       -- Instruction Register Size
      PC_SIZE      : integer := 32);      -- Program Counter Size
    port (
      Clk : in std_logic;
      Rst : in std_logic;                -- Active Low
      DELAY_SLOT : in std_logic;
      --Instruction Ram signals
      Iaddr : out  std_logic_vector(PC_SIZE - 1 downto 0);
      Idata : in std_logic_vector(IR_SIZE - 1 downto 0);

      --Data Ram signals
      Denable : out std_logic;
      Drd :	out std_logic;
      Dwd : out std_logic;
      Daddr : out std_logic_vector(PC_SIZE-1 downto 0);
      Ddatain :	out std_logic_vector(IR_SIZE-1 downto 0);
      Ddataout : in std_logic_vector(IR_SIZE-1 downto 0);

      DataOut : out std_logic_vector(31 downto 0));
end component;


signal Clk : std_logic := '0';
signal Rst : std_logic := '0';
signal DELAY_SLOT_EN : std_logic := '0';
signal DataOut : std_logic_vector(31 downto 0);
signal Iaddr : std_logic_vector(31 downto 0);
signal Idata : std_logic_vector(31 downto 0) := (others=>'0');

--Data Ram signals
signal Denable : std_logic;
signal Drd : std_logic;
signal Dwd : std_logic;
signal Daddr : std_logic_vector(31 downto 0);
signal Ddatain : std_logic_vector(31 downto 0);
signal Ddataout : std_logic_vector(31 downto 0) := (others=>'0');

constant Clk_period : time := 20 ns;

begin

  DLX_0: DLX port map (Clk, Rst, DELAY_SLOT_EN, Iaddr, Idata, Denable, Drd, Dwd, Daddr, Ddatain, Ddataout, DataOut);

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
