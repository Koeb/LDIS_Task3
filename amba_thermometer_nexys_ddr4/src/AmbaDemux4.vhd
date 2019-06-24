library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--package amba_demux_type is
--constant SLAVES : integer := 4;
--constant WIDTH : integer := 32;
--type DEMUX_DATA is array (0 to SLAVES-1) of std_logic_vector(WIDTH-1 downto 0);
--end package;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use work.amba_demux_type.all;

entity AmbaDemux4 is
  Port (

PSEL : in std_logic_vector(3 downto 0);

        PREADYS : in std_logic_vector(3 downto 0);

        PRDATA0 : in std_logic_vector(31 downto 0);
        PRDATA1 : in std_logic_vector(31 downto 0);
        PRDATA2 : in std_logic_vector(31 downto 0);
        PRDATA3 : in std_logic_vector(31 downto 0);
        
        PREADY_OUT : out std_logic;
        PRDATA_OUT : out std_logic_vector(31 downto 0)
  );
end AmbaDemux4;

architecture Behavioral of AmbaDemux4 is
begin
    process(PSEL, PREADYS, PRDATA0, PRDATA1, PRDATA2, PRDATA3)
    begin
        case(PSEL) is
            when "0001" =>
                PREADY_OUT <= PREADYS(0);
                PRDATA_OUT <= PRDATA0;
            when "0010" =>
                PREADY_OUT <= PREADYS(1);
                PRDATA_OUT <= PRDATA1;
            when "0100" =>
                PREADY_OUT <= PREADYS(2);
                PRDATA_OUT <= PRDATA2;
            when "1000" =>
                PREADY_OUT <= PREADYS(3);
                PRDATA_OUT <= PRDATA3;
            when others =>
                PREADY_OUT <= '0';
                PRDATA_OUT <= (others => '0');
       end case;
    end process;

end Behavioral;
