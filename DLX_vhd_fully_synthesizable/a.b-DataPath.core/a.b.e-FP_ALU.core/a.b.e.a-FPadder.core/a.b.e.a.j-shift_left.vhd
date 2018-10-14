library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity shift_left is
  port (s_in : in std_logic_vector(27 downto 0);
        shft : in std_logic_vector(4 downto 0);
        s_out : out std_logic_vector(27 downto 0));
end entity;

architecture Struct of shift_left is

  signal z1, z2, z3, z4, z5 : std_logic_vector(27 downto 0);

  component MUX
    port (a : in std_logic;
          b : in std_logic;
          sel : in std_logic;
          z : out std_logic);
  end component;

  begin

  placemux: for i in 0 to 27 generate
    shift0_0: if (i=0) generate
                shifter0_0: mux port map ('0', s_in(0), shft(0), z1(i));
              end generate;
    shift0_i: if ((i>0) and (i<28)) generate
                shifter0_i: mux port map (s_in(i-1), s_in(i), shft(0), z1(i));
              end generate;

    shift1_0: if ((i>=0) and (i<2)) generate
                shifter1_0: mux port map ('0', z1(i), shft(1), z2(i));
              end generate;
    shift1_i: if ((i>1) and (i<28)) generate
                shifter1_i: mux port map (z1(i-2), z1(i), shft(1), z2(i));
              end generate;

    shift2_0: if ((i>=0) and (i<4)) generate
                shifter2_0: mux port map ('0', z2(i), shft(2), z3(i));
              end generate;
    shift2_i: if ((i>3) and (i<28)) generate
                shifter2_i: mux port map (z2(i-4), z2(i), shft(2), z3(i));
              end generate;

    shift3_0: if ((i>=0) and (i<8)) generate
                shifter3_0: mux port map ('0', z3(i), shft(3), z4(i));
              end generate;
    shift3_i: if ((i>7) and (i<28)) generate
                shifter3_i: mux port map (z3(i-8), z3(i), shft(3), z4(i));
              end generate;

    shift4_0: if ((i>=0) and (i<16)) generate
                shifter4_0: mux port map ('0', z4(i), shft(4), z5(i));
              end generate;
    shift4_i: if ((i>15) and (i<28)) generate
                shifter4_i: mux port map (z4(i-16), z4(i), shft(4), z5(i));
              end generate;
  end generate;

  s_out<=z5;

end architecture;
