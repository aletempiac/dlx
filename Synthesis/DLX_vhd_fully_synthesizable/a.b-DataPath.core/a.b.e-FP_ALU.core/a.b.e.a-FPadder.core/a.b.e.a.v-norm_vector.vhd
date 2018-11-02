library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity norm_vector is
  port (ss : in std_logic;
        es : in std_logic_vector(7 downto 0);
        mms : in std_logic_vector(27 downto 0);
        co : in std_logic;
        n : out std_logic_vector(31 downto 0));
end entity;

architecture Struct of norm_vector is

  component block_norm is
    port (s : in std_logic_vector(27 downto 0);
          e : in std_logic_vector(7 downto 0);
          co : in std_logic;
          mantissa : out std_logic_vector(22 downto 0);
          exponent : out std_logic_vector(7 downto 0));
  end component;

  component vector is
    port (nsign : in std_logic;
          exponent : in std_logic_vector(7 downto 0);
          mantissa : in std_logic_vector(22 downto 0);
          vector : out std_logic_vector(31 downto 0));
  end component;

  signal maux : std_logic_vector(22 downto 0);
  signal eaux : std_logic_vector(7 downto 0);

begin

  block_norm0: block_norm port map(mms, es, co, maux, eaux);

  vector0: vector port map(ss, eaux, maux, n);

end architecture;
