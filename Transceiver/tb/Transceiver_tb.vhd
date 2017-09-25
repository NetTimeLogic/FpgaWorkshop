library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Transceiver_tb is
end entity;

architecture Transceiver_tb_Arch of Transceiver_tb is

component Transmitter is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : in  std_logic_vector(31 downto 0);
        SClk            : out std_logic;
        SEn             : out std_logic;
        SData           : out std_logic
    );
end component;

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
    
    DutTx : Transmitter
    port map
    (
        Clk             => Clk,     
        ResetN          => ResetN,  
        Brightness      => BrightnessTx, 
        SClk            => SClk,
        SEn             => SEn,
        SData           => SData
    );  
    
    DutRx : Receiver
    port map
    (
        Clk             => Clk,     
        ResetN          => ResetN,  
        Brightness      => BrightnessRx, 
        SClk            => SClk,
        SEn             => SEn,
        SData           => SData
    );  
    
end Transceiver_tb_Arch;
