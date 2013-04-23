-- Ian Roth
-- ECE 8455
-- Mandelbrot Calculation, final project
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY work;
USE work.fixed_pkg.all;

ENTITY Mandelbrot IS
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
END ENTITY Mandelbrot;

ARCHITECTURE Behavior of Mandelbrot IS
	CONSTANT limit			:sfixed(3 downto 0) := X"2";
	SIGNAL x_sqr, y_sqr	:sfixed(3 downto -32);
BEGIN
	x_sqr <= resize(x_in * x_in, x_sqr);
	y_sqr <= resize(y_in * y_in, y_sqr);
	Process(clk,rst)
	BEGIN
		IF (clk'EVENT and clk = '1') THEN
			IF (rst = '1') THEN
				iteration_out <= X"0000";
				done_out <= '0';
			ELSE
				x_out <= resize(x_sqr - y_sqr + x_const, x_sqr);
				y_out <= resize(((x_in * y_in) sll 1) + y_const, y_sqr);
				x_const_out <= x_const;
				y_const_out <= y_const;
				IF (done_in = '1') THEN
					done_out <= '1';
					iteration_out <= iteration_in;
				ELSE
					IF (resize(x_sqr + y_sqr, x_sqr) > limit) THEN
						done_out <= '1';
						iteration_out <= iteration_in;
					ELSE
						done_out <= '0';
						iteration_out <= iteration_in + 1;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavior;