library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity faN is
    generic (N : integer := 8);
    port ( A   : in std_logic_vector(N-1 downto 0);
           B   : in std_logic_vector(N-1 downto 0);
           Cin : in std_logic;
           Sum : out std_logic_vector(N-1 downto 0);
           Cout : out std_logic );
end faN;

architecture Structural of faN is
    signal carry_sig : std_logic_vector(N downto 0);
    signal sum_sig   : std_logic_vector(N-1 downto 0);
begin
    
    carry_sig(0) <= Cin;
    
    -- 0 to N-1 generate loop to instantiate the fulladders
    fa_gen : for i in 0 to N-1 generate
        fa_comp : entity work.fa
            port map ( A => A(i),
                       B => B(i),
                       Cin => carry_sig(i),
                       Sum => sum_sig(i),
                       Cout => carry_sig(i+1) );
    end generate;
    
    Sum <= sum_sig;
    Cout <= carry_sig(N);

end Structural;
