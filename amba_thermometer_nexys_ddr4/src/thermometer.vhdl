library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity thermometer is
    generic(
        SAMPLERATE : integer range 1 to 4 := 1 --1: 250ms, 2: 500ms, 4: 1s, do not use 3!
    );
    port(
        CLK_100MHz : in std_logic;
        SCL : inout std_logic;
        SDA : inout std_logic;
        BTN_U : in std_logic;                -- buttons for mavg window adjustment
        BTN_D : in std_logic;
        LEDS : out std_logic_vector(1 downto 0);    -- display mavg window setting
        SSEG_CATHODES : out std_logic_vector(7 downto 0);
        SSEG_ANODES : out std_logic_vector(7 downto 0)
    );
end thermometer;

architecture toparch of thermometer is
    component clkdivide is
        generic(
            DIVISOR : natural := 272
        );
        port(
            CLK_IN  : in std_logic; -- system clock as input, in this project 100MHz
            RST     : in std_logic; -- asynchronous reset
            CLK_OUT : out std_logic -- divided clock signal
        );
    end component;
    
    component ambaMaster is
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
    
    component SensorSlave is
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
      );
    end component;

    component InputSlave is
    port (
        PCLK: in std_logic;
        SAMPLECLK: in std_logic;
        PRESETn: in std_logic;
        PSEL : in std_logic;
        PADDR : in std_logic_vector(31 downto 0);
        PENABLE : in std_logic;
        PREADY : out std_logic;
        PWRITE : in std_logic;
        PWDATA : in std_logic_vector(31 downto 0);
        PRDATA : out std_logic_vector(31 downto 0);
        button_up : in std_logic;
        button_down : in std_logic
    );
    end component;
    
    component DSPSlave is
    port ( 
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
    end component;

    component OutputSlave is
      port (DISPLAYCLK : in std_logic;
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
            
            CATHODES : out std_logic_vector(7 downto 0);
            ANODES : out std_logic_vector(7 downto 0)
      );
    end component;

    signal reset : std_logic := '0';
    signal PRESETn : std_logic := '1';
    signal sample_clk, display_clk, amba_clk : std_logic;
    
    signal  PADDR   : std_logic_vector(31 downto 0);
    signal  PSEL    : std_logic_vector(3 downto 0);
    signal  PENABLE : std_logic;
    signal  PWRITE  : std_logic;
    signal  PWDATA  : std_logic_vector(31 downto 0);
    signal  PREADY_M  : std_logic;
    signal  PRDATA_M  : std_logic_vector(31 downto 0);
    signal  PREADY_S  : std_logic_vector(3 downto 0);
    signal  PRDATA_S0  : std_logic_vector(31 downto 0);
    signal  PRDATA_S1  : std_logic_vector(31 downto 0);
    signal  PRDATA_S2  : std_logic_vector(31 downto 0);
    signal  PRDATA_S3  : std_logic_vector(31 downto 0);
    
    signal m_transferRequest : std_logic;
    signal m_ready           : std_logic;
    signal m_takedata        : std_logic;
    signal m_write           : std_logic; 
    signal m_regaddr         : std_logic_vector(31 downto 0);
    signal m_slaveaddr       : std_logic_vector(3 downto 0);
    signal m_data            : std_logic_vector(31 downto 0);
    
    type TOP_MSTATE is (IDLE, INPUT, SENSOR, FEEDMAVG, MAVG, OUTPUT);
    signal m_state           : TOP_MSTATE := IDLE;
    signal m_state_nxt       : TOP_MSTATE;
    signal m_tempdata1, m_tempdata2 : std_logic_vector(15 downto 0) := (others => '0');
    signal m_windowsize      : std_logic_vector(1 downto 0) := "00";
    signal m_counter         : integer := 0;
    signal m_counter_nxt     : integer;
    
begin
    sampleclkgen : clkdivide
    generic map(
        DIVISOR => 250 * SAMPLERATE --25_000_000 * SAMPLERATE
    )
    port map(
        CLK_IN => display_clk, --CLK_100MHz
        RST => reset,
        CLK_OUT => sample_clk
    );
    
    displayclkgen : clkdivide
    generic map(
        DIVISOR => 100_000 -- 1000 Hz
    )
    port map(
        CLK_IN => CLK_100MHz,
        RST => reset,
        CLK_OUT => display_clk
    );
    
    ambaclkgen : clkdivide
    generic map(
        DIVISOR => 4
    )
    port map(
        CLK_IN => CLK_100MHz,
        RST => reset,
        CLK_OUT => amba_clk
    );
    
    ambaM : ambaMaster
    generic map(
        SLAVES => 4,
        SLAVEADDRWIDTH => 2 --ceil of log2 of SLAVES
    )
    port map(
        PCLK    => amba_clk,
        PRESETn => PRESETn,
        PADDR   => PADDR,
        PSEL    => PSEL,
        PENABLE => PENABLE,
        PWRITE  => PWRITE,
        PWDATA  => PWDATA,
        PREADY  => PREADY_M,
        PRDATA  => PRDATA_M,
        
        transferRequest => m_transferRequest,
        ready           => m_ready,
        takedata        => m_takedata,
        write           => m_write,
        regaddr         => m_regaddr,
        slaveaddr       => m_slaveaddr,
        data            => m_data
    );
    
    amba_demux : AmbaDemux4
    port map(
        PSEL        => PSEL,
        PREADYS     => PREADY_S,
        PRDATA0     => PRDATA_S0,
        PRDATA1     => PRDATA_S1,
        PRDATA2     => PRDATA_S2,
        PRDATA3     => PRDATA_S3,
        PREADY_OUT  => PREADY_M,
        PRDATA_OUT  => PRDATA_M
    );
    
    sensorS : sensorSlave
    generic map(
        SYSCLKFREQ => 100
    )
    port map(
        SYSCLK      => CLK_100MHz,
        PCLK        => amba_clk,
        SAMPLECLK   => sample_clk,
        
        PRESETn     => PRESETn,
        PSEL        => PSEL(0),
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY_S(0),
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA_S0,
        
        SRST_I      => reset,
        SCL         => SCL,
        SDA         => SDA
   );
  
   inputS : InputSlave
   port map(
        PCLK        => amba_clk,
        SAMPLECLK   => sample_clk,
        PRESETn     => PRESETn,
        PSEL        => PSEL(1),
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY_S(1),
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA_S1,
        button_up   => BTN_U,
        button_down => BTN_D
   );
  
   dspS : DSPSlave
   port map( 
        PCLK    => amba_clk,
        SAMPLECLK => sample_clk,
        PRESETn => PRESETn,
        PSEL    => PSEL(2),
        PADDR   => PADDR,
        PENABLE => PENABLE,
        PREADY  => PREADY_S(2),
        PWRITE  => PWRITE,
        PWDATA  => PWDATA,
        PRDATA  => PRDATA_S2
   );
  
   outputS : OutputSlave
   port map(
        DISPLAYCLK  => display_clk,
        PCLK        => amba_clk,
        SAMPLECLK   => sample_clk,
        
        PRESETn     => PRESETn,
        PSEL        => PSEL(3),
        PADDR       => PADDR,
        PENABLE     => PENABLE,
        PREADY      => PREADY_S(3),
        PWRITE      => PWRITE,
        PWDATA      => PWDATA,
        PRDATA      => PRDATA_S3,
        
        CATHODES    => SSEG_CATHODES,
        ANODES      => SSEG_ANODES
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
        m_tempdata1 <= (others => '0');
        m_tempdata2 <= (others => '0');
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
                    m_tempdata1 <= m_data(15 downto 0);
                end if;
            --when FEEDMAVG => -- write temp to dsp ~slaveadress 10
            when MAVG =>    -- read temp from dsp ~slaveadress 10       
                if m_ready = '1' then
                    m_tempdata2 <= m_data(15 downto 0);
                end if;
            --when OUTPUT =>  -- write temp to output ~slaveadress 11
            when others =>  
        end case;
    end if;
   end process;
   
   mctl_comb: process(m_state, m_data, m_counter, m_tempdata1, m_tempdata2, m_windowsize) 
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
                m_data(17 downto 0) <= m_windowsize & m_tempdata1;
                m_write <= '1';
                m_slaveaddr <= "0100";
            when MAVG =>    -- read temp from dsp ~slaveadress 10       
                m_data <= (others => 'Z');
                m_write <= '0';
                m_slaveaddr <= "0100";
            when OUTPUT =>  -- write temp to output ~slaveadress 11
                m_data <= (others => '0');       
                m_data(15 downto 0) <= m_tempdata2;
                m_write <= '1';
                m_slaveaddr <= "1000";
            when others =>  
                m_data <= (others => 'Z');
                m_write <= '0';
                m_slaveaddr <= "0000";
        end case;
    end process;   
   
    m_regaddr <= (others => '0');
    reset <= '0';
    PRESETn <= not reset;
    LEDS <= m_windowsize; --(15 downto 2 => '0') & 
end toparch;