library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FsmBtnFMG is
    port (
        ARst_N          : in    std_logic;
        Clk             : in    std_logic;
        Btn_N           : in    std_logic;
        BtnPressEvt     : out   std_logic
    );
end entity FsmBtnFMG;

architecture rtl of FsmBtnFMG is
    type BTN_ST is (ST_RELEASED, ST_PRESSED);
    signal CurrentST, NextST : BTN_ST;
    signal sBtn     : std_logic;
begin
    -- Rendre d'abord le signal Btn_N synchrone pour qu'il soit deterministe partout dans le FPGA
    process (Clk)
    begin
        if rising_edge(Clk) then
            sBtn <= not Btn_N; -- On le complemente pour travailler avec une logique non inversé
        end if;
    end process;
    -- Le désavantage d'écrire l'évolution de la machine à états de cette façon est qu'il faut lister
    -- tous les signaux de sensibilité. Si on modifie la machine à états, il faut reverifier la liste
    -- de sensibilité
    pBlocF: process(CurrentST, sBtn)
    begin
        case CurrentST is
            when ST_RELEASED =>
                if sBtn = '1' then
                    NextST <= ST_PRESSED;
                else
                    NextST <= CurrentST;
                end if;
            when ST_PRESSED =>
                if sBtn = '0' then
                    NextST <= ST_RELEASED;
                else
                    NextST <= CurrentST;
                end if;
            when others =>
        end case;
    end process pBlocF;
    pBlocM: process(Clk, ARst_N)
    begin
        if ARst_N = '0' then
            CurrentST <= ST_RELEASED;
        elsif rising_edge(Clk) then
            CurrentST <= NextST;
        end if;
    end process pBlocM;
    BtnPressEvt <= '1' when CurrentST = ST_RELEASED and sBtn = '1' else '0';    -- On cherche ici le moment où on quitte l'état ST_RELEASED qui correspond au moment où on relâche le bouton.
                                                                                -- La condition lorsque l'on quitte un état est vrai que pendant un coup d'horloge et c'est l'événement qu'on cherche.
    
end architecture rtl;