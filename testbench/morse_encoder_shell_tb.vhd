----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/03/2021 04:11:03 PM
-- Design Name: 
-- Module Name: morse_encoder_shell_tb - testbench
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity morse_encoder_shell_tb is
--  Port ( );
end morse_encoder_shell_tb;

architecture testbench of morse_encoder_shell_tb is

component morse_encoder_shell is
Port ( mclk : in STD_LOGIC;
       ascii : in STD_LOGIC_VECTOR (7 downto 0);
       queue_data : in STD_LOGIC;
       data_out : out STD_LOGIC_VECTOR (1 downto 0));
end component;

signal mclk : STD_LOGIC := '0';
signal ascii : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal queue_data : STD_LOGIC := '0';
signal data_out : STD_LOGIC_VECTOR(1 downto 0) := "00";

constant clk_period: time := 10ns;		-- simulating a 100 MHz clock

begin

dut : morse_encoder_shell
    port map ( mclk => mclk,
               ascii => ascii,
               queue_data => queue_data,
               data_out => data_out);
               
clkgen_proc: process
begin
    mclk <= not(mclk);
    wait for clk_period/2;
end process clkgen_proc;

stim_proc : process
begin
    wait for 5*clk_period;
    ascii <= "01100100"; --d
    wait for clk_period;
    queue_data <= '1'; 
    wait for 2*clk_period;
    queue_data <= '0';
    
    wait;
    
end process stim_proc; 

end testbench;
