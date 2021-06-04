----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/04/2021 05:47:16 PM
-- Design Name: 
-- Module Name: morse_outputter - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity morse_output is
    Port ( mclk : in STD_LOGIC;
           signal_in : in STD_LOGIC_VECTOR (1 downto 0);
           new_signal : in STD_LOGIC;
           wave_signal : in STD_LOGIC;
           led : out STD_LOGIC;
           sound : out STD_LOGIC);
end morse_output;

architecture Behavioral of morse_output is

-- for timing
constant counter_time : integer := 5e6; -- 2Hz "clock", since clk is 10MHZ. 0.5s for each dot-time
signal timer_counter : unsigned(22 downto 0) := (others => '0');
signal timer_tc : STD_LOGIC := '0';
signal period_count : unsigned(1 downto 0) := "00"; -- counter for dot & dash HIGH signal

signal curr_signal : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal curr_out : STD_LOGIC := '0';
signal sound_out : STD_LOGIC := '0';

begin

count_cycles : process(mclk, new_signal)
begin    
    if rising_edge(mclk) then
        if new_signal = '1' then
            curr_signal <= signal_in;
            period_count <= "00";
        end if;
    
        timer_counter <= timer_counter + 1;
        if to_integer(timer_counter) = counter_time then
            if period_count < "11" then
                period_count <= period_count + 1; -- don't roll over
            end if;
            timer_counter <= (others => '0'); -- reset timer
        end if;   
    end if;
end process count_cycles;

output : process(period_count, curr_signal, wave_signal)
begin
    case curr_signal is
        when "00" =>
            curr_out <= '0'; -- counter does not matter
            sound_out <= '0';
        when "10" =>
            if period_count = "00" then -- first time period
                curr_out <= '1';
                sound_out <= wave_signal;
            else 
                curr_out <= '0';
                sound_out <= '0';
            end if;
        when "11" =>
            if period_count = "11" then
                curr_out <= '0';
                sound_out <= '0';
            else
                curr_out <= '1';
                sound_out <= wave_signal;
            end if;
        when others => curr_out <= '0';
        
    end case;
end process output;
-- tie outputs
led <= curr_out;
sound <= sound_out;

end Behavioral;
