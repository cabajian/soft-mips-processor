library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xorN is
    GENERIC (N : INTEGER := 32); --bit width
    PORT (
            A : IN std_logic_vector(N-1 downto 0);
            B : IN std_logic_vector(N-1 downto 0);
            Y : OUT std_logic_vector(N-1 downto 0)
        );
end xorN;

architecture dataflow of xorN is
begin
    Y <= A xor B;
end dataflow;