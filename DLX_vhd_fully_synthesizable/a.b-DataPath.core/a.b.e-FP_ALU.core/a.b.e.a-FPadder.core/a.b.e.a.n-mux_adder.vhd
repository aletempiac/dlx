library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mux_adder is
  port (norsa : in std_logic;                           --Sign A normal
        norsb : in std_logic;                           --Sign B normal
        subsa : in std_logic;                           --Sign A subnormal
        subsb : in std_logic;                           --Sign B subnormal
        compn : in std_logic;                           --Comparison normal numbers
        comps : in std_logic;                           --Comparison subnormal numbers
        nore : in std_logic_vector(7 downto 0);         --Exponent normal
        sube : in std_logic_vector(7 downto 0);         --Exponent subnormals
        norma : in std_logic_vector(27 downto 0);       --Mantissa normal A
        normb : in std_logic_vector(27 downto 0);       --Mantissa normal B
        subma : in std_logic_vector(27 downto 0);       --Mantissa subnormal A
        submb : in std_logic_vector(27 downto 0);       --Mantissa subnormal B
        e_data : in std_logic_vector(1 downto 0);
        sa : out std_logic;                             --Sign A
        sb : out std_logic;                             --Sign B
        c : out std_logic;                              --Comparison
        e : out std_logic_vector(7 downto 0);           --Exponent output
        a : out std_logic_vector(27 downto 0);          --Mantissa A
        b : out std_logic_vector(27 downto 0));         --Mantissa B
end entity;

architecture behav of mux_adder is

begin

  a <=norma when e_data="01" or e_data="10" else
      subma when e_data="00" else
      "----------------------------";

  b <=normb when e_data="01" or e_data="10" else
      submb when e_data="00" else
      "----------------------------";

  c <=compn when e_data="01" or e_data="10" else
      comps when e_data="00" else
      '-';

  sa <= norsa when e_data="01" or e_data="10" else
        subsa when e_data="00" else
        '-';

  sb <= norsb when e_data="01" or e_data="10" else
        subsb when e_data="00" else
        '-';

  e <=nore when e_data="01" or e_data="10" else
      sube when e_data="00" else
      "--------";

end architecture;
