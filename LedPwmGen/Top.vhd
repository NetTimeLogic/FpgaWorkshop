library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        ButtonN         : in  std_logic;
        Led             : out std_logic_vector(7 downto 0)
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
        ButtonN         : in  std_logic;
        Brightness      : out std_logic_vector(31 downto 0)
    );
end component;

signal Brightness       : std_logic_vector(31 downto 0);

begin
    
    LedPwm_Array : for i in 0 to 7 generate
    begin
        LedPwm_Inst : LedPwm
            port map
            (
                Clk         => Clk,
                ResetN      => ResetN,
                Brightness  => Brightness(((i*4)+3) downto (i*4)),
                Led         => Led(i)
            );
    end generate LedPwm_Array;

    LedGen_Inst : LedGen
    port map
    (
        Clk         => Clk,
        ResetN      => ResetN,
        ButtonN     => ButtonN,
        Brightness  => Brightness
    );
    
end Top_Arch;
