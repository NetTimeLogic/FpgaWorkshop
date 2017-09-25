library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LedGen is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        ButtonN         : in  std_logic;
        Brightness      : out std_logic_vector(31 downto 0)
    );
end entity;

architecture LedGen_Arch of LedGen is
constant cUpdateRate    : natural := 50*1000*100;

signal ButtonN_f        : std_logic;
signal ButtonN_ff       : std_logic;
signal ButtonNOld       : std_logic;

signal UpdateInc        : natural := 1;
signal UpdateCnt        : natural;
signal UpCountIdx       : natural;
signal Direction        : natural;
signal BrightnessTemp   : std_logic_vector(31 downto 0);

begin
    Brightness <= BrightnessTemp;
    
    process(Clk, ResetN)
    begin
        if(ResetN = '0') then
            ButtonN_f <= '0';
            ButtonN_ff <= '0';
            ButtonNOld <= '0';
            
            UpdateInc <= 1;
            UpdateCnt <= 0;
            UpCountIdx <= 0;
            Direction <= 0;
            BrightnessTemp <= (others => '0');
            
        elsif((Clk'event) and (Clk = '1')) then
            ButtonN_f <= ButtonN;
            ButtonN_ff <= ButtonN_f;
            ButtonNOld <= ButtonN_ff;
        
            if ((ButtonNOld = '1') and (ButtonN_ff = '0')) then
                if (UpdateInc < 16) then
                    UpdateInc <= UpdateInc + 1;
                else
                    UpdateInc <= 1;
                end if;
            end if;
            
            if(UpdateCnt < cUpdateRate-1) then
                UpdateCnt <= UpdateCnt + UpdateInc;
            else
                UpdateCnt <= 0;
                
                for i in 0 to 7 loop
                    if(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) > 0) then
                        BrightnessTemp(((i*4)+3) downto (i*4)) <= std_logic_vector(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) - 1);
                    end if;
                    
                    if(i = UpCountIdx) then
                        if(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) < 16-4) then
                            BrightnessTemp(((i*4)+3) downto (i*4)) <= std_logic_vector(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) + 4);
                        else
                            BrightnessTemp(((i*4)+3) downto (i*4)) <= x"F";
                            if (Direction = 0) then
                                if(i < 7) then
                                    UpCountIdx <= UpCountIdx + 1;
                                else
                                    UpCountIdx <= UpCountIdx - 1;
                                    Direction <= 1;
                                end if;
                            else
                                if(i > 0) then
                                    UpCountIdx <= UpCountIdx - 1;
                                else
                                    UpCountIdx <= UpCountIdx + 1;
                                    Direction <= 0;
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;
            end if;
        end if;
    end process;
    
end LedGen_Arch;
