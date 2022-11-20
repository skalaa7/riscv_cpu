LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;
use work.alu_ops_pkg.all;


ENTITY ALU IS
   GENERIC(
      WIDTH : NATURAL := 32);
   PORT(
      a_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
      b_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
      op_i   : in STD_LOGIC_VECTOR(4 DOWNTO 0); --selekcija operacije
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --rezultat
      zero_o : out STD_LOGIC; --signalni bit jednakosti nuli
      of_o   : out STD_LOGIC); --signalni bit prekoracenja opsega
END ALU;

ARCHITECTURE behavioral OF ALU IS

   constant  l2WIDTH : natural := integer(ceil(log2(real(WIDTH))));
   signal    add_res, sub_res, or_res, and_res,slt_res,sltu_res,xor_res,sll_res,srl_res,sra_res,res_s, eq_res :  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);

   
BEGIN

   -- sabiranje
   add_res <= std_logic_vector(unsigned(a_i) + unsigned(b_i));
   -- oduzimanje
   sub_res <= std_logic_vector(unsigned(a_i) - unsigned(b_i));
   -- i kolo
   and_res <= a_i and b_i;
   -- ili kolo
   or_res <= a_i or b_i;
   -- jednakost
   eq_res <= std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i) = signed(b_i)) else
             std_logic_vector(to_unsigned(0,WIDTH));
   --rs1 manje od rs2 signed
   slt_res<=std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i) < signed(b_i)) else
             std_logic_vector(to_unsigned(0,WIDTH));
   --rs1 manje od rs2 unsigned
   sltu_res<=std_logic_vector(to_unsigned(1,WIDTH)) when (unsigned(a_i) < unsigned(b_i)) else
             std_logic_vector(to_unsigned(0,WIDTH));
   --shift left logic
   sll_res<=std_logic_vector(shift_left(unsigned(a_i),to_integer(unsigned(b_i))));
   --shift right logic
   srl_res<=std_logic_vector(shift_right(unsigned(a_i),to_integer(unsigned(b_i))));
   --shift rigth arithmetic
   sra_res<=std_logic_vector(shift_right(signed(a_i),to_integer(unsigned(b_i))));
   -- iskljucivo ili kolo
   xor_res<=a_i xor b_i;

   
   -- prosledi jedan od rezultata na izlaz u odnosu na  operaciju
   res_o <= res_s;
   with op_i select
      res_s <= and_res when and_op,
               or_res  when or_op,
               add_res when add_op,
               sub_res when sub_op,
               eq_res  when eq_op,
               slt_res when slt_op,
               sltu_res when sltu_op,
               sll_res when sll_op,
               srl_res when srl_op,
               sra_res when sra_op,
               xor_res when xor_op,
               (others => '1') when others; 


   -- signalni izlazi
   -- postavi singnalni bit jednakosti nuli
   zero_o <= '1' when res_s = std_logic_vector(to_unsigned(0,WIDTH)) else
             '0';
   -- postavi signalni bit prekoracenja
   of_o <= '1' when ((op_i="00011" and (a_i(WIDTH-1)=b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1))='1')) or (op_i="10011" and (a_i(WIDTH-1)=res_s(WIDTH-1)) and ((a_i(WIDTH-1) xor b_i(WIDTH-1))='1'))) else
           '0';


END behavioral;
