library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_mod is
    GENERIC (N : INTEGER := 1024);
    port ( addr  : in  std_logic_vector(27 downto 0);
           d_out : out std_logic_vector(31 downto 0) );
end memory_mod;

architecture Behavioral of memory_mod is

    -- r-type instruction codes
    constant r_code       : std_logic_vector(5 downto 0) := "000000";
    constant add_code     : std_logic_vector(5 downto 0) := "100000";
    constant and_code     : std_logic_vector(5 downto 0) := "100100";
    constant multu_code   : std_logic_vector(5 downto 0) := "011001";
    constant or_code      : std_logic_vector(5 downto 0) := "100101";
    constant sll_code     : std_logic_vector(5 downto 0) := "000000";
    constant sra_code     : std_logic_vector(5 downto 0) := "000011";
    constant srl_code     : std_logic_vector(5 downto 0) := "000010";
    constant sub_code     : std_logic_vector(5 downto 0) := "100011";
    constant xor_code     : std_logic_vector(5 downto 0) := "100110";
    -- i-type instruction codes
    constant addi_code    : std_logic_vector(5 downto 0) := "001000";
    constant andi_code    : std_logic_vector(5 downto 0) := "001100";
    constant ori_code     : std_logic_vector(5 downto 0) := "001101";
    constant xori_code    : std_logic_vector(5 downto 0) := "001110";
    constant sw_add_code  : std_logic_vector(5 downto 0) := "001111";
    constant lw_add_code  : std_logic_vector(5 downto 0) := "100011";
    -- j-type instruction codes
    constant j_code1      : std_logic_vector(5 downto 0) := "000010";
    constant j_code2      : std_logic_vector(5 downto 0) := "000011";
    
    -- sample instruction values
    constant imm0         : std_logic_vector(15 downto 0) := X"0000";
    constant imm1         : std_logic_vector(15 downto 0) := X"A5A5";
    constant imm2         : std_logic_vector(15 downto 0) := X"1234";
    constant jump_addr    : std_logic_vector(25 downto 0) := "00" & X"FFFFFF";
    constant r0        : std_logic_vector(4 downto 0) := "00000";
    constant r1        : std_logic_vector(4 downto 0) := "00001";
    constant r2        : std_logic_vector(4 downto 0) := "00010";
    constant r3        : std_logic_vector(4 downto 0) := "00011";
    constant r4        : std_logic_vector(4 downto 0) := "00100";
    constant r5        : std_logic_vector(4 downto 0) := "00101";
    constant shift        : std_logic_vector(4 downto 0) := "00100";

    -- *** to view registers at specific time: T = 20((ins# / 4) + 6)

    type mem_type is array (0 to N-1) of std_logic_vector(31 downto 0);
    signal mem : mem_type := ( /*
                               -- instruction set 1                             -- *** R4 = 0xa5a5 @ 380ns ***
                               04 => addi_code & r0 & r1 & imm1,                -- R1 <- 0xa5a5
                               08 => addi_code & r0 & r2 & imm2,                -- R2 <- 0x1234
                               28 => r_code & r1 & r2 & r3 & shift & add_code,  -- R3 <- R1 + R2
                               48 => sw_add_code & r3 & r1 & imm2,              -- [R3 + 0x1234] <- R1
                               52 => lw_add_code & r3 & r4 & imm2,              -- R4 <- [R3 + 0x1234]
                               
                               -- instruction set 2                             -- *** R5 = 0xb6fa @ 500ns ***
                               56 => r_code & r2 & r0 & r2 & shift & srl_code,  -- R2 <- R2 >> 3
                               76 => r_code & r2 & r3 & r5 & shift & xor_code,  -- R5 <- R2 XOR R3
                               96 => sw_add_code & r0 & r5 & imm2,              -- [0x1234] <- R5
                               
                               -- instruction set 3                               -- *** R2 = 0x76651122 @ 620ns ***
                               100 => r_code & r5 & r1 & r2 & shift & multu_code, -- R2 <- R5 * R1
                               
                               -- instruction set 4                               -- *** R3 = 0x1155 @ 640ns ***
                               104 => r_code & r5 & r1 & r3 & shift & sub_code,   -- R3 <- R5 - R1
                               
                               -- instruction set 5                               -- *** R4 = 0xa4a0 @ 660ns ***
                               108 => andi_code & r5 & r4 & imm1,                 -- R4 <- R5 AND 0xa5a5
                               */
                               
                               /* FIBONACCI SEQUENCE */
                               04 => addi_code & r0 & r1 & X"0001",             -- r1 <- 1
                               24 => sw_add_code & r1 & r1 & X"0000",           -- [1] <- 1
                               28 => addi_code & r0 & r1 & X"0000",             -- r1 <- 0
                               48 => lw_add_code & r1 & r2 & X"0000",           -- r2 <- [r1]
                               52 => lw_add_code & r1 & r3 & X"0001",           -- r3 <- [r1+1]
                               72 => r_code & r2 & r3 & r4 & shift & add_code,  -- r4 <- r2 + r3
                               92 => sw_add_code & r1 & r4 & X"0002",           -- [r1+2] <- r4
                               96 => addi_code & r1 & r1 & X"0001",             -- r1 <- r1 + 1
                               116 => j_code1 & "00" & X"00000C",               -- pc <- 48
                               
                               others => X"00000000"
                             );
                             

                             
    
                             
    /* SAMPLE INSTRUCTION FORMS
    00 => r_code & reg_s & reg_t & reg_d & shift & add_code,
    00 => addi_code & reg_s & reg_t & imm,
    00 => sw_add_code & reg_s & reg_t & imm,
    00 => lw_add_code & reg_s & reg_t & imm,
    00 => j_code1 & jump_addr,
    00 => j_code2 & jump_addr,
    */  
    
begin
    process (addr) begin
        d_out <= mem(to_integer(unsigned(addr(9 downto 0))));
    end process;
end Behavioral;