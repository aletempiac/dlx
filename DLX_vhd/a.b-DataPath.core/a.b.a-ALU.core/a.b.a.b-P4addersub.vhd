library ieee;
use ieee.std_logic_1164.all;

entity P4addersub is
	Generic(N : integer :=32);
	Port(A : in std_logic_vector(N-1 downto 0);
	     B : in std_logic_vector(N-1 downto 0);
	     sub_add : in std_logic;		--1 for sub, 0 for add
	     Y : out std_logic_vector(N-1 downto 0);
	     Cout : out std_logic);
end P4addersub;

architecture struct of P4addersub is

component STCG
generic(N : integer := 32;
				L : integer := 5);
	port (A, B : in std_logic_vector(N-1 downto 0);
	      cin : in std_logic;
	      cout : out std_logic_vector(N/4-1 downto 0));
end component;

component sumgen
	generic (N_blocks :	 integer:=8);

	Port (	A:	In	std_logic_vector(N_blocks*4-1 downto 0);
		B:	In	std_logic_vector(N_blocks*4-1 downto 0);
		Ci:	In	std_logic_vector(N_blocks-1 downto 0);
		S:	Out	std_logic_vector(N_blocks*4-1 downto 0));
end component;

signal carry : std_logic_vector(N/4 downto 0);
signal B_subadd : std_logic_vector(N-1 downto 0);

begin

	process (B, sub_add)
	begin
		for i in 0 to N-1 loop
			B_subadd(i)<=B(i) xor sub_add;
		end loop;
	end process;

	STCG_1: STCG generic map(N, 5) port map(A, B_subadd, sub_add, carry(N/4 downto 1));
	sumgen_1: sumgen generic map(N/4) port map(A, B_subadd, carry(N/4-1 downto 0), Y);

	carry(0)<=sub_add;
	Cout<=carry(N/4);

end struct;

configuration CFG_P4ADDER_STRUCTURAL of P4addersub is
  for struct
    for all : sumgen
      use configuration WORK.CFG_SUMGEN_STRUCTURAL;
    end for;
    --for all : STCG
      --use configuration WORK.CFG_STCG_STRUCTURAL;
    --end for;
  end for;
end CFG_P4ADDER_STRUCTURAL;
