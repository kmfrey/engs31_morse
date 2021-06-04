----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/04/2021 06:34:02 PM
-- Design Name: 
-- Module Name: morse_shell_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity morse_shell_tb is
--  Port ( );
end morse_shell_tb;

ARCHITECTURE testbench OF morse_shell_tb IS 
 
COMPONENT morse_shell is
    Port ( mclk : in STD_LOGIC;
           data_in : in STD_LOGIC;
           led : out STD_LOGIC;
           beep : out STD_LOGIC);
end COMPONENT;
   

   --Inputs
   signal sclk : std_logic := '0';
   signal data_in : std_logic := '1';

 	--Outputs
   signal led : std_logic := '0';
   signal beep : std_logic := '0';

   -- Clock period definitions
   constant sclk_period : time := 10ns;		-- 100 MHz clock for the shell
	
	-- Data definitions
	constant bit_time : time := 104us;		-- 9600 baud, baud period = 1/baud_rate 
--	constant bit_time : time := 8.68us;		-- 115,200 baud
	signal TxData : unsigned(7 downto 0) := "01100000";
	
	-- Test bench specific signals
	constant num_letters : integer := 5;
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
   uut: morse_shell PORT MAP (
        mclk => sclk,
        data_in => data_in,
        led => led,
        beep => beep
        );

   -- Clock process definitions
   sclk_process :process
   begin
		wait for sclk_period/2;
		sclk <= not sclk;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin
        for k in 0 to num_letters loop 		
            wait for 100 us;
            wait for 10.25*sclk_period;		
            
            TxData <= TxData + 1; -- Start from letter a
           
            data_in <= '0';		-- Start bit
            wait for bit_time;
            
            for bitcount in 0 to 7 loop
                data_in <= TxData(bitcount);
                wait for bit_time;
            end loop;
            
            data_in <= '1';		-- Stop bit
            wait for 200 us;
            
        end loop;
            	
		wait;
   end process;
END testbench;

