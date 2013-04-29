-- Ian Roth
-- ECE 8455
-- pipelined Mandelbrot Set, final project
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY work;
USE work.fixed_pkg.all;

ENTITY Math IS
	PORT(
		clk, rst					:IN STD_LOGIC;
		x_const, y_const		:IN STD_LOGIC_VECTOR(35 downto 0);
		result					:OUT STD_LOGIC_VECTOR(15 downto 0)
	);
END ENTITY Math;

ARCHITECTURE Behavior of Math IS
	TYPE fixed_array IS ARRAY(23 downto 0) OF sfixed(3 downto -32);
	TYPE unsigned_array IS ARRAY(23 downto 0) OF UNSIGNED(15 downto 0);
	SIGNAL x_array, y_array, x_const_array, y_const_array :fixed_array;
	SIGNAL result_array	:unsigned_array;
	SIGNAL done_array		:STD_LOGIC_VECTOR(23 downto 0);
	CONSTANT fixed_zero	:sfixed(3 downto -32) := X"000000000";
	COMPONENT Mandelbrot
	PORT(
		x_const, y_const	:IN sfixed(3 downto -32);
		x_in, y_in			:IN sfixed(3 downto -32);
		iteration_in		:IN unsigned(15 downto 0);
		done_in, clk, rst	:IN STD_LOGIC;
		x_const_out, y_const_out  :OUT sfixed(3 downto -32);
		x_out, y_out		:OUT sfixed(3 downto -32);
		iteration_out		:OUT unsigned(15 downto 0);
		done_out				:OUT STD_LOGIC
	);
	END COMPONENT;
BEGIN
	result <= STD_LOGIC_VECTOR(result_array(23));
	stage0: Mandelbrot PORT MAP(x_const => to_sfixed(x_const, 3, -32), y_const => to_sfixed(y_const, 3, -32),
		x_in => fixed_zero, y_in => fixed_zero, iteration_in => X"0000",
		done_in => '0', clk => clk, rst => rst, x_const_out => x_const_array(0),
		y_const_out => y_const_array(0), x_out => x_array(0),
		y_out => y_array(0), iteration_out => result_array(0), done_out => done_array(0));
	gen_math:
	FOR i IN 1 TO 23 GENERATE
		stageX: Mandelbrot PORT MAP(x_const => x_const_array(i-1), y_const => y_const_array(i-1),
			x_in => x_array(i-1), y_in => y_array(i-1), iteration_in => result_array(i-1),
			done_in => done_array(i-1), clk => clk, rst => rst, x_const_out => x_const_array(i),
			y_const_out => y_const_array(i), x_out => x_array(i),
			y_out => y_array(i), iteration_out => result_array(i), done_out => done_array(i));
	END GENERATE gen_math;
END Behavior;