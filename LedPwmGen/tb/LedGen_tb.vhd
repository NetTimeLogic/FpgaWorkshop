library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LedGen_tb is
end entity;

architecture LedGen_tb_Arch of LedGen_tb is

component LedGen is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        ButtonN         : in  std_logic;
        Brightness      : out std_logic_vector(31 downto 0)
    );
end component;

signal Clk              : std_logic;
signal ResetN           : std_logic;
signal Brightness       : std_logic_vector(31 downto 0);

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
        
    Dut : LedGen
    port map
    (
        Clk             => Clk,     
        ResetN          => ResetN,  
        ButtonN         => '1',
        Brightness      => Brightness 
    );  
    
end LedGen_tb_Arch;
