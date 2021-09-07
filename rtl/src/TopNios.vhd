library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TopNios is
    port (
        PinARst_N   : in    std_logic;
        PinClk      : in    std_logic;
        PinLed      : out   std_logic_vector(7 downto 0)
    );
end entity TopNios;

architecture rtl of TopNios is
    component Mcu is
		port (
			clk_clk       : in  std_logic                    := 'X'; -- clk
			reset_reset_n : in  std_logic                    := 'X'; -- reset_n
			leds_export   : out std_logic_vector(7 downto 0)         -- export
		);
	end component Mcu;
begin
    


	uMCU : Mcu
		port map (
			clk_clk       => PinClk,
			reset_reset_n => PinARst_N,
			leds_export   => PinLed
		);

    
end architecture rtl;