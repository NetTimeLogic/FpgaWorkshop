library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LedGen is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        AxesX           : in std_logic_vector(15 downto 0);
        AxesY           : in std_logic_vector(15 downto 0);
        AxesZ           : in std_logic_vector(15 downto 0);
        Led             : out std_logic_vector(7 downto 0)
    );
end entity;

architecture LedGen_Arch of LedGen is

begin

    process(Clk, ResetN)
    begin
        if(ResetN = '0') then
            Led <= (others => '0');
            
        elsif((Clk'event) and (Clk = '1')) then
        
            if (AxesX(15) = '0') then -- positive
                if ((signed(AxesX(15 downto 4)) >= 0) and
                    (signed(AxesX(15 downto 4)) < 1)) then
                    Led <= "00011000";
                elsif ((signed(AxesX(15 downto 4)) >= 1) and
                    (signed(AxesX(15 downto 4)) < 2)) then
                    Led <= "00010000";
                elsif ((signed(AxesX(15 downto 4)) >= 2) and
                    (signed(AxesX(15 downto 4)) < 3)) then
                    Led <= "00100000";
                elsif ((signed(AxesX(15 downto 4)) >= 3) and
                    (signed(AxesX(15 downto 4)) < 4)) then
                    Led <= "01000000";
                elsif (signed(AxesX(15 downto 4)) >= 4) then
                    Led <= "10000000";
                end if;
            else
                if ((signed(AxesX(15 downto 4)) <= 0) and
                    (signed(AxesX(15 downto 4)) > -1)) then
                    Led <= "00011000";
                elsif ((signed(AxesX(15 downto 4)) <= -1) and
                    (signed(AxesX(15 downto 4)) > -2)) then
                    Led <= "00001000";
                elsif ((signed(AxesX(15 downto 4)) <= -2) and
                    (signed(AxesX(15 downto 4)) > -3)) then
                    Led <= "00000100";
                elsif ((signed(AxesX(15 downto 4)) <= -3) and
                    (signed(AxesX(15 downto 4)) > -4)) then
                    Led <= "00000010";
                elsif (signed(AxesX(15 downto 4)) <= -4) then
                    Led <= "00000001";
                end if;
            end if;    
            
        end if;
    end process;
    
end LedGen_Arch;
