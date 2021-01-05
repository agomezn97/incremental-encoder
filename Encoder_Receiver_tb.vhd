----------------------------------------------------------------------------------
-- File: Encoder_Receiver_tb
-- Created by rtlogik
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Encoder_Receiver_tb is

end Encoder_Receiver_tb;

architecture SIM of Encoder_Receiver_tb is

    constant c_CLOCK_PERIOD: Time := 10 ns;
    constant c_VALUE_WIDTH: Integer := 2;

    component Encoder_Receiver is
        port (
            i_Clk : in  Std_Logic;          -- Clock signal
            i_A   : in  Std_Logic;          -- Encoder signal a
            i_B   : in  Std_Logic;          -- Encoder signal b
            i_Btn : in  Std_Logic;          -- Encoder button
            --
            o_Cw  : out Std_Logic;          -- Pulse when clock-wise rotation
            o_Ccw : out Std_Logic;          -- Pulse when counter clock-wise rotation
            o_Btn : out Std_Logic           -- Button state (with switch debounce)                                                          
        );
    end component;
    
    component Encoder_Incr2Abs is
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
    end component;

    signal r_SysClk: Std_Logic := '0';
    signal w_BtnInput: Std_Logic; 
    signal w_BtnOutput: Std_Logic; 
    signal w_A, w_B, w_Cw, w_Ccw: Std_Logic;
    signal w_ValueOut: Std_Logic_Vector(c_VALUE_WIDTH-1 downto 0);

begin

    uut: Encoder_Receiver 
        port map (
            i_Clk => r_SysClk,
            i_Btn => w_BtnInput,
            i_A   => w_A,
            i_B   => w_B,
            o_Cw  => w_Cw,
            o_Ccw => w_Ccw,
            o_Btn => w_BtnOutput
        );
     
     uut2 : Encoder_Incr2Abs
        generic map (
            g_COUNT_BITS   => c_VALUE_WIDTH,
            g_COUNT_MAX    => 4,
            g_COUNT_MIN    => 0,
            g_COUNT_INCR   => 1,
            g_COUNT_ORIGIN => 0
        )
        port map (
            i_Clk   => r_SysClk,
            i_Cw    => w_Cw, 
            i_Ccw   => w_Ccw,
            i_Btn   => w_BtnOutput,
            o_Value => w_ValueOut
        );    
        

    r_SysClk <= not r_SysClk after c_CLOCK_PERIOD/2;

    -- Stimulus:
    STIM: process
    begin
        w_A <= '1';
        w_B <= '1';
        w_BtnInput <= '0';
        wait for c_CLOCK_PERIOD;
        w_BtnInput <= '1';
        wait for 15*c_CLOCK_PERIOD;
        w_BtnInput <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_BtnInput <= '1';
        wait for 3*c_CLOCK_PERIOD;
        w_BtnInput <= '0';
        wait for 20*c_CLOCK_PERIOD;
        w_A <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_B <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_A <= '1';
        wait for 5*c_CLOCK_PERIOD;
        w_B <= '1';
        wait for 20*c_CLOCK_PERIOD;
        w_A <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_B <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_A <= '1';
        wait for 5*c_CLOCK_PERIOD;
        w_B <= '1';
        wait for 20*c_CLOCK_PERIOD;
        w_A <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_B <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_A <= '1';
        wait for 5*c_CLOCK_PERIOD;
        w_B <= '1';
        wait for 20*c_CLOCK_PERIOD;
        w_B <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_A <= '0';
        wait for 5*c_CLOCK_PERIOD;
        w_B <= '1';
        wait for 5*c_CLOCK_PERIOD;
        w_A <= '1';
        wait for 20*c_CLOCK_PERIOD;
        w_BtnInput <= '1';
        wait for 15*c_CLOCK_PERIOD;
        w_BtnInput <= '0';
        wait for 5*c_CLOCK_PERIOD;
    end process;

end SIM;
