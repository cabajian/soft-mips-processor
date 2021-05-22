library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sraN is
    generic (N : integer := 32;
             M : integer := 5 );
    port ( A : in std_logic_vector(N-1 downto 0);
           B : in std_logic_vector(N-1 downto 0);
           Y : out std_logic_vector(N-1 downto 0) );
end sraN;

architecture Behavioral of sraN is
begin

    sra_gen : for i in N-1 downto 0 generate
        process(A, B) begin
            if (i + to_integer(unsigned(B(M downto 0))) <= N-1) then
                Y(i) <= A(i + to_integer(unsigned(B(M downto 0))));
            else
                Y(i) <= A(N-1);
            end if;
        end process;
    end generate sra_gen;
    
end Behavioral;
