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
	port( BitChip	: in STD_LOGIC;
	      RX_enable	: in  STD_LOGIC; --_VECTOR (1 downto 0);
	      symbol_out: out integer range 0 to 15;
	  	  reset		: in STD_LOGIC;
	      clk_2Mhz	: in STD_LOGIC
		);
end Chip2Symbol;

architecture Behavioral of Chip2Symbol is
	-- Buffer for saving reveiving bits/chips
	signal temp_chip : std_logic_vector(tt-1 downto 0);
	-- Count how many chips I received so I can read the correct symbol
	signal chip_counter : integer range 0 to tt-1;
	
	-- Internal sig, register my input
	signal i_BitChip : std_logic;

	-- Internal signal
	signal i_symbol_out : integer range 0 to 15;

begin
	i_BitChip <= BitChip;

	GET_CHIP: process(clk_2Mhz, reset, RX_enable)
		begin
			if rising_edge(clk_2Mhz) then
				if reset = '1' or RX_enable = '0' then
					-- should go to idle state
					chip_counter <= 0;
					-- in output exports this because I do not have a state which I would say this is nothing
					temp_chip <= x"00000000";
				elsif RX_enable = '1' then
					-- Buffer for 31 + received chip
					temp_chip <= temp_chip(tt-2 downto 0) & i_BitChip;
					
					-- Count to 31
					if chip_counter = tt-1 then
						chip_counter <= 0;
					elsif chip_counter = 0 then
						chip_counter <=  chip_counter + 1;
						i_symbol_out <= get_symbol(temp_chip);
					else
						chip_counter <=  chip_counter + 1;
					end if;
				end if;
			end if;
		end process;

		symbol_out <= i_symbol_out;

--		OUTPUT_SYMBOL: process(clk_2Mhz, temp_chip, chip_counter, i_symbol_out)
--	   	--clk_62_5khz, was in the sensitivity list removed on 5/03 cause ise said it was not used.
--		begin
--			-- Every 32 chips you take translate them in a symbol
--			-- when counter = 0 cause when in use this module in the next level it has a ff delay
--			if chip_counter = 0 then -- and clk_62_5khz = '1'
--				i_symbol_out <= get_symbol(temp_chip);
--			end if;
--
----			case chip_counter is
----				when 0 => i_symbol_out <= get_symbol(temp_chip);
----				when others => i_symbol_out <= i_symbol_out;
----			end case;
--
--		end process;
end Behavioral;

