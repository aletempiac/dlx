library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

entity block_adder is
  port (sa : in std_logic;
        sb : in std_logic;
        a : in std_logic_vector(27 downto 0);
        b : in std_logic_vector(27 downto 0);
        sub_add : in std_logic;
        comp : in std_logic;
        sum_sign : out std_logic;
        sum : out std_logic_vector(27 downto 0);
        cout : out std_logic);
end entity;

architecture Struct of block_adder is

  component signout
    port (sa : in std_logic;
          sb : in std_logic;
          a : in std_logic_vector(27 downto 0);
          b : in std_logic_vector(27 downto 0);
          sub_add : in std_logic;                   --1 for Sub, 0 for Add
          comp : in std_logic;
          aout : out std_logic_vector(27 downto 0);
          bout : out std_logic_vector(27 downto 0);
          sub_add_out : out std_logic;
          sout : out std_logic);
  end component;

  component P4addersubvFP
  	Port(A : in std_logic_vector(27 downto 0);
  	     B : in std_logic_vector(27 downto 0);
  	     sub_add : in std_logic;		--1 for sub, 0 for add
  	     Y : out std_logic_vector(27 downto 0);
  	     Cout : out std_logic);
  end component;

  signal aaux, baux, saux : std_logic_vector(27 downto 0);
  signal sub_add_aux, so_aux, cout_aux : std_logic;

begin

  signout0: signout port map(sa, sb, a, b, sub_add, comp, aaux, baux, sub_add_aux, so_aux);

  P4addersubvFP0: P4addersubvFP port map(aaux, baux, sub_add_aux, saux, cout_aux);

  sum <= ((saux xor X"FFFFFFF") + '1') when ((sub_add_aux and so_aux)='1') else saux; --when a+b and a negative (swapped in signout in order to have the negative number in b)

  cout <= '0' when sub_add_aux='1' else cout_aux; --a subtraction happened

  sum_sign <= so_aux;

end architecture;
