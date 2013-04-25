LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Memory_Control IS
	PORT(
		clk, rst, R_out, R_start,WE	:IN STD_LOGIC;
		data_in					:IN STD_LOGIC_VECTOR(15 downto 0);
		data_mem					:INOUT STD_LOGIC_VECTOR(15 downto 0);
		VGA_R, VGA_G, VGA_B	:OUT STD_LOGIC_VECTOR(7 downto 0);
		addr_out					:OUT STD_LOGIC_VECTOR(19 downto 0);
		WE_out					:OUT STD_LOGIC
	);
END Memory_Control;

ARCHITECTURE Behavior OF Memory_Control IS
	CONSTANT iterations :STD_LOGIC_VECTOR(15 downto 0) := X"0018";
	SIGNAL do			:STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL addr_read	:UNSIGNED(19 downto 0);
	SIGNAL addr_write	:UNSIGNED(19 downto 0);
BEGIN
	data_mem <= "ZZZZZZZZZZZZZZZZ" WHEN WE = '0' ELSE data_in;
	addr_out <= STD_LOGIC_VECTOR(addr_read) WHEN WE = '0' ELSE STD_LOGIC_VECTOR(addr_write);
	PROCESS (clk, rst, R_start)
	BEGIN
		IF (clk'EVENT and clk = '1') THEN
			IF (rst = '1') THEN
				addr_read <= X"00000";
				addr_write <= X"00000";
				WE_out <= '1';
			ELSE
				IF WE = '1' THEN -- write out to memory, does not look at read
					WE_out <= '0';
					IF (addr_write > X"BFFFF") THEN
						addr_write <= X"00000";
					ELSE
						addr_write <= addr_write + 1;
					END IF;
				ELSIF (R_out = '1') THEN -- read out from memory, if needed
					WE_out <= '1';
					do <= data_mem;
					addr_read <= addr_read + 1;
					IF (data_mem = iterations) THEN -- blank pixel if in set
						VGA_R <= X"00";
						VGA_G <= X"00";
						VGA_B <= X"00";
					ELSE -- display iterations away from set in form of pixel color
						VGA_R <= do(15) & do(12) & do(9)  & do(6) & do(3) & do(0) & "11";
						VGA_G <= do(13) & do(10) & do(7) & do(4) & do(1) & "111";
						VGA_B <= do(14) & do(11) & do(8) & do(5) & do(2) & "111";
					END IF;
				END IF;
				IF (R_start = '1') THEN
					addr_read <= X"00000";
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavior;