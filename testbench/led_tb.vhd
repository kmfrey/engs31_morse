----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/04/2021 06:45:59 PM
-- Design Name: 
-- Module Name: led_tb - testbench
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

entity led_tb is
--  Port ( );
end led_tb;

architecture testbench of led_tb is

component morse_output is
Port ( mclk : in STD_LOGIC;
       signal_in : in STD_LOGIC_VECTOR (1 downto 0);
       new_signal : in STD_LOGIC;
       wave_signal : in STD_LOGIC;
       led : out STD_LOGIC;
       sound : out STD_LOGIC);
end component;

signal clk : STD_LOGIC := '0';
signal signal_in : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal new_signal : STD_LOGIC := '0';
signal led, sound : STD_LOGIC := '0';
constant clk_period : time := 10ns; -- 100 MHz for testing

begin

uut: morse_output 
    port map (
        mclk => clk,
        signal_in => signal_in,
        new_signal => new_signal,
        wave_signal => '1', -- don't worry about clock for sound, just output high
        led => led,
        sound => sound);
        
clk_proc : process
begin
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
end process clk_proc;

stim_proc : process
begin
    wait for clk_period;
    signal_in <= "10";
    wait for clk_period;
    new_signal <= '1';
    wait for clk_period;
    new_signal <= '0';
    wait for 10000000*clk_period;
    signal_in <= "11";
    wait for clk_period;
    new_signal <= '1';
    wait for clk_period;
    new_signal <= '0';
    wait;
    
end process stim_proc;
end testbench;
