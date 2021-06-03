----------------------------------------------------------------------------------
-- Company: Engs31 / CoSc 56
-- Engineer: Samuel Siaw
-- 
-- Create Date: 05/30/2021 08:47:03 PM
-- Design Name: Morse Code Generator
-- Module Name: SCI_Receiver - Behavioral
-- Project Name: Morse Code Generator
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
-- Code your design here

entity SCI_receiver is 
PORT (
	sclk : in std_logic;
    data_in : in std_logic;
    data_out : out std_logic_vector(7 downto 0);
    data_ready : out std_logic
);
end entity;

architecture behaviour of SCI_receiver is
-- Baud Counter Signals
signal baud_count_en : std_logic := '0';
signal baud_count_clr : std_logic := '0';
signal baud_count : integer := 0;
constant baud_rate : integer := 9600; -- Change later
constant clk_freq : integer := 10000000; -- Change later
constant N : integer := 1042;

--constant BAUD_PERIOD : integer := 391; 
--Number of clock cycles needed to achieve a 
--baud rate of 9600 given a 10 MHz clock 
--(10 MHz / 9600 = 1042)

-- Bits Counter Signals
signal bit_count_en : std_logic := '0';
signal bit_count_clr : std_logic := '0';
signal bit_count : integer := 0;
constant count_lim : integer := 10;

-- Controller States
type STATE_TYPE is (idle, start_bcount, hold, bit_shift, ready);
signal curr_state, next_state : STATE_TYPE := idle;

-- Internal Signal(s)
signal data : unsigned(9 downto 0) := (others => '0');
signal d_ready : std_logic := '0';
signal shift_en : std_logic := '0';

begin

stateAndCounterUpdate : process (sclk)
begin
	
    if rising_edge(sclk) then
    	-- Update Baud Counter
        if baud_count_en = '1' then	
        	baud_count <= baud_count + 1;
        elsif baud_count_clr = '1' then
        	baud_count <= 0;
        end if;
        
        -- Bits Counter
        if bit_count_en = '1' then
        	bit_count <= bit_count + 1;
        elsif bit_count_clr = '1' then
        	bit_count <= 0;
        end if;
        
        -- Shift
        if shift_en = '1' then
        	data <= data_in & data(9 downto 1); -- LSB is clocked in first. Use left shi
        end if;
        -- Current State 
        curr_state <= next_state;
      
    end if;
end process stateAndCounterUpdate;


nextStateLogic : process (data_in, curr_state, bit_count, baud_count)

begin
baud_count_en <= '0';
baud_count_clr <= '1';
bit_count_en <= '0';
bit_count_clr <= '1';
shift_en <= '0';


case curr_state is
	when idle =>	
    	if data_in = '0' then
        	next_state <= start_bcount;
        end if;
    
    when start_bcount => -- First bit detected. Start baud count
    	baud_count_en <= '1'; 
        baud_count_clr <= '0';
        bit_count_en <= '0';
        bit_count_clr <= '0';
        d_ready <= '0';  -- Keep data ready bit on till we detect a new set of bits
        
        if baud_count = (N/2) - 1 then 
        	next_state <= bit_shift;
        end if;
    
    when bit_shift => -- Shift in first (start) bit
    	shift_en <= '1';
        bit_count_clr <= '0';
        baud_count_en <= '0';
        baud_count_clr <= '1';
        bit_count_en <= '1';
        
        next_state <= hold;
        
    when hold => -- Pause and wait for baud count to count to N
    	baud_count_en <= '1';
        baud_count_clr <= '0';
        bit_count_en <= '0';
        bit_count_clr <= '0';
        shift_en <= '0';
        
        if bit_count = count_lim then --Clocked in everything
        	next_state <= ready;
            
        elsif baud_count = N-1 then
        	next_state <= bit_shift;
        end if;
    
    when ready =>  -- Send signal to other external components that data is ready
        d_ready <= '1'; 
        next_state <= idle;
end case;
end process nextStateLogic;

outputUpdate : process(d_ready)
begin

if d_ready = '1' then
	data_out <= std_logic_vector(data(8 downto 1));
    -- Discard first and last bits
end if;
end process outputUpdate;

data_ready <= d_ready;

end behaviour;