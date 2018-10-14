library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity comp_subn is
  port (a : in std_logic_vector(36 downto 0);
        b : in std_logic_vector(36 downto 0);
        out_a : out std_logic_vector(36 downto 0);    --normal number
        out_b : out std_logic_vector(36 downto 0));   --subnormal number
end entity;

architecture behav of comp_subn is

  signal ea : std_logic_vector(7 downto 0);
  --signal ea : std_logic_vector(7 downto 0);

begin

  ea<=a(35 downto 28);
  --eb<=b(35 downto 28);

  process(a, b, ea)
  begin
    if (ea=X"00") then    --a subnormal
      out_b<=a;
      out_a<=b;
    else                  --b subnormal
      out_b<=b;
      out_a<= a;
    end if;
  end process;

end architecture;
