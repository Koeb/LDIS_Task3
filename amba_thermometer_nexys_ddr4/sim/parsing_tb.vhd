
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SEGNUM.all;

entity parsing_tb is
end parsing_tb;

architecture Behavioral of parsing_tb is

constant clk_period : time := 1 us;
signal twoscomplement : std_logic_vector(15 downto 0);
signal testclk : std_logic;
signal segnumber : SEGNUMBERS;
signal sign : std_logic;

component parsing7seg is
port(
     sample_clk      : in std_logic;
     temp_averaged   : in std_logic_vector(15 downto 0);
     seg_numbers     : out SEGNUMBERS;
     signbit         : out std_logic  
    );
end component;

begin

uut : parsing7seg
    port map(
    sample_clk => testclk,
    temp_averaged => twoscomplement,
    seg_numbers => segnumber,
    signbit => sign
    );

smpclkgen : process
begin
	testclk <= '0';
	wait for clk_period/2;
	testclk <= '1';
	wait for clk_period/2;
end process;
	
inputproc : process
	begin
	twoscomplement <= (others => '0');
	wait for clk_period;
    twoscomplement <= x"0064";
    wait for clk_period;
    twoscomplement <= x"FF9C";
end process;

end Behavioral;
