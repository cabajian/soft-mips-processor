-- --------------------------------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT )
-- Engineer : Chris Abajian (cxa6282@rit.edu)
--
-- Create Date : 1/24/2019
-- Design Name : muxN_9to1
-- Module Name : muxN_9to1 - behavioral
-- Project Name : Exercise02
-- Target Devices : Basys3
--
-- Description : an N to 1 multiplexer
-- --------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity muxN_9to1 is
    GENERIC (N : INTEGER := 32); --bit width
    PORT (  data0   : in std_logic_vector(N-1 downto 0);
            data1   : in std_logic_vector(N-1 downto 0);
            data2   : in std_logic_vector(N-1 downto 0);
            data3   : in std_logic_vector(N-1 downto 0);
            data4   : in std_logic_vector(N-1 downto 0);
            data5   : in std_logic_vector(N-1 downto 0);
            data6   : in std_logic_vector(N-1 downto 0);
            data7   : in std_logic_vector(N-1 downto 0);
            data8   : in std_logic_vector(N-1 downto 0);
            sel     : in std_logic_vector(3 downto 0);
            output  : out std_logic_vector(N-1 downto 0)
         );
end muxN_9to1;

architecture Behavioral of muxN_9to1 is
begin
    mux_proc : process(data0, data1, data2, data3, data4, data5, data6, data7, data8, sel) begin
        case sel is
            when "0100" => output <= data0;
            when "1010" => output <= data1;
            when "0110" => output <= data2;
            when "1000" => output <= data3;
            when "1011" => output <= data4;
            when "1100" => output <= data5;
            when "1110" => output <= data6;
            when "1101" => output <= data7;
            when "0101" => output <= data8;
            when others => null;
        end case;
    end process;

end Behavioral;