----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:48:27 2/9/2016
-- Design Name: 
-- Module Name:    arbiter_v6 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: CLOCKED
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Created 2/9/16 to make the arbiter sychronous with 200Mhz
--		
--		17/02/16: FrReceivedx: 0 not received yet, 1 frame received
-- 				 if it's received, ok or not, allou papa evangelion, is checked on the ppdu degen)
--					 if the FrRec flag is up then somehow is has to go down that is happening
--					 also in ppdu degen

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity arbiter is
    port(  
		clk_250khz	: in std_logic;
		reset		: in std_logic;
		FrReceived0	: in std_logic;		
		FrReceived1	: in std_logic;
		TRX_request	: in std_logic_vector(1 downto 0);
		TX0_enable	: out std_logic;
		RX0_enable	: out std_logic;
		TX1_enable	: out std_logic;
		RX1_enable	: out std_logic
		);
end arbiter;

architecture behavioral of arbiter is
    type state_type is (IDLE, USER0, USER1);
    signal state: state_type;
    signal last_user: std_logic;
	 
--    signal request_sig: std_logic_vector(1 downto 0);
--    signal grant_sig: std_logic_vector(1 downto 0);
    
    begin
		
--		next_user: process(reset, TRX_request)  --(clk_200Mhz, reset)
		next_user: process(clk_250khz)
		begin
		if rising_edge(clk_250khz) then
			if reset = '1' then
				 state <= IDLE;
				 last_user <= '0';
			else
				case state is
					when IDLE =>	if TRX_request = "01" then
										state <=  USER0;
										last_user <=  '0';
									elsif TRX_request = "10" then
										state <=  USER1;
										last_user <=  '1'; 
									elsif TRX_request = "11" then
										if last_user = '0' then
											state <=  USER1;
											last_user <=  '1';
										else 
											state <=  USER0;
											last_user <=  '0';
										end if;  
									end if;
					-- if were at user1 and comes 11 then it goes to user0, 
					-- if then comes 01 it stays to user0 again for second time!!!
					when USER0 =>	if (TRX_request = "01" and FrReceived1 = '1') then --priority
										state <= USER0;
										last_user <= '0';
									elsif FrReceived1 = '1' then 
										if TRX_request = "10" or TRX_request = "11" then
											state <=  USER1;
											last_user <=  '1'; 
										elsif TRX_request = "00" then 
											state <=  IDLE;
											last_user <=  '0';
										end if;  
									-- take note that if TRX_request = "01" and FrReceived1 = '0' den kani tpt
									end if;
--										elsif FrReceived1 = '0' then
--											if TRX_request = "00" then
--												state <=   IDLE;
--											elsif TRX_request = "10" or TRX_request = "11" then
--												state <=  USER1;
--												last_user <=  '1'; 
--											end if;

					when USER1 =>	if (TRX_request = "10" and FrReceived0 = '1') then
										state <= USER1;
										last_user <= '1';
									elsif FrReceived0 = '1' then 
										if TRX_request = "01" or TRX_request = "11" then
											state <=  USER0;
											last_user <=  '0'; 
										elsif TRX_request = "00" then 
											state <=  IDLE;
											last_user <=  '1';
										end if;  
									end if;
--										elsif FrReceived0 = '0' then
--											if TRX_request = "00" then
--												state <= IDLE;
--											elsif TRX_request = "01" or TRX_request = "11" then
--												state <= USER0;
--												last_user <= '0'; 
--											end if;
				end case;   
			end if;
		end if;
		end process;

		output:process(state)
		begin
			case state is
				 when IDLE =>	TX1_enable <= '0';	--	Request	Reset	TX1 TX0 RX1 RX0
								TX0_enable <= '0';	--	-------  ----- --- --- --- ----
								RX1_enable <= '0';	--	0	0		1		0	 0		0	0
								RX0_enable <= '0';	--	0	1				0	 1		1	0
													--	1	0				1	 0		0	1
				 when USER0 => TX1_enable <= '0';	--	1	1				1	 1		1	1 --> not present
								TX0_enable <= '1';
								RX1_enable <= '1';
								RX0_enable <= '0';
									
				 when USER1 => TX1_enable <= '1';
								TX0_enable <= '0';
								RX1_enable <= '0';
								RX0_enable <= '1';
			end case;
		end process;
end behavioral;
