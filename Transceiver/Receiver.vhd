library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Receiver is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : out std_logic_vector(31 downto 0);
        SClk            : in  std_logic;
        SEn             : in  std_logic;
        SData           : in  std_logic
    );
end entity;

architecture Receiver_Arch of Receiver is

signal SClkIntOld       : std_logic;
signal BrightnessInt    : std_logic_vector(31 downto 0);

signal SClk_f           : std_logic;
signal SClk_ff          : std_logic;
signal SEn_f            : std_logic;
signal SEn_ff           : std_logic;
signal SData_f          : std_logic;
signal SData_ff         : std_logic;


begin

    process(Clk, ResetN)
    begin
        if(ResetN = '0') then
            SClkIntOld <= '0';
            BrightnessInt <= (others => '0');
            Brightness <= (others => '0');
            SClk_f <= '0';
            SClk_ff <= '0';
            SEn_f <= '0';
            SEn_ff <= '0';
            SData_f <= '0';
            SData_ff <= '0';
            
        elsif((Clk'event) and (Clk = '1')) then
            SClk_f <= SClk;
            SClk_ff <= SClk_f;
        
            SEn_f <= SEn;
            SEn_ff <= SEn_f;
        
            SData_f <= SData;
            SData_ff <= SData_f;
        
            SClkIntOld <= SClk_ff;
            
            if((SClk_ff = '0') and (SClkIntOld = '1')) then
                if(SEn_ff = '1') then
                    BrightnessInt <= SData_ff & BrightnessInt(31 downto 1);
                else
                    Brightness <= BrightnessInt;
                end if;
            end if;
                        
        end if;
    end process;
    
end Receiver_Arch;
