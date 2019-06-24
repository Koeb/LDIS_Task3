
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DSPSlave is
    Port ( 
        PCLK: in std_logic;
        SAMPLECLK: in std_logic;
        PRESETn: in std_logic;
        PSEL : in std_logic;
        PADDR : in std_logic_vector(31 downto 0);
        PENABLE : in std_logic;
        PREADY : out std_logic;
        PWRITE : in std_logic;
        PWDATA : in std_logic_vector(31 downto 0);
        PRDATA : out std_logic_vector(31 downto 0)
        );
end DSPSlave;

architecture Behavioral of DSPSlave is

    component ambaSlave is
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
    end component;
    
    component moving_average is
        Port (            
            Sample_Clk    :   in std_logic;                       
            Temp          :   in std_logic_vector(15 downto 0);	  
            Average_Temp  :   out std_logic_vector(15 downto 0); 
            state         :   in std_logic_vector(1 downto 0));
    end component;
    
    signal slv_data_in, slv_data_out : std_logic_vector(31 downto 0);
    signal slv_addr : std_logic_vector(31 downto 0);
    signal slv_read, slv_write, slv_done : std_logic;
    signal temp_in, temp_out : std_logic_vector(15 downto 0) := (others => '0');
    signal state_in : std_logic_vector(1 downto 0);

begin    

    slave_inst : ambaSlave
    port map(
        PCLK        => PCLK,
        PRESETn     => PRESETn,
        PSEL        => PSEL,
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY,
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA,
        -- slave to slave module
        data_in     => slv_data_in,
        data_out    => slv_data_out,
        addr        => slv_addr,
        readReg     => slv_read,
        writeReg    => slv_write,
        done        => slv_done
    );    

    dsp: moving_average 
    port  map(
		Sample_Clk    => SAMPLECLK,
		Temp          => temp_in,
		Average_Temp  => temp_out,
		state         => state_in
    
    );
    

    process(slv_write, PCLK, PADDR)
    begin
        if PCLK'event and PCLK = '1' then
            if slv_write = '1' then
                if PADDR = (31 downto 0 => '0') then
                    temp_in <= slv_data_out(15 downto 0);
                    state_in <= slv_data_out(17 downto 16); 
                end if;                   
            end if;        
        end if;
     
    end process;
    
    process(slv_read, PADDR, temp_out)
    begin
    slv_data_in <= (others => '0');
       -- if sampleclk'event and sampleclk = '1' then
            if slv_read = '1' then
                if PADDR = (31 downto 0 => '0') then
                    slv_data_in <= (31 downto 16 => '0') & temp_out;
                else
                    --slv_data <= (others => 'Z');
                end if;       
            else 
                --slv_data <= (others => 'Z');
            end if;
       -- end if;
    
    end process;
    
    slv_done <= '1';

end Behavioral;
