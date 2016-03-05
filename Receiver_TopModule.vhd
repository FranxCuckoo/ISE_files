----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:44:16 12/04/2015 
-- Design Name: 
-- Module Name:    Receiver_TopModule - Behavioral 
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

entity Receiver_TopModule is
		Port ( 
				clk_250khz	: in  STD_LOGIC;
				clk_2Mhz	: in  STD_LOGIC;
				reset	:	in STD_LOGIC;
				RX_enable  	: in  STD_LOGIC;
				RX_enable_delayed  	: in  STD_LOGIC;
				ChipIn		: in STD_LOGIC;
				received_frame : out STD_LOGIC;
				Frame_OK	: out STD_LOGIC
			  );
end Receiver_TopModule;

architecture Behavioral of Receiver_TopModule is
	-- Internal signal to connect the three modules.
	signal c2s_s2b : integer range 0 to 15;
	signal b2ppdu	: std_logic;

component Chip2Symbol is
	port( BitChip	: in STD_LOGIC;
			RX_enable 	: in  STD_LOGIC;
			symbol_out	: out integer range 0 to 15;
			reset	:	in STD_LOGIC;
			clk_2Mhz	: in STD_LOGIC 
			);
	end component;
		
component Symbol2Bit is
	port( symbol_in	: in integer range 0 to 15;
			bit_out	: out STD_LOGIC;
			reset	:	in STD_LOGIC;
			RX_enable	: in STD_LOGIC;
			clk_250khz	: in STD_LOGIC
			);
	end component;
	
component PPDU_degenerator is
    port( ppdu_bit	: in STD_LOGIC;
			 reset		:	in STD_LOGIC;
			 clk_250khz	: in STD_LOGIC;
			 RX_enable : in std_logic;
			 received_frame: out STD_LOGIC;
			 check_frame: out STD_LOGIC --if its 1 its ok, if its 0 is wrong
		 );
end component;

begin

U_Chip2Symbol	:	Chip2Symbol port map(clk_2Mhz => clk_2Mhz,
										 BitChip => ChipIn, --_delayed,
										 reset => reset,
										 RX_enable => RX_enable_delayed,
										 symbol_out => c2s_s2b
										 );
										 
U_Symbol2Bit	: Symbol2Bit port map(clk_250khz => clk_250khz,
									  RX_enable => RX_enable_delayed,
									  reset => reset,
									  symbol_in => c2s_s2b,
									  bit_out => b2ppdu
									  );
									  	
U_PPDU_degenerator: PPDU_degenerator port map(	ppdu_bit => b2ppdu,
												clk_250khz => clk_250khz,
												reset => reset,
												received_frame => received_frame,
												RX_enable => RX_enable, 	
												check_frame => Frame_OK
												);

end Behavioral;
