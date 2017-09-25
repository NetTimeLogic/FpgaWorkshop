library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Button_tb is
end entity;

architecture Button_tb_Arch of Button_tb is

component Button is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        ButtonN         : in  std_logic;
        Led             : out std_logic_vector(7 downto 0)
    );
end component;

signal Clk              : std_logic;
signal ResetN           : std_logic;
signal ButtonN          : std_logic;
signal Led              : std_logic_vector(7 downto 0); 

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
        ButtonN <= '1';
        loop
            wait for 1000 ns;
            ButtonN <= not ButtonN;
        end loop;
        wait;
    end process;
    
    process
    variable LedTemp    : std_logic_vector(7 downto 0);
    begin
        LedTemp := (others => '0');
        wait until (ResetN'event and (ResetN = '1'));
        loop
            wait until (Led'event);
            LedTemp := std_logic_vector(unsigned(LedTemp) + 1);
            assert (unsigned(LedTemp) = unsigned(Led))
            report "Led value does not match"
            severity error;
        end loop;
        wait;
    end process;
        
    Dut : Button
    port map
    (
        Clk             => Clk,    
        ResetN          => ResetN, 
        ButtonN         => ButtonN,
        Led             => Led    
    );    
    
end Button_tb_Arch;
