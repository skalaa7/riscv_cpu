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
      op_i   : in STD_LOGIC_VECTOR(4 DOWNTO 0); --port za izbor operacije
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --rezultat
      zero_o : out STD_LOGIC; -- signal da je rezultat nula
      of_o   : out STD_LOGIC); -- signal da je doslo do prekoracenja opsega
END ALU;

ARCHITECTURE behavioral OF ALU IS

   constant  l2WIDTH : natural := integer(ceil(log2(real(WIDTH))));
   signal    srl_res,xor_res,slt_res,sll_res,add_res, sub_res, or_res, and_res,res_s:  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);

   
BEGin

   -- addition
   add_res <= std_logic_vector(unsigned(a_i) + unsigned(b_i));
   -- subtraction
   sub_res <= std_logic_vector(unsigned(a_i) - unsigned(b_i));
   -- and gate
   and_res <= a_i and b_i;
   -- or gate
   or_res <= a_i or b_i; 
   --shift left logic
   sll_res<=std_logic_vector(shift_left(unsigned(a_i),to_integer(unsigned(b_i))));
   --shift right logic
   srl_res<=std_logic_vector(shift_right(unsigned(a_i),to_integer(unsigned(b_i))));
   --xor gate
   xor_res<=a_i xor b_i;
   --set lass than
   
   slt_res<=std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i)<signed(b_i)) else std_logic_vector(to_unsigned(0,WIDTH));

   
   -- SELECT RESULT
   res_o <= res_s;
   with op_i select
      res_s <= and_res when and_op, --and
               or_res  when or_op, --or
               add_res when add_op, --add
               sub_res when sub_op, --sub
               sll_res when sll_op,
               srl_res when srl_op,
               xor_res when xor_op,
               slt_res when lts_op,
               (others => '1') when others; 


   -- Postavlja zero_o na 1 ukoliko je rezultat operacije 0
   zero_o <= '1' when res_s = std_logic_vector(to_unsigned(0,WIDTH)) else
             '0';
   
   -- Prekoracenje se desava kada ulazi imaju isti znak, a izlaz razlicit
   of_o <= '1' when ((op_i="00011" and (a_i(WIDTH-1)=b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1))='1')) or (op_i="10011" and (a_i(WIDTH-1)=res_s(WIDTH-1)) and ((a_i(WIDTH-1) xor b_i(WIDTH-1))='1'))) else
           '0';


END behavioral;
