library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

entity n_case is
  port( a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        enable : out std_logic;
        s : out std_logic_vector(31 downto 0));
end entity n_case;

architecture arch of n_case is

  signal outa, outb : std_logic_vector(2 downto 0);

  signal s_a, s_b : std_logic;                        --Sign A and B
  signal e_a, e_b : std_logic_vector(7 downto 0);     --Exp A and B
  signal m_a, m_b : std_logic_vector(22 downto 0);    --Mantissa A and B

  signal s_s : std_logic;                             --Sign Sum
  signal e_s : std_logic_vector(7 downto 0);          --Exp Sum
  signal m_s : std_logic_vector(22 downto 0);         --Mantissa Sum

begin

  s_a <= a(31);
  s_b <= b(31);
  e_a <= a(30 downto 23);
  e_b <= b(30 downto 23);
  m_a <= a(22 downto 0);
  m_b <= b(22 downto 0);

  outa <= "000" when e_a=X"00" and m_a=0 else                     --zero
          "001" when e_a=X"00" and m_a/=0 else                     --subnormal
          "011" when (e_a/=X"00" and e_a/=X"FF") and m_a/=0 else   --normal
          "100" when e_a=X"FF" and m_a=0 else                     --infinity
          "110" when e_a=X"FF" and m_a/=0 else                     --NaN
          "000";

  outb <= "000" when e_b=X"00" and m_b=0 else                     --zero
          "001" when e_b=X"00" and m_b/=0 else                     --subnormal
          "011" when (e_b/=X"00" and e_b/=X"FF") and m_a/=0 else   --normal
          "100" when e_b=X"FF" and m_b=0 else                     --infinity
          "110" when e_b=X"FF" and m_b/=0 else                     --NaN
          "000";

  enable <= '1' when (outa(0) and outb(0))='1' else '0';

  process(s_a, s_b, outa, outb)
  begin
    --zero
    if (outa="000") then
      s_s<=s_b;
      e_s<=e_b;
      m_s<=m_b;
    elsif (outb="000") then
      s_s<=s_a;
      e_s<=e_a;
      m_s<=m_a;
    end if;
    --infinite
    if (outa(0)='1' and outb="100") then
      s_s<=s_b;
      e_s<=e_b;
      m_s<=m_b;
    elsif (outb(0)='1' and outa="100") then
      s_s<=s_a;
      e_s<=e_a;
      m_s<=m_a;
    end if;

    if ((outa and outb)="100" and s_a=s_b) then
      s_s<=s_a;
      e_s<=e_a;
      m_s<=m_a;
    --NaN
    elsif ((outa and outb)="100" and s_a/=s_b) then
      s_s<='1';
      e_s<=X"FF";
      m_s<="00000000000000000000001";
    end if;
    if (outa="110" or outb="110") then
      s_s<='1';
      e_s<=X"FF";
      m_s<="00000000000000000000001";
    end if;
    --normal/subnormal
    --if (outa(0)='0' and outb(0)='0') then
      --s_s<='-';
      --e_s<="--------";
      --m_s<="-----------------------";
    --end if;

  end process;

  s(31)<=s_s;
  s(30 downto 23)<=e_s;
  s(22 downto 0)<=m_s;

end architecture;
