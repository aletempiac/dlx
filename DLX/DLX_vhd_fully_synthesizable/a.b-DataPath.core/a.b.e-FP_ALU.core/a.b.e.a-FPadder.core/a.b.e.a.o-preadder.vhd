library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity preadder is
  port (a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        enable : in std_logic;
        sa : out std_logic;
        sb : out std_logic;
        c : out std_logic;
        eout : out std_logic_vector(7 downto 0);
        maout : out std_logic_vector(27 downto 0);
        mbout : out std_logic_vector(27 downto 0));
end entity;

architecture Struct of preadder is

  component n_normal
    port (a : in std_logic_vector(36 downto 0);
          b : in std_logic_vector(36 downto 0);
          comp : out std_logic;
          sa : out std_logic;
          sb : out std_logic;
          expo : out std_logic_vector(7 downto 0);
          ma : out std_logic_vector(27 downto 0);
          mb : out std_logic_vector(27 downto 0));
  end component;

  component mux_ns
    port (nora : in std_logic_vector(36 downto 0); --Normal a
          norb : in std_logic_vector(36 downto 0); --Normal b
          mixa : in std_logic_vector(36 downto 0); --Mixed a
          mixb : in std_logic_vector(36 downto 0); --Mixed b
          e_data : in std_logic_vector(1 downto 0);
          a : out std_logic_vector(36 downto 0);
          b : out std_logic_vector(36 downto 0));
  end component;

  component demux
    port (a : in std_logic_vector(36 downto 0);
          b : in std_logic_vector(36 downto 0);
          e_data : in std_logic_vector(1 downto 0);
          na0 : out std_logic_vector(36 downto 0);
          nb0 : out std_logic_vector(36 downto 0);
          na1 : out std_logic_vector(36 downto 0);
          nb1 : out std_logic_vector(36 downto 0);
          na2 : out std_logic_vector(36 downto 0);
          nb2 : out std_logic_vector(36 downto 0));
  end component;

  component mux_adder
    port (norsa : in std_logic;                           --Sign A normal
          norsb : in std_logic;                           --Sign B normal
          subsa : in std_logic;                           --Sign A subnormal
          subsb : in std_logic;                           --Sign B subnormal
          compn : in std_logic;                           --Comparison normal numbers
          comps : in std_logic;                           --Comparison subnormal numbers
          nore : in std_logic_vector(7 downto 0);         --Exponent normal
          sube : in std_logic_vector(7 downto 0);         --Exponent subnormals
          norma : in std_logic_vector(27 downto 0);       --Mantissa normal A
          normb : in std_logic_vector(27 downto 0);       --Mantissa normal B
          subma : in std_logic_vector(27 downto 0);       --Mantissa subnormal A
          submb : in std_logic_vector(27 downto 0);       --Mantissa subnormal B
          e_data : in std_logic_vector(1 downto 0);
          sa : out std_logic;                             --Sign A
          sb : out std_logic;                             --Sign B
          c : out std_logic;                              --Comparison
          e : out std_logic_vector(7 downto 0);           --Exponent output
          a : out std_logic_vector(27 downto 0);          --Mantissa A
          b : out std_logic_vector(27 downto 0));         --Mantissa B
  end component;

  component norm
    port (a : in std_logic_vector(36 downto 0);
          b : in std_logic_vector(36 downto 0);
          ma : out std_logic_vector(36 downto 0);
          mb : out std_logic_vector(36 downto 0));
  end component;

  component n_subn
    port (a : in std_logic_vector(36 downto 0);
          b : in std_logic_vector(36 downto 0);
          comp : out std_logic;
          sa : out std_logic;
          sb : out std_logic;
          expo : out std_logic_vector(7 downto 0);
          ma : out std_logic_vector(27 downto 0);
          mb : out std_logic_vector(27 downto 0));
  end component;

  component selector
    port (a : in std_logic_vector(31 downto 0);
          b : in std_logic_vector(31 downto 0);
          enable : in std_logic;
          e_data : out std_logic_vector(1 downto 0);
          outa : out std_logic_vector(36 downto 0);
          outb : out std_logic_vector(36 downto 0));
  end component;


  signal na_out_s, nb_out_s : std_logic_vector(36 downto 0);
  signal a_sub, b_sub : std_logic_vector(36 downto 0);
  signal a_nor, b_nor : std_logic_vector(36 downto 0);
  signal a_mix, b_mix : std_logic_vector(36 downto 0);
  signal mixaaux, mixbaux : std_logic_vector(36 downto 0);
  signal amux, bmux : std_logic_vector(36 downto 0);
  signal sanor, sbnor, sasub, sbsub, ncomp, scomp : std_logic;
  signal enor, esub : std_logic_vector(7 downto 0);
  signal manor, mbnor, masub, mbsub : std_logic_vector(27 downto 0);
  signal edata : std_logic_vector(1 downto 0);

begin

  n_normal0: n_normal port map(amux, bmux, ncomp, sanor, sbnor, enor, manor, mbnor);

  n_subn0: n_subn port map(a_sub, b_sub, scomp, sasub, sbsub, esub, masub, mbsub);

  norm0: norm port map(a_mix, b_mix, mixaaux, mixbaux);

  demux0: demux port map(na_out_s, nb_out_s, edata, a_sub, b_sub, a_nor, b_nor, a_mix, b_mix);

  mux_ns0: mux_ns port map(a_nor, b_nor, mixaaux, mixbaux, edata, amux, bmux);

  selector0: selector port map(a, b, enable, edata, na_out_s, nb_out_s);

  mux_adder0: mux_adder port map(sanor, sbnor, sasub, sbsub, ncomp, scomp, enor, esub, manor,
                                mbnor, masub, mbsub, edata, sa, sb, c, eout, maout, mbout);

end architecture;
