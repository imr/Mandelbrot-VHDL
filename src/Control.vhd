-- Ian Roth
-- ECE 8455
-- control logic, final project
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.fixed_pkg.all;

ENTITY Control IS
	PORT(
		clk, rst						:IN STD_LOGIC;
		Zoom, ZoomX, ZoomY		:IN STD_LOGIC;
		x_const, y_const			:OUT STD_LOGIC_VECTOR(35 downto 0);
		x_addr, y_addr, w_addr	:OUT STD_LOGIC_VECTOR(9 downto 0);
		WE_const, WE				:OUT STD_LOGIC

	);
END ENTITY Control;

ARCHITECTURE Behavior OF Control IS
	TYPE state_type IS (A,B,C,D,E,F,G);
	SIGNAL cur_state		:state_type;
	SIGNAL x_counter		:UNSIGNED(9 downto 0);
	SIGNAL y_counter		:UNSIGNED(9 downto 0);
	SIGNAL w_counter		:UNSIGNED(9 downto 0);
	SIGNAL pixel_counter	:UNSIGNED(19 downto 0);
	SIGNAL x_com_min, x_com_max, y_com_min, y_com_max, x_span, y_span 		:sfixed(3 downto -32);
	SIGNAL h_pixel, w_pixel, h_npixel, w_npixel, x_int_const, y_int_const	:sfixed(3 downto -32);
	SIGNAL iteration_counter	:UNSIGNED(15 downto 0);
	CONSTANT x_size			:sfixed(10 downto 0) := "10000000000"; -- 1024
	CONSTANT y_size			:sfixed(10 downto 0) := "01100000000"; -- 768
BEGIN
	x_const <= STD_LOGIC_VECTOR(x_int_const);
	y_const <= STD_LOGIC_VECTOR(y_int_const);
	x_addr <= STD_LOGIC_VECTOR(x_counter);
	y_addr <= STD_LOGIC_VECTOR(y_counter);
	w_addr <= STD_LOGIC_VECTOR(w_counter);
	w_npixel <= resize((x_span sra 1) / x_size, w_npixel);
	h_npixel <= resize((y_span sra 1) / y_size, h_npixel);
	PROCESS(clk, rst)
	BEGIN
		IF (clk'EVENT and clk = '1') THEN
			IF (rst = '1') THEN
				x_com_min <= to_sfixed(-2, x_com_min);
				x_com_max <= to_sfixed(1, x_com_max);
				y_com_min <= to_sfixed(-1, y_com_min);
				y_com_max <= to_sfixed(1, y_com_max);
				x_int_const <= to_sfixed(-2, x_int_const);
				y_int_const <= to_sfixed(1, y_int_const);
				w_pixel <= to_sfixed(0.0029296875, w_pixel);
				h_pixel <= to_sfixed(0.0026146667, h_pixel);
				x_span <= to_sfixed(4, x_span);
				y_span <= to_sfixed(2, y_span);
				WE_const <= '1';
				WE <= '0';
				cur_state <= A;
			ELSE
				CASE cur_state IS
					WHEN A =>
						x_counter <= "0000000000";
						y_counter <= "0000000000";
						w_counter <= "0000000000";
						pixel_counter <= X"00000";
						WE_const <= '1';
						WE <= '0';
						cur_state <= B;
					WHEN B => -- Load first constants for complex x y plane
						x_int_const <= resize(x_int_const + w_pixel, x_int_const);
						y_int_const <= resize(y_int_const - h_pixel, y_int_const);
						w_counter <= w_counter + 1;
						WE_const <= '1';
						WE <= '0';
						cur_state <= C;
					WHEN C => -- Start Pipeline, 23 (pipeline length) cycles
						x_int_const <= resize(x_int_const + w_pixel, x_int_const);
						y_int_const <= resize(y_int_const - h_pixel, y_int_const);
						w_counter <= w_counter + 1;
						WE_const <= '1';
						WE <= '0';
						x_counter <= x_counter + 1;
						IF (x_counter = 22) THEN
							cur_state <= D;
						END IF;
					WHEN D => -- Write into memory
						x_int_const <= resize(x_int_const + w_pixel, x_int_const);
						y_int_const <= resize(y_int_const - h_pixel, y_int_const);
						w_counter <= w_counter + 1;
						WE_const <= '1';
						WE <= '1';
						x_counter <= x_counter + 1;
						pixel_counter <= pixel_counter + 1; -- Actual written pixels
						IF (w_counter = 1022) THEN
							cur_state <= E;
						END IF;
					WHEN E => -- Stop constants
						WE_const <= '0';
						WE <= '1';
						x_counter <= x_counter + 1;
						pixel_counter <= pixel_counter + 1; -- Actual written pixels
						IF (x_counter = 1023) THEN
							y_counter <= y_counter + 1;
						ELSE
							y_counter <= y_counter;
						END IF;
						IF (pixel_counter = X"BFFFF") THEN
							cur_state <= F;
						END IF;
					WHEN F => -- Stop writing to memory
						WE_const <= '0';
						WE <= '0';
						IF (Zoom = '0') THEN
							IF (ZoomX = '0') THEN -- Zoom in on right
								x_com_min <= resize(x_com_min + (x_span sra 1), x_com_min);
							ELSE
								x_com_max <= resize(x_com_max - (x_span sra 1), x_com_max);
							END IF;
							IF (ZoomY = '0') THEN -- Zoom in on top
								y_com_min <= resize(y_com_min + (y_span sra 1), x_com_min);
							ELSE
								y_com_max <= resize(y_com_max - (y_span sra 1), x_com_max);
							END IF;
							w_pixel <= w_npixel;
							h_pixel <= h_npixel;
							x_span <= x_span sra 1;
							y_span <= y_span sra 1;
							cur_state <= G;
						END IF;
					WHEN G =>
						x_int_const <= x_com_min;
						y_int_const <= y_com_max;
						IF (Zoom = '1') THEN
							cur_state <= A;
						END IF;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
END Behavior;