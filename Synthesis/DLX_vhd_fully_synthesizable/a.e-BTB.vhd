library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity BTB is
  generic ( PC_SIZE : integer := 32;
            BTBSIZE : integer := 5);    --SIZE=2**BTBSIZE
  port (Reset : in std_logic; --active low
        Clk : in std_logic;
        Enable : in std_logic;
        --RD : in std_logic;
        PC_read : in std_logic_vector(PC_SIZE-1 downto 0);    --PC to be searched in LUT
        WR : in std_logic;
        PC_write : in std_logic_vector(PC_SIZE-1 downto 0);   --PC to be added to BTB
        SetT_NT : in std_logic;                               --Set PC to Taken or not Taken optional
        Set_target : in std_logic_vector(PC_SIZE-1 downto 0); --Next PC target in case of Taken
        DELAY_SLOT_EN : in std_logic;
        STALL : in std_logic;
        OUT_PC_target : out std_logic_vector(PC_SIZE-1 downto 0);
        OUTT_NT : out std_logic;
        prevT_NT: out std_logic);
end entity;

architecture Behavioral of BTB is

  subtype BTB_ENTRIES is natural range 0 to (2**BTBSIZE-1);   --2**BTBSIZE size because NPC as input
  type PC_type_in  is array(BTB_ENTRIES) of std_logic_vector(PC_SIZE-1 downto 0);
  type PC_type_off  is array(BTB_ENTRIES) of std_logic_vector(PC_SIZE-1 downto 0);
  signal pc_lut : PC_type_in;
  signal pc_target : PC_type_off;
  --signal t_nt : std_logic_vector(2**BTBSIZE-1 downto 0);  --optional

  signal PC_addrr, PC_addrw : BTB_ENTRIES;
  signal OUTT_NTs, prevT_NTs : std_logic;

begin

  PC_addrr<=to_integer(unsigned(PC_read(BTBSIZE-1 downto 0)));
  PC_addrw<=to_integer(unsigned(PC_write(BTBSIZE-1 downto 0)));

  read_process: process(Enable, PC_addrr, PC_read, pc_lut, pc_target)
  begin
    if (Enable='1') then
      OUT_PC_target<=pc_target(PC_addrr);
      if (pc_lut(PC_addrr)=PC_read) then
        --OUTT_NTs<=t_nt(PC_addrr);
        OUTT_NTs<='1';
      else
        OUTT_NTs<='0';   --not taken because not matched
      end if;
    end if;
  end process;

  write_process: process(Reset, Clk, Enable, WR, PC_addrw, PC_write, SetT_NT, Set_target, DELAY_SLOT_EN)
  begin
    if (Reset='0') then
      pc_lut<=(others=>(others=>'0'));
      pc_target<=(others=>(others=>'0'));
      --t_nt<=(others=>'0');
    else
      if (Enable='1' and Clk='1' and Clk'event) then
        if (WR='1') then
          if (SetT_NT='1') then
            if(SetT_NT/=prevT_NTs) then
              pc_lut(PC_addrw)<=PC_write;
              pc_target(PC_addrw)<=Set_target;
              --t_nt(PC_addrw)<=SetT_NT;  --optional
            end if;
          else
              pc_lut(PC_addrw)<=(others=>'0');  --removes entry
              --t_nt(PC_addrw)<='0';
          end if;
        end if;
      end if;
    end if;
  end process;

  prevT_NT_p: process(Clk, Reset)
  begin
    if (Reset='0') then
      prevT_NTs <= '0';
    elsif (Clk='1' and Clk'event) then
      if (STALL = '0') then
        prevT_NTs <= OUTT_NTs;
      end if;
    end if;
  end process;

  OUTT_NT <= OUTT_NTs;
  prevT_NT <= prevT_NTs;

end architecture;
