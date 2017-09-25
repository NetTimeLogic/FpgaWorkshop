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

component Button is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        ButtonN         : in  std_logic;
        Led             : out std_logic_vector(7 downto 0)
    );
end component;

begin
    
   --Led(3 downto 0) <= (others => not ButtonN) when (ResetN = '1') else (others => '1');
   --Led(7 downto 4) <= (others => ButtonN) when (ResetN = '1') else (others => '1');
    
    Button_Inst : Button
    port map
    (
        Clk             => Clk,    
        ResetN          => ResetN, 
        ButtonN         => ButtonN,
        Led             => Led    
    );    
    
end Top_Arch;
