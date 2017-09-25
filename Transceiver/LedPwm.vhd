library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LedPwm is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : in  std_logic_vector(3 downto 0);
        Led             : out std_logic
    );

end entity;

architecture LedPwm_Arch of LedPwm is
constant cPwmPeriod     : natural := 50*60;

type tLogTable          is array(0 to 15) of natural;

signal PwmPeriodCnt     : natural;
constant LogTable       : tLogTable := (0 => 0,
                                        1 => 18,
                                        2 => 42,
                                        3 => 73,
                                        4 => 113,
                                        5 => 164,
                                        6 => 232,
                                        7 => 319,
                                        8 => 432,
                                        9 => 579,
                                        10 => 770,
                                        11 => 1017,
                                        12 => 1339,
                                        13 => 1756,
                                        14 => 2297,
                                        15 => 3000);
                                        

begin

    process(Clk, ResetN)
    begin
        if(ResetN = '0') then
            PwmPeriodCnt <= 0;
            Led <= '0';
        elsif((Clk'event) and (Clk = '1')) then
            if(PwmPeriodCnt < (cPwmPeriod-1)) then
                PwmPeriodCnt <= PwmPeriodCnt + 1;
            else
                PwmPeriodCnt <= 0;
            end if;
            
            if(PwmPeriodCnt < LogTable(to_integer(unsigned(Brightness)))) then
                Led <= '1';
            else
                Led <= '0';
            end if;
            
        end if;
    end process;
    
end LedPwm_Arch;
