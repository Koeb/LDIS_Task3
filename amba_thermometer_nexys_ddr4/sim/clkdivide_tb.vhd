library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clkdivide_tb is
end clkdivide_tb;

architecture beh of clkdivide_tb is
    constant clk_period	: time := 10 ns;
    signal clk : std_logic;
    signal rst : std_logic := '0';
    signal output : std_logic;
    
    component clkdivide is
        generic(
            DIVISOR : natural := 272
        );
        port(
            CLK_IN  : in std_logic; -- system clock as input, in this project 100MHz
            RST     : in std_logic; -- asynchronous reset
            CLK_OUT : out std_logic -- divided clock signal
        );
    end component;
begin

    uut : clkdivide
    generic map(
        DIVISOR => 10
    )
    port map(
        CLK_IN => clk,
        RST => rst,
        CLK_OUT => output
    );
    
    clkgen : process
    begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
	inputproc : process
	begin
	    wait for 1 ms;
		assert false report "Successfully finished simulation" severity failure;
		wait;
	end process;


end beh;

