library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity norm is
  port (a : in std_logic_vector(36 downto 0);
        b : in std_logic_vector(36 downto 0);
        ma : out std_logic_vector(36 downto 0);
        mb : out std_logic_vector(36 downto 0));
end entity;

architecture Struct of norm is

  component comp_subn
    port (a : in std_logic_vector(36 downto 0);
          b : in std_logic_vector(36 downto 0);
          out_a : out std_logic_vector(36 downto 0);    --normal number
          out_b : out std_logic_vector(36 downto 0));   --subnormal number
  end component;

  component zero_counter
    port (a : in std_logic_vector(27 downto 0);
          zcount : out std_logic_vector(4 downto 0));
  end component;

  component shift_left
    port (s_in : in std_logic_vector(27 downto 0);
          shft : in std_logic_vector(4 downto 0);
          s_out : out std_logic_vector(27 downto 0));
  end component;

  signal zcount : std_logic_vector(4 downto 0);
  --signal eb : std_logic_vector(7 downto 0);
  signal nb : std_logic_vector(36 downto 0);
  signal mb_aux : std_logic_vector(27 downto 0);

begin

  comp_subn0: comp_subn port map(a, b, ma, nb);
  zero_counter0: zero_counter port map(nb(27 downto 0), zcount);
  shift_left0: shift_left port map(nb(27 downto 0), zcount, mb_aux);

  mb(27 downto 0)<=mb_aux(27 downto 1) & '1';
  mb(35 downto 28)<="000" & zcount;
  mb(36)<=nb(36);

end architecture;
