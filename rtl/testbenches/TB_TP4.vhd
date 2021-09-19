library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TB_TP4 is
end entity TB_TP4;

architecture rtl of TB_TP4 is
    constant CLK_PER    : time := 20 ns;
    signal ARst_N       : std_logic;
    signal Clk          : std_logic;

    signal BtnIncr      : std_logic;
    signal BtnDecr      : std_logic;

    signal PinBtnIncr   : std_logic;
    signal PinBtnDecr   : std_logic;
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

    uTopTp4De0Nano : entity work.TopTp4De0Nano
        port map (
            PinARst_N   => ARst_N,
            PinClk      => Clk,
            PinBtnIncr  => PinBtnIncr,
            PinBtnDecr  => PinBtnDecr,
            PinLed      => open);
    pRTL: process
    begin
        BtnDecr <= '0';
        BtnIncr <= '0';
        wait for 5*CLK_PER;
        BtnIncr <= '1';
        wait for 3*CLK_PER;
        BtnIncr <= '0';
        wait for 2*CLK_PER;
        BtnIncr <= '1';
        wait for 3*CLK_PER;
        BtnIncr <= '0';
        wait for CLK_PER;
        BtnDecr <= '1';
        wait for 3*CLK_PER;
        BtnDecr <= '0';
        wait;
    end process pRTL;
    PinBtnIncr <= not BtnIncr;
    PinBtnDecr <= not BtnDecr;
end architecture rtl;