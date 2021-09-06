library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TopTp3De0Nano is
    port (
        PinARst_N   : in    std_logic;
        PinClk      : in    std_logic;
        PinLed      : out   std_logic_vector(3 downto 0)
    );
end entity TopTp3De0Nano;

architecture rtl of TopTp3De0Nano is
    component CntCascade
        port (
            ARst_N  : in    std_logic;
            Clk     : in    std_logic;
            Q       : out   std_logic_vector(3 downto 0)
        );
    end component;
    signal Q_CntCascade : std_logic_vector(3 downto 0);
begin
    
    uCntCascade : CntCascade
        port map (
            ARst_N  => PinARst_N,   Clk => PinClk, 
            Q       => Q_CntCascade);
    PinLed <= Q_CntCascade;
end architecture rtl;