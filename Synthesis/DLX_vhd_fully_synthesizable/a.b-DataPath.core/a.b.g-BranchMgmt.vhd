library ieee;
use ieee.std_logic_1164.all;

entity BranchMgmt is
  generic(NUMBIT : integer := 32);
  port( Rin : in std_logic_vector(NUMBIT-1 downto 0);
        Cond : in std_logic;    --1 for BEQZ, 0 for BNEZ
        Jump : in std_logic;    --1 for jump, ->output always 1
        Branch : out std_logic);
end BranchMgmt;

architecture Behavioral of BranchMgmt is

  constant zero : std_logic_vector(NUMBIT-1 downto 0) := (others=>'0');

begin

  branch_p: process(Rin, Cond, Jump)
  begin
    if (Jump = '1') then
      Branch <= '1';
    else
      if ((Rin=zero and Cond='1') or (Rin/=zero and COND='0')) then
        Branch<='1';
      else
        Branch<= '0';
      end if;
    end if;
  end process;

end architecture;
