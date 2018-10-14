library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity zero_counter is
  port (a : in std_logic_vector(27 downto 0);
        zcount : out std_logic_vector(4 downto 0));
end entity;

architecture behav of zero_counter is

  constant zeros : std_logic_vector(27 downto 0):=X"0000000";
  signal aux : std_logic_vector(7 downto 0);

begin

  aux<=X"1C" when a(27 downto 0)=zeros(27 downto 0) else
          X"1B" when a(27 downto 1)=zeros(27 downto 1) else
          X"1A" when a(27 downto 2)=zeros(27 downto 2) else
          X"19" when a(27 downto 3)=zeros(27 downto 3) else
          X"18" when a(27 downto 4)=zeros(27 downto 4) else
          X"17" when a(27 downto 5)=zeros(27 downto 5) else
          X"16" when a(27 downto 6)=zeros(27 downto 6) else
          X"15" when a(27 downto 7)=zeros(27 downto 7) else
          X"14" when a(27 downto 8)=zeros(27 downto 8) else
          X"13" when a(27 downto 9)=zeros(27 downto 9) else
          X"12" when a(27 downto 10)=zeros(27 downto 10) else
          X"11" when a(27 downto 11)=zeros(27 downto 11) else
          X"10" when a(27 downto 12)=zeros(27 downto 12) else
          X"0F" when a(27 downto 13)=zeros(27 downto 13) else
          X"0E" when a(27 downto 14)=zeros(27 downto 14) else
          X"0D" when a(27 downto 15)=zeros(27 downto 15) else
          X"0C" when a(27 downto 16)=zeros(27 downto 16) else
          X"0B" when a(27 downto 17)=zeros(27 downto 17) else
          X"0A" when a(27 downto 18)=zeros(27 downto 18) else
          X"09" when a(27 downto 19)=zeros(27 downto 19) else
          X"08" when a(27 downto 20)=zeros(27 downto 20) else
          X"07" when a(27 downto 21)=zeros(27 downto 21) else
          X"06" when a(27 downto 22)=zeros(27 downto 22) else
          X"05" when a(27 downto 23)=zeros(27 downto 23) else
          X"04" when a(27 downto 24)=zeros(27 downto 24) else
          X"03" when a(27 downto 25)=zeros(27 downto 25) else
          X"02" when a(27 downto 26)=zeros(27 downto 26) else
          X"01" when a(27)=zeros(27) else
          X"00";

  zcount<=aux(4 downto 0);
  
end architecture;
