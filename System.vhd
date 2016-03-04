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
    Port( request_TRX 	: in  STD_LOGIC_VECTOR (1 downto 0);
		  clk_250khz	: in  STD_LOGIC;
		  clk_62_5khz	: in  STD_LOGIC;
		  clk_2Mhz		: in  STD_LOGIC;
		  reset 			: in  STD_LOGIC;
		  Frame0_Verif	: out STD_LOGIC;
		  Frame1_Verif	: out STD_LOGIC
  );
end System;

architecture Behavioral of System is
	 -- Ex: bus0 is what TX0 sents to RX1(what RX1 gets)
	signal Bus0, Bus1: std_logic;
	signal TX0_en,TX1_en,RX0_en,RX1_en: std_logic;
	signal received_frame1, received_frame0 : std_logic;

	component Transceiver is
		 Port(	 clk_250khz	: in  STD_LOGIC;
				 clk_62_5khz	: in  STD_LOGIC;
				 clk_2Mhz		: in  STD_LOGIC;
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
									Frame_Verif => Frame0_Verif,
									received_frame => received_frame0,												
									TX_enable 	=> TX0_en,
									RX_enable	=> RX0_en,
									reset 		=> reset,
									clk_250khz 	=> clk_250khz,
									clk_62_5khz => clk_62_5khz,
									clk_2Mhz		=> clk_2Mhz
								);
												  
	U_User1: Transceiver port map(	bitIn_rx 	=> Bus0,					  
									bitOut_tx	=> Bus1,
									Frame_Verif => Frame1_Verif,
									received_frame => received_frame1,
									TX_enable 	=> TX1_en,
									RX_enable	=> RX1_en,
									reset 		=> reset,
									clk_250khz 	=> clk_250khz,
									clk_62_5khz => clk_62_5khz,
									clk_2Mhz		=> clk_2Mhz
								);
												
	U_arbiter: arbiter port map(	TRX_request => request_TRX,
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
--
--
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--
--entity System is
--    Port ( 
--           request_TRX 	: in  STD_LOGIC_VECTOR (1 downto 0);
--			  
--			  clk_200Mhz	: in  STD_LOGIC;
--			  clk_250khz	: in  STD_LOGIC;
--			  clk_62_5khz	: in  STD_LOGIC;
--			  clk_2Mhz		: in  STD_LOGIC;
--			  
----			  bitIn_rx 		: in  STD_LOGIC;
--			  reset 			: in  STD_LOGIC;
----			  TX_enable 	: in  STD_LOGIC;
----			  RX_enable		: in  STD_LOGIC;
----			  bitOut_tx 	: out STD_LOGIC;
--			  Frame0_Verif	: out STD_LOGIC;
--			  Frame1_Verif	: out STD_LOGIC;
--			  
--			  TX0_enable	: out std_logic;
--			  RX0_enable	: out std_logic;
--			  TX1_enable	: out std_logic;
--			  RX1_enable	: out std_logic
--			  );
--end System;
--
--architecture Behavioral of System is
--signal sendBus: std_logic;
--signal receiveBus: std_logic;
--
--	component Transceiver0 is
--		 Port ( clk_200Mhz	: in  STD_LOGIC;
--				  clk_250khz	: in  STD_LOGIC;
--				  clk_62_5khz	: in  STD_LOGIC;
--				  clk_2Mhz		: in  STD_LOGIC;
--				  bitIn0_rx 		: in  STD_LOGIC;
--				  reset 			: in  STD_LOGIC;
--				  TX0_en 	: in  STD_LOGIC;
--				  RX0_en		: in  STD_LOGIC;
--				  bitOut0_tx 	: out STD_LOGIC;
--				  Frame0_Verif	: out STD_LOGIC
--				  );
--	end component;
--
--	component Transceiver1 is
--		 Port ( clk_200Mhz	: in  STD_LOGIC;
--				  clk_250khz	: in  STD_LOGIC;
--				  clk_62_5khz	: in  STD_LOGIC;
--				  clk_2Mhz		: in  STD_LOGIC;
--				  bitIn1_rx 	: in  STD_LOGIC;
--				  reset 			: in  STD_LOGIC;
--				  TX1_en	: in  STD_LOGIC;
--				  RX1_en		: in  STD_LOGIC;
--				  bitOut1_tx 	: out STD_LOGIC;
--				  Frame1_Verif	: out STD_LOGIC
--				  );
--	end component;
--
--	component arbiter_v3 is
--		 port(  clk_200Mhz	: in std_logic;
--				  reset			: in std_logic;
--				  TRX_request	: in std_logic_vector(1 downto 0);
--				  TX0_enable	: out std_logic;
--				  RX0_enable	: out std_logic;
--				  TX1_enable	: out std_logic;
--				  RX1_enable	: out std_logic
--				  );
--	end component;
--	
--begin
--	U_User0: Transceiver0 port map(	bitIn0_rx 	=> receiveBus,					  
--												RX0_en	=> RX0_enable,
--												bitOut0_tx	=> sendBus,
--												Frame0_Verif => Frame0_Verif,  
--												TX0_en 	=> TX0_enable,
--												reset 		=> reset,
--												clk_200Mhz 	=> clk_200Mhz,
--												clk_250khz 	=> clk_250khz,
--												clk_62_5khz => clk_62_5khz,
--												clk_2Mhz		=> clk_2Mhz
--												);
--												  
--	U_User1: Transceiver1 port map(	bitIn1_rx 	=> receiveBus,					  
--												RX1_en	=> RX1_enable,
--												bitOut1_tx	=> sendBus,
--												Frame1_Verif => Frame1_Verif,  
--												TX1_en 	=> TX1_enable,
--												reset 		=> reset,
--												clk_200Mhz 	=> clk_200Mhz,
--												clk_250khz 	=> clk_250khz,
--												clk_62_5khz => clk_62_5khz,
--												clk_2Mhz		=> clk_2Mhz
--												);
--												
--	U_arbiter: arbiter_v3 port map( TRX_request => request_TRX,
--											  reset => reset,
--											  clk_200Mhz => clk_200Mhz,
--											  TX0_enable => TX0_enable,
--											  RX0_enable => RX0_enable,
--											  TX1_enable => TX1_enable,
--											  RX1_enable => RX1_enable
--											  );
--
--end Behavioral;
--
--
--
