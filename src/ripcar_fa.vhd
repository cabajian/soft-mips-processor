library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ripcar_fa is
    generic (N : integer := 32);
    port ( A   : in std_logic_vector(N-1 downto 0);
           B   : in std_logic_vector(N-1 downto 0);
           Sum : out std_logic_vector(N-1 downto 0) );
end ripcar_fa;

architecture Structural of ripcar_fa is
    -- initial carry signal set to zero
    signal carry_sig : std_logic_vector(N downto 0);
    signal sum_sig   : std_logic_vector(N-1 downto 0);
begin
    
    carry_sig(0) <= '0';
    
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

end Structural;
