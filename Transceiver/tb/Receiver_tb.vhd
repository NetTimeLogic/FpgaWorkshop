library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Receiver_tb is
end entity;

architecture Receiver_tb_Arch of Receiver_tb is

component Receiver is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : out std_logic_vector(31 downto 0);
        SClk            : in  std_logic;
        SEn             : in  std_logic;
        SData           : in  std_logic
    );
end component;

signal Clk              : std_logic;
signal ResetN           : std_logic;
signal BrightnessTx     : std_logic_vector(31 downto 0);
signal BrightnessRx     : std_logic_vector(31 downto 0);
signal SClk             : std_logic;
signal SEn              : std_logic;
signal SData            : std_logic;

begin

    process
    begin
        Clk <= '0';
        loop
            wait for 10 ns;
            Clk <= not Clk;
        end loop;
        wait;
    end process;
    
    process
    begin
        ResetN <= '0';
        wait for 300 ns;
        ResetN <= '1';
        wait;
    end process;
        
    process
    begin
        BrightnessTx <= x"00000001";
        wait until (ResetN'event and (ResetN = '1'));
        loop
            wait until (SEn'event and (SEn = '0'));
            BrightnessTx <= std_logic_vector(unsigned(BrightnessTx) + 1);
        end loop;
        wait;
    end process;
        
    process
    begin
        SClk <= '0';
        loop
            wait for 500 ns;
            SClk <= not SClk;
        end loop;
        wait;
    end process;
    
    process
    begin
        SEn <= '0';
        SData <= '0';
        wait until (ResetN'event and (ResetN = '1'));
        loop
            wait for 1 ms;
            for i in 0 to 31 loop
                wait until (SClk'event and (SClk = '1'));
                SEn <= '1';
                SData <= BrightnessTx(i);
            end loop;    
            wait until (SClk'event and (SClk = '1'));
            SEn <= '0';
            SData <= '0';
        end loop;
        wait;
    end process;
    
    process
    variable BrightnessRxTemp    : std_logic_vector(31 downto 0);
    begin
        BrightnessRxTemp := (others => '0');
        wait until (ResetN'event and (ResetN = '1'));
        loop
            wait until (BrightnessRx'event);
            BrightnessRxTemp := std_logic_vector(unsigned(BrightnessRxTemp) + 1);
            assert (unsigned(BrightnessRxTemp) = unsigned(BrightnessRx))
            report "BrightnessRx value does not match"
            severity error;
        end loop;
        wait;
    end process;
    
    Dut : Receiver
    port map
    (
        Clk             => Clk,     
        ResetN          => ResetN,  
        Brightness      => BrightnessRx, 
        SClk            => SClk,
        SEn             => SEn,
        SData           => SData
    );  
    
end Receiver_tb_Arch;
