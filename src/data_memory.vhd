library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    GENERIC (width : INTEGER := 32;
             addr_space : INTEGER := 10);
    port ( clk : in std_logic;
           w_en : in std_logic;
           addr  : in std_logic_vector(addr_space-1 downto 0);
           d_in : in std_logic_vector(width-1 downto 0);
           d_out : out std_logic_vector(width-1 downto 0) );
end data_memory;

architecture Behavioral of data_memory is
    type mem_type is array (0 to (2**addr_space)-1) of std_logic_vector(width-1 downto 0);
    signal mem : mem_type := ( others => X"00000000" );    
begin
    process (clk) begin
        if rising_edge(clk) and w_en = '1' then
            -- if write enabled, set memory location specified by addr to d_in
            mem(to_integer(unsigned(addr))) <= d_in;
        end if;
    end process;
    
    -- read value from memory specified at addr
    d_out <= mem(to_integer(unsigned(addr)));
    
end Behavioral;