library ieee;
use ieee.std_logic_1164.all;

entity STCG is
	generic(N : integer := 32;
					L : integer := 5);
	port (A, B : in std_logic_vector(N-1 downto 0);
	      cin : in std_logic;
	      cout : out std_logic_vector(N/4-1 downto 0));
end STCG;



architecture struct of STCG is

component prop_gen_Cin
	port (a	: in std_logic;
	      b : in std_logic;
				cin : in std_logic;
	      prop : out std_logic;
	      gen : out std_logic);
end component;

component prop_gen
	port (a	: in std_logic;
	      b : in std_logic;
	      prop : out std_logic;
	      gen : out std_logic);
end component;

component PG
	port (pi : in std_logic;
	      gi : in std_logic;
	      pj : in std_logic;
				gj : in std_logic;
				pout : out std_logic;
				gout : out std_logic);
end component;

component G
	port (pi,gi : in std_logic;
	      gj : in std_logic;
	      gout : out std_logic);
end component;

	--propagate in 1, generate in 0
	type signal_type is array (0 to L) of std_logic_vector(N-1 downto 0);
	signal prop, gen : signal_type;

begin

	prop_gen_Cin0: prop_gen_Cin port map(a(0), b(0), cin, prop(0)(0), gen(0)(0));

	prop_gen0: for i in 1 to N-1 generate
		prop_gen_i: prop_gen port map (a(i), b(i), prop(0)(i), gen(0)(i));
	end generate;

	placing: for level in 1 to L generate
		pl_index: for i in 0 to N-1 generate
			if_place:if (((i+1) mod 2**level) = 0) generate
				if_G: if ((i+1) = 2**level) generate

					if_l1: if (level=1) generate
						G_1: G port map(prop(level-1)(i), gen(level-1)(i), gen(level-1)(i-(2**(level-1))), gen(level)(i));
					end generate;

					if_l23: if (level>1 and level<4) generate
						G_23: G port map(prop(level-1)(i), gen(level-1)(i), gen(level-1)(i-(2**(level-1))), gen(level)(i));
						cout(2**(level-2)-1) <= gen(level)(i);
					end generate;

					if_lM3G: if (level>3) generate
						stair_G: for j in level-3 downto 1 generate  --the last wiil be placed by "hand"
							place_G: for k in 0 to (2**(j-1)-1) generate
								G_jk: G port map(prop(j+2)(i-4*k-2**(level-1)+2**(j+2)), gen(j+2)(i-4*k-2**(level-1)+2**(j+2)), gen(level-1)(i-(2**(level-1))), gen(level)(i-4*k-2**(level-1)+2**(j+2)));
								cout(2**(level-3)-1+2**(j)-k) <= gen(level)(i-4*k-2**(level-1)+2**(j+2));

								last_place: if (j=1) generate
									G_jk1: G port map(prop(2)(i-2**(level-1)+4), gen(2)(i-2**(level-1)+4), gen(level-1)(i-(2**(level-1))), gen(level)(i-2**(level-1)+4));
									cout(2**(level-3)) <= gen(level)(i-2**(level-1)+4);
								end generate;
							end generate;
						end generate;
					end generate;

				end generate;
-----------------------------------------PG-------------------------------
				if_PG: if ((i+1) /= 2**level) generate
					--place PG
					if_PGm3: if (level>0 and level<4) generate
						PG_0_i: PG port map(prop(level-1)(i), gen(level-1)(i), prop(level-1)(i-(2**(level-1))), gen(level-1)(i-(2**(level-1))), prop(level)(i), gen(level)(i));
					end generate;

					if_lM3PG: if (level>3) generate
						stair_PG: for j in level-3 downto 1 generate  --the last wiil be placed by "hand"
							place_PG: for k in 0 to (2**(j-1)-1) generate
								PG_jk: PG port map(prop(j+2)(i-4*k-2**(level-1)+2**(j+2)), gen(j+2)(i-4*k-2**(level-1)+2**(j+2)), prop(level-1)(i-(2**(level-1))), gen(level-1)(i-(2**(level-1))), prop(level)(i-4*k-2**(level-1)+2**(j+2)), gen(level)(i-4*k-2**(level-1)+2**(j+2)));

								last_placePG: if (j=1) generate
									PG_jk1: PG port map(prop(2)(i-2**(level-1)+4), gen(2)(i-2**(level-1)+4), prop(level-1)(i-(2**(level-1))), gen(level-1)(i-(2**(level-1))), prop(level)(i-2**(level-1)+4), gen(level)(i-2**(level-1)+4));
								end generate;
							end generate;
						end generate;
					end generate;

				end generate;
			end generate;
		end generate;
	end generate;

end struct;
