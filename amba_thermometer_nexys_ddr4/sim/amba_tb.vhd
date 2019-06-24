library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity amba_tb is
end amba_tb;

architecture Behavioral of amba_tb is
    constant clk_period	: time := 40 ns;
    signal amba_clk : std_logic;
    signal reset : std_logic := '0';
    
    signal PADDR : std_logic_vector(31 downto 0);
    signal PSELsensor : std_logic := '0';
    signal PSELinput : std_logic := '0';
    signal PSELdsp : std_logic := '0'; 
    signal PSELoutput : std_logic := '0';
    signal PENABLE : std_logic;
    signal PWRITE  : std_logic;
    signal PWDATA  : std_logic_vector(31 downto 0);
    signal PREADY  : std_logic;
    signal PREADY_sensor, PREADY_input, PREADY_dsp, PREADY_output  : std_logic;
    signal PRDATA  : std_logic_vector(31 downto 0);
    signal PRDATA_sensor, PRDATA_input, PRDATA_dsp, PRDATA_output  : std_logic_vector(31 downto 0);
    signal PRESETn : std_logic :='1';
    
    signal m_transferRequest : std_logic;
    signal m_ready           : std_logic;
    signal m_takedata        : std_logic;
    signal m_write           : std_logic; 
    signal m_regaddr         : std_logic_vector(31 downto 0) := (others => '0');
    signal m_slaveaddr       : std_logic_vector(3 downto 0);
    signal m_data            : std_logic_vector(31 downto 0);
    
    type TOP_MSTATE is (IDLE, INPUT, SENSOR, FEEDMAVG, MAVG, OUTPUT);
    signal m_state           : TOP_MSTATE := IDLE;
    signal m_state_nxt       : TOP_MSTATE;
    signal m_tempdata        : std_logic_vector(15 downto 0) := (others => '0');
    signal m_windowsize      : std_logic_vector(1 downto 0) := "00";
    signal m_counter         : integer := 0;
    signal m_counter_nxt     : integer;
    
    signal slv_data_sensor_in : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_data_sensor_out : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_addr_sensor : std_logic_vector(31 downto 0);
    signal slv_read_sensor  : std_logic;
    signal slv_write_sensor : std_logic;
    signal slv_done_sensor : std_logic;
    
    signal slv_data_input_in : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_data_input_out : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_addr_input : std_logic_vector(31 downto 0);
    signal slv_read_input  : std_logic;
    signal slv_write_input : std_logic;
    signal slv_done_input : std_logic;
    
    signal slv_data_dsp_in : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_data_dsp_out : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_addr_dsp : std_logic_vector(31 downto 0);
    signal slv_read_dsp  : std_logic;
    signal slv_write_dsp : std_logic;
    signal slv_done_dsp : std_logic;
    
    signal slv_data_output_in : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_data_output_out : std_logic_vector(31 downto 0):= (others => '0');
    signal slv_addr_output : std_logic_vector(31 downto 0);
    signal slv_read_output  : std_logic;
    signal slv_write_output : std_logic;
    signal slv_done_output : std_logic;
    
    signal temperature_2comp : std_logic_vector(15 downto 0) := x"000A";
    signal windowstate_i : std_logic_vector(1 downto 0) := "01";
    signal state_in : std_logic_vector(1 downto 0) := "00";
    signal temp_in, temp_out, temp_averaged : std_logic_vector(15 downto 0) := x"0000";
    
    signal PSEL : std_logic_vector(3 downto 0);
    signal PREADY_S : std_logic_vector(3 downto 0);
    
    component ambaMaster is
        generic (
            SLAVES : integer := 4;
            SLAVEADDRWIDTH : integer := 2 --ceil of log2 of SLAVES
        );
        port (
            PCLK : in std_logic;                    -- system
            PRESETn : in std_logic;                 -- system
            PADDR   : out std_logic_vector(31 downto 0);
            PSEL    : out std_logic_vector(SLAVES-1 downto 0);
            PENABLE : out std_logic;
            PWRITE  : out std_logic;
            PWDATA  : out std_logic_vector(31 downto 0);
            PREADY  : in std_logic;
            PRDATA  : in std_logic_vector(31 downto 0);
            
            transferRequest : in std_logic;
            ready           : out std_logic;
            takedata        : out std_logic;
            write           : in std_logic; 
            regaddr         : in std_logic_vector(31 downto 0);
            slaveaddr       : in std_logic_vector(SLAVES-1 downto 0);
            data            : inout std_logic_vector(31 downto 0)
        );
    end component;
    
    component AmbaDemux4 is
    port (
        PSEL : in std_logic_vector(3 downto 0);

        PREADYS : in std_logic_vector(3 downto 0);

        PRDATA0 : in std_logic_vector(31 downto 0);
        PRDATA1 : in std_logic_vector(31 downto 0);
        PRDATA2 : in std_logic_vector(31 downto 0);
        PRDATA3 : in std_logic_vector(31 downto 0);
        
        PREADY_OUT : out std_logic;
        PRDATA_OUT : out std_logic_vector(31 downto 0)
    );
    end component;
    
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

    
begin
    clkgen : process
    begin
		amba_clk <= '0';
		wait for clk_period/2;
		amba_clk <= '1';
		wait for clk_period/2;
	end process;
	
	uut_m : ambaMaster
    port map(
        PCLK => amba_clk,
        PRESETn => PRESETn,
        PADDR => PADDR,
        PSEL(0) => PSELsensor,
        PSEL(1) => PSELinput,
        PSEL(2) => PSELdsp,
        PSEL(3) => PSELoutput,
        PENABLE => PENABLE,
        PWRITE => PWRITE,
        PWDATA => PWDATA,
        PREADY => PREADY,
        PRDATA => PRDATA,
        transferRequest => m_transferRequest,
        ready => m_ready,
        takedata => m_takedata,
        write => m_write,
        regaddr => m_regaddr,
        slaveaddr => m_slaveaddr,
        data => m_data
    );
    
    amba_demux : AmbaDemux4
    port map(
        PSEL        => PSEL,
        PREADYS     => PREADY_S,
        PRDATA0     => PRDATA_sensor,
        PRDATA1     => PRDATA_input,
        PRDATA2     => PRDATA_dsp,
        PRDATA3     => PRDATA_output,
        PREADY_OUT  => PREADY,
        PRDATA_OUT  => PRDATA
    );
    
    slave_sensor : ambaSlave
    port map(
        PCLK        => amba_clk,
        PRESETn     => PRESETn,
        PSEL        => PSELsensor,
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY_sensor,
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA_sensor,
        -- slave to slave module
        data_in        => slv_data_sensor_in,
        data_out        => slv_data_sensor_out,
        addr        => slv_addr_sensor,
        readReg     => slv_read_sensor,
        writeReg    => slv_write_sensor,
        done        => slv_done_sensor
    );
    
    slave_input : ambaSlave
    port map(
        PCLK        => amba_clk,
        PRESETn     => PRESETn,
        PSEL        => PSELinput,
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY_input,
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA_input,
        -- slave to slave module
        data_in        => slv_data_input_in,
        data_out        => slv_data_input_out,
        addr        => slv_addr_input,
        readReg     => slv_read_input,
        writeReg    => slv_write_input,
        done        => slv_done_input
    );
    
    slave_dsp : ambaSlave
    port map(
        PCLK        => amba_clk,
        PRESETn     => PRESETn,
        PSEL        => PSELdsp,
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY_dsp,
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA_dsp,
        -- slave to slave module
        data_in        => slv_data_dsp_in,
        data_out        => slv_data_dsp_out,
        addr        => slv_addr_dsp,
        readReg     => slv_read_dsp,
        writeReg    => slv_write_dsp,
        done        => slv_done_dsp
    );
    
    slave_output : ambaSlave
    port map(
        PCLK        => amba_clk,
        PRESETn     => PRESETn,
        PSEL        => PSELoutput,
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY_output,
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA_output,
        -- slave to slave module
        data_in        => slv_data_output_in,
        data_out        => slv_data_output_out,
        addr        => slv_addr_output,
        readReg     => slv_read_output,
        writeReg    => slv_write_output,
        done        => slv_done_output
    );
    
    
   mctl_nextstate: process(m_state, m_ready, m_counter)
   begin
       m_state_nxt <= m_state;
       m_counter_nxt <= m_counter + 1;
       
       case (m_state) is
            when IDLE =>
                m_state_nxt <= INPUT;
                m_counter_nxt <= 0;
            when INPUT =>   -- read window size ~slaveadress 01
                if m_ready = '1' then
                    m_state_nxt <= SENSOR;
                    m_counter_nxt <= 0;
                end if;
            when SENSOR =>  -- read temp reg ~slaveadress 00
                if m_ready = '1' then
                    m_state_nxt <= FEEDMAVG;
                    m_counter_nxt <= 0;
                end if;
            when FEEDMAVG => -- write temp to dsp ~slaveadress 10
                if m_ready = '1' then
                    m_state_nxt <= MAVG;
                    m_counter_nxt <= 0;
                end if;
            when MAVG =>    -- read temp from dsp ~slaveadress 10
                if m_ready = '1' then
                    m_state_nxt <= OUTPUT;
                    m_counter_nxt <= 0;
                end if;
            when OUTPUT =>  -- write temp to output ~slaveadress 11
                if m_ready = '1' then
                    m_state_nxt <= INPUT;
                    m_counter_nxt <= 0;
                end if;
            when others =>  
                m_state_nxt <= INPUT;
                m_counter_nxt <= 0;
        end case;
   end process;
   
   mctl_clkproc: process(amba_clk, reset)
   begin
    if reset = '1' then
        m_state <= IDLE;
        m_counter <= 0;
        m_windowsize <= (others => '0');
        m_tempdata <= (others => '0');
    elsif amba_clk'event and amba_clk = '1' then
        m_state <= m_state_nxt;
        m_counter <= m_counter_nxt;
        
        case (m_state) is
            when INPUT =>   -- read window size ~slaveadress 01          
                if m_ready = '1' then
                    m_windowsize <= m_data(1 downto 0);
                end if;
            when SENSOR =>  -- read temp reg ~slaveadress 00   
                if m_ready = '1' then
                    m_tempdata <= m_data(15 downto 0);
                end if;
            --when FEEDMAVG => -- write temp to dsp ~slaveadress 10
            when MAVG =>    -- read temp from dsp ~slaveadress 10       
                if m_ready = '1' then
                    m_tempdata <= m_data(15 downto 0);
                end if;
            --when OUTPUT =>  -- write temp to output ~slaveadress 11
            when others =>  
        end case;
    end if;
   end process;
   
   mctl_comb: process(m_state, m_data, m_counter, m_tempdata, m_windowsize) 
   begin
        m_transferRequest <= '0';
        if m_counter = 0 and m_state /= IDLE then
            m_transferRequest <= '1';
        end if;
        
        case (m_state) is
            when INPUT =>   -- read window size ~slaveadress 01    
                m_data <= (others => 'Z');
                m_write <= '0';
                m_slaveaddr <= "0010";
            when SENSOR =>  -- read temp reg ~slaveadress 00   
                m_data <= (others => 'Z');
                m_write <= '0';
                m_slaveaddr <= "0001";
            when FEEDMAVG => -- write temp to dsp ~slaveadress 10
                m_data <= (others => '0');
                m_data(17 downto 0) <= m_windowsize & m_tempdata;
                m_write <= '1';
                m_slaveaddr <= "0100";
            when MAVG =>    -- read temp from dsp ~slaveadress 10       
                m_data <= (others => 'Z');
                m_write <= '0';
                m_slaveaddr <= "0100";
            when OUTPUT =>  -- write temp to output ~slaveadress 11
                m_data <= (others => '0');       
                m_data(15 downto 0) <= m_tempdata;
                m_write <= '1';
                m_slaveaddr <= "1000";
            when others =>  
                m_data <= (others => 'Z');
                m_write <= '0';
                m_slaveaddr <= "0000";
        end case;
    end process;   
    
    sensor_R: process(slv_read_sensor, PADDR, temperature_2comp)
    begin
        if slv_read_sensor = '1' then
            if PADDR = (31 downto 0 => '0') then
                slv_data_sensor_in <= (31 downto temperature_2comp'length => '0') & temperature_2comp;
            end if;
        end if;
    end process;
    
    slv_done_sensor <= '1';
    
    input_R: process(slv_read_input, PADDR, windowstate_i) is
    begin
        if slv_read_input = '1' then
            if PADDR = (31 downto 0 => '0') then
                slv_data_input_in <= (31 downto 2 => '0') & windowstate_i;
            end if;
        end if;
    end process;
    
    slv_done_input <= '1';
    
    
    dsp_W: process(slv_write_dsp, amba_clk, PADDR)
    begin
        if amba_clk'event and amba_clk = '1' then
            if slv_write_dsp = '1' then
                if PADDR = (31 downto 0 => '0') then
                    temp_in <= slv_data_dsp_out(15 downto 0);
                    state_in <= slv_data_dsp_out(17 downto 16); 
                end if;                   
            end if;        
        end if;
     
    end process;
    
    dsp_R: process(slv_read_dsp, PADDR, temp_out)
    begin
            if slv_read_dsp = '1' then
                if PADDR = (31 downto 0 => '0') then
                    slv_data_dsp_in <= (31 downto 16 => '0') & temp_out;
                end if;       
            end if;
    
    end process;
    
    slv_done_dsp <= '1';
    temp_out <= temp_in;
    
    output_W: process(slv_write_output, amba_clk, PADDR)
    begin
        if amba_clk'event and amba_clk = '1' then
            if slv_write_output = '1' then
                if PADDR = (31 downto 0 => '0') then
                    temp_averaged <= slv_data_output_out(15 downto 0);
                end if;
            end if;
        end if;
    end process;
    
    slv_done_output <= '1';
    
    PREADY_S <= PREADY_output & PREADY_dsp & PREADY_input & PREADY_sensor;
    PSEL <= PSELoutput & PSELdsp & PSELinput & PSELsensor;
end Behavioral;
