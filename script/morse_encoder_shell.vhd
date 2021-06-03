----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/03/2021 01:36:04 AM
-- Design Name: 
-- Module Name: morse_encoder_shell - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity morse_encoder_shell is
    Port ( mclk : in STD_LOGIC;
           ascii : in STD_LOGIC_VECTOR (7 downto 0);
           queue_data : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (1 downto 0));
end morse_encoder_shell;

architecture Behavioral of morse_encoder_shell is

-- controller & datapath
component morse_sequencer is 
    port ( clk : in STD_LOGIC;
           morse_in : in STD_LOGIC_VECTOR (7 downto 0); -- from morse_LUT
           queue_sent : in STD_LOGIC; -- signal from queue
           signal_out : out STD_LOGIC_VECTOR (1 downto 0);
           ready : out STD_LOGIC);
end component;

component morse_LUT is 
    port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (7 downto 0); -- from queue
           output : out STD_LOGIC_VECTOR (7 downto 0)); -- to sequencer
end component;

-- signals
signal queue_ready : STD_LOGIC := '0';
signal morse_encoded : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal ready : STD_LOGIC := '0';

begin

--=============================================================
--Port Maps:
--=============================================================

sequencer: morse_sequencer
    port map( clk => mclk,
              morse_in => morse_encoded,
              queue_sent => queue_data,
              signal_out => data_out,
              ready => ready);
          
lut : morse_LUT
    port map( clk => mclk,
              addr => ascii,
              output => morse_encoded);
              


end Behavioral;
