--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 	  Demetris Tziambazis
-- Email:	  tziambazis71@gmail.com
-- Create Date:   2016
-- Design Name:   
-- Module Name:   
-- Project Name:  
-- Target Device:  
-- COPYRIGHT = Copyright (c) 2016, Demetris Tziambazis
-- Description:   
-- 
-- 
-- Dependencies:
-- 
-- Additional Comments:
--
-- Notes: 
-- 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.trans_pkg.all;

entity Symbol2Chip is
	port(	clk_2Mhz	: in STD_LOGIC;  -- 2mhz
			reset	: in STD_LOGIC;
			symbol_in : in integer range 0 to 15;
			chip_out : out STD_LOGIC);
end Symbol2Chip;

architecture BEHAV2 of Symbol2Chip is
	signal i_symbol_in : integer range 0 to 15;
	signal i_chip_out : std_logic;

	signal output_chip : std_logic_vector(0 to tt-1);
	signal i_out : std_logic_vector(0 to tt-1);
	signal i_bit_i : integer range 0 to tt-1;

begin
	i_symbol_in <= symbol_in;
	chip_out <= i_chip_out;
	
	with i_symbol_in select
		output_chip <= "11011001110000110101001000101110" when 0,
					   "11101101100111000011010100100010" when 1,
					   "00101110110110011100001101010010" when 2,
					   "00100010111011011001110000110101" when 3,
					   "01010010001011101101100111000011" when 4,
					   "00110101001000101110110110011100" when 5,
					   "11000011010100100010111011011001" when 6,
					   "10011100001101010010001011101101" when 7,
					   "10001100100101100000011101111011" when 8,
					   "10111000110010010110000001110111" when 9,
					   "01111011100011001001011000000111" when 10,
					   "01110111101110001100100101100000" when 11,
					   "00000111011110111000110010010110" when 12,
					   "01100000011101111011100011001001" when 13,
					   "10010110000001110111101110001100" when 14,
					   "11001001011000000111011110111000" when 15;

	CHIP_OUTPUT: process(clk_2Mhz)
		variable bit_i : integer range 0 to tt-1;
	begin
		if reset = '1' then
			i_chip_out <= '0';
			bit_i := 0;
		elsif rising_edge(clk_2Mhz) then
			i_chip_out <= output_chip(bit_i);

			i_bit_i <= bit_i;	
			if bit_i = tt-1 then
				bit_i := 0;
			else
				bit_i := bit_i + 1;
			end if;
		end if;
	end process;
end BEHAV2;

