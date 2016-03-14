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

entity Transmitter is 
	port (	clk_250khz : in std_logic;
			clk_2Mhz : in std_logic;
			clk_1Mhz : in std_logic;
			reset : in std_logic;
			TX_enable : in std_logic;
			stream_out : out std_logic
		);
end Transmitter;

architecture Behavioral of Transmitter is
	-- Connection of all_tog output with oqpsk input
	signal i_chip : std_logic;


	-- Number of clk_2Mhz_period to delay
	constant D_en : integer := 4;
	signal delay_buffer_en : std_logic_vector(D_en downto 0);
	signal TX_enable_delayed : std_logic;

	component all_together is
		port(	clk_250khz	: in STD_LOGIC; -- means to be 250khz
				clk_2Mhz	: in STD_LOGIC;  -- 2mhz
				reset		: in STD_LOGIC; -- active when 1
				TX_enable	: in STD_LOGIC;	-- high enable shifting/outputting a bit at a time
				
				chip_out	: out std_logic
			);
	
	end component;

	component oqpsk is
		port(	clk_1Mhz	: in STD_LOGIC; -- means to be 250khz
				clk_2Mhz	: in STD_LOGIC;  -- 2mhz
				reset		: in STD_LOGIC; -- active when 1
				modulation_en : in STD_LOGIC;	-- high enable shifting/outputting a bit at a time
				chip_in		: in std_logic;
				stream_out	: out std_logic
			);
	end component;
begin

Chip_creation : all_together port map (	clk_250khz	=> clk_250khz, 
                                        clk_2Mhz	=> clk_2Mhz, 
                                        reset		=> reset,
                                        TX_enable	=> TX_enable,	
                                        
                                        chip_out	=> i_chip
									);


oqpsk_modulation : oqpsk port map (	clk_1Mhz	=> clk_1Mhz, 
                                    clk_2Mhz	=> clk_2Mhz,
                                    reset		=> reset, 
                                    modulation_en	=> TX_enable_delayed,
                                    chip_in		=> i_chip,
                                    stream_out	=> stream_out
								);

-- Creation of a delay until the next rising edge of clks
-- according to the time that my TX module delays to output the packet.
delay_buffer_en(0) <= TX_enable;

gen_delay_en: for i in 1 to D_en generate
	delay_enable: process(clk_2Mhz)
	begin
		if rising_edge(clk_2Mhz) then
			delay_buffer_en(i) <= delay_buffer_en(i-1);
		end if;
	end process;
end generate;

TX_enable_delayed <= delay_buffer_en(D_en);

end Behavioral;
