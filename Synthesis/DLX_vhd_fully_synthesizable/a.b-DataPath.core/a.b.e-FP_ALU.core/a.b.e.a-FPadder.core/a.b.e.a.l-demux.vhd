library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity demux is
  port (a : in std_logic_vector(36 downto 0);
        b : in std_logic_vector(36 downto 0);
        e_data : in std_logic_vector(1 downto 0);
        na0 : out std_logic_vector(36 downto 0);
        nb0 : out std_logic_vector(36 downto 0);
        na1 : out std_logic_vector(36 downto 0);
        nb1 : out std_logic_vector(36 downto 0);
        na2 : out std_logic_vector(36 downto 0);
        nb2 : out std_logic_vector(36 downto 0));
end entity;

architecture behav of demux is

begin

  process(a, b, e_data)
  begin
    case e_data is
      --subnormals
      when "00" =>  na0<=a;
                    nb0<=b;
                    na1<="-------------------------------------";
                    nb1<="-------------------------------------";
                    na2<="-------------------------------------";
                    nb2<="-------------------------------------";
      --normals
      when "01" =>  na0<="-------------------------------------";
                    nb0<="-------------------------------------";
                    na1<=a;
                    nb1<=b;
                    na2<="-------------------------------------";
                    nb2<="-------------------------------------";
      --mixed
      when "10" =>  na0<="-------------------------------------";
                    nb0<="-------------------------------------";
                    na1<="-------------------------------------";
                    nb1<="-------------------------------------";
                    na2<=a;
                    nb2<=b;
      when others=> na0<="-------------------------------------";
                    nb0<="-------------------------------------";
                    na1<="-------------------------------------";
                    nb1<="-------------------------------------";
                    na2<="-------------------------------------";
                    nb2<="-------------------------------------";
    end case;
  end process;

end architecture;
