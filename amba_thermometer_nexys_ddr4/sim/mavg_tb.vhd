library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mavg_tb is
end mavg_tb;

architecture beh of mavg_tb is
    constant clk_period	: time := 10 ns;
    constant sclk_period : time := 1 us;

    signal testclk : std_logic;
    signal testsclk : std_logic;
    signal windowsize : std_logic_vector(1 downto 0);
    signal temp_in : std_logic_vector(15 downto 0);
    signal temp_out : std_logic_vector(15 downto 0);

    component moving_average is
        port (
            Sample_Clk    :   in std_logic;                       -- sampling clock		
            Temp          :   in std_logic_vector(15 downto 0);	  -- Temperature Input
            Average_Temp  :   out std_logic_vector(15 downto 0);  -- average temperature for output
            state         :   in std_logic_vector(1 downto 0)    
        );
    end component;
begin

    uut : moving_average
    port map(
        Sample_Clk => testsclk,
        Temp => temp_in,
        Average_Temp => temp_out,
        state => windowsize
    );

	
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
        windowsize <= (others => '0');
        wait for sclk_period;
        temp_in <= x"0001";
        wait for sclk_period;
        temp_in <= x"0002";
        wait for sclk_period;
        windowsize <= "01";
        temp_in <= x"0008";
        wait for sclk_period;
        temp_in <= x"0004";
        wait for sclk_period;
        temp_in <= x"000A";
        windowsize <= "10";
        wait for sclk_period;
        temp_in <= x"0001";
        windowsize <= "11";
        wait for sclk_period;
		wait for 5 * sclk_period;
        temp_in <= x"FF9C";
		wait;
	end process;

end beh;
