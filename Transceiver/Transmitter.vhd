library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Transmitter is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : in  std_logic_vector(31 downto 0);
        SClk            : out std_logic;
        SEn             : out std_logic;
        SData           : out std_logic
    );
end entity;

architecture Transmitter_Arch of Transmitter is
constant cSClkPeriod    : natural := 50;
constant cSIdleTime     : natural := 50*1000;
type tState             is (StIdle, StSend);

signal SBitCnt          : natural;
signal SIdleCnt         : natural;
signal SClkCnt          : natural;
signal SClkInt          : std_logic;
signal SClkIntOld       : std_logic;
signal BrightnessInt    : std_logic_vector(31 downto 0);
signal State            : tState;

begin

    SClk <= SClkInt;
    
    process(Clk, ResetN)
    begin
        if(ResetN = '0') then
            SClkInt <= '0';
            SClkIntOld <= '0';
            SEn <= '0';
            SData <= '0';
            SClkCnt <= 0;
            SBitCnt <= 0;
            SIdleCnt <= 0;
            BrightnessInt <= (others => '0');
            State <= StIdle;
            
        elsif((Clk'event) and (Clk = '1')) then
            SClkIntOld <= SClkInt;
            
            if(SClkCnt < (cSClkPeriod/2)-1) then
                SClkCnt <= SClkCnt + 1;
            else
                SClkInt <= not SClkInt;
                SClkCnt <= 0;
            end if;
            
            case State is
                when StIdle =>
                    SEn <= '0';
                    SData <= '0';
                    if(SIdleCnt < (cSIdleTime-1)) then
                        SIdleCnt <= SIdleCnt + 1;
                    else
                        SIdleCnt <= 0;
                        BrightnessInt <= Brightness;
                        SBitCnt <= 0;
                        State <= StSend;
                    end if;
                    
                when StSend =>
                    if((SClkInt = '1') and (SClkIntOld = '0')) then
                        SEn <= '1';
                        for i in 0 to 31 loop
                            if(i = SBitCnt) then
                                SData <= BrightnessInt(i);
                            end if;
                        end loop;
                        SBitCnt <= SBitCnt + 1;
                        if(SBitCnt = 32) then
                            State <= StIdle;
                        end if;
                    end if;
                    
                when others =>
                    State <= StIdle;
            end case;
        end if;
    end process;
    
end Transmitter_Arch;
