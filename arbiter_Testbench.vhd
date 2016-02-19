--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:42:41 01/09/2016
-- Design Name:   
-- Module Name:   C:/Users/Tziambazis/Copy/ThesisM/Xilinx_files_2016/TransceiverArbiter/arboter_v6_Testbench.vhd
-- Project Name:  TransceiverArbiter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: arbiter_v6
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
 
ENTITY arbiter_Testbench IS
END arbiter_Testbench;
 
ARCHITECTURE behavior OF arbiter_Testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT arbiter
    PORT(
         clk_200Mhz : IN  std_logic;
         reset : IN  std_logic;
         FrReceived0 : IN  std_logic;
         FrReceived1 : IN  std_logic;
         TRX_request : IN  std_logic_vector(1 downto 0);
         TX0_enable : OUT  std_logic;
         RX0_enable : OUT  std_logic;
         TX1_enable : OUT  std_logic;
         RX1_enable : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_200Mhz : std_logic := '0';
   signal reset : std_logic := '0';
   signal FrReceived0 : std_logic := '0';
   signal FrReceived1 : std_logic := '0';
   signal TRX_request : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal TX0_enable : std_logic;
   signal RX0_enable : std_logic;
   signal TX1_enable : std_logic;
   signal RX1_enable : std_logic;

   -- Clock period definitions
   constant clk_200Mhz_period : time := 5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: arbiter_v6 PORT MAP (
          clk_200Mhz => clk_200Mhz,
          reset => reset,
          FrReceived0 => FrReceived0,
          FrReceived1 => FrReceived1,
          TRX_request => TRX_request,
          TX0_enable => TX0_enable,
          RX0_enable => RX0_enable,
          TX1_enable => TX1_enable,
          RX1_enable => RX1_enable
        );

   -- Clock process definitions
   clk_200Mhz_process :process
   begin
		clk_200Mhz <= '0';
		wait for clk_200Mhz_period/2;
		clk_200Mhz <= '1';
		wait for clk_200Mhz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		

      -- wait for clk_200Mhz_period;

      -- insert stimulus here 
		-- synchronous stimulus
		reset <= '1';
		wait for 20 ns;
		reset <= '0';
		
		-- dioti einai IDLE mode tha mbi sto USER1 mode kai tha mini eki 
		TRX_request <= "00"; -- stays idle cause no one wants to transmit
		wait for 10 ns;
		TRX_request <= "01"; -- USER0 tekes grant
		wait for 10 ns;
		TRX_request <= "10"; -- FrRec = 0 so it shouldnt change
		wait for 10 ns;
		TRX_request <= "11"; -- FrRec = 0 so it shouldnt change
		wait for 10 ns;
		FrReceived1 <= '1'; -- o user1 received the data, so USER0 did his job 
		
		TRX_request <= "01"; -- USER0 mode asks for access but goes to IDLE mode first
		wait for 5 ns;		-- at the next clk, user0 takes grant
		FrReceived1 <= '0';
		wait for 5 ns;
		FrReceived1 <= '1'; -- receiver1 received data, USER0 did his job
		wait for 5 ns;		  -- after a clk mode goes to IDLE
		FrReceived1 <= '0';
		
		TRX_request <= "10"; -- USER1 mode asks for access
			wait for 5 ns;
			FrReceived0 <= '0';
			wait for 5 ns;
			FrReceived0 <= '1'; -- receiver1 received data, USER0 did his job
			wait for 5 ns;
			FrReceived0 <= '0';
			
		TRX_request <= "11"; -- USER1 and USER0 asks for access
			wait for 5 ns;		-- lastuser was USER1 so it should access user0
			FrReceived1 <= '0';
			wait for 5 ns;
			FrReceived1 <= '1'; -- receiver1 received data, USER0 did his job
			wait for 5 ns;
			FrReceived1 <= '0';
		
		
		wait for 10 ns;
		reset <= '1';
		wait for 10 ns;
		reset <= '0';

      wait;
   end process;

END;
