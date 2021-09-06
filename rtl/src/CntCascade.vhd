library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity CntCascade is
    port (
        ARst_N  : in    std_logic;
        Clk     : in    std_logic;
        Q       : out   std_logic_vector(3 downto 0)
    );
end entity CntCascade;

architecture rtl of CntCascade is
    component Cnt
        generic (
            N   : integer := 8                                  -- Constante qui defini la largeur du compteur sur N bits
        );
        port (
            ARst_N  : in    std_logic;                          -- Remise à 0 de façon asynchrone active niveau bas
            Clk     : in    std_logic;                          -- Horloge
            SRst    : in    std_logic;                          -- Remise à 0 de façon synchrone
            En      : in    std_logic;                          -- '1' --> autorise le comptage
            Ud      : in    std_logic;                          -- '1' --> Incremente; '0' --> Decremente
            Q       : out   std_logic_vector(N - 1 downto 0)    -- Sortie du compteur sur N bits
        );
    end component;
    constant N_Cnt1 : integer := 26;    -- Il faut compter jusqu'a 50 000 000 donc il nous faut 26 bits pour arriver jusqu'a cette valeur 
                                        -- ceil(log2(50e6)) = 26
    signal Rst_Cnt1 : std_logic;
    signal Q_Cnt1   : std_logic_vector(N_Cnt1 - 1 downto 0); 
    signal En_Cnt2  : std_logic;
    signal Q_Cnt2   : std_logic_vector(3 downto 0);
begin
    
    uCnt1 : Cnt
        generic map (
            N   => N_Cnt1)
        port map(
            ARst_N  => ARst_N,  Clk => Clk, SRst    => Rst_Cnt1,
            En      => '1',     Ud => '1',
            Q       => Q_Cnt1);

    En_Cnt2 <= '1' when Q_Cnt1 > 49_999_999 else '0'; -- 0 à 49 999 999 il y a 50 000 000 en prenant le 0 en compte
    Rst_Cnt1 <= En_Cnt2;
    uCnt2 : Cnt
        generic map (
            N   => 4)
        port map(
            ARst_N  => ARst_N,  Clk => Clk, SRst    => '0',
            En      => En_Cnt2, Ud  => '1',
            Q       => Q_Cnt2);
    Q <= Q_Cnt2;
    
end architecture rtl;