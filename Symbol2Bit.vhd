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
	port(	clk_250khz	: in STD_LOGIC;
			reset			: in STD_LOGIC;
			RX_enable	: in STD_LOGIC;
			
			symbol_in	: in INTEGER RANGE 0 TO 15;
			bit_out		: out STD_LOGIC			
			);
end Symbol2Bit;

architecture Behavioral of Symbol2Bit is
	signal temp_bits : std_logic_vector(3 downto 0);
	signal pointer : integer range 3 downto 0;

begin

	temp_bits <= std_logic_vector(to_unsigned(symbol_in,4));

	BIT_OUTPUT: process(clk_250khz, temp_bits)
	begin
		if rising_edge(clk_250khz) then
			if reset = '1' or RX_enable = '0' then
				pointer <= 3;
				bit_out <= '0';
			elsif RX_enable = '1' then
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
