library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity FPadder is
  port (Clk : in std_logic;
        Res : in std_logic;
        a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        sub_add : in std_logic;
        result : out std_logic_vector(31 downto 0));
end entity;

architecture struct of FPadder is

  component n_case is
    port( a : in std_logic_vector(31 downto 0);
          b : in std_logic_vector(31 downto 0);
          enable : out std_logic;
          s : out std_logic_vector(31 downto 0));
  end component n_case;

  component preadder is
    port (a : in std_logic_vector(31 downto 0);
          b : in std_logic_vector(31 downto 0);
          enable : in std_logic;
          sa : out std_logic;
          sb : out std_logic;
          c : out std_logic;
          eout : out std_logic_vector(7 downto 0);
          maout : out std_logic_vector(27 downto 0);
          mbout : out std_logic_vector(27 downto 0));
  end component;

  component block_adder is
    port (sa : in std_logic;
          sb : in std_logic;
          a : in std_logic_vector(27 downto 0);
          b : in std_logic_vector(27 downto 0);
          sub_add : in std_logic;
          comp : in std_logic;
          sum_sign : out std_logic;
          sum : out std_logic_vector(27 downto 0);
          cout : out std_logic);
  end component;

  component norm_vector is
    port (ss : in std_logic;
          es : in std_logic_vector(7 downto 0);
          mms : in std_logic_vector(27 downto 0);
          co : in std_logic;
          n : out std_logic_vector(31 downto 0));
  end component;

  component muxFPadder is
    port (n1 : in std_logic_vector(31 downto 0); --adder number
          n2 : in std_logic_vector(31 downto 0); --ncase number
          sel : in std_logic;
          res : out std_logic_vector(31 downto 0));
  end component;

  signal ma_aux, mb_aux, mout_aux : std_logic_vector(27 downto 0);
  signal sa_aux, sb_aux, s_aux : std_logic;
  signal eout_aux : std_logic_vector(7 downto 0);
  signal comp_aux, carry_aux, enable_aux : std_logic;
  signal ncase, nadder : std_logic_vector(31 downto 0);

------------For Pipeline--------
  signal ncase_clk1, ncase_clk2 : std_logic_vector(31 downto 0);
  signal sa_clk, sb_clk, sub_add_clk, comp_clk, s_clk, carry_clk, enable_clk1, enable_clk2 : std_logic;
  signal eout_clk1, eout_clk2 : std_logic_vector(7 downto 0);
  signal ma_clk, mb_clk, mout_clk : std_logic_vector(27 downto 0);

begin

----------------------First Stage-----------------------------------------------------
  n_case0: n_case port map(a, b, enable_aux, ncase);

  preadder0: preadder port map(a, b, enable_aux, sa_aux, sb_aux, comp_aux, eout_aux, ma_aux, mb_aux);
--------------------------------------------------------------------------------------
----------------------Second Stage----------------------------------------------------
  block_adder0: block_adder port map(sa_clk, sb_clk, ma_clk, mb_clk, sub_add_clk, comp_clk, s_aux, mout_aux, carry_aux);
--------------------------------------------------------------------------------------
----------------------Third Stage-----------------------------------------------------
  norm_vector0: norm_vector port map(s_clk, eout_clk2, mout_clk, carry_clk, nadder);

  muxFPadder0: muxFPadder port map(nadder, ncase_clk2, enable_clk2, result);
--------------------------------------------------------------------------------------

  process(Clk, Res)
  begin
    if (Res='0') then
      ncase_clk1<=(others=>'0');
      ncase_clk2<=(others=>'0');
      sa_clk<='0';
      sb_clk<='0';
      sub_add_clk<='0';
      comp_clk<='0';
      s_clk<='0';
      carry_clk<='0';
      eout_clk1<=(others=>'0');
      eout_clk2<=(others=>'0');
      ma_clk<=(others=>'0');
      mb_clk<=(others=>'0');
      mout_clk<=(others=>'0');
      enable_clk1<='0';
      enable_clk2<='0';
    elsif (Clk='1' and Clk'event) then
      ncase_clk1<=ncase;
      ncase_clk2<=ncase_clk1;
      sa_clk<=sa_aux;
      sb_clk<=sb_aux;
      sub_add_clk<=sub_add;
      comp_clk<=comp_aux;
      s_clk<=s_aux;
      carry_clk<=carry_aux;
      eout_clk1<=eout_aux;
      eout_clk2<=eout_clk1;
      ma_clk<=ma_aux;
      mb_clk<=mb_aux;
      mout_clk<=mout_aux;
      enable_clk1<=enable_aux;
      enable_clk2<=enable_clk1;
    end if;
  end process;

end architecture;
