----------------------------------------------------------------------------------
-- Company: ENGS 31
-- Engineer: Kai Frey
-- 
-- Create Date: 06/01/2021 12:25:47 AM
-- Design Name: 
-- Module Name: morse_LUT - lut
-- Project Name: Morse Code Encoder 
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

entity morse_LUT is
    Port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (7 downto 0);
           output : out STD_LOGIC_VECTOR (7 downto 0));
end morse_LUT;

architecture Behavior of morse_LUT is

-- monopulse signal
signal data_pulse : STD_LOGIC := '0';

begin

-- synchronous lookup
lookup : process(clk)
begin
    if rising_edge(clk) then
        case addr is
            -- form is the code and trailing 0s to pad
            -- "10" is a dot, "11" is a dash
            -- starts at 'a', goes to 'z'. Then space
            when "01100001" => output <= "1011" & "0000"; -- a
            when "01100010" => output <= "11101010";
            when "01100011" => output <= "11101110";
            when "01100100" => output <= "111010" & "00";
            when "01100101" => output <= "10" & "000000";
            when "01100110" => output <= "10101110";
            when "01100111" => output <= "111110" & "00";
            when "01101000" => output <= "10101010";
            when "01101001" => output <= "1010" & "0000";
            when "01101010" => output <= "10111111";
            when "01101011" => output <= "111011" & "00";
            when "01101100" => output <= "10111010";
            when "01101101" => output <= "1111" & "0000";
            when "01101110" => output <= "1110" & "0000";
            when "01101111" => output <= "111111" & "00";
            when "01110000" => output <= "10111110";
            when "01110001" => output <= "11111011";
            when "01110010" => output <= "101110" & "00";
            when "01110011" => output <= "101010" & "00";
            when "01110100" => output <= "11" & "000000";
            when "01110101" => output <= "101011" & "00";
            when "01110110" => output <= "10101011";
            when "01110111" => output <= "101111" & "00";
            when "01111000" => output <= "11101011";
            when "01111001" => output <= "11101111";
            when "01111010" => output <= "11111010";    -- z
            
            when "00100000" => output <= "00000000"; -- space
            when others => output <= "00000000";
        end case;
    end if;
end process lookup;

end Behavior;
