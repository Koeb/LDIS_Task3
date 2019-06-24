library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SensorSlave is
  generic (SYSCLKFREQ : natural := 100); -- CLK frequency in MHz
  Port (SYSCLK : in std_logic;
        PCLK : in std_logic;
        SAMPLECLK: in std_logic;
        
        PRESETn: in std_logic;
        PSEL : in std_logic;
        PADDR : in std_logic_vector(31 downto 0);
        PENABLE : in std_logic;
        PREADY : out std_logic;
        PWRITE : in std_logic;
        PWDATA : in std_logic_vector(31 downto 0);
        PRDATA : out std_logic_vector(31 downto 0);
        
        
        SRST_I : in STD_LOGIC;
        SCL : inout STD_LOGIC;
        SDA : inout STD_LOGIC
        --TEMP : out STD_LOGIC_VECTOR(15 downto 0)
  );
end SensorSlave;

architecture Behavioral of SensorSlave is

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
    
    component TempSensorCtl is
        generic (CLOCKFREQ : natural := SYSCLKFREQ); -- input CLK frequency in MHz
        port (
            TMP_SCL : inout STD_LOGIC;
            TMP_SDA : inout STD_LOGIC;
            
            TEMP_O : out STD_LOGIC_VECTOR(15 downto 0); --15-bit two's complement temperature with sign bit
            RDY_O : out STD_LOGIC;	--'1' when there is a valid temperature reading on TEMP_O
            ERR_O : out STD_LOGIC; --'1' if communication error
            
            CLK_I : in STD_LOGIC;
            SRST_I : in STD_LOGIC
        );
    end component;
    
    signal temp_unsampled : std_logic_vector(15 downto 0);
    signal temperature_2comp : std_logic_vector(15 downto 0);
    signal sensor_ready, sensor_error : std_logic;
    signal slv_data_in, slv_data_out : std_logic_vector(31 downto 0);
    signal slv_addr : std_logic_vector(31 downto 0);
    signal slv_read, slv_write, slv_done : std_logic;
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

    tmpsensor : TempSensorCtl
    generic map(
        CLOCKFREQ => 100
    )
    port map(
        TMP_SCL => SCL,
        TMP_SDA => SDA,
        TEMP_O => temp_unsampled,
        RDY_O => sensor_ready,
        ERR_O => sensor_error,
        CLK_I => SYSCLK,
        SRST_I => SRST_I
    );

    --pseudo sampling on register read
    process(SAMPLECLK, sensor_ready)
    begin
        if SAMPLECLK'event and SAMPLECLK = '1' then
            if sensor_ready = '1' then
                temperature_2comp <= temp_unsampled;
            end if;
        end if;
    end process;
    
    process(slv_read, PADDR, temperature_2comp)
    begin
    slv_data_in <= (others => '0');
        if slv_read = '1' then
            if PADDR = (31 downto 0 => '0') then
                slv_data_in <= (31 downto temperature_2comp'length => '0') & temperature_2comp;
            else
                --slv_data <= (others => 'Z');
            end if;
        else
            --slv_data <= (others => 'Z');
        end if;
    end process;
    
    slv_done <= '1';
end Behavioral;