----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:11:27 11/26/2015 
-- Design Name: 
-- Module Name:    PPDU_Generator - Behavioral 
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
--	The PPDU frame is sent first the Preamble then the SFD etc 
--	ending up with the FCS
--	EACH CLK OUTPUTS ONE BIT OF THE PPDU Frame
--	Valid Output chip a clk_250_period + clk_2Mhz after.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.trans_pkg.ALL;
use IEEE.NUMERIC_STD.ALL;

entity all_together is
    Port (  clk_250khz	: in STD_LOGIC; -- means to be 250khz
			clk_2Mhz	: in STD_LOGIC;  -- 2mhz
			reset		: in STD_LOGIC; -- active when 1
			TX_enable	: in STD_LOGIC;	-- high enable shifting/outputting a bit at a time
			chip_out	: out std_logic;
			bit_ppdu 	: out  STD_LOGIC); -- serial out
end all_together;

architecture BEHAV of all_together is
	-- saves ppdu, shifting out one bit
	signal temp_register : std_logic_vector(m-1 downto 0); -- := (others => 'U');
	
	-- internal signal that has the value of temp_register(0)
	signal i_mux_in : std_logic;

	-- internal signal that has the value of mux output
	signal i_mux_out : std_logic;
	
	-- Register the output
	signal i_bit_ppdu : std_logic;
	signal i_bit_ppdu_delayed : std_logic_vector(23 downto 0);

	-- PPDU
	signal PPDU : std_logic_vector(m-1 downto 0); -- := (others => 'U');
	
	signal temp_symbol : STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal i_symbol_out : integer range 0 to 15;
	signal counter : integer range 0 to 3;

	signal i_symbol_in : integer range 0 to 15;
	signal i_chip_out : std_logic;
--	signal i_chip_out_delayed : std_logic_vector(23 downto 0);

	signal output_chip : std_logic_vector(0 to tt-1);
	signal i_bit_i : integer range 0 to tt-1;
	-- whenevent is the same as tx_enable but one 250period later
	signal whenevent :std_logic;
begin
	-- Connect i_bit_ppdu with bit_ppdu
	bit_ppdu <= i_bit_ppdu;
	
	-- Connect i_bit_ppdu with bit_ppdu
	chip_out <= i_chip_out; --_delayed;
	--------------------------------------
	-- Delay the output
--	i_chip_out_delayed(0) <= i_chip_out;
--	
--	gen_delay: for i in 1 to 23 generate
--		delay: process(clk_2Mhz)
--		begin
--			if rising_edge(clk_2Mhz) then
--				i_chip_out_delayed(i) <= i_chip_out_delayed(i-1);
--			end if;
--		end process;
--	end generate;
--
--	chip_out <= i_chip_out_delayed(23);
	-------------------------------------
	
	-- Creating MAC frame and PPDU frame
	PPDU <= PPDU_func(MPDU_frame);
	
	MUX: process(TX_enable, i_mux_in)
	begin
		i_mux_out <= '0'; -- default assigment if TX_en = 0 --> transmits nothing
		if TX_enable = '1' then
			i_mux_out <= i_mux_in;
		end if;
	end process;

	SYMBOL_OUTPUT: process(clk_250khz)
	begin
		if rising_edge(clk_250khz) then
			if reset = '1' then
				i_bit_ppdu <= '0';
				temp_register <= PPDU;
					
				temp_symbol <= "0000";
				counter <= 0;
				
				whenevent <= '0';
			elsif TX_enable = '1' then
				i_bit_ppdu <= i_mux_out;
				
				temp_symbol <= temp_symbol(2 downto 0) & i_mux_out;
				if counter = 4 then
					counter <= 1;
				elsif counter = 1 then
					i_symbol_out <= to_integer(unsigned(temp_symbol));
					counter <= counter + 1;
				else
					counter <= counter + 1;
				end if;

				i_mux_in <= temp_register(m-1);
				-- If i dont put &'0' it fills with 1 so it does numerical shift not logical that i want
				temp_register(m-1 downto 0) <= temp_register(m-2 downto 0) & '0';
				
				if TX_enable = '1' and (counter > 0)then
					whenevent <= TX_enable;
				end if;
			end if;
		end if;
	end process;

	with i_symbol_out select
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
						
	CHIP_OUTPUT: process(clk_2Mhz, counter)
		variable bit_i : integer range 0 to tt-1;
	begin
		if reset = '1' then
			i_chip_out <= '0';
			bit_i := 0;
		elsif rising_edge(clk_2Mhz) then
			if whenevent = '1' then
				i_chip_out <= output_chip(bit_i);

				i_bit_i <= bit_i;	
				if bit_i = tt-1 then
					bit_i := 0;
				else
					bit_i := bit_i + 1;
				end if;
			end if;
		end if;
	end process;
end BEHAV;
