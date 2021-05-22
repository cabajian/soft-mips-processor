library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    generic (N : integer := 32;
             M : integer := 5 );
    port ( in1 : in std_logic_vector(N-1 downto 0);
           in2 : in std_logic_vector(N-1 downto 0);
           control : in std_logic_vector(3 downto 0);
           out1 : out std_logic_vector(N-1 downto 0) );
end alu;

architecture Structural of alu is
    
    -- function to convert a vector to two's comp
    function twos_comp(input : std_logic_vector(N-1 downto 0)) return std_logic_vector is
        variable temp : std_logic_vector(N-1 downto 0);
    begin
        temp := not input;
        return std_logic_vector(unsigned(temp + 1));
    end function;

    signal ripcar_add_out : std_logic_vector(N-1 downto 0);
    signal ripcar_sub_out : std_logic_vector(N-1 downto 0);
    signal mult_out : std_logic_vector(N-1 downto 0);
    signal sll_out : std_logic_vector(N-1 downto 0);
    signal sra_out : std_logic_vector(N-1 downto 0);
    signal srl_out : std_logic_vector(N-1 downto 0);
    signal or_out : std_logic_vector(N-1 downto 0);
    signal xor_out : std_logic_vector(N-1 downto 0);
    signal and_out : std_logic_vector(N-1 downto 0);
begin

    ripcar_add_comp : entity work.ripcar_fa
        generic map (N => N)
        port map ( A => in1,
                   B => in2,
                   Sum => ripcar_add_out );
                   
    ripcar_sub_comp : entity work.ripcar_fa
        generic map (N => N)
        port map ( A => in1,
                   B => twos_comp(in2),
                   Sum => ripcar_sub_out );
                   
    mult_comp : entity work.cs_mult
        generic map (N => N)
        port map ( A => in1(N/2-1 downto 0),
                  B => in2(N/2-1 downto 0),
                  Product => mult_out );
                  
    sll_comp : entity work.sllN
        generic map (N => N,
                     M => M)
        port map ( A => in1,
                   B => in2,
                   Y => sll_out );
                   
    sra_comp : entity work.sraN
        generic map (N => N,
                     M => M)
        port map ( A => in1,
                   B => in2,
                   Y => sra_out );
                   
    srl_comp : entity work.srlN
        generic map (N => N,
                     M => M)
        port map ( A => in1,
                   B => in2,
                   Y => srl_out );
                   
    or_comp : entity work.orN
        generic map (N => N)
        port map ( A => in1,
                   B => in2,
                   Y => or_out );
                   
    xor_comp : entity work.xorN
        generic map (N => N)
        port map ( A => in1,
                   B => in2,
                   Y => xor_out );
                                      
    and_comp : entity work.andN
        generic map (N => N)
        port map ( A => in1,
                   B => in2,
                   Y => and_out );
                   
    mux_comp : entity work.muxN_9to1
        generic map (N => N)
        port map ( data0 => ripcar_add_out,
                   data1 => and_out,
                   data2 => mult_out,
                   data3 => or_out,
                   data4 => xor_out,
                   data5 => sll_out,
                   data6 => sra_out,
                   data7 => srl_out,
                   data8 => ripcar_sub_out,
                   sel => control,
                   output => out1 );
end Structural;