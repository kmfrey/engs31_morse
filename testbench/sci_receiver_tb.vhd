--------------------------------------------------------------------------------
-- Course:	 		Engs 31 16S
-- 
-- Create Date:   17:11:39 07/25/2009
-- Modified:      06/03/2021
-- Design Name:   SCI Receiver Testbench
-- Module Name:   SerialRx_tb.vhd
-- Project Name:  Lab5
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SerialRx
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 2.00 - Adapted for Morse Code Generator -ENGS 31 21S [Kai and Sam]
-- Additional Comments:

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
 
ENTITY SerialRx_tb IS
END SerialRx_tb;
 
ARCHITECTURE behavior OF SerialRx_tb IS 
 
COMPONENT SCI_Receiver
	PORT(
		sclk : IN std_logic;
		data_in : IN std_logic;   
		--rx_shift : out std_logic;		-- for testing      
		data_out :  out std_logic_vector(7 downto 0);
		data_ready : out std_logic  );
	END COMPONENT;
   

   --Inputs
   signal sclk : std_logic := '0';
   signal data_in : std_logic := '1';

 	--Outputs
   signal rx_shift : std_logic;
   signal data_out : std_logic_vector(7 downto 0);
   signal data_ready : std_logic;

   -- Clock period definitions
   constant sclk_period : time := 100ns;		-- 10 MHz clock
	
	-- Data definitions
	constant bit_time : time := 104us;		-- 9600 baud
--	constant bit_time : time := 8.68us;		-- 115,200 baud
	constant TxData : std_logic_vector(7 downto 0) := "01101001";
	
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
   uut: SCI_Receiver PORT MAP (
          sclk => sclk,
          data_in => data_in,
         -- rx_shift => rx_shift,
          data_out => data_out,
          data_ready => data_ready
        );

   -- Clock process definitions
   sclk_process :process
   begin
		sclk <= '0';
		wait for sclk_period/2;
		sclk <= '1';
		wait for sclk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
		wait for 100 us;
		wait for 10.25*sclk_period;		
		
		data_in <= '0';		-- Start bit
		wait for bit_time;
		
		for bitcount in 0 to 7 loop
			data_in <= TxData(bitcount);
			wait for bit_time;
		end loop;
		
		data_in <= '1';		-- Stop bit
		wait for 200 us;
		
		data_in <= '0';		-- Start bit
		wait for bit_time;
		
		for bitcount in 0 to 7 loop
			data_in <= not( TxData(bitcount) );
			wait for bit_time;
		end loop;
		
		data_in <= '1';		-- Stop bit
		
		wait;
   end process;
END;
