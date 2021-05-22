-- --------------------------------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT )
-- Engineer : Chris Abajian (cxa6282@rit.edu)
--
-- Create Date : 1/24/2019
-- Design Name : muxN_2to1
-- Module Name : muxN_2to1 - behavioral
-- Project Name : Exercise02
-- Target Devices : Basys3
--
-- Description : an N to 1 multiplexer
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- entity declaration
entity muxN_2to1 is
    GENERIC (N : INTEGER := 8);
    PORT ( data0  : in STD_LOGIC_VECTOR (N-1 downto 0);
           data1  : in STD_LOGIC_VECTOR (N-1 downto 0);
           sel    : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (N-1 downto 0) );
end muxN_2to1;

architecture behavioral of muxN_2to1 is
begin
    -- Asynchronous process. Output gets value of data line designated by sel.
    process (data0, data1, sel) begin
        case sel is
            when '0' => output <= data0;
            when '1' => output <= data1;
            when others => output <= (others => 'Z');
        end case;
    end process;
    
end behavioral;
