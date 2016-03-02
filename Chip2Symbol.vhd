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
	-- Buffer for saving reveiving bits/chips
	signal temp_chip : std_logic_vector(tt-1 downto 0);
	-- Count how many chips I received so I can read the correct symbol
	signal chip_counter : integer range 0 to tt-1;
	
	-- Internal sig, register my input
	signal i_BitChip : std_logic;
begin
	i_BitChip <= BitChip;
-- Register my input -- DOES NOT MAKE A DIFF
-- Uncomment below only to check the Receiver_TopModule
--	REG_INPUT: process(clk_2Mhz)
--	begin
--		if rising_edge(clk_2Mhz) then
--			i_BitChip <= BitChip;
--		end if;
--	end process;

	GET_CHIP: process(clk_2Mhz, reset, RX_enable)
		begin
			if rising_edge(clk_2Mhz) then
				if reset = '1' then
					-- should go to idle state
					chip_counter <= 0;
					-- in output exports this because I do not have a state which I would say this is nothing
					temp_chip <= x"00000000";
				elsif RX_enable = '0' then
					temp_chip <= x"00000000";
					chip_counter <= 0;
				elsif RX_enable = '1' then
					-- Buffer for 31 + received chip
					temp_chip <= temp_chip(tt-2 downto 0) & i_BitChip;
					
					-- Count to 31
					if chip_counter = tt-1 then
						chip_counter <= 0;
					else
						chip_counter <=  chip_counter + 1;
					end if;
				end if;
			end if;
		end process;
		
	OUTPUT_SYMBOL: process(clk_62_5khz, temp_chip)
		begin
			-- Every 32 chips you take translate them in a symbol
			-- when counter = 0 cause when in use this module in the next level it has a ff delay
			if clk_62_5khz = '1' and chip_counter = 0 then
				symbol_out <= get_symbol(temp_chip);
			end if;
		end process;
end Behavioral;

