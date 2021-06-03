-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity Queue_tb is
end Queue_tb;

architecture testbench of Queue_tb is

component Queue IS
PORT ( 	clk		:	in	STD_LOGIC; --10 MHz clock
		Write	: 	in 	STD_LOGIC;
		read	: 	in 	STD_LOGIC;
        Data_in	:	in	STD_LOGIC_VECTOR(7 downto 0);
		Data_out:	out	STD_LOGIC_VECTOR(7 downto 0);
        data_present : out STD_LOGIC );
end component;

signal 	clk		:	STD_LOGIC := '0'; --10 MHz clock
signal 	Write	: 	STD_LOGIC 	:= '0';
signal 	Read	: 	STD_LOGIC	:= '0';
signal 	Data_in	:	STD_LOGIC_Vector(7 downto 0) := "00000000";
signal 	Data_out:	STD_LOGIC_Vector(7 downto 0) := "00000000";
signal data_present : STD_LOGIC := '0';

signal period : time := 10ns;
begin

uut : Queue PORT MAP(
		clk  => CLK,
		Read => Read,
        Write => Write,
        Data_in => Data_in,
		Data_out => Data_out,
        data_present => data_present);
    
    
clk_proc : process
BEGIN

  wait for period/2;
  clk <= not clk;

END PROCESS clk_proc;

stim_proc : process
begin
	
    wait for 2*period;
    
    Data_in <= "11110000";
    Write <= '1';
    
    Wait for period;
    
    Write <= '0';
    
    wait for 3*period;
    
    
    Data_in <= "00001111";
    Write <= '1';
    
    wait for period;
    
    Write <= '0';
    
    wait for 2*period;
    
    read <= '1';
    
    wait for 2*period; -- Should read  (should become empty too)
    read <= '0';
    
    wait for 3*period;
    
    write <= '1';
    Data_in <= "11011010";
    
    wait for period;
    
    write <= '0';
    
    wait for period;
    
    read <= '1';
    
    wait for 3*period; -- Attempt to read more than what is in the queue
    read <= '0';
	
    wait;
end process stim_proc;
end testbench;