----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.12.2020 17:47:12
-- Design Name: 
-- Module Name: Incr2Abs_Encoder - RTL
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Encoder_Incr2Abs is
    generic (
        g_COUNT_BITS   : Integer;                                   -- Width of output value
        g_COUNT_MAX    : Integer;                                   -- Maximum output value (< 2^g_COUNT_BITS)
        g_COUNT_MIN    : Integer;                                   -- Minimum output value
        g_COUNT_INCR   : Integer;                                   -- Increment of output value with every pulse
        g_COUNT_ORIGIN : Integer                                    -- Origin of output value 
    );
    port (
        i_Clk   : in Std_Logic;
        i_Cw    : in Std_Logic;
        i_Ccw   : in Std_Logic;
        i_Btn   : in Std_Logic;
        --
        o_Value : out Std_Logic_Vector(g_COUNT_BITS-1 downto 0)
    );
end Encoder_Incr2Abs;

architecture RTL of Encoder_Incr2Abs is

    signal r_Value : Unsigned(g_COUNT_BITS-1 downto 0) := to_Unsigned(g_COUNT_ORIGIN, g_COUNT_BITS);
    signal w_value : Unsigned(g_COUNT_BITS-1 downto 0);

begin

    COMB: process (i_Cw, i_Ccw, i_Btn)
    begin
        w_Value <=  r_Value;
        if i_Cw = '1' then
            if r_Value < g_COUNT_MAX then
                w_Value <= r_Value + g_COUNT_INCR;
            end if;

        elsif i_Ccw = '1' then
            if r_Value > g_COUNT_MIN then
                w_Value <= r_Value - g_COUNT_INCR;
            end if;

        elsif i_Btn = '1' then
            w_Value <= to_Unsigned(g_COUNT_ORIGIN, g_COUNT_BITS);
        
        end if;
    end process COMB;

    REGS: process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            r_Value <= w_Value;
        end if;
    end process;

    o_Value <= Std_Logic_Vector(r_Value);

end RTL;
