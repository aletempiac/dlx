library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity signExtend is
  generic (NUMBIT_in : integer := 16;
           NUMBIT_out : integer := 32);
  port (
    in_s :     in std_logic_vector(NUMBIT_in-1 downto 0);
    sign_unsign :    in std_logic;                          --1 for sign, 0 for unsign
    out_s :  out std_logic_vector (NUMBIT_out-1 downto 0)
  );
end entity;

architecture beh of signExtend is

	constant pos : std_logic_vector(NUMBIT_out-1 downto NUMBIT_in) := (others => '0');
	constant neg : std_logic_vector(NUMBIT_out-1 downto NUMBIT_in) := (others => '1');

begin

  out_s<= (neg & in_s) when (in_s(NUMBIT_in-1) = '1' and sign_unsign = '1') else (pos & in_s);   --in1 (NPC) always extended signed

end architecture;
