library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
-- Use Wavedrom : https://wavedrom.com/editor.html
--! **Bus Avalon**
--!    {signal: [
--!        {name: 'clk', wave: 'p..........', period: 2},
--!        {name: 'Address', wave: 'x.5.x.5.x.5...x.5...x.', data : ['A0', 'A0', 'A1', 'A2']},
--!        {name: 'Write', wave: '0.1.0.....1...0.......'},
--!        {name: 'WriteData', wave: 'x.5.x.....5...x.......', data : ['D1', 'D2']},
--!        {name: 'ByteEnable', wave: 'x.5.x.5.x.5...x.5...x.', data : ['4 bytes', '4 bytes', '2 bytes', '2 bytes']}, 
--!        {name: 'Read', wave: '0.....1.0.......1...0.'},
--!        {name: 'ReadData', wave: 'x.....5.x.........5.x.', data : ['D1', 'D3']},
--!        {name: 'ChipSelect', wave: '0.1.0.1.0.1...0.1...0.'},
--!        {name: 'WaitRequest', wave: '0.........1.0...1.0...'}
--!    ]}
entity AvalonSlave is
    port (
        Reset       : in    std_logic;
        Clk         : in    std_logic;
        Address     : in    std_logic_vector(1 downto 0);
        Write       : in    std_logic;
        WriteData   : in    std_logic_vector(31 downto 0);
        Read        : in    std_logic;
        ReadData    : out   std_logic_vector(31 downto 0);
        ByteEnable  : in    std_logic_vector(3 downto 0);
        WaitRequest : out   std_logic
    );
end entity AvalonSlave;

architecture rtl of AvalonSlave is


    signal sReg                 : std_logic_vector(31 downto 0);
    signal sRegByteEnable       : std_logic_vector(31 downto 0);
    signal sReadCount           : std_logic_vector(31 downto 0);
    signal sReadCountPipelined  : std_logic_vector(31 downto 0);
    signal dRead                : std_logic;
begin
    -- Ecriture du bus avalon. Write passe à 1 quand le Nios s'adresse à ce peripherique.
    -- Si on veut faire une ecriture sur une Fifo ou EBR (Embedded Block of Ram), on est pas
    -- obligé d'utiliser un process. On peut utiliser les intructions concurrentes qui sont recommandés
    pWrite : process (Clk, reset)
    begin
        if reset = '1' then
            sReg <= (others => '0');
        elsif rising_edge(Clk) then
            if Write = '1' then
                case to_integer(unsigned(Address)) is
                    when 0 =>
                        sReg <= WriteData;
                    when 1 =>
                        if ByteEnable(0) = '1' then
                            sRegByteEnable(7 downto 0) <= WriteData(7 downto 0);
                        end if;
                        if ByteEnable(1) = '1' then
                            sRegByteEnable(15 downto 8) <= WriteData(15 downto 8);
                        end if;
                        if ByteEnable(2) = '1' then
                            sRegByteEnable(23 downto 16) <= WriteData(23 downto 16);
                        end if;
                        if ByteEnable(3) = '1' then
                            sRegByteEnable(31 downto 24) <= WriteData(31 downto 24);
                        end if;
                        --for i in 0 to 3 loop
                        --    if ByteEnable(i) = '1' then
                        --        sRegByteEnable(i*8 + 7 downto i*8) <= WriteData(i*8 + 7 downto i*8);
                        --    end if;
                        --end loop;
                    when others =>
                end case;
            end if;
        end if;
    end process pWrite;
    -- Read sert à lire des structures pilotés. Par exemple des Fifo, EBR.
    -- Si la donnée est immediatement, on peut ignorer le signal Read.
    pRead: process(Clk, Reset)
    begin
        if Reset = '1' then
            sReadCount <= (others => '0');
            sReadCountPipelined <= (others => '0');
        elsif rising_edge(Clk) then
            if Read = '1' then
                case to_integer(unsigned(Address)) is
                    when 2 =>
                        sReadCount <= sReadCount + 1;
                    when 3 =>
                        if dRead = '0' then -- Si on est sur un front montant de Read on incrementes
                                            -- Read va etre à 1 pendant 2 coups d'horloge donc on veut
                                            -- detecter un front montant de read pour eviter d'incrementer
                                            -- sReadCountPipelined 2 fois.
                            sReadCountPipelined <= sReadCountPipelined + 1;
                        end if;
                    when others =>
                end case;
            end if;
        end if;
    end process pRead;
    pDelayRead: process(Clk)
    begin
        if rising_edge(Clk) then
            dRead <= Read;
        end if;
    end process pDelayRead;
    WaitRequest <= '1' when Read = '1' and dRead = '0' and Address = 3 else '0'; -- On met waitrequest à 1 que si on lit à l'addresse 3
    ReadData <= sReg when Address = 0 else          -- Bus de lecture en fonction de l'address
                sRegByteEnable when Address = 1 else
                sReadCount when Address = 2 else
                sReadCountPipelined;
    
end architecture rtl;