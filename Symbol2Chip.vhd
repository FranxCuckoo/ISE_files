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
	port(	clk_62_5Khz : in STD_LOGIC; -- 62.5khz
			clk_2Mhz	: in STD_LOGIC;  -- 2mhz
			reset	: in STD_LOGIC;
			symbol_in : in integer range 0 to 15;
			chip_out : out STD_LOGIC);
end Symbol2Chip;

architecture BEHAV of Symbol2Chip is
	signal i_symbol_in : integer range 0 to 15;
	signal i_chip_out : std_logic;

	signal output_chip : std_logic_vector(0 to tt-1);
		
	subtype index_int is  integer range 0 to tt-1;
	signal bit_i: index_int; --outputting a single bit out of 32 each time

begin
	i_symbol_in <= symbol_in;
	chip_out <= i_chip_out;
	
	GET_SYMBOL: process(clk_62_5Khz)
	begin
		if reset = '1' then
			output_chip <= chipArray(0);
		elsif rising_edge(clk_62_5Khz) then
			output_chip <= chipArray(i_symbol_in);
		end if;
	end process;

	CHIP_OUTPUT: process(clk_2Mhz)
	begin
		if rising_edge(clk_2Mhz) then
			i_chip_out <= output_chip(bit_i);
			if bit_i = tt-1 then
				bit_i <= 0;
			else
				bit_i <= bit_i + 1;
			end if;
		end if;
	end process;
end BEHAV;
