library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SEGNUM.all;


entity parsing7seg is
    Port ( 
        sample_clk      : in std_logic;
        temp_averaged   : in std_logic_vector(15 downto 0);
        seg_numbers     : out SEGNUMBERS;
        signbit         : out std_logic  
    );
end parsing7seg;

architecture Behavioral of parsing7seg is
    signal twoComp : std_logic_vector(15 downto 0);
begin 
  
    sync: process(sample_clk)
    begin
        if sample_clk'event and sample_clk = '1' then
            twoComp <= temp_averaged;
        end if;
    end process;
            
     parsing: process(twoComp)
        variable y : integer := 0;
        variable z : integer;
     begin       
            if twoComp(15) = '1' then
                signbit <= '1';
            else
                signbit <= '0';
            end if;
            
            y := abs(to_integer(signed(twoComp)) * 78);
    
            z := y/100000;
            seg_numbers(5) <= z;
            y := y - z * 100000;
            
            z := y/10000;
            seg_numbers(4) <= z;
            y := y - z * 10000;
            
            z := y/1000;
            seg_numbers(3) <= z;
            y := y - z * 1000;
            
            z := y/100;
            seg_numbers(2) <= z;
            y := y - z * 100;
            
            z := y/10;
            seg_numbers(1) <= z;
            y := y - z * 10;
            seg_numbers(0) <= y;
    end process;

end Behavioral;
