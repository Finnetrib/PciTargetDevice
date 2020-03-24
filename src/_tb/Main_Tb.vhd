--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:23:33 10/12/2012
-- Design Name:   
-- Module Name:   E:/work/users/Pci/ConnectToPci/src/_tb/Main_Tb.vhd
-- Project Name:  ConnectToPci
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
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
 
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all; 
 
ENTITY Main_Tb IS
END Main_Tb;
 
ARCHITECTURE behavior OF Main_Tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
  

   --Inputs
   signal clk : std_logic := '0';
   signal IDSEL : std_logic := '0';
   signal CBE : std_logic_vector(3 downto 0) := (others => 'Z');
   signal FRAME : std_logic := 'H';
   signal IRDY : std_logic := 'H';
   signal RST : std_logic := '0';

	--BiDirs
   signal AD : std_logic_vector(31 downto 0) := (others => 'Z');
   signal TRDY : std_logic;
   signal STOP : std_logic;
   signal PAR : std_logic;
   signal DEVSEL : std_logic;

   -- Clock period definitions
   constant clk_period : time := 30 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity WORK.main(Behavioral) PORT MAP (
          clk => clk,
          AD => AD,
          IDSEL => IDSEL,
          CBE => CBE,
          FRAME => FRAME,
          IRDY => IRDY,
          TRDY => TRDY,
          STOP => STOP,
          PAR => PAR,
          RST => RST,
          DEVSEL => DEVSEL
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
--   
	PULLUP_FRAME:	PULLUP port map (O => FRAME);
	PULLUP_IRDY:	PULLUP port map (O => IRDY);
	PULLUP_TRDY:	PULLUP port map (O => TRDY);
	PULLUP_DEVSEL:	PULLUP port map (O => DEVSEL);
	PULLUP_STOP:	PULLUP port map (O => STOP);

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 60 ns.
	  --Configuration Read
	  RST <= '0';
      wait for 60 ns;	-- Rst будет выставлен на 60 нс
	  RST <= '1';
	  
      wait for clk_period*2;
	  IDSEL <= '1';
	  AD <= x"00040800";
	  CBE <= x"A";
	  FRAME <= '0';
	  IRDY <= 'H';
	  --TRDY <= '1';
	  
	  wait for clk_period;
	  IDSEL <= '0';
	  AD <= (others => 'Z');
	  CBE <= b"0000";
	  FRAME <= '1';
	  IRDY <= '0';
	  
	  wait for clk_period;
	  FRAME <= 'H';
	  
	  wait until rising_edge(clk) and DEVSEL = '0' and (STOP = '0' or TRDY = '0');
	  --wait for clk_period;
	  IRDY  <= '1' after 3 ns;
	  CBE	<= (others => 'Z')  after 3 ns;
	  wait for clk_period;
	  IRDY	<= 'H' after 3 ns;
	  
	  ------------------------------------------
	  -- Configuration Write
--	  wait for clk_period*2;
--	  wait for clk_period/2;
--	  IDSEL <= '1';
--	  AD <= x"80041014";
--	  CBE <= x"B";
--	  FRAME <= '0';
--	  IRDY <= 'H';
--	  --TRDY <= '1';
--	  
--	  wait for clk_period;
--	  IDSEL <= '0';
--	  AD <= x"0A0B0C0D";
--	  CBE <= b"0110";
--	  FRAME <= '1';
--	  IRDY <= '0';
--	  
--	  wait for clk_period;
--	  FRAME <= 'H';
--	  
--	  wait until rising_edge(clk) and DEVSEL = '0' and (STOP = '0' or TRDY = '0');
--	  --wait for clk_period;
--	  IRDY  <= '1' after 3 ns;
--	  AD	<= (others => 'Z') after 3 ns;
--	  CBE	<= (others => 'Z') after 3 ns;
--	  wait for clk_period;
--	  IRDY  <= 'H' after 3 ns;
	  
	  
	  -----------------------------------------
	  -- IO Write
--	  wait for clk_period*2;
--	  wait for clk_period/2;
--	  AD <= x"00000000";
--	  CBE <= x"3";
--	  FRAME <= '0';
--	  IRDY <= 'H';
--	  --TRDY <= '1';
--	  
--	  wait for clk_period;
--	  IDSEL <= '0';
--	  AD <= x"1A2B3C45";
--	  CBE <= b"1001";
--	  FRAME <= '1';
--	  IRDY <= '0';
--	  
--	  wait for clk_period;
--	  FRAME <= 'H';
--	  
--	  wait until rising_edge(clk) and DEVSEL = '0' and (STOP = '0' or TRDY = '0');
--	  --wait for clk_period;
--	  IRDY  <= '1' after 3 ns;
--	  AD	<= (others => 'Z') after 3 ns;
--	  CBE	<= (others => 'Z') after 3 ns;
--	  wait for clk_period;
--	  IRDY  <= 'H' after 3 ns;
	  
	  -----------------------------------------
	  -- IO Read
--	  wait for clk_period*2;
--	  wait for clk_period/2;
--	  AD <= x"00000024";
--	  CBE <= x"2";
--	  FRAME <= '0';
--	  IRDY <= 'H';
--	  --TRDY <= '1';
--	  
--	  wait for clk_period;
--	  IDSEL <= '0';
--	  AD <= (others => 'Z');
--	  CBE <= b"0000";
--	  FRAME <= '1';
--	  IRDY <= '0';
--	  
--	  wait for clk_period;
--	  FRAME <= 'H';
--	  
--	  wait until rising_edge(clk) and DEVSEL = '0' and (STOP = '0' or TRDY = '0');
--	  --wait for clk_period;
--	  IRDY  <= '1' after 3 ns;
--	  AD	<= (others => 'Z') after 3 ns;
--	  CBE	<= (others => 'Z') after 3 ns;
--	  wait for clk_period;
--	  IRDY  <= 'H' after 3 ns;	  

	  -----------------------------------------
	  -- MEM Write
	  wait for clk_period*2;
	  wait for clk_period/2;
	  AD <= x"00000004";
	  CBE <= x"7";
	  FRAME <= '0';
	  IRDY <= 'H';
	  --TRDY <= '1';
	  
	  wait for clk_period;
	  IDSEL <= '0';
	  AD <= x"1A2B3C48";
	  CBE <= b"0000";
	  FRAME <= '1';
	  IRDY <= '0';
	  
	  wait for clk_period;
	  FRAME <= 'H';
	  
	  wait until rising_edge(clk) and DEVSEL = '0' and (STOP = '0' or TRDY = '0');
	  --wait for clk_period;
	  IRDY  <= '1' after 3 ns;
	  AD	<= (others => 'Z') after 3 ns;
	  CBE	<= (others => 'Z') after 3 ns;
	  wait for clk_period;
	  IRDY  <= 'H' after 3 ns;


	  -----------------------------------------
	  -- MEM Read
	  wait for clk_period*2;
	  wait for clk_period/2;
	  AD <= x"00000004";
	  CBE <= x"6";
	  FRAME <= '0';
	  IRDY <= 'H';
	  --TRDY <= '1';
	  
	  wait for clk_period;
	  IDSEL <= '0';
	  AD <= (others => 'Z');
	  CBE <= b"0000";
	  FRAME <= '1';
	  IRDY <= '0';
	  
	  wait for clk_period;
	  FRAME <= 'H';
	  
	  wait until rising_edge(clk) and DEVSEL = '0' and (STOP = '0' or TRDY = '0');
	  --wait for clk_period;
	  IRDY  <= '1' after 3 ns;
	  AD	<= (others => 'Z') after 3 ns;
	  CBE	<= (others => 'Z') after 3 ns;
	  wait for clk_period;
	  IRDY  <= 'H' after 3 ns;


	  ------------------------------------------
      -- insert stimulus here 

      wait;
   end process;

END;
