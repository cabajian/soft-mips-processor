library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mips_processor_tb is
end mips_processor_tb;

architecture Behavioral of mips_processor_tb is

    signal clk, rst, test_sig : std_logic := '0';
    
    signal alu_out : std_logic_vector(31 downto 0);
    
    constant clk_period : time := 20 ns;
    
begin

    uut : entity work.mips_processor
        port map ( CLK_100MHz => clk,
                   rstn => rst,
                   alu_out => alu_out
                 );
       
    -- initial reset
    rst <= '0', '1' after clk_period*2;
    
    -- clock process
    clk <= not clk after clk_period/2;
    
    -- data process
    data_proc : process is begin
     
        wait for 3.5 us;
     
        assert false;
          
        wait;
        
    end process;

end Behavioral;
