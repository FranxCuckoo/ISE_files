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
			 clk_250khz	: in STD_LOGIC; -- in
			 clk_200Mhz	: in STD_LOGIC; -- in
			 reset		: in STD_LOGIC;
			 received_frame: out STD_LOGIC;
			 check_frame: out STD_LOGIC -- if its 0 its ok, if its 1 is wrong or not ready
			 );
end PPDU_degenerator;

architecture Behavioral of PPDU_degenerator is

-- For getting the whole frame
signal temp_frame	:	std_logic_vector(m-1 downto 0) := (others => '0');

-- For getting the Preamble and SFD frame
signal preSFD_temp	:	std_logic_vector(39 downto 0) := (others => '0'); --temp_frame(39 downto 0);
signal SFD_en	: std_logic := '0';

signal fr_len_temp	: std_logic_vector(7 downto 0);
signal fr_len_counter: integer range 0 to 7 := 0;

signal PSDU_en	: std_logic := '0';
--signal PSDU_counter: std_logic_vector(5 downto 0 );
signal PSDU_counter: integer range 0 to 127 := 0;
signal PSDU_temp	: std_logic_vector(39 downto 0) := (others => '1');

signal fr_len_int : integer range 0 to 127 := 0;

-- for outputting FCS result
signal output_enable : std_logic := '0';

signal fcs_check : std_logic_vector(tth-1 downto 0) := (others => '1');

begin

	preSFD_temp <= temp_frame(39 downto 0);
	
--	check_frame <= '0' when fcs_check = x"0000";
--	
--	with fcs_check select check_frame <=  '0' when x"0000",
--													  '1' when others;
					  
	process(clk_250khz)
	begin
		if rising_edge(clk_250khz) then
		
			-- The SFD is a field indicating the end of the SHR 
			-- (of a O-QPSK PHY) and the start of the packet data.
			if preSFD_temp = x"00000000e5" then
				SFD_en <= '1';
--				else
--					SFD_en <= '0';
			end if;
						
			temp_frame <= temp_frame(m-2 downto 0) & ppdu_bit;
		
		end if;
	end process;

	process(SFD_en, clk_250khz)
	variable frame_length : std_logic_vector(6 downto 0);
	begin
			if (SFD_en = '1' and clk_250khz = '1') then
				fr_len_temp <= fr_len_temp(8-2 downto 0) & ppdu_bit;
				fr_len_counter <= fr_len_counter + 1;
				if fr_len_counter = 8 then
					PSDU_en <= '1';
					
					-- How many bits the PSDU is
					fr_len_int <= 8*(to_integer(unsigned(fr_len_temp(7 downto 1))));
				end if;
			end if;
	end process;
	
	process(PSDU_en, clk_250khz)
	variable frame_length : std_logic_vector(6 downto 0);
	begin
		
		if (PSDU_en = '1' and clk_250khz = '1') then
			
			PSDU_temp <= PSDU_temp(38 downto 0) & ppdu_bit;
			PSDU_counter <= PSDU_counter + 1;
		end if;			
	end process;
	
	process(PSDU_counter, clk_200Mhz)
	begin
		-- When you get them 40 bits of PSDU
		if rising_edge(clk_200Mhz) then --FALLING
			if (PSDU_counter = fr_len_int) and (PSDU_en = '1') then
				fcs_check <= crc_func(PSDU_temp);
				output_enable <= '1';
			end if;	
		end if;
	end process;

	process(clk_200Mhz, reset)
	begin
		if reset = '1' then		 -- if reset then what??
			check_frame <= '1';	-- If not commented out we drive the check_frame with two drivers
			received_frame <= '0';
		elsif rising_edge(clk_200Mhz) then
			if output_enable = '1' then
				-- Check if our received frame is correct
				if fcs_check = "0000000000000000" then --x"0000" then
					-- OK
					check_frame <= '1';
					received_frame <= '1';
				else
					-- NOT OK
					check_frame <= '0'; 
					received_frame <= '1';
				end if;
			end if;
		end if;
	end process;

end Behavioral;

