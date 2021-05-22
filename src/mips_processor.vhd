-- --------------------------------------------------------------------------------
-- Company : Rochester Institute of Technology (RIT )
-- Engineer : Chris Abajian (cxa6282@rit.edu)
--
-- Create Date : 4/7/2019
-- Design Name : mips_processor
-- Module Name : mips_processor
-- Project Name : Project 1
-- Target Devices : Basys3
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity mips_processor is
    port ( CLK_100MHz : in std_logic;
           rstn  : in std_logic;
           alu_out : out std_logic_vector(31 downto 0)
         );
end mips_processor;

architecture Behavioral of mips_processor is

    -- clock, reset
    signal clk : std_logic;
    -- stage 0
    signal s0_pc_addr : std_logic_vector(27 downto 0);
    -- stage 1
    signal s1_pc_addr_plus4 : std_logic_vector(27 downto 0);
    signal s1_pc_addr : std_logic_vector(27 downto 0);
    signal s1_instr_fetch_instruction : std_logic_vector(31 downto 0);
    -- stage 2
    signal s2_pc_addr_plus4 : std_logic_vector(27 downto 0);
    signal s2_instr_fetch_instruction : std_logic_vector(31 downto 0);
    signal s2_rega_idx, s2_regb_idx, s2_wb_idx : std_logic_vector(4 downto 0);
    signal s2_rega_data, s2_regb_data : std_logic_vector(31 downto 0);
    signal s2_jump_addr : std_logic_vector(27 downto 0);
    signal s2_memrd_en, s2_memwr_en, s2_jump_en : std_logic;
    signal s2_aluop : std_logic_vector(3 downto 0);
    signal s2_vala, s2_valb : std_logic_vector(31 downto 0);
    -- stage 3
    signal s3_wb_idx : std_logic_vector(4 downto 0);
    signal s3_jump_addr : std_logic_vector(27 downto 0);
    signal s3_memrd_en, s3_memwr_en, s3_jump_en : std_logic;
    signal s3_aluop : std_logic_vector(3 downto 0);
    signal s3_vala, s3_valb, s3_store_val : std_logic_vector(31 downto 0);
    signal s3_alu_result : std_logic_vector(31 downto 0);
    -- stage 4
    signal s4_alu_result, s4_store_val, s4_mem_out : std_logic_vector(31 downto 0);
    signal s4_wb_idx : std_logic_vector(4 downto 0);
    signal s4_jump_addr : std_logic_vector(27 downto 0);
    signal s4_memrd_en, s4_memwr_en, s4_jump_en : std_logic;
    -- stage 5
    signal s5_wb_idx : std_logic_vector(4 downto 0);
    signal s5_memrd_en, s5_memwr_en, s5_memwr_en_not : std_logic;
    signal s5_alu_result, s5_mem_out : std_logic_vector(31 downto 0);
    signal s5_reg_data : std_logic_vector(31 downto 0);    
    
    component clk_wiz_0
    port
     (-- Clock in ports
      -- Clock out ports
      clk_out1          : out    std_logic;
      -- Status and control signals
      resetn             : in     std_logic;
      clk_in1           : in     std_logic
     );
    end component;
    
begin
    
    alu_out <= s3_alu_result;

    clk_wiz : clk_wiz_0
        port map ( 
            -- Clock out ports  
            clk_out1 => clk,
            -- Status and control signals                
            resetn => rstn,
            -- Clock in ports
            clk_in1 => CLK_100MHz
        );

    --clk <= CLK_100MHz;
    
    -- ----------------------------
    -- STAGE 0 
    -- ----------------------------
    
    -- program counter 2 to 1 multiplexer
    s0_pc_addr <= (others => '0') when rstn = '0'
            else s1_pc_addr_plus4 when s4_jump_en = '0'
            else s4_jump_addr;
                                  
    -- stage 0 to 1 transition
    s0_to_s1_proc : process(clk, rstn) is begin
        if rstn = '0' then
            s1_pc_addr <= (others => '0');
        elsif rising_edge(clk) then
            s1_pc_addr <= s0_pc_addr;
        end if;
    end process;
    
    -- ----------------------------
    -- STAGE 1 
    -- ----------------------------
    
    -- unstruction memory
    s1_instr_mem_comp : entity work.memory_mod
        generic map ( N => 1024 )
        port map ( addr => s1_pc_addr,
                   d_out => s1_instr_fetch_instruction
                 );
    
    -- program counter increment
    s1_pc_addr_plus4 <= (others => '0') when rstn = '0' else std_logic_vector(unsigned(s1_pc_addr) + to_unsigned(4,28));
                 
    -- stage 1 to 2 transition
    s1_to_s2_proc : process(clk, rstn) is begin
        if rstn = '0' then
            s2_pc_addr_plus4 <= (others => '0');
            s2_instr_fetch_instruction <= (others => '0');
        elsif rising_edge(clk) then
            s2_pc_addr_plus4 <= s1_pc_addr_plus4;
            s2_instr_fetch_instruction <= s1_instr_fetch_instruction;
        end if;
    end process;
    
    -- ----------------------------
    -- STAGE 2 
    -- ----------------------------
    
    -- instruction decode
    s2_instruction_decode_comp : entity work.instruction_decode
        port map ( Instruction => s2_instr_fetch_instruction,
                   RegDataA => s2_rega_data,
                   RegDataB => s2_regb_data,
                   Jump => s2_jump_en,
                   JumpAddr => s2_jump_addr,
                   ALUOp => s2_aluop,
                   ValA => s2_vala,
                   ValB => s2_valb,
                   MemWr => s2_memwr_en,
                   MemRd => s2_memrd_en,
                   RegIdxA => s2_rega_idx,
                   RegIdxB => s2_regb_idx,
                   RegIdxWb => s2_wb_idx
                 );
    
    -- register file
    s2_reg_file_comp : entity work.register_file
        port map ( clk => clk,
                   rst => rstn,
                   we => s5_memwr_en_not,
                   rd1 => s2_rega_idx,
                   rd2 => s2_regb_idx,
                   wr => s5_wb_idx,
                   din => s5_reg_data,
                   out1 => s2_rega_data,
                   out2 => s2_regb_data
                 );
                 
    -- stage 2 to 3 transition
    s2_to_s3_proc : process(clk, rstn) is begin
        if rstn = '0' then
            s3_jump_addr <= (others => '0');
            s3_jump_en <= '0';
            s3_memrd_en <= '0';
            s3_memwr_en <= '0';
            s3_wb_idx <= (others => '0');
            s3_aluop <= (others => '0');
            s3_vala <= (others => '0');
            s3_valb <= (others => '0');
            s3_store_val <= (others => '0');
        elsif rising_edge(clk) then
            s3_jump_addr <= s2_jump_addr;
            s3_jump_en <= s2_jump_en;
            s3_memrd_en <= s2_memrd_en;
            s3_memwr_en <= s2_memwr_en;
            s3_wb_idx <= s2_wb_idx;
            s3_aluop <= s2_aluop;
            s3_vala <= s2_vala;
            s3_valb <= s2_valb;
            s3_store_val <= s2_regb_data;
        end if;
    end process;
    
    -- ----------------------------
    -- STAGE 3 
    -- ----------------------------
    
    -- alu
    s3_alu_comp : entity work.alu
        generic map ( N => 32)
        port map ( in1 => s3_vala,
                   in2 => s3_valb,
                   control => s3_aluop,
                   out1 => s3_alu_result
                 );
                 
    -- stage 3 to 4 transition
    s3_to_s4_proc : process(clk, rstn) is begin
        if rstn = '0' then
            s4_jump_addr <= (others => '0');
            s4_jump_en <= '0';
            s4_memrd_en <= '0';
            s4_memwr_en <= '0';
            s4_wb_idx <= (others => '0');
            s4_alu_result <= (others => '0');
            s4_store_val <= (others => '0');
        elsif rising_edge(clk) then
            s4_jump_addr <= s3_jump_addr;
            s4_jump_en <= s3_jump_en;
            s4_memrd_en <= s3_memrd_en;
            s4_memwr_en <= s3_memwr_en;
            s4_wb_idx <= s3_wb_idx;
            s4_alu_result <= s3_alu_result;
            s4_store_val <= s3_store_val;
        end if;
    end process;
    
    -- ----------------------------
    -- STAGE 4 
    -- ----------------------------
    
    -- data memory
    s4_data_mem_comp : entity work.data_memory
        generic map ( width => 32,
                      addr_space => 10 )
        port map ( clk => clk,
                   w_en => s4_memwr_en,
                   addr => s4_alu_result(9 downto 0),
                   d_in => s4_store_val,
                   d_out => s4_mem_out
                 );
    
    -- stage 4 to 5 transition
    s4_to_s5_proc : process(clk, rstn) is begin
        if rstn = '0' then
            s5_memrd_en <= '0';
            s5_memwr_en <= '0';
            s5_wb_idx <= (others => '0');
            s5_alu_result <= (others => '0');
            s5_mem_out <= (others => '0');
        elsif rising_edge(clk) then
            s5_memrd_en <= s4_memrd_en;
            s5_memwr_en <= s4_memwr_en;
            s5_wb_idx <= s4_wb_idx;
            s5_alu_result <= s4_alu_result;
            s5_mem_out <= s4_mem_out;
        end if;
    end process;
    
    -- ----------------------------
    -- STAGE 5 
    -- ----------------------------

    -- 2 to 1 multiplexer          
    s5_reg_data <= s5_alu_result when s5_memrd_en = '0'
              else s5_mem_out;
                 
    -- invert memwr_en
    s5_memwr_en_not <= not s5_memwr_en;

end Behavioral;
