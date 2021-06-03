----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/01/2021 05:16:17 PM
-- Design Name: 
-- Module Name: morse_controller - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity morse_sequencer is
    Port ( clk  : in STD_LOGIC;
           morse_in : in STD_LOGIC_VECTOR (7 downto 0);
           queue_sent : in STD_LOGIC;
           signal_out : out STD_LOGIC_VECTOR (1 downto 0);
           ready : out STD_LOGIC);
end morse_sequencer;

architecture Behavioral of morse_sequencer is
-- signals
type state_type is (await, read, analyze, dash_pause, dot_pause, letter_end, space);
signal cs, ns : state_type := await;

-- for output
signal curr_letter : STD_LOGIC_VECTOR(7 downto 0);
signal index : integer := 7;
signal assign_output, clear_output : STD_LOGIC := '0';
signal output_bits : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- assigned during read phase

-- for timing
constant counter_time : integer := 5e6; -- creates a dot-time of 0.5seconds
signal timer_counter : unsigned(26 downto 0) := (others => '0');
signal timer_tc : STD_LOGIC := '0';

-- for state control
signal signal_type : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- assigned in analyze phase, 001 = dot, 010 = dash, 011 = space, 100 = letter end
signal dot_count, dash_count, pause_count, space_count  : STD_LOGIC := '0'; -- used in the pause phases
signal tc : STD_LOGIC := '0';
signal letter_done : STD_LOGIC := '0'; -- HIGH when we have read 8 bts
signal counter : unsigned(2 downto 0) := "000"; -- for the pauses
signal new_data : STD_LOGIC := '0'; -- monopulse queue signal, debounced one cycle
signal queue_wait : integer := 0;

begin

update_state : process(clk)
begin

    if rising_edge(clk) then
        cs <= ns;
        -- debounce & monopulse if needed
        if queue_sent = '1' then
            new_data <= '0'; -- default
            if queue_wait = 0 then
                queue_wait <= queue_wait + 1;
            elsif queue_wait = 1 then -- then we have waited 1 cycle, so new_data can go high
                new_data <= '1';
                queue_wait <= queue_wait + 1; -- set to 2, which does nothing
            end if;
        else 
            queue_wait <= 0; -- reset
            new_data <= '0';
        end if;
         
        -- count for timing
        timer_counter <= timer_counter + 1;
        timer_tc <= '0';
        if to_integer(timer_counter) = counter_time then
            timer_tc <= '1';
            timer_counter <= (others => '0'); -- reset timer
        end if;   
    end if;
    
end process update_state;

next_state : process(cs, new_data, signal_type, tc)
begin
    -- default signals
    ready <= '0';
    assign_output <= '0';
    dot_count <= '0';
    dash_count <= '0';
    space_count <= '0';
    pause_count <= '0';
    clear_output <= '0';
    ns <= cs;
    
    case (cs) is
        when await =>
            clear_output <= '1';
            ready <= '1';
            if new_data = '1' then
                ns <= read;
            end if;
        when read =>
            ns <= analyze;
            assign_output <= '1';
        when analyze =>
            if signal_type = "001" then
                ns <= dot_pause;
            elsif signal_type = "010" then
                ns <= dash_pause;
            elsif signal_type = "011" then
                ns <= space;
            elsif signal_type = "100" then
                ns <= letter_end;
            else ns <= await;
            end if;
        when dot_pause =>
            dot_count <= '1';
            if tc = '1' then
                ns <= read; -- default
                if letter_done = '1' then
                    ns <= await;
                end if;
            end if;
        when dash_pause =>
            dash_count <= '1';
            if tc = '1' then
                ns <= read; -- default
                if letter_done = '1' then
                    ns <= await;
                end if; 
            end if;
        when letter_end =>
            pause_count <= '1';
            if tc = '1' then
                ns <= await;
            end if;
        when space =>
            space_count <= '1';
            if tc = '1' then
                ns <= await;
            end if;
        when others => ns <= cs;
    end case;

end process next_state;

-- count the time that the state should not change when dealing with signals
-- uses the slow clock
time_counter : process(clk)
begin
    if rising_edge(clk) then
        tc <= '0';
        if timer_tc = '1' then
            if dot_count = '1' then
                counter <= counter + 1;
                if counter = "001" then
                    tc <= '1';
                    counter <= "000";
                end if;
            elsif dash_count = '1' then
                counter <= counter + 1;
                if counter = "011" then 
                    tc <= '1';
                    counter <= "000";
                end if;
            elsif space_count = '1' then
                counter <= counter + 1;
                if counter = "110" then -- 6 instead of 7 for the wait time
                    tc <= '1';
                    counter <= "000";
                end if;
            elsif pause_count = '1' then
             -- take into account the 2 clk cycle delay, so do 2 cycles instead of 3
                if counter = "010" then
                    tc <= '1';
                    counter <= "000";
                end if;
            else tc <= '0';
            end if;
        end if;
    end if;

end process time_counter;

-- synchronously get the output data
-- using fast clock
morse_data : process(clk)
begin
    
    if rising_edge(clk) then
        if clear_output = '1' then
            output_bits <= "00"; -- clear out
        end if;
        if new_data = '1' then
            curr_letter <= morse_in;
            index <= 7; -- reset
        elsif assign_output = '1' then
            output_bits <= curr_letter(index downto index-1);
            signal_type <= "000"; -- default signal type
            -- assign signal type
            if curr_letter(index downto index-1) = "00" then
                if index = 7 then
                    signal_type <= "011"; -- it is a space
                else signal_type <= "100"; -- end
                end if;
            elsif curr_letter(index downto index-1) = "10" then
                signal_type <= "001";
            elsif curr_letter(index downto index-1) = "11" then
                signal_type <= "010";
            end if;
        
            -- if at the end, set letter_done to 1
            letter_done <= '0';
            if index = 1 then
                letter_done <= '1';
            else index <= index - 2; -- increase index
            end if;
        end if;
    end if;

end process morse_data;

signal_out <= output_bits; -- tie asynchronously

end Behavioral;
