----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:27:24 12/04/2015 
-- Design Name: 
-- Module Name:    PPDU_degenerator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: The PPDU structure is presented so that the leftmost field as written
--								in this standard shall be transmitted or received first. All  multiple
--								octet fields shall be transmitted or received least significant octet first,
--								and each octet shall be transmitted or received least significant bit (LSB) first
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.receiver_pkg.all;

entity PPDU_degenerator is
    port( ppdu_bit	: in STD_LOGIC;
		  clk_250khz	: in STD_LOGIC;
		  reset		: in STD_LOGIC;
		  RX_enable : in std_logic;
		  received_frame: out STD_LOGIC;
		  check_frame: out STD_LOGIC -- if its 1 its ok, if its 0 is wrong
		);
end PPDU_degenerator;

architecture BEHAV of PPDU_degenerator is
	-- For saving the receiving frame
	signal temp_frame	:	std_logic_vector(m-1 downto 0);-- := (others => '0');

	-- For getting the Preamble and SFD frame
	signal preSFD_temp	:	std_logic_vector(39 downto 0);-- := (others => '0');

	signal SFD_en	: std_logic;

	signal fr_len_temp	: std_logic_vector(7 downto 0);
	signal fr_len_counter: integer range 0 to 7;-- := 0;

	signal PSDU_en	: std_logic; -- := '0';
	--signal PSDU_counter: std_logic_vector(5 downto 0 );
	signal PSDU_counter: integer range 0 to 127;
	signal PSDU_temp	: std_logic_vector(39 downto 0);

	signal fr_len_int : integer range 0 to 127;-- := 0;

	-- for outputting FCS result
	signal output_enable : std_logic;

	signal fcs_check : std_logic_vector(tth-1 downto 0);-- := (others => '1');

begin

	preSFD_temp <= temp_frame(39 downto 0);
--	
--	with preSFD_temp select
--		SFD_en <= '1' when x"00000000e5",
--				  '0' when others; -- here i could insert different values if others kind of packets
--					  
	process(clk_250khz)
	begin
		if  rising_edge(clk_250khz) then
	
			-- The SFD is a field indicating the end of the SHR 
			-- (of a O-QPSK PHY) and the start of the packet data.
			-- For the specific packet that I sent
			if preSFD_temp = x"00000000e5" then
				SFD_en <= '1';
				fr_len_temp <= fr_len_temp(6 downto 0) & ppdu_bit;
				fr_len_counter <= fr_len_counter + 1;
			end if;
						
			if SFD_en = '1' then
				fr_len_temp <= fr_len_temp(6 downto 0) & ppdu_bit;
				fr_len_counter <= fr_len_counter + 1;
				if fr_len_counter = 8 then -- eprepe na en 8
					PSDU_en <= '1';
				
					PSDU_temp <= PSDU_temp(38 downto 0) & ppdu_bit;
					PSDU_counter <= PSDU_counter + 1;

					-- How many bits the PSDU is
					fr_len_int <= 8*(to_integer(unsigned(fr_len_temp(7 downto 1))));
				end if;
			end if;
			if PSDU_en = '1' then
				PSDU_temp <= PSDU_temp(38 downto 0) & ppdu_bit;
				PSDU_counter <= PSDU_counter + 1;
			end if;

			temp_frame <= temp_frame(m-2 downto 0) & ppdu_bit;
--			if (temp_frame(m-2 downto 0) & ppdu_bit) = (x"00000000e5") then
--				SFD_en <= '1'; why this doesnt work?
--			end if;
		end if;
	end process;

--	process(SFD_en, clk_250khz)
--	begin 
--		if rising_edge(clk_250khz) then
--			if SFD_en = '1' then
--				fr_len_temp <= fr_len_temp(6 downto 0) & ppdu_bit;
--				fr_len_counter <= fr_len_counter + 1;
--				if fr_len_counter = 6 then -- eprepe na en 8
--					PSDU_en <= '1';
--				
--					PSDU_temp <= PSDU_temp(38 downto 0) & ppdu_bit;
--					PSDU_counter <= PSDU_counter + 1;
--
--					-- How many bits the PSDU is
--					fr_len_int <= 8*(to_integer(unsigned(fr_len_temp(7 downto 1))));
--				end if;
--			end if;
--			if PSDU_en = '1' then
--				PSDU_temp <= PSDU_temp(38 downto 0) & ppdu_bit;
--				PSDU_counter <= PSDU_counter + 1;
--			end if;
--		end if;
--	end process;
	
--	process(PSDU_en, clk_250khz)
--	begin
--		if rising_edge(clk_250khz) then
--			if PSDU_en = '1' then
--				PSDU_temp <= PSDU_temp(38 downto 0) & ppdu_bit;
--				PSDU_counter <= PSDU_counter + 1;
--			end if;
--		end if;			
--	end process;
	
	process(PSDU_counter, clk_250khz)
	begin
		-- When you get them 40 bits of PSDU
		if rising_edge(clk_250khz) then
			if (PSDU_counter = fr_len_int) and (PSDU_en = '1') then
				fcs_check <= crc_func(PSDU_temp);
				output_enable <= '1';
			end if;	
		end if;
	end process;

	process(clk_250khz, reset)
	begin
		if reset = '1' then
			check_frame <= '0';
			received_frame <= '0';
		elsif rising_edge(clk_250khz) then
			if output_enable = '1' then
				-- Inform that we received a packet
				received_frame <= '1';
				-- Check if our received frame is correct
				if fcs_check = "0000000000000000" then --x"0000" then
					-- OK
					check_frame <= '1';
					case RX_enable is
						when '0' => check_frame <= '0';
						when others => check_frame <= '1'; 
					end case;
				else
					-- NOT OK
					check_frame <= '0'; 
				end if;
			
--				if check_frame = '1' then
--					case RX_enable is
--						when '0' => check_frame <= '0';
--						when '1' => check_frame <= '1'; 
--					end case;
--				end if;
			end if;

		end if;
	end process;

--	check_frame <= '0' when RX_enable'event else
--				   '1' when fcs_check = "0000000000000000";

end BEHAV;

