library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity n_normal is
  port (a : in std_logic_vector(36 downto 0);
        b : in std_logic_vector(36 downto 0);
        comp : out std_logic;
        sa : out std_logic;
        sb : out std_logic;
        expo : out std_logic_vector(7 downto 0);
        ma : out std_logic_vector(27 downto 0);
        mb : out std_logic_vector(27 downto 0));
end entity;

architecture behav of n_normal is

  component comp_exp
    port (a : in std_logic_vector(36 downto 0);
          b : in std_logic_vector(36 downto 0);
          sa : out std_logic;
          sb : out std_logic;
          expo : out std_logic_vector(7 downto 0);
          ma : out std_logic_vector(27 downto 0);
          mb : out std_logic_vector(27 downto 0);
          diffexp : out std_logic_vector(4 downto 0);
          comp : out std_logic);
  end component;

  component logshifter
    port (s_in : in std_logic_vector(27 downto 0);
          shft : in std_logic_vector(4 downto 0);
          s_out : out std_logic_vector(27 downto 0));
  end component;

  signal mshift : std_logic_vector(27 downto 0);
  signal dexp : std_logic_vector(4 downto 0);

begin

  comp_exp0: comp_exp port map(a, b, sa, sb, expo, ma, mshift, dexp, comp);

  logshifter0: logshifter port map(mshift, dexp, mb);

end architecture;
