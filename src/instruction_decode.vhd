-- --------------------------------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT )
-- Engineer : Chris Abajian (cxa6282@rit.edu)
--
-- Create Date : 2/21/2019
-- Design Name : instruction_decode
-- Module Name : instruction_decode - behavioral
-- Project Name : Exercise04
--
-- Description : Instruction decode stage of a pipelined MIPS processor
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_decode is
    port ( Instruction : in std_logic_vector(31 downto 0);
           RegDataA    : in std_logic_vector(31 downto 0);
           RegDataB    : in std_logic_vector(31 downto 0);
           Jump        : out std_logic;
           JumpAddr    : out std_logic_vector(27 downto 0);
           ALUOp       : out std_logic_vector(3 downto 0);
           ValA        : out std_logic_vector(31 downto 0);
           ValB        : out std_logic_vector(31 downto 0);
           MemWr       : out std_logic;
           MemRd       : out std_logic;
           RegIdxA     : out std_logic_vector(4 downto 0);
           RegIdxB     : out std_logic_vector(4 downto 0);
           RegIdxWb    : out std_logic_vector(4 downto 0)
         );
end instruction_decode;

architecture Behavioral of instruction_decode is

    -- op code function constants
    constant f_add_code   : std_logic_vector(3 downto 0) := "0100";
    constant f_and_code   : std_logic_vector(3 downto 0) := "1010";
    constant f_multu_code : std_logic_vector(3 downto 0) := "0110";
    constant f_or_code    : std_logic_vector(3 downto 0) := "1000";
    constant f_xor_code   : std_logic_vector(3 downto 0) := "1011";
    constant f_sll_code   : std_logic_vector(3 downto 0) := "1100";
    constant f_sra_code   : std_logic_vector(3 downto 0) := "1110";
    constant f_srl_code   : std_logic_vector(3 downto 0) := "1101";
    constant f_sub_code   : std_logic_vector(3 downto 0) := "0101";
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
    
    -- function to retrieve the ALU op codes from the function code.    
    function get_alu_op (
        constant func_code : std_logic_vector(5 downto 0);
        rtype     : boolean )
        return std_logic_vector is
    begin
        -- prevent r-type SUB and i-type LW, ADD from colliding
        if rtype and func_code = sub_code then
            return f_sub_code;
        end if;
        case func_code is
            when add_code | addi_code | sw_add_code | lw_add_code => return f_add_code;
            when and_code | andi_code => return f_and_code;
            when multu_code => return f_multu_code;
            when or_code | ori_code => return f_or_code;
            when xor_code | xori_code => return f_xor_code;
            when sll_code => return f_sll_code;
            when sra_code => return f_sra_code;
            when srl_code => return f_srl_code;
            when others => return "0000";
        end case;
    end function;              
        
begin

    reg_en_wb_process : process(Instruction, RegDataA, RegDataB) is begin

        -- assign default output values
        Jump <= '0';
        JumpAddr <= (others => '0');
        ValA <= RegDataA;
        ValB <= RegDataB;
        MemWr <= '0';
        MemRd <= '0';
        RegIdxA <= Instruction(25 downto 21);
        RegIdxB <= Instruction(20 downto 16);
        RegIdxWb <= Instruction(15 downto 11);

        case Instruction(31 downto 26) is
            when r_code => -- r-type instruction
                -- set ALUOp code
                ALUOp <= get_alu_op(Instruction(5 downto 0), true);
                -- if shift, change ValB to shift ammount, RegIdxA to Instruction(20 downto 16), and clear RegIdxB
                if (get_alu_op(Instruction(5 downto 0), true) = f_sll_code or get_alu_op(Instruction(5 downto 0), true) = f_sra_code or get_alu_op(Instruction(5 downto 0), true) = f_srl_code) then
                    ValB <= (31 downto 5 => '0') & Instruction(10 downto 6);
                    RegIdxB <= (others => '0');
                end if;
            when addi_code | andi_code | ori_code | xori_code | sw_add_code | lw_add_code => -- i-type instructions, non-memory
                -- set outputs
                ALUOp <= get_alu_op(Instruction(31 downto 26), false);
                ValB <= (31 downto 16 => '0') & Instruction(15 downto 0);
                RegIdxB <= (others => '0');
                RegIdxWb <= Instruction(20 downto 16);
                -- Set MemWr
                if (Instruction(31 downto 26) = sw_add_code) then
                    MemWr <= '1';
                    RegIdxB <= Instruction(20 downto 16);
                    RegIdxWb <= (others => '0');
                elsif (Instruction(31 downto 26) = lw_add_code) then
                    MemRd <= '1';
                end if;
            when j_code1 | j_code2 =>
                -- set Jump values
                Jump <= '1';
                JumpAddr <= Instruction(25 downto 0) & "00";
                -- set ALUOp to zero
                ALUOp <= (others => '0');
                -- clear other outputs
                RegIdxA <= (others => '0');
                RegIdxB <= (others => '0');
                RegIdxWb <= (others => '0');
                ValA <= (others => '0');
                ValB <= (others => '0');
            when others => null;
        end case;
    end process;
    
end Behavioral;
