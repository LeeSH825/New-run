----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/12/01 14:14:53
-- Design Name: 
-- Module Name: neuron_module - Behavioral
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
use IEEE.numeric_std.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity neuron_module is
	generic (	NUM_INPUT_NEURONS : integer := 10;
						LEAKAGE : integer := 5;
						VOLTAGE_TH : integer := 1000 );
    Port (	 in_spike : in STD_LOGIC_VECTOR (0 to 10);
    			CLK : in std_logic;
           		out_spike : out STD_LOGIC);
end neuron_module;

architecture Behavioral of neuron_module is
	component synapse_module
		port( in_spike_s : in STD_LOGIC;
    		out_spike_s : in STD_LOGIC;
    		CLK : in std_logic;
           weight : out integer range -127 to 127);
	end component;
	type weight_reg is array (0 to NUM_INPUT_NEURONS) of integer range -127 to 127;
	signal weight_val_s  : weight_reg := (others => 0);
	type int_in_sig is array(0 to NUM_INPUT_NEURONS) of integer range 0 to 1;
	signal in_sig : int_in_sig;
	signal out_sig : std_logic := '0';
	--signal voltage : integer := 0;
begin
	CONNECT_SYNAPSE:
	for i in 0 to NUM_INPUT_NEURONS generate
		synapse_x : synapse_module port map(in_spike_s => in_spike(i), out_spike_s => out_sig, CLK => CLK, weight => weight_val_s(i));
	end generate CONNECT_SYNAPSE;
	--std_logic to integer values;
	process (in_spike) begin
		for k in 0 to NUM_INPUT_NEURONS loop
			if (in_spike(k) = '1') then
				in_sig(k) <= 1;
			else
				in_sig(k) <= 0;
			end if;
		end loop;
	end process;
		--VOLTAGE:
	process ( CLK, weight_val_s, in_sig,  out_sig )
		variable  voltage_temp : integer := 0;
		variable delay : integer range 0 to 2 := 0;
	 begin
	 	--Renew Voltage
		if (rising_edge(CLK)) then
			for j in 0 to NUM_INPUT_NEURONS loop
				voltage_temp := voltage_temp +  ( weight_val_s(j) *  in_sig(j) );
			end loop;
		end if;
		--Threshold Check
		if (rising_edge(CLK)) then
			if (voltage_temp > VOLTAGE_TH) then
				out_sig <= '1';
				delay := delay + 1;
				voltage_temp := 0;
			end if;
			if ( delay = 1) then		--out_sig become 0 after 1ns;
				out_sig <= '0';
				delay := 0;
			end if;
		voltage_temp := voltage_temp - LEAKAGE;
		end if;
		--voltage <= voltage_temp;		--voltage can be removed; since it is not uesed one
		out_spike <= out_sig;
	end process;
	
end Behavioral;
