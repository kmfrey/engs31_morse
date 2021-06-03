-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity sound_wave_tb is
end entity;

architecture tb of sound_wave_tb is

component sound_wave is 
port ( sclk : in std_logic;
	wave_signal : out std_logic);
end component;

-- signals 
signal period : time := 100ns; -- 10 MHz clock
signal sclk, output_clock : std_logic := '0';

begin

uut : sound_wave port map (
	sclk => sclk,
    wave_signal => output_clock
);

clk_proc : process
begin
  wait for period/2;
  sclk <= not sclk;
end process clk_proc;

stim_proc : process
begin
	wait;
end process stim_proc;
end tb;
