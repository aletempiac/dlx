library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

entity shifter is
  port (R : in std_logic_vector(31 downto 0);
        Offset : in std_logic_vector(4 downto 0);
        Conf : in integer range 0 to 2; --0 for SLL, 1 for SRL, 2 for SRA
        Shift_OUT : out std_logic_vector(31 downto 0));
end entity;

architecture Struct of shifter is

  constant zeros : std_logic_vector(7 downto 0):="00000000";
  signal arithm : std_logic_vector(7 downto 0);
  signal mask00, mask08, mask16, mask24 : std_logic_vector(39 downto 0);
  signal finegrainsel : std_logic_vector(2 downto 0);

  signal grainmask : std_logic_vector(39 downto 0);

begin

  p_arithm: process(R)
  begin
    for i in 0 to 7 loop
      arithm(i)<=R(31);
    end loop;
  end process;

  p_mask00: process(R, Conf, arithm)
  begin
    if (Conf=0) then
      mask00<= R & zeros;
    elsif (Conf=1) then
      mask00<= zeros & R;
    else
      mask00<= arithm & R;
    end if;
  end process;

  p_mask08: process(R, Conf, arithm)
  begin
    if (Conf=0) then
      mask08<= R(23 downto 0) & zeros & zeros;
    elsif (Conf=1) then
      mask08<= zeros & zeros & R(31 downto 8);
    else
      mask08<= arithm & arithm & R(31 downto 8);
    end if;
  end process;

  p_mask16: process(R, Conf, arithm)
  begin
    if (Conf=0) then
      mask16<= R(15 downto 0) & zeros & zeros & zeros;
    elsif (Conf=1) then
      mask16<= zeros & zeros & zeros & R(31 downto 16);
    else
      mask16<= arithm & arithm & arithm & R(31 downto 16);
    end if;
  end process;

  p_mask24: process(R, Conf, arithm)
  begin
    if (Conf=0) then
      mask24<= R(7 downto 0) & zeros & zeros & zeros & zeros;
    elsif (Conf=1) then
      mask24<= zeros & zeros & zeros & zeros & R(31 downto 24);
    else
      mask24<= arithm & arithm & arithm & arithm & R(31 downto 24);
    end if;
  end process;

  p_selgrain: process(mask00, mask08, mask16, mask24, Offset)
  begin
    case Offset(4 downto 3) is
      when "00" => grainmask <= mask00;
      when "01" => grainmask <= mask08;
      when "10" => grainmask <= mask16;
      when others => grainmask <= mask24;
    end case;
  end process;

  finegrainsel <= (not(Offset(2 downto 0)) +1) when (Conf=0) else Offset(2 downto 0);

  p_selfine: process(grainmask, finegrainsel)
  begin
    case finegrainsel is
      when "000" => Shift_OUT<=grainmask(31 downto 0);
      when "001" => Shift_OUT<=grainmask(32 downto 1);
      when "010" => Shift_OUT<=grainmask(33 downto 2);
      when "011" => Shift_OUT<=grainmask(34 downto 3);
      when "100" => Shift_OUT<=grainmask(35 downto 4);
      when "101" => Shift_OUT<=grainmask(36 downto 5);
      when "110" => Shift_OUT<=grainmask(37 downto 6);
      when others => Shift_OUT<=grainmask(38 downto 7);
    end case;
  end process;

end architecture;
