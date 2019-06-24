library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package SEGNUM is
    
    type SEGNUMBERS is array (5 downto 0) of integer;
    
end package;


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.SEGNUM.all;

entity whole7segment is
    port(
        display_clk : in std_logic;
        seg_numbers  : in SEGNUMBERS;
        signbit : in std_logic;
        CATHODES : out std_logic_vector(7 downto 0);
        ANODES : out std_logic_vector(7 downto 0)
         
        );
end entity;

architecture beh of whole7segment is
    
    signal seg_counter : integer := 0;
    
begin


    output: process(display_clk)
        variable dot : std_logic;
    begin
        if display_clk'event and display_clk = '1' then
        
            if seg_counter = 4 then
                dot := '0';
            else
                dot := '1';
            end if;

            if seg_counter < 6 then
                case seg_numbers(seg_counter) is
                    -------------- abcdefg + dot ----------------
                    when 0 => CATHODES <="0000001" & dot;  -- '0'
                    when 1 => CATHODES <="1001111" & dot;  -- '1'
                    when 2 => CATHODES <="0010010" & dot;  -- '2'
                    when 3 => CATHODES <="0000110" & dot;  -- '3'
                    when 4 => CATHODES <="1001100" & dot;  -- '4'
                    when 5 => CATHODES <="0100100" & dot;  -- '5'
                    when 6 => CATHODES <="0100000" & dot;  -- '6'
                    when 7 => CATHODES <="0001111" & dot;  -- '7'
                    when 8 => CATHODES <="0000000" & dot;  -- '8'
                    when 9 => CATHODES <="0000100" & dot;  -- '9'
                    
                    --nothing is displayed when a number more than 9 is given as input.
                    when others=> CATHODES <= "11111111";
                end case;
            elsif seg_counter = 6 then
                if signbit = '1' then
                    CATHODES <= "11111101";
                else
                    CATHODES <= "11111111";
                end if;
            else
                CATHODES <= "11111111"; 
            end if;

            ANODES <= x"FF";
            ANODES(seg_counter) <= '0';

            seg_counter <= seg_counter + 1;
            if seg_counter = 7 then
                seg_counter <= 0;
            end if;
         end if;
    end process;
end architecture;
