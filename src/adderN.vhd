library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity adderN is
    generic (N : integer := 28);
    port ( A   : in   std_logic_vector(N-1 downto 0);
           B   : in   std_logic_vector(N-1 downto 0);
           Sum : out  std_logic_vector(N-1 downto 0) );
end adderN;

architecture Behavioral of adderN is
begin
    process (A, B) begin
        Sum <= A + B;
    end process;
end Behavioral;