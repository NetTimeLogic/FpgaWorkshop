library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accelerometer is
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
end entity;

architecture Accelerometer_Arch of Accelerometer is
constant cChipAddr      : std_logic_vector(6 downto 0) := "0011101";
constant cRegAddr       : std_logic_vector(7 downto 0) := x"32";
constant cNrInitBytes   : natural := 11;

type tByteArray         is array(0 to (cNrInitBytes-1)) of std_logic_vector(7 downto 0);

constant cInitAddr      : tByteArray := (0 => x"24",
                                         1 => x"25",
                                         2 => x"26",
                                         3 => x"27",
                                         4 => x"28",
                                         5 => x"29",
                                         6 => x"2C",
                                         7 => x"2E",
                                         8 => x"2F",
                                         9 => x"31",
                                         10 => x"2D");

constant cInitData      : tByteArray := (0 => x"20",
                                         1 => x"03",
                                         2 => x"01",
                                         3 => x"7F",
                                         4 => x"09",
                                         5 => x"46",
                                         6 => x"09",
                                         7 => x"00",
                                         8 => x"00",
                                         9 => x"00",
                                         10 => x"08");

type tState             is (StIdle,
                            StStart,
                            StWriteChipAddress,
                            StWrite,
                            StAcknowledge0,
                            StRegAddress,
                            StAcknowledge1,
                            StRepeatedStart0,
                            StRepeatedStart1,
                            StReadChipAddress,
                            StRead,
                            StAcknowledge2,
                            StData,
                            StAcknowledge3,
                            StStop,
                            StWait);
    
signal State            : tState := StIdle;

signal InitWaitCnt      : natural;
signal InitIndex        : natural;
signal Init             : std_logic := '1';
    
signal SClk             : std_logic; 
signal SClkF            : std_logic; 
signal SClkR            : std_logic; 
signal SClkCnt          : natural := 0; 
signal SClkDlyCnt       : natural := ((10000/2)-200); 
    
signal BitCnt           : natural; 
signal ByteCnt          : natural; 
    
signal SDataOe          : std_logic; 
signal SDataOut         : std_logic; 
signal SDataIn          : std_logic; 
    
--*****************************************************************************************
-- Architecture Implementation
--*****************************************************************************************
begin

    --*************************************************************************************
    -- Concurrent Statements
    --*************************************************************************************
    I2cSData <= SDataOut when (SDataOe = '1') else 'Z';
    
    --*************************************************************************************
    -- Procedural Statements
    --*************************************************************************************
    SClk_Prc : process(Clk, ResetN) is
    begin
        if (ResetN = '0') then
            SClk <= '0';
            SClkR <= '0';
            SClkF <= '0';
            SClkCnt <= 0;
            SClkDlyCnt <= ((10000/2)-200);
            
        elsif ((Clk'event) and (Clk = '1')) then
            SClkR <= '0';
            SClkF <= '0';
            
            if ((SClkCnt + 20) < (10000/2)) then
                SClkCnt <= SClkCnt + 20;
            else
                SClk <= not SClk;
                SClkR <= not SClk; -- rising edge
                SClkCnt <= 0;
            end if;
            
            if ((SClkDlyCnt + 20) < (10000/2)) then
                SClkDlyCnt <= SClkDlyCnt + 20;
            else
                SClkF <= not SClk; -- falling edge delayed
                SClkDlyCnt <= 0;
            end if;
            
        end if;
    end process SClk_Prc;
    
    SData_Prc : process(Clk, ResetN) is
    begin
        if (ResetN = '0') then
            InitWaitCnt <= 0;
            InitIndex <= 0;
            Init <= '1';
            I2cSClk <= '1';
            SDataOut <= '1';  
            SDataOe <= '0';
            BitCnt <= 0;
            ByteCnt <= 0;
            AxesX <= (others => '0');
            AxesY <= (others => '0');
            AxesZ <= (others => '0');
            State <= StIdle;
            
        elsif ((Clk'event) and (Clk = '1')) then
            SDataIn <= I2cSData;
            case (State) is    
                when StIdle =>
                    SDataOut <= '1';  
                    SDataOe <= '0';
                    BitCnt <= 0;
                    if (InitWaitCnt < 50000000) then
                        InitWaitCnt <= InitWaitCnt + 1;
                    else
                        State <= StStart;
                    end if;
                    
                when StStart =>
                    I2cSClk <= '1';
                    if (SClkR = '1') then
                        SDataOut <= '0';  
                        SDataOe <= '1';
                        BitCnt <= 0;
                        State <= StWriteChipAddress;
                    end if;
                    
                when StWriteChipAddress =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        for i in 0 to 6 loop
                            if (i = BitCnt) then
                                SDataOut <= cChipAddr(6-i);  
                                SDataOe <= '1';
                            end if;
                        end loop;
                        if (BitCnt < 6) then
                            BitCnt <= BitCnt + 1;
                        else
                            BitCnt <= 0;
                            State <= StWrite;
                        end if;
                    end if;
                    
                    
                when StWrite =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        SDataOut <= '0'; -- always write  
                        SDataOe <= '1';
                        BitCnt <= 0;
                        State <= StAcknowledge0;
                    end if;
                    
                when StAcknowledge0 =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        SDataOut <= '0';  
                        SDataOe <= '0';
                    elsif (SClkR = '1') then
                        if (SDataOe = '0') then -- this means we are in the condition
                            if (SDataIn = '1') then
                                State <= StStop;
                            else
                                State <= StRegAddress;
                            end if;
                        end if;
                    end if;
                    
                when StRegAddress =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        for i in 0 to 7 loop
                            if (i = BitCnt) then
                                if (Init = '0') then
                                    SDataOut <= cRegAddr(7-i);  
                                else
                                    for j in 0 to (cNrInitBytes-1) loop
                                        if (j = InitIndex) then
                                            SDataOut <= cInitAddr(j)(7-i);  
                                        end if;
                                    end loop;
                                end if;
                                SDataOe <= '1';
                            end if;
                        end loop;
                        if (BitCnt < 7) then
                            BitCnt <= BitCnt + 1;
                        else
                            BitCnt <= 0;
                            State <= StAcknowledge1;
                        end if;
                    end if;
                        
                when StAcknowledge1 =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        SDataOut <= '0';  
                        SDataOe <= '0';
                    elsif (SClkR = '1') then
                        if (SDataOe = '0') then -- this means we are in the condition
                            if (SDataIn = '1') then
                                State <= StStop;
                            else
                                if (Init = '0') then
                                    State <= StRepeatedStart0;
                                else
                                    State <= StData;
                                end if;
                            end if;
                        end if;
                    end if;
                    
                when StRepeatedStart0 =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        SDataOut <= '1';  
                        SDataOe <= '1';
                    elsif (SClkR = '1') then
                        SDataOut <= '1';  
                        SDataOe <= '0';
                        State <= StRepeatedStart1;
                  end if;
                    
                when StRepeatedStart1 =>
                    I2cSClk <= '1';
                    if (SClkR = '1') then
                        SDataOut <= '0';  
                        SDataOe <= '1';
                        
                        BitCnt <= 0;
                        State <= StReadChipAddress;
                    end if;
                    
                when StReadChipAddress =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        for i in 0 to 6 loop
                            if (i = BitCnt) then
                                SDataOut <= cChipAddr(6-i);  
                                SDataOe <= '1';
                            end if;
                        end loop;
                        if (BitCnt < 6) then
                            BitCnt <= BitCnt + 1;
                        else
                            BitCnt <= 0;
                            State <= StRead;
                        end if;
                    end if;
                    
                when StRead =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        SDataOut <= '1'; -- always read  
                        SDataOe <= '1';
                        BitCnt <= 0;
                        ByteCnt <= 0;
                        State <= StAcknowledge2;
                    end if;
                    
                when StAcknowledge2 =>
                    I2cSClk <= SClk;
                    if (SClkF = '1') then
                        SDataOut <= '0';  
                        SDataOe <= '0';
                    elsif (SClkR = '1') then
                        if (SDataOe = '0') then -- this means we are in the condition
                            if (SDataIn = '1') then
                                State <= StStop;
                            else
                                State <= StData;
                            end if;
                        end if;
                    end if;
                                        
                when StData =>
                    I2cSClk <= SClk;
                    if (Init = '0') then
                        if (SClkR = '1') then
                            SDataOe <= '0';
                            for i in 0 to 7 loop
                                if (i = BitCnt) then
                                    for j in 0 to 5 loop
                                        if (j = ByteCnt) then
                                            if (j < 2) then
                                                AxesX(((j-0)*8)+7-i) <= SDataIn;
                                            elsif (j < 4) then
                                                AxesY(((j-2)*8)+7-i) <= SDataIn;
                                            elsif (j < 6) then
                                                AxesZ(((j-4)*8)+7-i) <= SDataIn;
                                            end if;
                                        end if;
                                    end loop;
                                end if;
                            end loop;
                            if (BitCnt < 7) then
                                BitCnt <= BitCnt + 1;
                            else
                                BitCnt <= 0;
                                ByteCnt <= ByteCnt + 1;
                                State <= StAcknowledge3;
                            end if;
                        end if;
                    else
                        if (SClkF = '1') then
                            SDataOe <= '1';
                            for i in 0 to 7 loop
                                if (i = BitCnt) then
                                    for j in 0 to (cNrInitBytes-1) loop
                                        if (j = InitIndex) then
                                            SDataOut <= cInitData(j)(7-i);  
                                        end if;
                                    end loop;
                                    SDataOe <= '1';
                                end if;
                            end loop;
                            if (BitCnt < 7) then
                                BitCnt <= BitCnt + 1;
                            else
                                BitCnt <= 0;
                                State <= StAcknowledge3;
                            end if;
                        end if;
                    end if;
                                        
                when StAcknowledge3 =>
                    I2cSClk <= SClk;
                    if (Init = '0') then
                        if (SClkF = '1') then
                            if (SDataOe = '1') then -- this means we are in the condition
                                SDataOut <= '0';
                                SDataOe <= '0';
                                BitCnt <= 0;
                                State <= StData;
                            else
                                if (ByteCnt < 5) then
                                    SDataOut <= '0'; -- acknowledge with ACK
                                else
                                    SDataOut <= '1'; -- end with NACK
                                end if;
                                SDataOe <= '1';
                            end if;
                        elsif (SClkR = '1') then
                            if (ByteCnt >= 5) then
                                SDataOut <= '1'; -- end with NACK
                                SDataOe <= '0';
                                State <= StStop;
                            else
                                SDataOut <= '0'; -- acknowledge with ACK
                                SDataOe <= '1';
                            end if;
                        end if;
                    else
                        if (SClkF = '1') then
                            SDataOut <= '0';  
                            SDataOut <= '0';
                        elsif (SClkR = '1') then
                            if (SDataOut = '0') then -- this means we are in the condition
                                if (SDataIn = '1') then
                                    State <= StStop;
                                else
                                    State <= StStop;
                                end if;
                            end if;
                        end if;
                    end if;
                                        
                when StStop =>
                    if (SClkF = '1') then
                        SDataOe <= '1';
                        if (SDataOe = '1') then -- this means we are in the condition
                            I2cSClk <= '1';
                            SDataOut <= '1'; -- it has to be a zero to one transition 
                            SDataOe <= '0';
                            BitCnt <= 0;
                            State <= StWait;
                        else
                            I2cSClk <= '0';
                            SDataOut <= '0'; -- it has to be a zero to one transition 
                            SDataOe <= '1';
                        end if;
                        
                    elsif (SClkR = '1') then
                        I2cSClk <= '1';
                        SDataOut <= '0';  
                        SDataOe <= '1';
                    end if;
                
                when StWait =>
                    if (SClkF = '1') then
                        SDataOut <= '1';  
                        SDataOe <= '0';
                        if (BitCnt < 2) then -- two additional waits
                            BitCnt <= BitCnt + 1;
                        else
                            BitCnt <= 0;
                            if (InitIndex < (cNrInitBytes-1)) then
                                InitIndex <= InitIndex + 1;
                                Init <= '1';
                            else
                                Init <= '0';
                            end if;                    
                            State <= StIdle;
                        end if;
                    end if;
                    
                when others =>
            end case;
            
        end if;
    end process SData_Prc;
    
end architecture Accelerometer_Arch;