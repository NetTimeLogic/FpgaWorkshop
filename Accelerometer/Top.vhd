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
        I2cEn           : out std_logic;
        I2cSClk         : out std_logic;
        I2cSData        : inout std_logic
    );
end entity;

architecture Top_Arch of Top is

component Accelerometer is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        AxesX           : out std_logic_vector(15 downto 0);
        AxesY           : out std_logic_vector(15 downto 0);
        AxesZ           : out std_logic_vector(15 downto 0);
        I2cSClk         : out std_logic;
        I2cSData        : inout std_logic
    );
end component;

component LedGen is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        AxesX           : in std_logic_vector(15 downto 0);
        AxesY           : in std_logic_vector(15 downto 0);
        AxesZ           : in std_logic_vector(15 downto 0);
        Led             : out std_logic_vector(7 downto 0)
    );
end component;

signal AxesX            : std_logic_vector(15 downto 0);
signal AxesY            : std_logic_vector(15 downto 0);
signal AxesZ            : std_logic_vector(15 downto 0);

begin
    I2cEn <= '1';
    
    Accelerometer_Inst : Accelerometer 
    port map
    (
        Clk             => Clk,     
        ResetN          => ResetN,  
        AxesX           => AxesX,   
        AxesY           => AxesY,   
        AxesZ           => AxesZ,   
        I2cSClk         => I2cSClk, 
        I2cSData        => I2cSData
    );

    LedGen_Inst : LedGen
    port map
    (
        Clk             => Clk,
        ResetN          => ResetN,
        AxesX           => AxesX,
        AxesY           => AxesY,
        AxesZ           => AxesZ,
        Led             => Led
    );
    
end Top_Arch;
