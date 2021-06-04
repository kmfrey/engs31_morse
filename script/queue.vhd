-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY Queue IS
PORT ( 	clk		:	in	STD_LOGIC; --10 MHz clock
		Write	: 	in 	STD_LOGIC;
		read	: 	in 	STD_LOGIC;
        Data_in	:	in	STD_LOGIC_VECTOR(7 downto 0);
		Data_out:	out	STD_LOGIC_VECTOR(7 downto 0);
		data_sent:  out STD_LOGIC;
        data_present : out STD_LOGIC ); -- Queue not empty signal
end Queue;


architecture behavior of Queue is
constant queue_size : integer := 80;

type regfile is array(0 to (queue_size - 1)) of STD_LOGIC_VECTOR(7 downto 0);
signal Queue_reg : regfile;

signal W_ADDR : integer := 0;
signal R_ADDR : integer := 0;

signal q_empty : std_logic := '1';

signal d_sent : std_logic := '0';
signal data_sent_pulse : unsigned(1 downto 0) := "00"; -- HIGH for 2 cycles

BEGIN

process(clk)
begin
	if rising_edge(clk) then
    	if (Write = '1') then  
        	Queue_reg(W_ADDR) <= Data_in;
            if W_ADDR = (queue_size-1) then  --- W_ADDR Counter
            	W_ADDR <= 0;
      		else
            	W_ADDR <= W_ADDR + 1;
            end if;
        end if;
        
        if (read = '1') and (not (W_ADDR = R_ADDR)) then -- Only update r_addr counter when read signal is asserted and queue is not empty
        	Queue_reg(R_ADDR) <= (others => '0');
        	d_sent <= '1';
        	if R_ADDR = (queue_size-1) then   --- R_ADDR Counter
            	R_ADDR <= 0;
      		else
            	R_ADDR <= R_ADDR + 1;
            end if;
        end if;
        -- update data_sent after 2 full clock cycles
        if d_sent = '1' then
            data_sent_pulse <= data_sent_pulse + 1;
            if data_sent_pulse = "10" then
                d_sent <= '0';
                data_sent_pulse <= "00";
            end if;
        else data_sent_pulse <= "00";
        end if;
        
    end if;
    
    
end process;

process(W_ADDR, R_ADDR) -- Async Empty Signal
begin
if (W_ADDR = R_ADDR) then
  q_empty <= '1';
  else 
    q_empty <= '0';
  end if;
end process;

process(R_ADDR, W_ADDR, q_empty, read) -- Output Update
-- Keeps the previous data_out bits, If queue is empty and read signal not asserted
begin
if (read = '1') and (not (W_ADDR = R_ADDR)) then
	Data_out <= Queue_reg(R_ADDR);

end if;

end process;

data_present <= not q_empty;
data_sent <= d_sent;

end behavior;
        
        