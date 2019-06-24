----------------
--Moving Average
----------------



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity moving_average is
	PORT (
		Sample_Clk    :   in std_logic;                       -- sampling clock		
		Temp          :   in std_logic_vector(15 downto 0);	  -- Temperature Input
		Average_Temp  :   out std_logic_vector(15 downto 0);  -- average temperature for output
		state         :   in std_logic_vector(1 downto 0)    
	);
end moving_average;



architecture behavioral of moving_average is
	signal temp_in_ex0, temp_in_ex1, temp_in_ex2, temp_in_ex3: std_logic_vector(18 downto 0) := (others => '0');	-- extendend temperature register
	signal temp_in_ex4, temp_in_ex5, temp_in_ex6, temp_in_ex7: std_logic_vector(18 downto 0) := (others => '0');
begin

    sync: process(Sample_Clk)
    begin
        if Sample_Clk'event and Sample_Clk = '1' then
            temp_in_ex7 <= temp_in_ex6;			
            temp_in_ex6 <= temp_in_ex5;			
            temp_in_ex5 <= temp_in_ex4;			
            temp_in_ex4 <= temp_in_ex3;			
            
			temp_in_ex3 <= temp_in_ex2;			-- shift Temp register
			temp_in_ex2 <= temp_in_ex1;	
			temp_in_ex1 <= temp_in_ex0;		

			temp_in_ex0(15 downto 0) <= Temp;	--Copy input in extended vector for bigger range	
			temp_in_ex0(18 downto 16) <= Temp(15) & Temp(15) & Temp(15); --and duplicate sign bit to MSB 
		end if;
	end process;

	average: process(Temp, state, temp_in_ex0, temp_in_ex1, temp_in_ex2, temp_in_ex3,
	   temp_in_ex4, temp_in_ex5, temp_in_ex6, temp_in_ex7)
	   
        variable temp_sum : std_logic_vector(18 downto 0) := (others => '0');		-- summarized temperature
	begin 	
        case state is
            when "00" => 	Average_Temp <= temp_in_ex0(15 downto 0);
            
            when "01" => 	temp_sum := std_logic_vector(signed(temp_in_ex0) + signed(temp_in_ex1));
                        
                        for i in 0 to 15 loop
                        Average_Temp(i) <= temp_sum(i+1);	-- divide by factor 2 
                        end loop;	

            when "10" =>	temp_sum := std_logic_vector(signed(temp_in_ex0) + signed(temp_in_ex1) + signed(temp_in_ex2) + signed(temp_in_ex3));

                        for i in 0 to 15 loop
                        Average_Temp(i) <= temp_sum(i+2);	-- divide by factor 4 
                        end loop;
            when "11" =>
                temp_sum := std_logic_vector(signed(temp_in_ex0) + signed(temp_in_ex1) + signed(temp_in_ex2) + signed(temp_in_ex3)
                    + signed(temp_in_ex4) + signed(temp_in_ex5) + signed(temp_in_ex6) + signed(temp_in_ex7));

                        for i in 0 to 15 loop
                        Average_Temp(i) <= temp_sum(i+3);	-- divide by factor 8 
                        end loop;	

            when others => Average_Temp <= "0000000000000000";
        end case;
	end process;

end behavioral;