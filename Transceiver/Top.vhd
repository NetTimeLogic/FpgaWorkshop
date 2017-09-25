library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        ButtonN         : in  std_logic;
        Led             : out std_logic_vector(7 downto 0);
        SClkOut         : out std_logic;
        SEnOut          : out std_logic;
        SDataOut        : out std_logic;
        SClkIn          : in  std_logic;
        SEnIn           : in  std_logic;
        SDataIn         : in  std_logic

    );
end entity;

architecture Top_Arch of Top is

component LedPwm is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : in  std_logic_vector(3 downto 0);
        Led             : out std_logic
    );
end component;

component LedGen is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : out std_logic_vector(31 downto 0)
    );
end component;

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

signal BrightnessRx     : std_logic_vector(31 downto 0);
signal BrightnessTx     : std_logic_vector(31 downto 0);

begin
    
    LedPwm_Array : for i in 0 to 7 generate
    begin
        LedPwm_Inst : LedPwm
            port map
            (
                Clk         => Clk,
                ResetN      => ResetN,
                Brightness  => BrightnessRx(((i*4)+3) downto (i*4)),
                Led         => Led(i)
            );
    end generate LedPwm_Array;

    LedGen_Inst : LedGen
    port map
    (
        Clk         => Clk,
        ResetN      => ResetN,
        Brightness  => BrightnessTx
    );
    
    Transmitter_Inst : Transmitter
    port map
    (
        Clk         => Clk,
        ResetN      => ResetN,
        Brightness  => BrightnessTx,
        SClk        => SClkOut,
        SEn         => SEnOut,  
        SData       => SDataOut
    );
    
    Receiver_Inst : Receiver
    port map
    (
        Clk         => Clk,
        ResetN      => ResetN,
        Brightness  => BrightnessRx,
        SClk        => SClkIn,
        SEn         => SEnIn,   
        SData       => SDataIn
    );
    
end Top_Arch;
