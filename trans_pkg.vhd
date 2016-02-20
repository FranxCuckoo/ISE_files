--
--	Package File Template
--
--	Purpose: This package defines constants, and functions that are needed in:
--				1) ppdu generation module
--				2) CRC check 
--				3) and clock details
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package trans_pkg is
	--------------------------------------
	-- Global constants
	--------------------------------------

	-- Declare lengths
	constant tt : integer := 32;	--Thirty Two, chip size (bits)
	constant tth: integer := 16;	--Thirty Two Half
	
	-- Types
	-- If using symbols as integers 
	type symbol_array is array (integer range <>) of INTEGER RANGE 0 TO tth-1;
	
	-- type for chip array values
	type chip_array is array(0 to tth-1) of std_logic_vector(tt-1 downto 0);
	
--	constant symbol_length : integer := 4; -- 4 bits
--	constant chip_length	  : integer := tt; -- 32 bits/chips every chip chunk
--	
--	constant m	: integer := 88; -- PPDU size frame
--	constant s	: integer := m/symbol_length; -- 22; number of symbols
--	constant c	: integer := s * tt; -- 704 for an ACK frame
--	
--	constant T_bit		: time := 4000 ns; -- 1/250e3 kbit/s
--	constant T_symbol : time := T_bit*4; --16000 ns; (T_bit * symbol_length) ns; -- 1/62.5e3 kbit/s = 16000 ns
--	constant T_chip 	: time := T_bit/8; -- 1/2000e3 kbit/s = 500 ns
--	constant T_fstClk : time := 5 ns; -- 1/200000e3
	
	-- Chip Values, mapping for the 2450 MHz band 
	constant chipArray : chip_array :=	(	"11011001110000110101001000101110", -- 0
														"11101101100111000011010100100010", -- 1
														"00101110110110011100001101010010", -- 2
														"00100010111011011001110000110101", -- 3
														"01010010001011101101100111000011", -- 4
														"00110101001000101110110110011100", -- 5
														"11000011010100100010111011011001", -- 6
														"10011100001101010010001011101101", -- 7
														"10001100100101100000011101111011", -- 8
														"10111000110010010110000001110111", -- 9
														"01111011100011001001011000000111", -- 10
														"01110111101110001100100101100000", -- 11
														"00000111011110111000110010010110", -- 12
														"01100000011101111011100011001001", -- 13
														"10010110000001110111101110001100", -- 14
														"11001001011000000111011110111000"); -- 15
	
	--------------------------------------
	-- Declare lengths constants
	--------------------------------------
	constant symbol_length : integer := 4; -- 4 bits
	constant chip_length	  : integer := tt; -- 32 bits/chips every chip chunk
	
	constant m	: integer := 88; -- PPDU size frame
	constant s	: integer := m/symbol_length; -- 22; number of symbols
	constant c	: integer := s * tt; -- 704 for an ACK frame
	
	-- Oscilations of Fast clk in a T_bit period
	constant T_bit		: integer := 4000;
	constant T_symbol : integer := T_bit*4;
	constant T_chip 	: integer := T_bit/8;
	constant T_fstClk : integer := 5;
	
	-- Clocks periods
	constant T_bit_period		: time := 4000 ns; -- 1/250e3 kbit/s
	constant T_symbol_period	: time := T_bit_period*4; --16000 ns; (T_bit * symbol_length) ns; -- 1/62.5e3 kbit/s = 16000 ns
	constant T_chip_period 		: time := T_bit_period/8; -- 1/2000e3 kbit/s = 500 ns
	constant T_fstClk_period 	: time := 5 ns; -- 1/200000e3
	
	-------------------------------------------
	-- Declare functions and procedures needed
	-------------------------------------------

	-- Assembles MAC Frame
	function MPDU_frame return std_logic_vector;
	
	-- Assembles together the PPDU frame to be sent to the next block
	-- Inserts preamble, SFD and computes length of 
	function PPDU_func(data : std_logic_vector) return std_logic_vector;
	
	-- CRC-16
	function crc_func(x_MHR : std_logic_vector) return std_logic_vector;

	-- Reverse a vector
	function reverse(x: in std_logic_vector) return std_logic_vector;

end trans_pkg;

package body trans_pkg is
	
	------------------------------------------------------------------------
	-- Puts together the input of the whole system the MAC Frame
	------------------------------------------------------------------------
	function MPDU_frame return std_logic_vector is
	
		-- Basic elements of Frame Control
		-- According to the IEEE Std 802.15.4-2011 figure 36 page 57
		constant FrType	: std_logic_vector(2 downto 0) := "010";	-- 000 : Beacon
		constant SecEn		: std_logic := '0';								--	001 : Data 
		constant FrPend	: std_logic := '0';								-- 010 : ACK frame
		constant AR 		: std_logic := '0';								-- 011 : MAC Command
		constant PANID		: std_logic := '0';
		constant Compr		: std_logic := '0';
		constant Res		: std_logic_vector(1 downto 0) := "00";
		constant DesAddrMode : std_logic_vector(1 downto 0) := "00";
		constant FrVer			: std_logic_vector(1 downto 0) := "00"; --01
		constant SouAddrMode : std_logic_vector(1 downto 0) := "00";

		-- Basic elements of MAC Frame
		constant frame_ctrl : std_logic_vector := FrType & SecEn & FrPend & AR & PANID & Compr & Res & DesAddrMode & FrVer & SouAddrMode;
		constant seq_num : std_logic_vector(7 downto 0) := (others => '0');
--		constant FCS : std_logic_vector(15 downto 0) := CRC_func(MHR);
		-- FCS is calculated over the MHR and MAC payload
		-- Calling CRC function on MHR
		-- MHR: 0X4000 & 0X00
		-- POLY: 0X11021
		-- FCS: 0X1DAD
		
		-- Constructive elements
		constant MHR : std_logic_vector(23 downto 0)	:= frame_ctrl & seq_num;
		constant FCS : std_logic_vector(15 downto 0) := CRC_func(MHR); -- MFR field
--															^
--															|
--															|											
		--		Nesting of functions and procedures is allowed to any level of complexity, and recursion is
--		also supported in the language. (Of course, if you expect to generate actual hardware from
--		your VHDL descriptions using synthesis tools, then you will need to avoid writing recursive
--		functions and procedures, as such descriptions are not synthesizable)


		constant MPDU : std_logic_vector := MHR & FCS; --> vsk touto en xriazete
		
		begin
		--Statements within a subprogram are sequential (like a process)
			return (MHR & FCS);
		
		end MPDU_frame;	
		
	------------------------------------------------------------------------
	-- Puts together the PPDU - Physical Protocol Data Unit
	------------------------------------------------------------------------
	function PPDU_func(data : std_logic_vector) return std_logic_vector is
		-- Basic elements
		constant preamble 	: std_logic_vector(31 downto 0) := x"00000000";
		constant SFD 			: std_logic_vector(7 downto 0):= "11100101";
		constant reserved 	: std_logic := '0';
		constant frame_length: std_logic_vector := std_logic_vector(to_unsigned((data'length/8), 7));

		-- Constructive elements
		constant SHR	: std_logic_vector := preamble & SFD;
		constant PHR	: std_logic_vector := frame_length & reserved;
		constant PSDU	: std_logic_vector := data; -- data is MPDU
		
		begin
			assert (data'high + 1) mod 8 = 0 report "MPDU field not multiple of 8 bits" severity error ;
--			frame_length := std_logic_vector(to_unsigned((MPDU'length/8), frame_length'length));
--			ppdu_frame := preamble & SFD & frame_length & reserved & MPDU;
			
			return SHR & PHR & PSDU;
			
		end PPDU_func;	
		
	---------------------------------------------------------------------	
	-- CRC 16bit for MHR ONLY, using ACK frame so there is no mac payload
	---------------------------------------------------------------------
	function CRC_func(x_MHR : std_logic_vector) return std_logic_vector is
		-- Calling CRC function on MHR
		-- MHR: 0X4000 & 0X00
		-- POLY: 0X11021
		-- FCS: 0X1DAD
		constant m	: integer := x_MHR'length; -- MHR field bits 3 octets
		constant n	: integer := 17; -- poly bits
		
		variable v	: std_logic_vector(m+n-2 downto 0);
		variable u	: std_logic_vector(n-1 downto 0);
		variable w	: std_logic_vector(n-1 downto 0);
		variable y	: std_logic_vector(n-1 downto 0);
		variable i,j: integer := 0;
		variable x	: std_logic_vector(n-2 downto 0);
		
		begin
			v(m+n-2 downto n-1) := x_MHR(m-1 downto 0);
			for j in n-2 downto 0 loop
				v(j):='0';
			end loop;
			u:= "10001000000100001"; --b; G(x) = x16 + x 12 + x 5 + 1
			w:=v(m+n-2 downto m-1);
			
			for i in m-1 downto 0 loop
				if(w(n-1)='1') then
					w:=w xor u;
				else
					null;
				end if;
				
				y:=w;
				w(n-1 downto 1):=y(n-2 downto 0);
				
				if(i=0) then
					w(0):='0';
				else
					w(0):=v(i-1);
				end if;
			end loop;
			x:=w(n-1 downto 1); --redundant bits
			
			return x;
			--t(m+n-2 downto n-1)<=a;
			--t(n-2 downto 0)<=w(n-1 downto 1);
		end CRC_func;
		
	-------------------
	-- Reverse a vector
	-------------------
	function reverse(x: in std_logic_vector) return std_logic_vector is
		variable result : std_logic_vector(x'reverse_range);
	begin
		for i in x'range loop
			result(i) := x(i);
		end loop;
		return result;
	end reverse;
	
	--=======================================================
	-- end of detials help package
	--=======================================================
end trans_pkg;
