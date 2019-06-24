library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InputSlave is
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
        PRDATA : out std_logic_vector(31 downto 0);
        
        button_up : in std_logic;
        button_down : in std_logic);
end InputSlave;

architecture Behavioral of InputSlave is

component windowsize is
    Port(
        Sample_Clk:	in std_logic;
        State_up:	in std_logic;
        State_down:	in std_logic;
        state: out std_logic_vector(1 downto 0)
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
      
    signal slv_data_in, slv_data_out : std_logic_vector(31 downto 0);
    signal slv_addr : std_logic_vector(31 downto 0);
    signal slv_read, slv_write, slv_done : std_logic;
    signal state : std_logic_vector (1 downto 0);
    --signal State_up, State_down : std_logic;
    
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
    
    input : windowsize
    port map(
        Sample_Clk  => SAMPLECLK,
        State_up    => button_up,
        State_down  => button_down,
        state       => state   
    );

process(slv_read, PADDR, state) is
begin
slv_data_in <= (others => '0');
    --slv_data <= (others => 'Z');
    if slv_read = '1' then
        if PADDR = (31 downto 0 => '0') then
            slv_data_in <= (31 downto 2 => '0') & state;
        end if;
    end if;
end process;

slv_done <= '1';

end Behavioral;
