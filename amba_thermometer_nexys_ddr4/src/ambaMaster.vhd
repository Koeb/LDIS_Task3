library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ambaMaster is
  generic (
    SLAVES : integer := 4;
    SLAVEADDRWIDTH : integer := 2 --ceil of log2 of SLAVES
  );
  Port (
        PCLK : in std_logic;                    -- system
        PRESETn : in std_logic;                 -- system
        PADDR   : out std_logic_vector(31 downto 0);
        PSEL    : out std_logic_vector(SLAVES-1 downto 0);
        PENABLE : out std_logic;
        PWRITE  : out std_logic;
        PWDATA  : out std_logic_vector(31 downto 0);
        PREADY  : in std_logic;
        PRDATA  : in std_logic_vector(31 downto 0);
        --PSLVERR : in std_logic;
        
        transferRequest : in std_logic;
        ready           : out std_logic;
        takedata        : out std_logic;
        write           : in std_logic; 
        regaddr         : in std_logic_vector(31 downto 0);
        slaveaddr       : in std_logic_vector(SLAVES-1 downto 0);
        data            : inout std_logic_vector(31 downto 0));
end ambaMaster;

architecture Behavioral of ambaMaster is
    type AMBA_MASTER_STATE IS (IDLE, SETUP, ACC, PROVIDE);
	signal state, state_nxt : AMBA_MASTER_STATE := IDLE;
	signal write_ff : std_logic := '0';
	signal psel_reg : std_logic_vector(SLAVES-1 downto 0) := (others => '0');
	signal data_reg : std_logic_vector(31 downto 0) := (others => '0');
	signal regaddr_reg : std_logic_vector(31 downto 0) := (others => '0');
begin

    nxtstatelogic : process(state, PREADY, transferRequest, write_ff)
    begin
        case(state) is
            when IDLE =>
                if transferRequest = '0' then
                    state_nxt <= IDLE;
                else
                    state_nxt <= SETUP;
                end if;
            when SETUP =>
                state_nxt <= ACC;
            when ACC =>
                if PREADY = '0' then
                    state_nxt <= ACC;
                else
                    if transferRequest = '1' then
                        state_nxt <= SETUP;
                    else
                        state_nxt <= IDLE;
                    end if;
                    
                    if write_ff = '0' then
                        state_nxt <= PROVIDE;
                    end if;
                end if;
            when PROVIDE =>
                if transferRequest = '1' then
                    state_nxt <= SETUP;
                else
                    state_nxt <= IDLE;
                end if;
            when others =>
                state_nxt <= IDLE;
        end case;
    end process;

    process(PCLK, PRESETn)
    begin
        if PRESETn = '0' then
            state <= IDLE;
            write_ff <= '0';
            psel_reg <= (others => '0');
            regaddr_reg <= (others => '0');
        else
            if PCLK'event and PCLK = '1' then
                state <= state_nxt;
                write_ff <= write_ff;
                psel_reg <= (others => '0');
            
                case(state_nxt) is
                    when SETUP =>
                        write_ff <= write;
                        --psel_reg(to_integer(unsigned(slaveaddr))) <= '1';
                        psel_reg <= slaveaddr;
                        regaddr_reg <= regaddr;
                        if write = '1' then
                            data_reg <= data;
                        end if;
                    when ACC =>
                        psel_reg <= psel_reg;
                        
--                        if write_ff = '0' then
--                            data_reg <= PRDATA;
--                        end if;
                    when PROVIDE =>
                        data_reg <= PRDATA;
                    when others =>
                end case;
                
--                if state = ACC then
--                    if write_ff = '0' then
--                        data_reg <= PRDATA;
--                    end if;
--                end if;
            end if;
        end if;
    end process;

    
    combout : process(state, state_nxt, write_ff, data_reg, PREADY)
    begin
            ready <= '0';
            
            data <= (others => 'Z');
            PWDATA <= (others => '0');
            takedata <= '0';
            PENABLE <= '0';
            
            case(state) is
                    when IDLE =>
                        if state_nxt /= SETUP then
                            ready <= '1';
                        end if;
                    when SETUP =>
                        if write_ff = '1' then
                            PWDATA <= data_reg;
                        end if;
                    when ACC =>
                        PENABLE <= '1';
                        if write_ff = '1' then
                            PWDATA <= data_reg;
                            
                            if state_nxt /= ACC then
                                ready <= '1';
                            end if;
                        end if;
                    when PROVIDE =>
                        data <= data_reg;
                        ready <= '1';
                    when others =>
                end case;
    end process;
    
    PWRITE <= write_ff;
    PSEL <= psel_reg;
    PADDR <= regaddr_reg;

end Behavioral;
