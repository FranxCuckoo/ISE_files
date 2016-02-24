---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:36:12 12/06/2015 
-- Design Name: 
-- Module Name:    Chip2Symbol - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.receiver_pkg.all;

entity Chip2Symbol is
	port( 	BitChip	: in STD_LOGIC;
			RX_enable  	: in  STD_LOGIC; --_VECTOR (1 downto 0);
			symbol_out	: out integer range 0 to 15;
			reset	:	in STD_LOGIC;
			clk_2Mhz	: in STD_LOGIC; -- in 
			clk_62_5khz	: in STD_LOGIC --out
			);
end Chip2Symbol;

architecture Behavioral of Chip2Symbol is
	signal temp_chip : std_logic_vector(tt-1 downto 0);

begin
	process(clk_2Mhz, reset, RX_enable)
		begin
			if reset = '1' or RX_enable = '0' then
			-- should go to idle state
				temp_chip <= x"00000000"; -- in output exports 15 because I do not have a state which I would say this is nothing
			elsif rising_edge(clk_2Mhz) then --FALLING
				temp_chip <= temp_chip(tt-2 downto 0) & BitChip;
			end if;
		end process;
		
	process(clk_62_5khz) -- try when progress with only temp_chip in the sensitivity list
		begin
			if rising_edge(clk_62_5khz) then
				symbol_out <= get_symbol(temp_chip);
			end if;
		end process;
		
end Behavioral;

