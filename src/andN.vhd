-- --------------------------------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT )
-- Engineer : Chris Abajian (cxa6282@rit.edu)
--
-- Create Date : 1/24/2019
-- Design Name : andN
-- Module Name : andN - dataflow
-- Project Name : Exercise02
-- Target Devices : Basys3
--
-- Description : bitwise AND unit
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity andN is
    GENERIC (N : INTEGER := 32); --bit width
    PORT (
            A : IN std_logic_vector(N-1 downto 0);
            B : IN std_logic_vector(N-1 downto 0);
            Y : OUT std_logic_vector(N-1 downto 0)
        );
end andN;

architecture dataflow of andN is
begin
    Y <= A and B;
end dataflow;