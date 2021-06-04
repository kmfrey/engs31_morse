----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/03/2021 10:13:51 PM
-- Design Name:
-- Module Name: morse_shell - Behavioral
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

entity morse_shell is
    Port ( mclk : in STD_LOGIC;
           data_in : in STD_LOGIC;
           led : out STD_LOGIC;
           beep : out STD_LOGIC);
end morse_shell;

architecture Behavioral of morse_shell is

-- SCI receiver
component SCI_receiver is
PORT (
	sclk : in std_logic;
    data_in : in std_logic;
    data_out : out std_logic_vector(7 downto 0);
    data_ready : out std_logic);
end component;

-- Queue to hold ASCII signals from SCI Receiver
component Queue IS
PORT ( 	clk		:	in	STD_LOGIC; --10 MHz clock
		Write	: 	in 	STD_LOGIC;
		read	: 	in 	STD_LOGIC;
        Data_in	:	in	STD_LOGIC_VECTOR(7 downto 0);
		Data_out:	out	STD_LOGIC_VECTOR(7 downto 0);
		data_sent : out STD_LOGIC;
        data_present : out STD_LOGIC ); -- Queue not empty signal
end component;

-- look up table for ascii->morse encoding
component morse_LUT is
    port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (7 downto 0);
           output : out STD_LOGIC_VECTOR (7 downto 0));
end component;

-- controller & datapath
component morse_sequencer is
    port ( clk : in STD_LOGIC;
           morse_in : in STD_LOGIC_VECTOR (7 downto 0);
           queue_sent : in STD_LOGIC;
           signal_out : out STD_LOGIC_VECTOR (1 downto 0);
           signal_sent : out STD_LOGIC;
           ready : out STD_LOGIC);

end component;

-- clock divider
component sound_wave is
    port ( sclk : in STD_LOGIC;
           wave_signal : out STD_LOGIC);
end component;

-- sound & led output
component morse_output is
    port ( mclk : in STD_LOGIC;
           signal_in : in STD_LOGIC_VECTOR (1 downto 0);
           new_signal : in STD_LOGIC;
           wave_signal : in STD_LOGIC;
           led : out STD_LOGIC;
           sound : out STD_LOGIC);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timing Signals:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Signals for the clock divider, which divides the master clock down to 10MHz
-- Master clock frequency / CLOCK_DIVIDER_VALUE = 20 MHz
constant clk10MHz_tc: integer := 5;
--constant clk10Hz_tc: integer := 10;
signal clk10MHz_count: unsigned(3 downto 0) := (others => '0');    -- clock divider counter
signal clk10MHz_tog: std_logic := '0';                        -- terminal count
signal clk: std_logic := '0';

-- signals
signal ascii_enqueue : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- SCI to queue
signal write : STD_LOGIC := '0'; -- SCI to queue
signal ascii_dequeued : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- queue to LUT
signal encoded_morse : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- LUT to sequencer
signal sent_new_char : STD_LOGIC := '0'; -- queue to sequencer
signal ready_for_new_char : STD_LOGIC := '0'; -- sequencer to queue
signal output_signal : STD_LOGIC_VECTOR := "00"; -- sequencer to output
signal signal_sent : STD_LOGIC := '0';
signal not_empty : STD_LOGIC := '0';
signal read_char : STD_LOGIC := '0'; -- monopulsed ready
signal read_mono : STD_LOGIC := '0'; -- to keep track of monopulse
signal wave : STD_LOGIC := '0'; -- soundwave to output


begin

--10 Hz Clock:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Clock buffer for the 10 MHz clock
-- Copied from lab 3
clock_buffer_10MHz: BUFG
      port map (I => clk10MHz_tog,
                O => clk );

-- Divide the master clock down to 20 MHz, then toggling the
-- clkdiv_tog signal at 20 MHz gives a 10 MHz clock with 50% duty cycle.
clock10MHz_divider: process(mclk)
begin
	if rising_edge(mclk) then
	   	if clk10MHz_count = clk10MHz_tc-1 then
	   		clk10MHz_tog <= NOT(clk10MHz_tog);       -- Toggle flip flop
			clk10MHz_count <= (others => '0');
		else
			clk10MHz_count <= clk10MHz_count + 1;    -- Counter
		end if;
	end if;
end process clock10MHz_divider;

--=============================================================
--Port Maps:
--=============================================================
sci_rec : SCI_receiver
    port map( sclk => clk,
                data_in => data_in,
                data_out => ascii_enqueue,
                data_ready => write);

ascii_queue : Queue
    port map( clk => clk,
              Write => write,
              read => read_char,
              Data_in => ascii_enqueue,
              Data_out => ascii_dequeued,
              data_sent => sent_new_char,
              data_present => not_empty);

lut : morse_LUT
    port map( clk => clk,
              addr => ascii_dequeued,
              output => encoded_morse);

sequencer: morse_sequencer
    port map( clk => clk,
              morse_in => encoded_morse,
              queue_sent => sent_new_char,
              signal_out => output_signal,
              signal_sent => signal_sent,
              ready => ready_for_new_char);

 sound_generator: sound_wave
    port map ( sclk => clk,
               wave_signal => wave);

 outputter: morse_output
    port map ( mclk => clk,
               signal_in => output_signal,
               new_signal => signal_sent,
               wave_signal => wave,
               led => led,
               sound => beep);

-- monopulse for read (based on whether there is something in queue or not)
pop : process(clk)
begin
    if rising_edge(clk) then
        read_char <= '0'; -- default
        if ready_for_new_char = '1' then
            -- only go high if there is something to read, otherwise keep tryng
            if read_mono = '0' and not_empty = '1' then
                read_char <= '1';
                read_mono <= '1'; -- monopulse
            end if;
        else
            read_mono <= '0'; -- reset the monopulse
        end if;
    end if;
end process pop;

end Behavioral;
