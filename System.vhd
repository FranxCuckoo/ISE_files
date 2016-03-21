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
		  clk			: in std_logic; -- 100Mhz clk
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

	-- Generating clk 2Mhz
	signal prescaler2 : integer range 0 to 25; -- max value of counter
  	signal clk_2Mhz : std_logic := '1';

	-- Generating clk 250Khz
	signal prescaler250 : integer range 0 to 200;
  	signal clk_250Khz : std_logic := '1';

	component Transceiver is
		 Port(	 clk_250khz		: in  STD_LOGIC;
				 clk_2Mhz		: in  STD_LOGIC;
				 bitIn_rx 		: in  STD_LOGIC;
				 reset 			: in  STD_LOGIC;
				 TX_enable 		: in  STD_LOGIC;
				 RX_enable		: in  STD_LOGIC;

				 bitOut_tx 		: out STD_LOGIC;
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

	gen_clk : process (clk, reset)
	begin -- process gen_clk
--		if reset = '1' then
--			clk_2Mhz   <= '0';
--			clk_250khz <= '0';
--			prescaler2   <= 0;
--			prescaler250 <= 0;
--		elsif rising_edge(clk) then   -- rising clock edge
		if rising_edge(clk) then   -- rising clock edge
			if prescaler250 = 100000000/500000 then -- 250000 * 2 half period
				prescaler250 <= 0;	-- resetting to 0
				clk_250Khz  <= not clk_250Khz;
			else
				prescaler250 <= prescaler250 + 1;
			end if;

			if prescaler2 = 100000000/4000000 then -- 2000000*2 half period => 
				prescaler2 <= 0;
				clk_2Mhz  <= not clk_2Mhz;
			else
				prescaler2 <= prescaler2 + 1;
			end if;
		end if;
  	end process gen_clk;

end Behavioral;

