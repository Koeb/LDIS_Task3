library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mavg_tb is
end mavg_tb;

architecture beh of mavg_tb is
    constant clk_period	: time := 10 ns;
    constant sclk_period : time := 1 us;

    signal testclk : std_logic;
    signal testsclk : std_logic;
    signal btnu : std_logic;
    signal btnd : std_logic;
    signal temp_in : std_logic_vector(15 downto 0);
    signal temp_out : std_logic_vector(15 downto 0);

    component moving_average is
        port (
            Clk : 		in std_logic;  					 	-- clock
            Sample_Clk :	in std_logic;					-- sampling clock
            State_up :	in std_logic;     					-- moving average state up
            State_down :	in std_logic;     				-- moving average state down
            Temp : 		in std_logic_vector(15 downto 0);	-- Temperature Input
            Average_Temp : out std_logic_vector(15 downto 0)-- average temperature for output
        );
    end component;
begin

    uut : moving_average
    port map(
        Clk => testclk,
        Sample_Clk => testsclk,
        State_up => btnu,
        State_down => btnd,
        Temp => temp_in,
        Average_Temp => temp_out
    );

    clkgen : process
    begin
		testclk <= '0';
		wait for clk_period/2;
		testclk <= '1';
		wait for clk_period/2;
	end process;
	
	smpclkgen : process
    begin
		testsclk <= '0';
		wait for sclk_period/2;
		testsclk <= '1';
		wait for sclk_period/2;
	end process;
	
	inputproc : process
	begin
        temp_in <= (others => '0');
        btnu <= '1'; -- high active buttons
        btnd <= '1';
        wait for sclk_period;
        temp_in <= x"0001";
        wait for sclk_period;
        temp_in <= x"0002";
        wait for sclk_period;
        temp_in <= x"0008";
        wait for sclk_period;
        btnu <= '0';
        temp_in <= x"0004";
        wait for sclk_period;
        btnu <= '1';
        wait for 3 * sclk_period;
        temp_in <= x"000A";
        btnu <= '0';
        wait for sclk_period;
        btnu <= '1';
        wait for 3 * sclk_period;
        temp_in <= x"0001";
        btnu <= '0';
        wait for sclk_period;
        btnu <= '1';
		wait for 5 * sclk_period;
        temp_in <= x"FF9C";
        btnd <= '0';
		--assert false report "Successfully finished simulation" severity failure;
		wait;
	end process;

end beh;
