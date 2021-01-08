----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/12/01 14:14:53
-- Design Name: 
-- Module Name: synapse_module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity synapse_module is
    Port ( in_spike_s : in STD_LOGIC;
    		out_spike_s : in STD_LOGIC;
    		CLK : in std_logic;
           weight : out integer range -127 to 127);
end synapse_module;

architecture Behavioral of synapse_module is
signal in_time : integer range -127 to 127 := 0;
signal in_flag : std_logic := '0';
signal out_time : integer range -127 to 127 := 0;
signal out_flag : std_logic := '0';
signal dif_in_out : integer range -255 to 255:= 0;
signal weight_val : integer range -127 to 127 := 0;
begin
--Detect_in_spike : 
	process(in_spike_s) begin
		if (rising_edge(in_spike_s)) then
			in_flag <= '1';
			in_time <= 0;
		end if;
	end process;
--in time counter
	process(in_flag, CLK) begin
		if (rising_edge(CLK)) then
			if (in_flag = '1') then
				in_time <= in_time + 1;
			end if;
		end if;
	end process;
--Detect out_spike
	process (out_spike_s) begin
		if (rising_edge(out_spike_s)) then
			out_flag <= '1';
			out_time <= 0;
		end if;
	end process;
--out time counter
	process (out_flag, CLK) begin
		if (rising_edge(CLK)) then
			if (out_flag = '1') then
				out_time <= out_time + 1;	
			end if;
		end if;
	end process;
	--STDP learning curve
	dif_in_out <= in_time - out_time;
	process(weight_val, dif_in_out, in_flag, out_flag) begin			--work by clock if not working well
		if (in_flag = '1') then
			if (out_flag ='1') then
				case dif_in_out is
					when 127 to 255 => if (weight_val >= 127) then weight_val <= 127; else  weight_val <= weight_val + 1; end if;
					when 1 to 126 => if (weight_val >= 127) then weight_val <= 127; else weight_val <= weight_val + 2; end if;
					when -126 to -1 => if (weight_val <= -127) then weight_val <= -127; else weight_val <= weight_val - 2; end if;
					when -255 to -127 => if (weight_val <= -127) then weight_val <= -127; else weight_val <= weight_val - 1; end if;
					when others => weight_val <= weight_val;
				end case;
				in_flag <= '0';
				out_flag <= '0';
			end if;
		end if;
	end process;
	weight <= weight_val;

end Behavioral;
