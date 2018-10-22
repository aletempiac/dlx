library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ComparatorUnit is
  port (A_MSB : in std_logic;
        B_MSB : in std_logic;
        SUBIN : in std_logic_vector(31 downto 0);
        COUT : in std_logic;
        SIGN_UNSIGN : in std_logic;
        OP : in integer range 0 to 5;
        CU_OUT : out std_logic_vector(31 downto 0));
end entity;

architecture Beh of ComparatorUnit is

  signal SUBIN_eq0 : std_logic:='0';

begin

  process(A_MSB, B_MSB, SUBIN_eq0, COUT, SIGN_UNSIGN, OP)
  begin
    CU_OUT<=(others=>'0');
    if ((SIGN_UNSIGN='1') and ((A_MSB xor B_MSB)='1')) then
      case OP is
        when 0 => CU_OUT(0)<='0'; --SES
        when 1 => CU_OUT(0)<='1'; --SNES
        when 2 => CU_OUT(0)<=A_MSB; --SLTS
        when 3 => CU_OUT(0)<=not(A_MSB); --SGTS
        when 4 => CU_OUT(0)<=A_MSB; --SLES
        when 5 => CU_OUT(0)<=not(A_MSB); --SGES
        when others => CU_OUT<=(others=>'0');
      end case;
    else
      case OP is
        when 0 => CU_OUT(0)<=SUBIN_eq0; --SES
        when 1 => CU_OUT(0)<=not(SUBIN_eq0); --SNES
        when 2 => CU_OUT <= not(COUT); --SLTS
        when 3 =>  CU_OUT <= (COUT and not(SUBIN_eq0)); --SGTS
        when 4 =>  CU_OUT <= (not(COUT) or SUBIN_eq0); --SLES
        when 5 =>  CU_OUT <= COUT; --SGES
        when others => CU_OUT<=(others=>'0');
      end case;
    end if;
  end process;

  process(SUBIN)
  begin
    if (SUBIN=X"00000000") then
      SUBIN_eq0<='1';
    else
      SUBIN_eq0<='0';
    end if;
  end process;

end architecture;
