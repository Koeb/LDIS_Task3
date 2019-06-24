library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SEGNUM.all;

entity OutputSlave is
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
end OutputSlave;

architecture Behavioral of OutputSlave is
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
    
    component parsing7seg is
    Port ( 
        sample_clk      : in std_logic;
        temp_averaged   : in std_logic_vector(15 downto 0);
        seg_numbers     : out SEGNUMBERS;
        signbit         : out std_logic  
    );
    end component;
    
    component whole7segment is
    port(
        display_clk : in std_logic;
        seg_numbers  : in SEGNUMBERS;
        signbit : in std_logic;
        CATHODES : out std_logic_vector(7 downto 0);
        ANODES : out std_logic_vector(7 downto 0)
  
    );
    end component;
    
    signal slv_data_in, slv_data_out : std_logic_vector(31 downto 0);
    signal slv_addr : std_logic_vector(31 downto 0);
    signal slv_read, slv_write, slv_done : std_logic;
    
    signal signbit : std_logic;
    signal seg_numbers : SEGNUMBERS;
    signal temp_averaged : std_logic_vector(15 downto 0);
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
    
    p7s : parsing7seg
    port map ( 
        sample_clk      => SAMPLECLK,
        temp_averaged   => temp_averaged,
        seg_numbers     => seg_numbers,
        signbit         => signbit
    );
    
    seg7 : whole7segment
    port map(
        display_clk => DISPLAYCLK,
        seg_numbers => seg_numbers,
        signbit     => signbit,
        CATHODES    => CATHODES,
        ANODES      => ANODES
    );
    
    process(slv_write, PCLK, PADDR)
    begin
        if PCLK'event and PCLK = '1' then
            if slv_write = '1' then
                if PADDR = (31 downto 0 => '0') then
                    temp_averaged <= slv_data_out(15 downto 0);
                end if;
            end if;
        end if;
    end process;
    
    --slv_data <= (others => 'Z');
    slv_done <= '1';
    slv_data_in <= (others => '0');
end Behavioral;
