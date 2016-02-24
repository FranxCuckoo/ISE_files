----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:17:39 12/04/2015 
-- Design Name: 
-- Module Name:    Symbol2Bit - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use work.receiver_pkg.all;

entity Symbol2Bit is
	port( 	symbol_in	: in INTEGER RANGE 0 TO 15;
			bit_out		: out STD_LOGIC;
			reset			: in STD_LOGIC;
			clk_62_5khz	: in STD_LOGIC;
			--clk_200Mhz	: in STD_LOGIC;
			clk_250khz	: in STD_LOGIC
			);
end Symbol2Bit;

architecture Behavioral of Symbol2Bit is
	signal temp_bits : std_logic_vector(3 downto 0);
	signal pointer : integer range 0 to 3 := 3;

begin

	temp_bits <= std_logic_vector(to_unsigned(symbol_in,4));
--	GET_SYMBOL: process(clk_62_5khz)
--	begin
--		if reset = '1' then
--			bit_out <= '0';
--		elsif rising_edge(clk_62_5khz) then
--			temp_bits <= std_logic_vector(to_unsigned(symbol_in,4));
--		end if;
--	end process;

	BIT_OUTPUT: process(clk_250khz, temp_bits)
	begin
		if rising_edge(clk_250khz) then
			if reset = '1' then
				pointer <= 0;
				bit_out <= '0';
			else
				bit_out <= temp_bits(pointer);
				if pointer = 0 then
					pointer <= 3;
				else
					pointer <= pointer - 1 ;
				end if;
			end if;
		end if;
	end process;

end Behavioral;		
