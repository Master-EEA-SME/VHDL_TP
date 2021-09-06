library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TopTp4De0Nano is
    port (
        PinARst_N   : in    std_logic;
        PinClk      : in    std_logic;
        PinBtnIncr  : in    std_logic;
        PinBtnDecr  : in    std_logic;
        PinLed      : out   std_logic_vector(3 downto 0)
    );
end entity TopTp4De0Nano;

architecture rtl of TopTp4De0Nano is
    signal sBtnIncrEvt  : std_logic;
    signal sBtnDecrEvt  : std_logic;
    signal sEn_Cnt      : std_logic;
    signal sUd_Cnt      : std_logic;
    signal sQ_Cnt       : std_logic_vector(3 downto 0);
begin
    -- Ici on a une autre façon d'instancier un composant sans avoir declarer component. 
    -- Pour pouvoir utiliser cette instanciation, il faut que le composant "FsmBtnFMG" soit dans la librarie work
    -- Quand vous ajoutez un fichier VHDL dans votre projet par défaut il sera dans la librarie work
    uFsmBtnFMG_Incr : entity work.FsmBtn                     -- Machine a état qui va detecter le relâchement du bouton PinBtnIncr 
        port map (
            ARst_N          => PinARst_N,       Clk => PinClk,
            Btn_N           => PinBtnIncr,
            BtnPressEvt     => sBtnIncrEvt);
    uFsmBtnFMG_Decr : entity work.FsmBtn                     -- Machine a état qui va detecter le relâchement du bouton PinBtnDecr
        port map (
            ARst_N          => PinARst_N,       Clk => PinClk,
            Btn_N           => PinBtnDecr,
            BtnPressEvt     => sBtnDecrEvt);
    sEn_Cnt <= '1' when sBtnIncrEvt = '1' and sBtnDecrEvt = '0' else -- On autorise le comptage/decomptage que si sBtnIncrEvt vaut 1 ou
               '1' when sBtnIncrEvt = '0' and sBtnDecrEvt = '1' else -- si sBtnDecrEvt vaut 1 mais
               '0';                                                  -- pas quand sBtnIncrEvt et sBtnDecrEvt valent 1 ou 0 tout les 2
    
    sUd_Cnt <= '1' when sBtnIncrEvt = '1' and sBtnDecrEvt = '0' else -- On met le compteur en incrementation si on appuie sur le bouton d'incrementer 
               '0' when sBtnIncrEvt = '0' and sBtnDecrEvt = '1' else -- On met le compteur en decrementation si on appuie sur le bouton de decrementer
               '0';                                                  -- Valeur par defaut si on appuie sur aucun bouton
    uCnt : entity work.Cnt
        generic map (
            N => 4)
        port map (
            ARst_N  => PinARst_N,       Clk => PinClk,  SRst    => '0',
            En      => sEn_Cnt,         Ud  => sUd_Cnt,
            Q       => sQ_Cnt);
    PinLed <= sQ_Cnt;    
end architecture rtl;