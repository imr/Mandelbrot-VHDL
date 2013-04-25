-- Ian Roth
-- ECE 8455
-- VGA module, final project

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY VGA IS
	PORT(
		VGA_CLK, VGA_BLANK_N, VGA_HS, VGA_VS, start :OUT STD_LOGIC;
		clk, rst	:IN STD_LOGIC
	);
END ENTITY VGA;

ARCHITECTURE Behavior OF VGA IS
	SIGNAL Hcount	:UNSIGNED(10 downto 0);
	SIGNAL Vcount	:UNSIGNED(10 downto 0);
	SIGNAL int_hs, int_vs :STD_LOGIC;
	CONSTANT Hactive	:UNSIGNED(10 downto 0)	:= "10000000000"; -- 1024
	CONSTANT Hsyncs	:UNSIGNED(10 downto 0)	:= "10000011001"; -- 1048 = 1024 + 24 (+1)
	CONSTANT Hsynce	:UNSIGNED(10 downto 0)	:= "10010100001"; -- 1184 = 1024 + 24 + 136 (+1)
	CONSTANT Htotal	:UNSIGNED(10 downto 0)	:= "10101000000"; -- 1344
	CONSTANT Vactive	:UNSIGNED(9 downto 0)	:= "1100000000"; -- 768
	CONSTANT Vsysns	:UNSIGNED(9 downto 0)	:= "1100000011"; -- 768 + 3 (+1)
	CONSTANT Vsynce	:UNSIGNED(9 downto 0)	:= "1100001001"; -- 768 + 3 + 6 (+1)
	CONSTANT Vtotal	:UNSIGNED(9 downto 0)	:= "1100100110"; -- 806
BEGIN
	VGA_CLK <= NOT clk;
	start <= (NOT int_hs) AND (NOT int_vs);
	VGA_HS <= int_hs;
	VGA_VS <= int_vs;
	PROCESS(clk, rst)
	BEGIN
		IF (clk'EVENT AND clk = '1') THEN
			IF (rst = '1') THEN
				Hcount <= "00000000000";
				Vcount <= "00000000000";
				int_hs <= '1';
				int_vs <= '1';
			ELSE
				IF (Hcount < Htotal) THEN
					Hcount <= Hcount + 1;
				ELSE
					Hcount <= "00000000000";
				END IF;
				IF (Hcount = Hsyncs) THEN
					int_hs <= '0';
				END IF;
				IF (Hcount = Hsynce) THEN
					int_hs <= '1';
					IF (Vcount < Vtotal) THEN
						Vcount <= Vcount + 1;
					ELSE
						Vcount <= "00000000000";
					END IF;
				END IF;
				IF (Vcount = Vsysns) THEN
					int_vs <= '0';
				END IF;
				IF (Vcount = Vsynce) THEN
					int_vs <= '1';
				END IF;
				IF ((Hcount < Hactive) AND (Vcount < Vactive)) THEN
					VGA_BLANK_N <= '1';
				ELSE
					VGA_BLANK_N <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavior;