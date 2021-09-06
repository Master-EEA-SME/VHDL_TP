library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FsmBtn is
    port (
        ARst_N          : in    std_logic;
        Clk             : in    std_logic;
        Btn_N           : in    std_logic;
        BtnPressEvt     : out   std_logic
    );
end entity FsmBtn;

architecture rtl of FsmBtn is
    type BTN_ST is (ST_RELEASED, ST_PRESSED);
    signal CurrentST    : BTN_ST;
    signal sBtn         : std_logic;
begin
    -- Rendre d'abord le signal Btn_N synchrone pour qu'il soit deterministe partout dans le FPGA
    process (Clk)
    begin
        if rising_edge(Clk) then
            sBtn <= not Btn_N; -- On le complemente pour travailler avec une logique non inversé
        end if;
    end process;
    -- Dans ce process, on decrit directement le bloc F (calcul de l'état suivant) en mettant à jour
    -- directement la variable d'état (bloc M)
    -- L'avantage d'écrire la machine à états de cette façon est que c'est plus compacte et plus rapide
    -- à écrire
    pBlocFM: process(Clk, ARst_N)
    begin
        if ARst_N = '1' then
            CurrentST <= ST_RELEASED;
        elsif rising_edge(Clk) then
            case CurrentST is
                when ST_RELEASED =>
                    if sBtn = '1' then
                        CurrentST <= ST_PRESSED;
                    end if;
                when ST_PRESSED =>
                    if sBtn = '0' then
                        CurrentST <= ST_RELEASED;
                    end if;
                when others =>
            end case;
        end if;
    end process pBlocFM;
    BtnPressEvt <= '1' when CurrentST = ST_RELEASED and sBtn = '1' else '0';    -- On cherche ici le moment où on quitte l'état ST_RELEASED qui correspond au moment où on relâche le bouton.
                                                                                -- La condition lorsque l'on quitte un état est vrai que pendant un coup d'horloge et c'est l'événement qu'on cherche.

    
end architecture rtl;