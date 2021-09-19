library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TB_TP3 is
end entity TB_TP3;

architecture rtl of TB_TP3 is
    constant CLK_PER    : time := 20 ns;
    signal ARst_N       : std_logic;
    signal Clk          : std_logic;
begin
    
    pGenARst_N: process
    begin
        ARst_N <= '0';
        wait for 63 ns;
        ARst_N <= '1';
        wait;
    end process pGenARst_N;
    
    pGenClk: process
    begin
        Clk <= '1';
        wait for CLK_PER / 2;
        Clk <= '0';
        wait for CLK_PER / 2;
    end process pGenClk;

    uTopTp3De0Nano : entity work.TopTp3De0Nano
        port map (
            PinARst_N   => ARst_N,
            PinClk      => Clk,
            PinLed      => open);
end architecture rtl;