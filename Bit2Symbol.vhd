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
use ieee.NUMERIC_STD.ALL;
use work.trans_pkg.ALL;

------------------------------------------------
--	entity C2S
------------------------------------------------
entity Bit2Symbol is
	port(	clk_250khz	: in STD_LOGIC; -- means to be 250khz
			clk_62_5khz: in STD_LOGIC; -- 62.5 KHZ
			reset	: in STD_LOGIC;
			bit_in : in STD_LOGIC;
			symbol_out : out INTEGER RANGE 0 TO 15); --integers range 0-15
end Bit2Symbol;

architecture Behavioral of Bit2Symbol is
-----------------------------------------
--Declaring in-module signals
-----------------------------------------
signal temp_symbol	: STD_LOGIC_VECTOR(3 DOWNTO 0);
signal i_symbol_out : integer range 0 to 15;
signal i_bit_in	: std_logic;
signal counter : integer range 0 to 3;

begin
symbol_out <= i_symbol_out; -- register my output
i_bit_in <= bit_in; -- register my input

symbol_creation: process(clk_250khz)
begin
	if reset = '1' then
		temp_symbol <= "0000";
		counter <= 0;
	elsif rising_edge(clk_250khz) then
		temp_symbol <= temp_symbol(2 downto 0) & i_bit_in;
		if counter = 4 then
			counter <= 1;
		elsif counter = 1 then
			i_symbol_out <= to_integer(unsigned(temp_symbol));
			counter <= counter + 1;
		else
			counter <= counter + 1;
		end if;
	end if;
end process;

--LUT: process(clk_62_5khz)
--begin
--	if rising_edge(clk_62_5khz) then
--		i_symbol_out <= to_integer(unsigned(temp_symbol));
--	end if;
--end process;

end Behavioral;

