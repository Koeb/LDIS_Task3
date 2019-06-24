library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


--------------------------------------
--	Gliding Window Time Table		--
--									--
--	state		Average Time		--
--------------------------------------
--	default		1 x sampling time	--
--	1			2 x sampling time	--
--	2			4 x sampling time	--
--------------------------------------


entity windowsize is
    PORT (
        Sample_Clk:	in std_logic;						-- sampling clock		
        State_up:	in std_logic;     					-- moving average state up
        State_down:	in std_logic;                        -- moving average state down
        state: out std_logic_vector(1 downto 0)
       );  					
end windowsize;


architecture behavioral of windowsize is

signal current_state : std_logic_vector(1 downto 0) := "00";

begin	
	
	window_size: process(Sample_Clk, State_up, State_down)
    begin
        if Sample_Clk'event and Sample_Clk = '1' then
            if State_up = '1' and State_down = '0' then
                if unsigned(current_state) < 3 then
                    current_state <= std_logic_vector(unsigned(current_state) + 1);
                end if;
            elsif State_up = '0' and State_down = '1' then
                if unsigned(current_state) > 0 then
                    current_state <= std_logic_vector(unsigned(current_state) - 1);
                end if;
            end if;
        end if;  
    end process;
    
    state <= current_state;
end Behavioral;
