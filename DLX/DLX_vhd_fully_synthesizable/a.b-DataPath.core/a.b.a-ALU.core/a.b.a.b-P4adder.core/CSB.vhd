library ieee;
use ieee.std_logic_1164.all;

entity CSB is
port (
	A,B: In std_logic_vector (3 downto 0);
	Ci: In std_logic;
	S: Out std_logic_vector (3 downto 0));
end entity;

architecture structural of CSB is

component RCA
	generic (N  :        integer:= 6);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N-1 downto 0));
end component;

signal sum0, sum1: std_logic_vector (3 downto 0);

begin

	RCA_0: RCA 	generic map (N => 4)
			port map (A, B, '0', sum0);
	RCA_1: RCA 	generic map (N => 4)
			port map (A, B, '1', sum1);

	S <= sum1 when Ci = '1' else sum0;

end structural;

configuration CFG_CSB_STRUCTURAL of CSB is
  for structural
    for all : RCA
      use configuration WORK.CFG_RCA_STRUCTURAL;
    end for;
  end for;
end CFG_CSB_STRUCTURAL;
