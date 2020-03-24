----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:26:31 09/28/2012 
-- Design Name: 
-- Module Name:    main - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity main is
   Port (	
    	clk	: in	std_logic;
	AD	: inout	std_logic_vector(31 downto 0);
	IDSEL	: in	std_logic;
	CBE	: in	std_logic_vector(3 downto 0);
	FRAME	: in	std_logic;			  
	IRDY	: in	std_logic;
	TRDY	: inout	std_logic;
	STOP	: inout	std_logic;
	PAR	: inout	std_logic;
	RST	: in	std_logic;
	DEVSEL	: inout	std_logic;
	LED6	: out	std_logic;
	LED	: out	std_logic
   );
end main;

architecture Behavioral of main is

	signal CfgRData:		std_logic_vector(31 downto 0):=x"00000000";
	
	signal AdrPhASE:		std_logic;
	signal FRAME_D:			std_logic;
	
	signal DEVSEL_T:		std_logic;
	signal DEVSEL_O:		std_logic;
	signal DEVSEL_I:		std_logic;
	
	signal TRDY_T:			std_logic;
	signal TRDY_O:			std_logic;
	signal TRDY_I:			std_logic;

	signal PAR_T:			std_logic;
	signal PAR_O:			std_logic;
	signal PAR_I:			std_logic;
	
	signal STOP_T:			std_logic;
	signal STOP_O:			std_logic;
	signal STOP_I:			std_logic;
	
	signal IDSEL_I: 		std_logic;
	signal FRAME_I:			std_logic;
	signal IRDY_I:			std_logic;
	signal RST_I:			std_logic;
	signal clk_I:			std_logic;
		
	signal AD_I:			std_logic_vector (AD'range);
	signal AD_O:			std_logic_vector (AD'range);
	signal AD_T:			std_logic;
	
	
	signal CBE_I:			std_logic_vector (CBE'range);
	
	signal AD_ID:			std_logic_vector (AD_I'range);
	signal CBE_ID:			std_logic_vector (CBE_I'range);
	signal FRAME_ID:		std_logic;
	signal IRDY_ID:			std_logic;
	signal TRDY_ID:			std_logic;
	signal DEVSEL_ID:		std_logic;
	
	signal AddrPhase:		std_logic;

	constant cTCQ:			time := 2 ns;
	
	type TSM_PCI_T is		(sIDLE, sDECODE, sCFG_READ, sCFG_WRITE, sIO_READ, sIO_WRITE, sMEM_READ, sMEM_WRITE); 
	signal smPCI_T: 		TSM_PCI_T;
	signal Address:			std_logic_vector(AD_I'range);
	signal Command:			std_logic_vector(CBE'range);
	signal bCfgTr:			boolean;
	
	signal CommandReg:		std_logic_vector(15 downto 0) := x"0000";
	signal StatusReg:		std_logic_vector(15 downto 0) := x"0200";
	signal LatencyTimer:		std_logic_vector(7 downto 0) := x"00";
	signal CacheLineSize:		std_logic_vector(7 downto 0) := x"00";
	signal BAR0:			std_logic_vector(31 downto 0) := x"00000001";
	signal BAR1:			std_logic_vector(31 downto 0) := x"00000000";
	signal InterruptLine:		std_logic_vector(7 downto 0);
	
	signal IOReg0:			std_logic_vector (31 downto 0);
	signal IOReg1:			std_logic_vector (31 downto 0);
	signal IOReg2:			std_logic_vector (31 downto 0);
	signal IOReg3:			std_logic_vector (31 downto 0);
	signal IOReg4:			std_logic_vector (31 downto 0);
	signal IOReg5:			std_logic_vector (31 downto 0);
	signal IOReg6:			std_logic_vector (31 downto 0);
	signal IOReg7:			std_logic_vector (31 downto 0);
	signal IOReg8:			std_logic_vector (31 downto 0);
	signal IOReg9:			std_logic_vector (31 downto 0);
	signal IORDate:			std_logic_vector (31 downto 0);
	
	signal RamWrEn:			std_logic;
	signal RamOutputDate:		std_logic_vector (31 downto 0);
	signal RamInputDate:		std_logic_vector (31 downto 0);
	signal RamRst:			std_logic := '0';
	
	
	function b2l(b : boolean) return std_logic is
	begin
		if(b)then return '1'; end if;
		return '0';
	end b2l;
	
begin


-------------------------------------------------------------------------	
--Перевести шину AD в третье состояние
	AD_BUF:
	for iCount in AD'low to AD'high generate
	      begin
        
		IOBUF_AD : IOBUF
		generic map 
		(
		DRIVE => 12,
		IOSTANDARD => "PCI33_3",
		SLEW => "SLOW")
		port map (
			O => AD_I(iCount),
			IO => AD(iCount),
			I => AD_O(iCount),
			T => AD_T
		);
	end generate;
--

	CBE_BUF:
	for iCount in CBE'low to CBE'high generate
	begin
		IBUF_CBE : IBUF
		generic map (IOSTANDARD => "PCI33_3")
		port map (	
		O => CBE_I(iCount),     -- Buffer output
		I => CBE(iCount));      -- Buffer input (connect directly to top-level port)
	end generate;

	IOBUF_TRDY : IOBUF
	generic map (
		DRIVE => 12,
		IOSTANDARD => "PCI33_3",
		SLEW => "SLOW")
	port map (
		O => TRDY_I,     -- Buffer output
		IO => TRDY,   	-- Buffer inout port (connect directly to top-level port)
		I => TRDY_O,     -- Buffer input
		T => TRDY_T      -- 3-state enable input, high=input, low=output 
	);
	

	IOBUF_DEVSEL : IOBUF
	generic map (
		DRIVE => 12,
		IOSTANDARD => "PCI33_3",
		SLEW => "SLOW")
	port map (
		O => DEVSEL_I,     -- Buffer output
		IO => DEVSEL,   -- Buffer inout port (connect directly to top-level port)
		I => DEVSEL_O,     -- Buffer input
		T => DEVSEL_T      -- 3-state enable input, high=input, low=output 
	);
	

	IOBUF_RAR : IOBUF
	generic map (
		DRIVE => 12,
		IOSTANDARD => "PCI33_3",
		SLEW => "SLOW")
	port map (
		O => PAR_I,     -- Buffer output
		IO => PAR,   -- Buffer inout port (connect directly to top-level port)
		I => PAR_O,     -- Buffer input
		T => PAR_T      -- 3-state enable input, high=input, low=output 
	);
	

	IOBUF_STOP : IOBUF
	generic map (
		DRIVE => 12,
		IOSTANDARD => "PCI33_3",
		SLEW => "SLOW")
	port map (
		O => STOP_I,     -- Buffer output
		IO => STOP,   -- Buffer inout port (connect directly to top-level port)
		I => STOP_O,     -- Buffer input
		T => STOP_T      -- 3-state enable input, high=input, low=output 
	);
	
	IBUF_IDSEL : IBUF
	generic map (
		IOSTANDARD => "PCI33_3")
	port map (
		O => IDSEL_I,     -- Buffer output
		I => IDSEL      -- Buffer input (connect directly to top-level port)
	);
	
	IBUF_IRDY: IBUF
	generic map (
		IOSTANDARD => "PCI33_3")
	port map (
		O => IRDY_I,     -- Buffer output
		I => IRDY      -- Buffer input (connect directly to top-level port)
	);	
	
	IBUF_RST: IBUF
	generic map (
		IOSTANDARD => "PCI33_3")
	port map (
		O => RST_I,     -- Buffer output
		I => RST      -- Buffer input (connect directly to top-level port)
	);		
	
	IBUFG_clk : IBUFG
	generic map (
		IOSTANDARD => "PCI33_3")
	port map (
		O => clk_I, -- Clock buffer output
		I => clk  -- Clock buffer input (connect directly to top-level port)
	);	

	IBUF_FRAME: IBUF
	generic map (IOSTANDARD => "PCI33_3")
	port map 	(	O => FRAME_I,     -- Buffer output
					I => FRAME	 );    -- Buffer input (connect directly to top-level port)
		
	
	RAMB16_S36_S36_inst : RAMB16_S36_S36
	port map (
		DOA	=> open,			-- Port A 32-bit Data Output
		DOB	=> RamOutputDate,		-- Port B 32-bit Data Output
		DOPA	=> open,			-- Port A 4-bit Parity Output
		DOPB	=> open,			-- Port B 4-bit Parity Output
		ADDRA	=> Address(8 downto 0),		-- Port A 9-bit Address Input
		ADDRB	=> Address(8 downto 0),		-- Port B 9-bit Address Input
		CLKA	=> clk_I,			-- Port A Clock
		CLKB	=> clk_I,			-- Port B Clock
		DIA	=> RamInputDate,		-- Port A 32-bit Data Input
		DIB	=> x"00000000",			-- Port B 32-bit Data Input
		DIPA	=> x"0",			-- Port A 4-bit parity Input
		DIPB	=> x"0",			-- Port-B 4-bit parity Input
		ENA	=> '1',				-- Port A RAM Enable Input
		ENB	=> '1',				-- PortB RAM Enable Input
		SSRA	=> '0',				-- Port A Synchronous Set/Reset Input
		SSRB	=> '0',				-- Port B Synchronous Set/Reset Input
		WEA	=> RamWrEn,			-- Port A Write Enable Input
		WEB	=> '0'				-- Port B Write Enable Input
	);

	
	-------------------------------------Внутренние сигналы---------------------------------------------------	

	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			FRAME_D <= '1' after cTCQ;
		elsif (rising_edge(clk_I)) then
			FRAME_D <= FRAME_I after cTCQ;
		end if;
	end process;
	
	AdrPhASE <= not FRAME_I and FRAME_D;
	
	process(clk_I) begin
		if (rising_edge(clk_I)) then
			if (RST_I = '1') then
				RamRst <= '0';
			else
				RamRst <= '1';
			end if;
		end if;
	end process;
	
	process (clk_I) begin
		if (rising_edge(clk_I)) then
			case (Address(7 downto 0)) is 
				when x"00"	=> CfgRData <= x"00017788" ; --Device ID and Vendor ID
				when x"04"	=> CfgRData <= StatusReg & CommandReg; --Status Register, Command Register
				when x"08"	=> CfgRData <= x"10000001"; -- Class Code and Revision ID
				when x"0C"	=> CfgRData <= x"0000" & LatencyTimer & CacheLineSize; -- BIST, Header Type(bit 7 = 0, single, bits 6-0 = 0, type0), Latency Timer(for masters), Cache Line Size (bit 2 in 1)
				when x"10"	=> CfgRData <= BAR0; -- Base Adress 0 (Register IO address decoder)
				when x"14"	=> CfgRData <= BAR1; -- Base Adress 1
				when x"28"	=> CfgRData <= x"00000000"; -- CarfdBus CIS Pointer
				when x"2C"	=> CfgRData <= x"00017788"; -- Subsystem ID, Subsystem Vendor ID
				when x"30"	=> CfgRData <= x"00000000"; -- Expanxion Rom Base Address
				when x"34"	=> CfgRData <= x"00000000"; -- Reserved, Capabilitis Pointer
				when x"38"	=> CfgRData <= x"00000000";	-- Reserved
				when x"3C"	=> CfgRData <= x"004001" & InterruptLine;	-- Max_Lat(only bus master), Min_Gnt, Interrupt Pin, Interrupt Line
				when others	=> CfgRData <= (others => '0');
			end case;	
		end if;
	end process;
	

	process(clk_I, RST_I) begin
		if (RST_I = '0') then
			smPCI_T <= sIDLE after cTCQ;
		elsif (rising_edge(clk_I)) then
			case (smPCI_T) is
				when sIDLE	=>	if (AdrPhASE = '1') then smPCI_T <= sDECODE after cTCQ;	end if;
				when sDECODE	=>	if (bCfgTr and Address(10 downto 8) = b"000" and Command(3 downto 1) = b"101")  then
								if (Command(0) = '0') then smPCI_T <= sCFG_READ	after cTCQ;
								else smPCI_T <= sCFG_WRITE after cTCQ; end if;
							elsif (Command(3 downto 1)= b"001") and (Address(31 downto 8) = BAR0(31 downto 8))then	
								if (Command(0) = '0') then smPCI_T <= sIO_READ after cTCQ;
								else smPCI_T <= sIO_WRITE after cTCQ;	end if;
							elsif (Command(3 downto 1) = b"011") and (Address(31 downto 16) = BAR1(31 downto 16)) then
								if (Command(0) = '0') then smPCI_T <= sMEM_READ	after cTCQ;
									else smPCI_T <= sMEM_WRITE after cTCQ; end if;
							else smPCI_T <= sIDLE after cTCQ; 
							end if;
				when sCFG_READ	=>	if (IRDY_I = '0') then	smPCI_T <= sIDLE after cTCQ;  end if;  	
				when sCFG_WRITE	=>	if (IRDY_I = '0') then	smPCI_T <= sIDLE after cTCQ;  end if;  	
				when sIO_WRITE	=>	if (IRDY_I = '0') then	smPCI_T <= sIDLE after cTCQ;  end if;  	
				when sIO_READ	=>	if (IRDY_I = '0') then	smPCI_T <= sIDLE after cTCQ;  end if;  	
				when sMEM_READ	=>	if (IRDY_I = '0') then	smPCI_T <= sIDLE after cTCQ;  end if;
				when sMEM_WRITE	=>	if (IRDY_I = '0') then	smPCI_T	<= sIDLE after cTCQ;  end if;
				when others		=>										smPCI_T <= sIDLE		after cTCQ;
			end case;
		end if;
	end process;
	
	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			Address	<= (others => '0') after cTCQ;
			Command	<= (others => '0') after cTCQ;
			bCfgTr <= false after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (AdrPhASE = '1') then
				Address	<= AD_I	 after cTCQ;
				Command	<= CBE_I after cTCQ;
				bCfgTr	<= (IDSEL_I = '1') after cTCQ;
			end if;
		end if;
	end process;
	
	----------------------------------------Выходные сигналы------------------------------------------
	
	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			DEVSEL_O <= '1' after cTCQ;
		elsif(rising_edge(clk_I))then
			DEVSEL_O <= not b2l(smPCI_T = sCFG_READ or smPCI_T = sCFG_WRITE or 
			smPCI_T = sIO_READ or smPCI_T = sIO_WRITE or 
			smPCI_T = sMEM_READ or smPCI_T = sMEM_WRITE or
			(smPCI_T = sDECODE and bCfgTr and Address(10 downto 8) = b"000" and Command(3 downto 1) = b"101")) after cTCQ;
		end if;
	end process;
	
	DEVSEL_STS : entity WORK.componentIO(Behavioral)
	port map (iD => DEVSEL_O, oT => DEVSEL_T, clk => clk_I, rst => RST_I);
	
	process(RST_I, clk_I)begin
		if(RST_I = '0')then
			TRDY_O <= '1' after cTCQ;
		elsif(rising_edge(clk_I))then
			TRDY_O <= not b2l(smPCI_T = sCFG_READ or smPCI_T = sCFG_WRITE or 
			smPCI_T = sIO_WRITE or smPCI_T = sIO_READ or
			smPCI_T = sMEM_READ or smPCI_T = sMEM_WRITE) after cTCQ;
		end if;
	end process;
	
	TRDY_STS : entity WORK.componentIO(Behavioral)
	port map ( iD => TRDY_O, oT	=> TRDY_T, clk => clk_I, rst => RST_I);
	
	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			STOP_O <= '1' after cTCQ;
		elsif(rising_edge(clk_I))then
			STOP_O <= '1' after cTCQ; 
		end if;
	end process;
	
	STOP_STS : entity	WORK.componentIO(Behavioral)
	port map ( iD => STOP_O, oT => STOP_T, clk	=> clk_I, rst => RST_I);
	
	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			PAR_O <= '1' after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (AD_T = '0') then
				PAR_O <= (	AD_I( 0) xor AD_I( 1) xor AD_I( 2) xor AD_I(3) xor AD_I(4) xor AD_I(5) xor AD_I(6) xor AD_I(7) xor
									AD_I( 8) xor AD_I( 9) xor AD_I(10) xor AD_I(11) xor AD_I(12) xor AD_I(13) xor AD_I(14) xor AD_I(15) xor
									AD_I(16) xor AD_I(17) xor AD_I(18) xor AD_I(19) xor AD_I(20) xor AD_I(21) xor AD_I(22) xor AD_I(23) xor 
									AD_I(24) xor AD_I(25) xor AD_I(26) xor AD_I(27) xor AD_I(28) xor AD_I(29) xor AD_I(30) xor AD_I(31) xor
									CBE_I(0) xor CBE_I(1) xor CBE_I(2) xor CBE_I(3)) after cTCQ;
			end if;
		end if;
	end process;
	
	process(clk_I) begin
		if (RST_I = '0') then
			PAR_T <= '1' after cTCQ;
		elsif (rising_edge(clk_I)) then
			PAR_T <= AD_T after cTCQ;
		end if;
	end process;
	
	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			AD_O <= (others => '0') after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sCFG_READ) then
				AD_O <= CfgRData after cTCQ;
			elsif (smPCI_T = sIO_READ) then
				AD_O <= IORDate after cTCQ;
			elsif (smPCI_T = sMEM_READ) then
				AD_O <= RamOutputDate after cTCQ;
			end if;
		end if;
	end process;
	
	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			AD_T <= '1' after cTCQ;
		elsif (rising_edge(clk_I)) then
			AD_T <= not b2l(smPCI_T = sCFG_READ or smPCI_T = sIO_READ or smPCI_T = sMEM_READ) after cTCQ;
		end if;
	end process;
	
	----------------------------------------------------------------------
	--Configuration Write
	----------------------------------------------------------------------
	process(clk_I, RST_I) begin
		if(RST_I = '0')then
			CommandReg <= x"0000" after cTCQ;
			StatusReg <= x"0200" after cTCQ;
			LatencyTimer <= x"00" after cTCQ;
			CacheLineSize <= x"00" after cTCQ;
			BAR0 <= x"00000001" after cTCQ;
			BAR1 <= x"00000000" after cTCQ;
		elsif(rising_edge(clk_I)) then
			if (smPCI_T = sCFG_WRITE) then
				case(Address(7 downto 0)) is 
					when x"04"	=>	if (CBE_I(1) = '0') then	CommandReg(15 downto 8) <= AD_I(15 downto 8)	after cTCQ; end if;
									if (CBE_I(0) = '0') then	CommandReg(7 downto 0) <= AD_I(7 downto 0)		after cTCQ; end if;
					when x"0C"	=>	if (CBE_I(1) = '0') then	LatencyTimer <= AD_I(15 downto 8)				after cTCQ; end if;
									if (CBE_I(0) = '0') then	CacheLineSize <= AD_I(7 downto 0)				after cTCQ; end if;
					when x"10"	=>	if (CBE_I(3) = '0')	then 	BAR0(31 downto 24) <= AD_I(31 downto 24)		after cTCQ; end if;
									if (CBE_I(2) = '0')	then 	BAR0(23 downto 16) <= AD_I(23 downto 16)		after cTCQ; end if;
									if (CBE_I(1) = '0')	then 	BAR0(15 downto 8) <= AD_I(15 downto 8)			after cTCQ; end if;
					when x"14"	=>	if (CBE_I(3) = '0')	then 	BAR1(31 downto 24) <= AD_I(31 downto 24)		after cTCQ; end if;
									if (CBE_I(2) = '0')	then 	BAR1(23 downto 16) <= AD_I(23 downto 16)		after cTCQ; end if;
					when x"3C"	=>	if (CBE_I(0) = '0') then	InterruptLine <= AD_I(7 downto 0)				after cTCQ; end if;
					when others	=>	null;
				end case;
			end if;
		end if;
	end process;
	
	-----------------------------------------------------------------------
	--IO WRITE
	-----------------------------------------------------------------------
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
			IOReg0 <= x"00000000" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"00") then
				if (CBE_I(0) = '0') then	IOReg0( 7 downto  0) <= AD_I( 7 downto  0) after cTCQ; end if;
				if (CBE_I(1) = '0') then 	IOReg0(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg0(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg0(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
			IOReg1 <= x"00000000" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"04") then
				if (CBE_I(0) = '0') then	IOReg1( 7 downto  0) <= AD_I( 7 downto  0) after cTCQ; end if;
				if (CBE_I(1) = '0') then 	IOReg1(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg1(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg1(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;	
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
			IOReg2 <= x"00000000" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"08") then
				if (CBE_I(0) = '0') then	IOReg2( 7 downto  0) <= AD_I(7  downto  0) after cTCQ; end if;
				if (CBE_I(1) = '0') then 	IOReg2(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg2(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg2(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;	
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
			IOReg3 <= x"00000003" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"0C") then
				if (CBE_I(1) = '0') then 	IOReg3(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg3(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg3(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;		
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
			IOReg3 <= x"00000003" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"0C") then
				if (CBE_I(1) = '0') then 	IOReg3(15 downto  8) <= AD_I(15 downto 8 ) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg3(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg3(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;		
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
		    IOReg4 <= x"00000000" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"10") then
				if (CBE_I(0) = '0') then	IOReg4( 7 downto  0) <= AD_I( 7 downto  0) after cTCQ; end if;
				if (CBE_I(1) = '0') then 	IOReg4(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg4(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg4(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
		    IOReg5 <= x"00000000" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"14") then
					if (CBE_I(0) = '0') then	IOReg5( 7 downto  0) <= AD_I( 7 downto  0) after cTCQ; end if;
					if (CBE_I(1) = '0') then 	IOReg5(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
					if (CBE_I(2) = '0') then 	IOReg5(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
					if (CBE_I(3) = '0') then 	IOReg5(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
		    IOReg6 <= x"00000000" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"18") then
				if (CBE_I(0) = '0') then	IOReg6( 7 downto  0) <= AD_I( 7 downto  0) after cTCQ; end if;
				if (CBE_I(1) = '0') then 	IOReg6(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg6(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg6(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
		    IOReg7 <= x"00000000" after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sIO_WRITE and Address(7 downto 0) = x"1C") then
				if (CBE_I(0) = '0') then	IOReg7( 7 downto  0) <= AD_I( 7 downto  0) after cTCQ; end if;
				if (CBE_I(1) = '0') then 	IOReg7(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0') then 	IOReg7(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0') then 	IOReg7(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
			end if;
		end if;
	end process;
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
		    IOReg8 <= x"88888888" after cTCQ; --ReadOnly
		end if;
	end process;
	
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
		    IOReg9 <= x"99999999" after cTCQ; --ReadOnly
		end if;
	end process;

	
	process(clk_I) begin
		if (rising_edge(clk_I)) then
			LED6 <= IOReg4(0) after cTCQ;
		end if;
	end process;
	
	
	-----------------------------------------------------------------------
	--IO Read
	-----------------------------------------------------------------------
	process (clk_I, RST_I) begin
		if (RST_I = '0') then
			IORDate <= x"00000000";
		elsif (rising_edge(clk_I)) then
				case (Address(7 downto 0)) is
					when x"00" =>	IORDate <= IOReg0 after cTCQ;
					when x"04" =>	IORDate <= IOReg1 after cTCQ;
					when x"08" =>	IORDate <= IOReg2 after cTCQ;
					when x"0C" =>	IORDate <= IOReg3 after cTCQ;
					when x"10" =>	IORDate <= IOReg4 after cTCQ;
					when x"14" =>	IORDate <= IOReg5 after cTCQ;
					when x"18" =>	IORDate <= IOReg6 after cTCQ;
					when x"1C" =>	IORDate <= IOReg7 after cTCQ;
					when x"20" =>	IORDate <= IOReg8 after cTCQ;
					when x"24" =>	IORDate <= IOReg9 after cTCQ;
					when others =>	IORDate <= (others => '0');
				end case;
		end if;
	end process;
	
	
	-----------------------------------------------------------------------
	-- Memory Write
	-----------------------------------------------------------------------
	process(clk_I, RST_I) begin
		if(RST_I = '0') then
			RamInputDate <= (others => '0') after cTCQ;
			RamWrEn <= '0' after cTCQ;
		elsif (rising_edge(clk_I)) then
			if (smPCI_T = sMEM_WRITE) then
				if (CBE_I(0) = '0')	then	RamInputDate(7  downto  0) <= AD_I( 7 downto  0) after cTCQ; end if;
				if (CBE_I(1) = '0')	then	RamInputDate(15 downto  8) <= AD_I(15 downto  8) after cTCQ; end if;
				if (CBE_I(2) = '0')	then	RamInputDate(23 downto 16) <= AD_I(23 downto 16) after cTCQ; end if;
				if (CBE_I(3) = '0')	then	RamInputDate(31 downto 24) <= AD_I(31 downto 24) after cTCQ; end if;
				RamWrEn <= '1' after cTCQ;
			else 
				RamWrEn <= '0' after cTCQ;
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------
	-- Memory Read
	----------------------------------------------------------------------


	------------------------------------------------------------------------
	-- Debug
	------------------------------------------------------------------------
	process(clk_I)begin
		if(rising_edge(clk_I))then
			AD_ID		<= AD_I;
			CBE_ID		<= CBE_I;
			FRAME_ID	<= FRAME_I;
			IRDY_ID		<= IRDY_I;
			TRDY_ID		<= TRDY_I;
			DEVSEL_ID	<= DEVSEL_I;
		end if;
	end process;
	
	process(clk_I)begin
		if(rising_edge(clk_I))then
			LED <= FRAME_ID xor IRDY_ID xor TRDY_ID xor DEVSEL_ID xor CBE_ID(3) xor CBE_ID(2) xor CBE_ID(1) xor CBE_ID(0) xor
					AD_ID(31) xor AD_ID(30) xor AD_ID(29) xor AD_ID(28) xor AD_ID(27) xor AD_ID(26) xor AD_ID(25) xor AD_ID(24) xor 
					AD_ID(23) xor AD_ID(22) xor AD_ID(21) xor AD_ID(20) xor AD_ID(19) xor AD_ID(18) xor AD_ID(17) xor AD_ID(16) xor 
					AD_ID(15) xor AD_ID(14) xor AD_ID(13) xor AD_ID(12) xor AD_ID(11) xor AD_ID(10) xor AD_ID( 9) xor AD_ID( 8) xor 
					AD_ID( 7) xor AD_ID( 6) xor AD_ID( 5) xor AD_ID( 4) xor AD_ID( 3) xor AD_ID( 2) xor AD_ID( 1) xor AD_ID( 0);
		end if;
	end process;

end Behavioral;
