----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Samuel Siaw
-- 
-- Create Date: 06/03/2021 10:40:23 PM
-- Design Name: 
-- Module Name: sound_wave - Behavioral
-- Project Name: 
-- Target Devices: Morse Code Generator [Kai & Sam]
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

entity sound_wave is
    Port ( sclk : in STD_LOGIC;  -- 10MHz clock
           wave_signal : out STD_LOGIC);  -- 500 Hz clock signal  
end sound_wave;

architecture Behavioral of sound_wave is
-- Signal 
signal count : integer := 0;
signal period_count : integer := 20000; -- 10MHz / 500 Hz
signal output : std_logic := '0';
begin

process(sclk) 
begin
if rising_edge(sclk) then
    if count = period_count/2 then
        output <= not output;
    end if;
    
    if count = period_count then
        count <= 0;
        output <= not output;
    else
        count <= count + 1;
    end if;
    
end if;
end process;

wave_signal <= output;

end Behavioral;
