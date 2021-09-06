library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ExempleMae is
    port (
        ARst_N  : in    std_logic;
        Clk     : in    std_logic;
        E1, E2  : in    std_logic;
        Q1, Q2  : out   std_logic
    );
end entity ExempleMae;

architecture rtl of ExempleMae is
    type STATES_ST is (ST_A, ST_B, ST_C, ST_D);
    signal CurrentST, NextST    : STATES_ST;
begin

    pBlocF: process(CurrentST, E1, E2)
    begin
        case CurrentST is
            when ST_A =>
                if E1 = '1' then
                    NextST <= ST_B;
                else
                    NextST <= CurrentST;
                end if; 
            when ST_B =>
                if E2 = '1' then
                    NextST <= ST_C;
                else
                    NextST <= ST_D;
                end if;
            when ST_C =>
                if E2 = '0' then
                    NextST <= ST_D;
                else
                    NextST <= CurrentST;
                end if;
            when ST_D =>
                if E1 = '0' then
                    NextST <= ST_A;
                else
                    NextST <= CurrentST;
                end if;
            when others =>
        end case;
    end process pBlocF;

    pBlocM: process(Clk, ARst_N)
    begin
        if ARst_N = '0' then
            CurrentST <= ST_A;
        elsif rising_edge(Clk) then
            CurrentST <= NextST;
        end if;
    end process pBlocM;

    Q1 <= '1' when CurrentST = ST_C else '0';               -- Q1 est vrai quand on est dans l'état ST_C
    Q2 <= '1' when CurrentST = ST_D and E1 = '0' else '0';  -- Q2 est vrai quand on sort de l'état ST_D
    
    
    
end architecture rtl;