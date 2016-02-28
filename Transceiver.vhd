----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:25:07 12/13/2015 
-- Design Name: 
-- Module Name:    Transceiver0 - Behavioral 
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

entity Transceiver is
    Port ( clk_200Mhz	: in  STD_LOGIC;
		   clk_250khz	: in  STD_LOGIC;
           clk_62_5khz	: in  STD_LOGIC;
           clk_2Mhz		: in  STD_LOGIC;
		   reset		: in  STD_LOGIC;
		   TX_enable 	: in  STD_LOGIC;
		   RX_enable	: in  STD_LOGIC;
		   bit_ppdu 	: out  STD_LOGIC;
		   received_frame : out STD_LOGIC;
		   Frame_Verif	: out STD_LOGIC
	   );
end Transceiver;

architecture Behavioral of Transceiver is
	-- data bus connects the TR output with the RX input
	signal data_bus : std_logic;
	signal data_bus_delayed : std_logic;
	
	constant D_en : integer := 32;
	constant D_chip : integer := 23;
	signal delay_buffer_chip : std_logic_vector(D_chip downto 0);
	signal delay_buffer_en : std_logic_vector(D_en downto 0);
	signal RX_enable_delayed : std_logic;

	component all_together is
		port ( 	
				clk_250khz	: in STD_LOGIC;
				clk_2Mhz		: in STD_LOGIC;
				TX_enable 	: in  STD_LOGIC;
				reset			: in STD_LOGIC;
				chip_out	: out std_logic;
				bit_ppdu 	: out  STD_LOGIC -- serial out
				);
	end component;
	
	component Receiver_TopModule is
		Port ( 
				clk_200Mhz	: in  STD_LOGIC;
				clk_250khz	: in  STD_LOGIC;
				clk_62_5khz	: in  STD_LOGIC;
				clk_2Mhz	: in  STD_LOGIC;
				reset	:	in STD_LOGIC;
				RX_enable 	: in  STD_LOGIC;
				ChipIn		: in STD_LOGIC;
				received_frame : out STD_LOGIC;
				Frame_OK	: out STD_LOGIC
			  );
	end component;
begin
	U_Transmitter: all_together port map( chip_out => data_bus,
										  TX_enable => TX_enable,
						 				  reset => reset,
										  clk_250khz => clk_250khz,
										  bit_ppdu => bit_ppdu,
										  clk_2Mhz => clk_2Mhz
									  );
																  
	U_Receiver: Receiver_TopModule port map( ChipIn => data_bus, --_delayed,
											 Frame_OK => Frame_Verif,
											 received_frame => received_frame,
											 RX_enable => RX_enable, --_delayed,
											 reset => reset,
											 clk_250khz => clk_250khz,
											 clk_200Mhz => clk_200Mhz,
											 clk_62_5khz => clk_62_5khz,
											 clk_2Mhz => clk_2Mhz
				 						 );

--delay_buffer_en(0) <= RX_enable;
--delay_buffer_chip(0) <= data_bus;
--
--gen_delay_en: for i in 1 to D_en generate
--	delay: process(clk_2Mhz)
--	begin
--		if rising_edge(clk_2Mhz) then
--			delay_buffer_en(i) <= delay_buffer_en(i-1);
--		end if;
--	end process;
--end generate;
--
--gen_delay_chip: for i in 1 to D_chip generate
--	delay: process(clk_2Mhz)
--	begin
--		if rising_edge(clk_2Mhz) then
--			delay_buffer_chip(i) <= delay_buffer_chip(i-1);
--		end if;
--	end process;
--end generate;
----
--RX_enable_delayed <= delay_buffer_en(D_en);
--data_bus_delayed <= delay_buffer_chip(D_chip);

end Behavioral;

