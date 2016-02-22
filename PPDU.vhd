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
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.trans_pkg.ALL;

use IEEE.NUMERIC_STD.ALL;

entity PPDU is
    Port (  clk_250khz	: in STD_LOGIC; -- means to be 250khz
			reset		: in STD_LOGIC; -- active when 1
			TX_enable	: in STD_LOGIC;	-- high enable shifting/outputting a bit at a time
			bit_ppdu 	: out  STD_LOGIC); -- serial out
end PPDU;

architecture BEHAV of PPDU is
	-- saves ppdu, shifting out one bit
	signal temp_register : std_logic_vector(m-1 downto 0); -- := (others => 'U');
	
	-- internal signal that has the value of temp_register(0)
	signal i_mux_in : std_logic;

	-- internal signal that has the value of mux output
	signal i_mux_out : std_logic;
	
	-- Register the output
	signal i_bit_ppdu : std_logic;

	-- PPDU
	signal PPDU : std_logic_vector(m-1 downto 0); -- := (others => 'U');
	
	begin
		-- Connect i_bit_ppdu with bit_ppdu
		bit_ppdu <= i_bit_ppdu;

		-- Creating MAC frame and PPDU frame
		PPDU <= PPDU_func(MPDU_frame);
		
		MUX: process(TX_enable, i_mux_in)
		begin
			i_mux_out <= '0'; -- default assigment if TX_en = 0 --> transmits nothing
			if TX_enable = '1' then
				i_mux_out <= i_mux_in;
			end if;
		end process;

		main: process(clk_250khz)
		begin
			if rising_edge(clk_250khz) then
				if reset = '1' then
					i_bit_ppdu <= '0';
					temp_register <= PPDU;
				else
					i_bit_ppdu <= i_mux_out;
					
					i_mux_in <= temp_register(m-1);
					-- If i dont put &'0' it fills with 1 so it does numerical shift not logical that i want
					temp_register(m-1 downto 0) <= temp_register(m-2 downto 0) & '0';
				end if;
			end if;
		end process;
	end BEHAV;


--architecture BEHAV2 of PPDU is
--	-- saves ppdu, shifting out one bit
--	signal temp_register : std_logic_vector(m-1 downto 0); -- := (others => 'U');
--	
--	-- internal signal that has the value of temp_register(0)
--	signal i_mux_in : std_logic;
--
--	-- internal signal that has the value of mux output
--	signal i_mux_out : std_logic;
--	
--	-- Register the output
--	signal i_bit_ppdu : std_logic;
--
--	-- Frame control & seq_num bits
--	signal MPDU : std_logic_vector(39 downto 0); -- := (others => 'U');
--	
--	-- PPDU
--	signal PPDU : std_logic_vector(m-1 downto 0); -- := (others => 'U');
--	
--	begin
--		-- Connect i_bit_ppdu with bit_ppdu
--		bit_ppdu <= i_bit_ppdu;
--
--		-- Creating MAC frame and PPDU frame
--		PPDU <= PPDU_func(MPDU_frame);
--
--		main: process(clk_250khz)
--		begin
--			if rising_edge(clk_250khz) then
--				if reset = '1' then
--					i_bit_ppdu <= '0';
--					temp_register <= PPDU;
--				elsif TX_enable = '1' then
--					i_bit_ppdu <= i_mux_in;
--					
--					i_mux_in <= temp_register(m-1); -- load new bit
--					-- If i dont put &'0' it fills with 1 so it does numerical shift not logical that i want
--					temp_register(m-1 downto 0) <= temp_register(m-2 downto 0) & '0';
--				else -- TX_enable = '0' then
--					i_bit_ppdu <= '0';
--				end if;
--			end if;
--		end process;
--	end BEHAV2;
