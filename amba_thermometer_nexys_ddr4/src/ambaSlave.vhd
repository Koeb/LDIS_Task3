library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ambaSlave is
  Port (PCLK : in std_logic;
        PRESETn: in std_logic;
        PSEL : in std_logic;
        PADDR : in std_logic_vector(31 downto 0);
        PENABLE : in std_logic;
        PREADY : out std_logic;
        PWRITE : in std_logic;
        PWDATA : in std_logic_vector(31 downto 0);
        PRDATA : out std_logic_vector(31 downto 0);
        -- slave to slave module
        data_in : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0);
        addr : out std_logic_vector(31 downto 0);
        readReg : out std_logic;
        writeReg : out std_logic;
        done : in std_logic);
end ambaSlave;

architecture Behavioral of ambaSlave is
    type AMBA_SLAVE_STATE IS (IDLE, SETUP, ACC);
	signal state, state_nxt : AMBA_SLAVE_STATE := IDLE;
    signal data_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal addr_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal prdata_int : std_logic_vector(31 downto 0);-- := (others => '0');
begin
    process(PCLK, PRESETn)
    begin
        if PRESETn = '0' then
            state <= IDLE;
            data_reg <= (others => '0');
            addr_reg <= (others => '0');
        elsif PCLK'event and PCLK = '1' then
            state <= state_nxt;
            data_reg <= data_reg;
            addr_reg <= addr_reg;
            
            case(state_nxt) is
                --when IDLE =>
                when SETUP =>
                    addr_reg <= PADDR;
                when ACC =>
                    if PWRITE = '1' then
                        data_reg <= PWDATA;
                    else
                        data_reg <= data_in;
                    end if;
                when others =>
            end case;
        end if;
    end process;
    
    process(state, PSEL, PENABLE, PWRITE, data_reg, done)
    begin
        state_nxt <= IDLE;
        if PSEL = '1' then
            state_nxt <= SETUP;
            if PENABLE = '1' then
                state_nxt <= ACC;
            end if;
        end if;
    
        --data <= (others => 'Z');
        prdata_int <= (others => '0');
        writeReg <= '0';
        readReg <= '0';
        PREADY <= done;
        data_out <= (others => '0');
        
        case(state) is
            --when IDLE =>   
            when SETUP =>
               if PWRITE = '0' then
                    readReg <= '1';    
               end if;
               PREADY <= '0';
            when ACC =>
                if PWRITE = '1' then
                    data_out <= data_reg;
                    writeReg <= '1';
                else
                    prdata_int <= data_reg;
                end if;
            when others =>
        end case;
    end process;
   
   --PREADY <= done;
   addr <= addr_reg;
   PRDATA <= prdata_int;
    
end Behavioral;
