library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity selector is
  port (a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        enable : in std_logic;
        e_data : out std_logic_vector(1 downto 0);
        outa : out std_logic_vector(36 downto 0);
        outb : out std_logic_vector(36 downto 0));
end entity;

architecture behav of selector is

  signal s_a, s_b : std_logic;                        --Sign A and B
  signal e_a, e_b : std_logic_vector(7 downto 0);     --Exp A and B
  signal m_a, m_b : std_logic_vector(22 downto 0);    --Mantissa A and B

begin

  s_a <= a(31);
  s_b <= b(31);
  e_a <= a(30 downto 23);
  e_b <= b(30 downto 23);
  m_a <= a(22 downto 0);
  m_b <= b(22 downto 0);

  process(s_a, s_b, e_a, e_b, m_a, m_b, enable)
  begin
    if (enable='1') then
      outa(36)<=s_a;
      outa(35 downto 28)<=e_a;
      outb(36)<=s_b;
      outb(35 downto 28)<=e_b;

      outa(26 downto 4)<=m_a;
      outa(3 downto 0)<="0000";
      outb(26 downto 4)<=m_b;
      outb(3 downto 0)<="0000";

      if (e_a/=X"00") then
        outa(27)<='1';
      elsif(e_a=X"00") then
        outa(27)<='0';
      end if;

      if (e_b/=X"00") then
        outb(27)<='1';
      elsif(e_b=X"00") then
        outb(27)<='0';
      end if;
    else
  		outa<="-------------------------------------";
  		outb<="-------------------------------------";
    end if;
  end process;

  e_data<="00" when (e_a=X"00" and e_b=X"00" and enable='1') else       --subnormals
          "01" when (e_a/=X"00" and e_b/=X"00" and enable='1') else     --normals
          "10";                                                         --mixed

end architecture;
