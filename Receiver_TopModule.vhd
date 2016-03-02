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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Receiver_TopModule is
		Port ( 
				clk_250khz	: in  STD_LOGIC;
				clk_62_5khz	: in  STD_LOGIC;
				clk_2Mhz	: in  STD_LOGIC;
				reset	:	in STD_LOGIC;
				RX_enable  	: in  STD_LOGIC; --_VECTOR (1 downto 0);
				ChipIn		: in STD_LOGIC;
				received_frame : out STD_LOGIC;
				Frame_OK	: out STD_LOGIC
			  );
end Receiver_TopModule;

architecture Behavioral of Receiver_TopModule is
--	constant D : integer := 1; -- Number of 2Mhz_periods that the TR delays
--	signal delay_buffer : std_logic_vector(D downto 0);
--	signal ChipIn_delayed : std_logic;
	
	signal c2s_s2b : integer range 0 to 15;
	signal b2ppdu	: std_logic;

component Chip2Symbol is
	port( BitChip	: in STD_LOGIC;
			RX_enable  	: in  STD_LOGIC;
			symbol_out	: out integer range 0 to 15;
			reset	:	in STD_LOGIC;
			clk_2Mhz	: in STD_LOGIC; -- in 
			clk_62_5khz	: in STD_LOGIC --out
			);
	end component;
		
component Symbol2Bit is
	port( symbol_in	: in integer range 0 to 15;
			bit_out	: out STD_LOGIC;
			reset	:	in STD_LOGIC;
			clk_62_5khz	: in STD_LOGIC;
			RX_enable	: in STD_LOGIC;
			clk_250khz	: in STD_LOGIC
			);
	end component;
	
component PPDU_degenerator is
    port( ppdu_bit	: in STD_LOGIC;
			 reset		:	in STD_LOGIC;
			 clk_250khz	: in STD_LOGIC; --in
			 received_frame: out STD_LOGIC;
			 check_frame: out STD_LOGIC --if its 1 its ok, if its 0 is wrong
			 );
end component;

begin

U_Chip2Symbol	:	Chip2Symbol port map(	clk_62_5khz => clk_62_5khz,
														clk_2Mhz => clk_2Mhz,
														BitChip => ChipIn, --_delayed,
														reset => reset,
														RX_enable => RX_enable,
														symbol_out => c2s_s2b
														);
														
U_Symbol2Bit	: Symbol2Bit port map(	clk_62_5khz => clk_62_5khz,
													clk_250khz => clk_250khz,
													RX_enable => RX_enable,
													reset => reset,
													symbol_in => c2s_s2b,
													bit_out => b2ppdu
													);
														
U_PPDU_degenerator: PPDU_degenerator port map(	ppdu_bit => b2ppdu,
																clk_250khz => clk_250khz,
																reset => reset,
																received_frame => received_frame,
																check_frame => Frame_OK
																);

--delay_buffer(0) <= ChipIn;
--
--gen_delay: for i in 1 to D generate
--	delay: process(clk_2Mhz)
--	begin
--		if rising_edge(clk_2Mhz) then
--			delay_buffer(i) <= delay_buffer(i-1);
--		end if;
--	end process;
--end generate;
--
--ChipIn_delayed <= delay_buffer(D);

end Behavioral;
