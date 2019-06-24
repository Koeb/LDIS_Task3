library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity clkdivide is
    generic(
        DIVISOR : natural := 272 -- this value is suitable for creating the I2C SCL clock
    );
    port(
        CLK_IN  : in std_logic; -- system clock as input, in this project 100MHz
        RST     : in std_logic; -- asynchronous reset
        CLK_OUT : out std_logic  -- divided clock signal
    );
end clkdivide;

architecture beh of clkdivide is
    signal counter : integer range 0 to DIVISOR/2-1 := 0;
    signal tmp : std_logic := '0'; -- needed as we cannot read from output pin
begin
    process(RST, CLK_IN)
    begin
        if RST = '1' then
            counter <= 0;
            tmp <= '0';
        elsif CLK_IN'event and CLK_IN = '1' then
            if counter = DIVISOR/2-1 then
                counter <= 0;
                tmp <= not tmp;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    CLK_OUT <= tmp;

end beh;