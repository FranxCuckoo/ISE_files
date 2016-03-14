----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:03:33 12/13/2015 
-- Design Name: 
-- Module Name:    System - Behavioral 
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

entity System is
    Port( TRX_request 	: in  STD_LOGIC_VECTOR (1 downto 0);
		  clk_250khz	: in  STD_LOGIC;
		  clk_2Mhz		: in  STD_LOGIC;
		  clk_1Mhz		: in  STD_LOGIC;
		  reset			: in  STD_LOGIC;
		  Frame_Verif0	: out STD_LOGIC;
		  Frame_Verif1	: out STD_LOGIC
  );
end System;

architecture Behavioral of System is
	-- Ex: bus0 is what TX0 sents to RX1(what RX1 gets)
	signal Bus0, Bus1: std_logic;
	signal TX0_en,TX1_en,RX0_en,RX1_en: std_logic;
	signal received_frame1, received_frame0 : std_logic;

	component Transceiver is
		 Port(	 clk_250khz	: in  STD_LOGIC;
				 clk_2Mhz		: in  STD_LOGIC;
				 clk_1Mhz		: in  STD_LOGIC;
				 bitIn_rx 		: in  STD_LOGIC;
				 reset 			: in  STD_LOGIC;
				 TX_enable 	: in  STD_LOGIC;
				 RX_enable		: in  STD_LOGIC;

				 bitOut_tx 	: out STD_LOGIC;
				 received_frame : out STD_LOGIC;
				 Frame_Verif	: out STD_LOGIC
			 );
	end component;

	component arbiter is
		 port(clk_250khz		: in std_logic;
			  reset				: in std_logic;
			  FrReceived0		: in std_logic;		
			  FrReceived1		: in std_logic;
			  TRX_request		: in std_logic_vector(1 downto 0);
			  TX0_enable		: out std_logic;
			  RX0_enable		: out std_logic;
			  TX1_enable		: out std_logic;
			  RX1_enable		: out std_logic
			  );
	end component;
	
begin
	U_User0: Transceiver port map(	bitIn_rx 	=> Bus1,					  
									bitOut_tx	=> Bus0,
									Frame_Verif => Frame_Verif0,
									received_frame => received_frame0,												
									TX_enable 	=> TX0_en,
									RX_enable	=> RX0_en,
									reset 		=> reset,
									clk_250khz 	=> clk_250khz,
									clk_1Mhz	=> clk_1Mhz,
									clk_2Mhz	=> clk_2Mhz
								);
												  
	U_User1: Transceiver port map(	bitIn_rx 	=> Bus0,					  
									bitOut_tx	=> Bus1,
									Frame_Verif => Frame_Verif1,
									received_frame => received_frame1,
									TX_enable 	=> TX1_en,
									RX_enable	=> RX1_en,
									reset 		=> reset,
									clk_250khz 	=> clk_250khz,
									clk_1Mhz	=> clk_1Mhz,
									clk_2Mhz	=> clk_2Mhz
								);
												
	U_arbiter: arbiter port map(	TRX_request => TRX_request,
									reset => reset,
									FrReceived0 => received_frame0,
									FrReceived1 => received_frame1,
									clk_250khz => clk_250khz,
									TX0_enable => TX0_en,
									RX0_enable => RX0_en,
									TX1_enable => TX1_en,
									RX1_enable => RX1_en
								);

end Behavioral;

