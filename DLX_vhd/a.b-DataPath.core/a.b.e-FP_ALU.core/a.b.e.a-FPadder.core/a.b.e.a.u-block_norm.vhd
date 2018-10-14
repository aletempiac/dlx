library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

entity block_norm is
  port (s : in std_logic_vector(27 downto 0);
        e : in std_logic_vector(7 downto 0);
        co : in std_logic;
        mantissa : out std_logic_vector(22 downto 0);
        exponent : out std_logic_vector(7 downto 0));
end entity;

architecture struct of block_norm is

  component zero_counter
    port (a : in std_logic_vector(27 downto 0);
          zcount : out std_logic_vector(4 downto 0));
  end component;

  component shift_left is
    port (s_in : in std_logic_vector(27 downto 0);
          shft : in std_logic_vector(4 downto 0);
          s_out : out std_logic_vector(27 downto 0));
  end component;

  component round is
    port (a : in std_logic_vector(27 downto 0);
          s : out std_logic_vector(22 downto 0));
  end component;

  signal zcount_aux, shift : std_logic_vector(4 downto 0);
  signal num : std_logic_vector(27 downto 0);

begin

  zero_counter0: zero_counter port map(s, zcount_aux);

  shift_left0: shift_left port map(s, shift, num);

  round0: round port map(num, mantissa);

  process(s, e, co, zcount_aux)
  begin
    if (e>zcount_aux) then    --normal
      shift<=zcount_aux;
      exponent<=e-zcount_aux+co;
    elsif (e<zcount_aux) then --subnormal
      shift<=e(4 downto 0);
      exponent<=X"00";
    else                      --normal
      shift<=zcount_aux;
      exponent<=X"01";
    end if;
  end process;

end architecture;
