----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:00:59 11/08/2012 
-- Design Name: 
-- Module Name:    ComponentIO - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity ComponentIO is
	generic ( 
		gTCQ	: time	:= 2 ns
	); 
		Port (
		iD		:	in		std_logic;
		oT		:	out	std_logic;
		clk	:	in 	std_logic;
		rst	: 	in 	std_logic);
end ComponentIO;

architecture Behavioral of ComponentIO is

signal D : std_logic;

begin
	process(clk, rst) begin
		if (rst = '0') then
			D <= '1' after gTCQ;
		elsif(rising_edge(clk)) then
			D <= iD after gTCQ;
		end if;
	end process;
	
	oT <= D and iD after gTCQ;

end Behavioral;

