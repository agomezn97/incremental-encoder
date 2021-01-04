----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.12.2020 18:05:17
-- Design Name: 
-- Module Name: enc_rcvr - Behavioral
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

entity Encoder_Receiver is
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
end Encoder_Receiver;

architecture RTL of Encoder_Receiver is

    constant c_DEBOUNCE_LIMIT : Integer := 1000000;

    type t_EncoderState is (IDLE, WAIT_A, WAIT_B, CW_PULSE, CCW_PULSE, WAIT_FOR_IDLE);

    signal r_EncoderState, w_EncoderState : t_EncoderState := IDLE;

    signal r_BtnState : Std_Logic := '0';
    signal r_Count    : Integer range 0 to c_DEBOUNCE_LIMIT := 0;
    signal r_CountEnc : Integer range 0 to c_DEBOUNCE_LIMIT := 0;

    signal w_BtnState : Std_Logic;
    signal w_Count    : Integer range 0 to c_DEBOUNCE_LIMIT; 
    signal w_CountEnc : Integer range 0 to c_DEBOUNCE_LIMIT; 

begin --======================== ARCHITECTURE ================================--


    ROT_DETECT: process (i_A, i_B, r_EncoderState, r_CountEnc)
    begin
        o_Cw  <= '0';
        o_Ccw <= '0';
        case r_EncoderState is
            when IDLE =>
                if i_A = '0' then
                    w_EncoderState <= WAIT_B;
                elsif i_B = '0' then
                    w_EncoderState <= WAIT_A;
                else
                    w_EncoderState <= IDLE;
                end if;
            
            when WAIT_A =>
                if i_A = '0' then
                    w_EncoderState <= CW_PULSE;
                    -- o_Cw <= '1' 
                    w_CountEnc <= 0;
                elsif (r_CountEnc = c_DEBOUNCE_LIMIT) then
                    w_EncoderState <= IDLE;
                    w_CountEnc <= 0;
                else
                    w_EncoderState <= WAIT_A;
                    w_CountEnc <= r_CountEnc + 1;
                end if;
            
            when WAIT_B =>
                if i_B = '0' then
                    w_EncoderState <= CCW_PULSE;
                    -- o_Ccw <= '1' 
                    w_CountEnc <= 0;
                elsif (r_CountEnc = c_DEBOUNCE_LIMIT) then
                    w_EncoderState <= IDLE;
                    w_CountEnc <= 0;
                else
                    w_EncoderState <= WAIT_B;
                    w_CountEnc <= r_CountEnc + 1;
                end if;    
            
            when CW_PULSE =>
                o_Cw <= '1';
                w_EncoderState <= WAIT_FOR_IDLE;
                    
            when CCW_PULSE =>
                o_Ccw <= '1';
                w_EncoderState <= WAIT_FOR_IDLE;

            when WAIT_FOR_IDLE =>
                if (i_A = '1' and i_B = '1') then
                    w_EncoderState <= IDLE;
                else 
                    w_EncoderState <= WAIT_FOR_IDLE;
                end if;

            when others =>
                w_EncoderState <= IDLE;       
        end case ;

    end process ROT_DETECT;

    BTN_DEBOUNCE: process (i_Btn, r_Count, r_BtnState) 
    begin       
        w_BtnState <= r_BtnState; 
        w_Count <= 0;    
        -- Button input is different than internal button value, so an input is
        -- changing.  Increase counter until it is stable
        if (r_BtnState /= i_Btn and r_Count < c_DEBOUNCE_LIMIT) then       
            w_Count <= r_Count + 1;
        
        -- End of counter reached, switch is stable, reset counter
        elsif (r_Count = c_DEBOUNCE_LIMIT) then
            w_BtnState <= i_Btn;     
        end if;
    end process BTN_DEBOUNCE;

    --- Registers ---
    REGS: process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            r_CountEnc     <= w_CountEnc;
            r_EncoderState <= w_EncoderState;
            r_Count        <= w_Count;
            r_BtnState     <= w_BtnState;
        end if;
    end process REGS;

    o_Btn <= r_BtnState;

end RTL;
