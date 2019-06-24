
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity windowsize_tb is
--  Port ( );
end windowsize_tb;

architecture Behavioral of windowsize_tb is
    constant clk_period	: time := 10 ns;

    signal testclk : std_logic;
    signal btnu : std_logic;
    signal btnd : std_logic;
    signal state : std_logic_vector(1 downto 0);
  
  
    component windowsize is
           PORT (
        Sample_Clk:	in std_logic;						-- sampling clock		
        State_up:	in std_logic;     					-- moving average state up
        State_down:	in std_logic;                        -- moving average state down
        state: out std_logic_vector(1 downto 0) 			
                );
    end component;
    
begin

    uut : windowsize
    port map(
        Sample_Clk => testclk,
        State_up => btnu,
        State_down => btnd,
        state => state
    );

    clkgen : process
    begin
		testclk <= '0';
		wait for clk_period/2;
		testclk <= '1';
		wait for clk_period/2;
	end process;
	
	proc : process
	begin
	
        btnu <= '1'; -- high active buttons
        btnd <= '1';
        wait for 10 ns;
        btnu <= '0';
        wait for 10 ns;
        btnu <= '1';
        wait for 10 ns;
        btnu <= '0';
        wait for 10 ns;
        btnu <= '1';
        wait for 10 ns;
        btnu <= '0';
        wait for 10 ns;
        btnu <= '1';
        wait for 10 ns;
        btnd <= '0';
        wait for 10 ns;
       
 btnd <= '1';
 		--assert false report "Successfully finished simulation" severity failure;
		wait;
	end process;




end Behavioral;
