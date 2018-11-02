library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mux_ns is
  port (nora : in std_logic_vector(36 downto 0); --Normal a
        norb : in std_logic_vector(36 downto 0); --Normal b
        mixa : in std_logic_vector(36 downto 0); --Mixed a
        mixb : in std_logic_vector(36 downto 0); --Mixed b
        e_data : in std_logic_vector(1 downto 0);
        a : out std_logic_vector(36 downto 0);
        b : out std_logic_vector(36 downto 0));
end entity;

architecture behav of mux_ns is

begin

  a <= nora when e_data="01" else
       mixa when e_data="10" else
       "-------------------------------------";

  b <= norb when e_data="01" else
       mixb when e_data="10" else
       "-------------------------------------";

end architecture;
