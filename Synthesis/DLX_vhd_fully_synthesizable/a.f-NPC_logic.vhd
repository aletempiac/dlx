library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity NPC_logic is
  generic (PC_SIZE : integer := 32);
  port (Flush_BTB : in std_logic;
        BRANCH_CTRL_SIG : in std_logic;
        OUTT_NT_i : in std_logic;
        PC_next : in std_logic_vector(PC_SIZE-1 downto 0);
        BRANCH_ALU_OUT : in std_logic_vector(PC_SIZE-1 downto 0);
        OUT_PC_target_i : in std_logic_vector(PC_SIZE-1 downto 0);
        NPC : in std_logic_vector(PC_SIZE-1 downto 0);
        PC_BUS : out std_logic_vector(PC_SIZE-1 downto 0));
end entity;

architecture arch of NPC_logic is

begin

  PC_BUS_p: process(Flush_BTB, BRANCH_CTRL_SIG, OUTT_NT_i, PC_next, BRANCH_ALU_OUT, OUT_PC_target_i, NPC)
  begin
    if (Flush_BTB='1') then
      if (BRANCH_CTRL_SIG='0') then --misspredicted branch
        PC_BUS <= NPC; --branch not taken
      else
        PC_BUS <= BRANCH_ALU_OUT; --branch taken
      end if;
    elsif (OUTT_NT_i='1') then
      PC_BUS <= OUT_PC_target_i; --predicted taken
    else
      PC_BUS <= PC_next; --predicted not taken
    end if;
  end process;

end architecture;
