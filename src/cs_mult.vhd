library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cs_mult is
    generic (N : integer := 4);
    port ( A : in STD_LOGIC_VECTOR(N/2-1 downto 0);
           B : in STD_LOGIC_VECTOR(N/2-1 downto 0);
           Product : out STD_LOGIC_VECTOR(N-1 downto 0) );
end cs_mult;

architecture Structural of cs_mult is

    -- Define an "array of vectors" to hold PP's and accumulations
    type vec_array is array (N/2 downto 0) of std_logic_vector(N-2 downto 0);
    -- Create partial product array and accumulator array. Set all values to 0.
    signal pp_array : vec_array := ((others => (others => '0')));
    signal accum_array : vec_array := ((others => (others => '0')));
    -- Create vector to hold all carry-out values produced from M-bit full adders
    signal cout_vec : STD_LOGIC_VECTOR(N/2-1 downto 0) := (others => '0');
    
begin

    -- The partial products array is to be populated in a way that accounts for
    --     the leading zeros (on the right) for each layer. As such, the bit
    --     assignment within each layer is offset by the layer value. For example,
    --     the zero'th layer will correspond to a PP array with no shift; the first
    --     layer will correspond to a PP array with a single bit shift to the left.
    --     This creates a diagonal pattern in the 2D array similar to how humans
    --     perform this operation.
    pp_layer_gen : for i in 0 to ( N/2-1 ) generate begin
        pp_bit_gen : for j in 0 to ( N/2-1 ) generate begin
            pp_array(i)(j+i) <= A(j) and B(i);
        end generate pp_bit_gen;
    end generate pp_layer_gen;
    
    -- Generate accumulation values. One (N-1)-bit FA per layer (N/2 layers).
    accum_gen : for i in 0 to ( N/2-1 ) generate

        -- Each (N-1)-bit FA is mapped with the layer's partial product vector, the
        --     current accumulation vector, and no carry-in. The sum goes to the next
        --     layer's accumulation vector and the carry-out is stored.
        faN_comp : entity work.faN
            generic map (N => (N-1))
            port map (
                A    =>    pp_array(i),      -- A gets PP vector at position i
                B    =>    accum_array(i),   -- B gets accumulator vector at position i
                Cin  =>    '0',              -- carry in set to 0 for the multi-bit adder
                Sum  =>    accum_array(i+1), -- Sum gets next accumulator vector designated by position i+1
                Cout =>    cout_vec(i)       -- carry out is stored. We only care about the very last carry.
            );
            
    end generate accum_gen;

    -- Finally, the Product output must be assigned. The last entries for both
    --     the accumulator and the carry-out are used. The last accumulator
    --     entry signifies the addition of all previous accummulations with
    --     the partial products at each layer. Because the multi-bit full adders
    --     were (N-1)-bit width, the remaining MSB in the Product is the last 
    --     carry out bit.
    Product <= cout_vec(N/2-1) & accum_array(N/2);

end Structural;
