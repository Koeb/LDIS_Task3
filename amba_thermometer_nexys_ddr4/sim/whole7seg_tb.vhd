library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity whole7seg_tb is
end whole7seg_tb;

architecture beh of whole7seg_tb is
    constant clk_period	: time := 10 ns;
    constant sclk_period : time := 1 ms;--250 ms;
    signal testclk : std_logic;
    signal testsclk : std_logic;
    signal input : std_logic_vector(15 downto 0);
    signal cath : std_logic_vector(7 downto 0);
    signal an : std_logic_vector(7 downto 0);
    
    component whole7segment is
    port(
        clk : in std_logic;
        sample_clk : in std_logic;
        temp_averaged : in std_logic_vector(15 downto 0);
        CATHODES : out std_logic_vector(7 downto 0);
        ANODES : out std_logic_vector(7 downto 0));
    end component;
begin

    uut : whole7segment
    port map(
        clk => testclk,
        sample_clk => testsclk,
        temp_averaged => input,
        CATHODES => cath,
        ANODES => an
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
	    --for i in 0 to 9 loop
		--	bcd <= std_logic_vector(to_unsigned(i,4));
		--	wait for 2 ns;
		--end loop;
		input <= (others => '0');
		wait for 1 ms;
		input <= x"0064";
		wait for 1 ms;
        input <= x"FF9C";
		--assert false report "Successfully finished simulation" severity failure;
		wait;
	end process;


end beh;
