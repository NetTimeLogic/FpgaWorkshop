library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Button is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        ButtonN         : in  std_logic;
        Led             : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Button_Arch of Button is

signal ButtonN_f        : std_logic;
signal ButtonN_ff       : std_logic;
signal ButtonNOld       : std_logic;

signal LedTemp          : std_logic_vector(7 downto 0);

begin
    Led <= LedTemp;
    
    process(Clk, ResetN)
    begin
        if(ResetN = '0') then
            ButtonN_f <= '0';
            ButtonN_ff <= '0';
            ButtonNOld <= '0';
            LedTemp <= (others => '0');
            
        elsif((Clk'event) and (Clk = '1')) then
            ButtonN_f <= ButtonN;
            ButtonN_ff <= ButtonN_f;
            ButtonNOld <= ButtonN_ff;
        
            if ((ButtonNOld = '1') and (ButtonN_ff = '0')) then
                LedTemp <= std_logic_vector(unsigned(LedTemp) + 1);
            end if;
            
        end if;
    end process;
    
end Button_Arch;
