--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:43:35 02/29/2016
-- Design Name:   
-- Module Name:   /home/franx/Documents/Xilinx_files_2016/temp/System_testbench.vhd
-- Project Name:  temp
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: System
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY System_testbench IS
END System_testbench;
 
ARCHITECTURE behavior OF System_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT System
    PORT(
         TRX_request : IN  std_logic_vector(1 downto 0);
         clk_250khz : IN  std_logic;
         clk_2Mhz : IN  std_logic;
         clk_1Mhz : IN  std_logic;
         reset : IN  std_logic;
         Frame_Verif0 : OUT  std_logic;
         Frame_Verif1 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal TRX_request : std_logic_vector(1 downto 0) := (others => '0');
   signal clk_250khz : std_logic := '0';
   signal clk_2Mhz : std_logic := '0';
   signal clk_1Mhz : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal Frame_Verif0 : std_logic;
   signal Frame_Verif1 : std_logic;

   -- Clock period definitions
	constant clk_2Mhz_period : time := 0.5 us;
	constant clk_1Mhz_period : time := 1 us;
   constant clk_250khz_period : time := 4 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: System PORT MAP (
          TRX_request => TRX_request,
          clk_250khz => clk_250khz,
          clk_2Mhz => clk_2Mhz,
          clk_1Mhz => clk_1Mhz,
          reset => reset,
          Frame_Verif0 => Frame_Verif0,
          Frame_Verif1 => Frame_Verif1
        );

   -- Clock process definitions
   clk_250khz_process :process
   begin
		clk_250khz <= '1';
		wait for clk_250khz_period/2;
		clk_250khz <= '0';
		wait for clk_250khz_period/2;
   end process;
 
   clk_2Mhz_process :process
   begin
		clk_2Mhz <= '1';
		wait for clk_2Mhz_period/2;
		clk_2Mhz <= '0';
		wait for clk_2Mhz_period/2;
   end process;
	
	clk_1Mhz_process :process
   begin
		clk_1Mhz <= '1';
		wait for clk_1Mhz_period/2;
		clk_1Mhz <= '0';
		wait for clk_1Mhz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 200 ns.
		reset <= '1';
		wait for 200 us;		
		reset <= '0';
		
		-- shouldnt start transmitting
--		wait for 200 us;	
		-- should start now
		
      -- insert stimulus here 
		TRX_request <= "00";
		wait for 200 us;
		TRX_request <= "01";
		wait for 500 us;
		TRX_request <= "10";
		wait for 500 us;
		TRX_request <= "11";
		wait for 500 us;
		TRX_request <= "01";
		wait for 500 us;
		TRX_request <= "00";
		wait for 50 us;
		
		reset <= '1';
		wait for 800 us;		
		reset <= '0';

		TRX_request <= "00";
		wait for 500 us;
		TRX_request <= "01";
		wait for 500 us;
		TRX_request <= "10";
		wait for 500 us;
		TRX_request <= "11";
		wait for 500 us;
		TRX_request <= "01";
		wait for 500 us;
		TRX_request <= "00";
		wait for 500 us;
		
      wait;
   end process;

END;
