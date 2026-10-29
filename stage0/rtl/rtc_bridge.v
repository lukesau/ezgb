// The RTC bridge, written by EZ Flash, on the 2x clock: the real-time clock's
// values pass between the PicoBlaze, which talks to the PCF8563, and the
// Game Boy, which reads and sets them through the register window, and
// this block holds both directions' copies.
//
//   - the readings: the firmware's idle loop (rtc_dump) copies PCF8563
//     registers 2-8 out as pairs, OUTPUT index to ED, OUTPUT value to EE.
//     Any OUTPUT instruction's strobe while ED holds index k loads the
//     EE register into the copy for k, so a copy takes its value on the
//     OUTPUT after the EE write (the first of the I2C acknowledge's), and
//     the EE write's strobe loads the previous reading into it for a
//     moment. The copies are what the data bus block serves at offsets
//     $08-$0E of the register window
//   - the set values: command $10 (cmd_set_rtc) writes each index 2-8 to
//     F0 and reads the Game Boy's value for it at B6; this block's
//     registered mux over the seven $A008-$A00E registers (gb_regs)
//     follows F0 one 2x cycle later, which the firmware's NOP between
//     the two covers. Indices outside 2-8 hold the last value
//
// The PCF8563's register numbers are the indices: 2 seconds, 3 minutes,
// 4 hours, 5 days, 6 weekdays, 7 months, 8 years.
//
// Block: stage0/blocks/rtc_bridge.blk.

module rtc_bridge (
    input clk_2x,
    input write_strobe,             // the core's, every OUTPUT
    input [3:0] rtc_reg_index,      // port ED
    input [7:0] rtc_reg_value,      // port EE
    input [3:0] rtc_set_index,      // port F0
    input [7:0] rtc_set_sec, rtc_set_min, rtc_set_hour, rtc_set_day, rtc_set_wday, rtc_set_month, rtc_set_year,
    output reg [7:0] rtc_sec, rtc_min, rtc_hour, rtc_day, rtc_wday, rtc_month, rtc_year,
    output reg [7:0] rtc_set_data_i // port B6
);
    initial begin
        rtc_sec = 8'd0; rtc_min = 8'd0; rtc_hour = 8'd0; rtc_day = 8'd0;
        rtc_wday = 8'd0; rtc_month = 8'd0; rtc_year = 8'd0; rtc_set_data_i = 8'd0;
    end

    // ---- the readings
    always @(posedge clk_2x)
        if (write_strobe)
            case (rtc_reg_index)
                4'd2: rtc_sec <= rtc_reg_value;
                4'd3: rtc_min <= rtc_reg_value;
                4'd4: rtc_hour <= rtc_reg_value;
                4'd5: rtc_day <= rtc_reg_value;
                4'd6: rtc_wday <= rtc_reg_value;
                4'd7: rtc_month <= rtc_reg_value;
                4'd8: rtc_year <= rtc_reg_value;
                default: ;
            endcase

    // ---- the set values
    always @(posedge clk_2x)
        case (rtc_set_index)
            4'd2: rtc_set_data_i <= rtc_set_sec;
            4'd3: rtc_set_data_i <= rtc_set_min;
            4'd4: rtc_set_data_i <= rtc_set_hour;
            4'd5: rtc_set_data_i <= rtc_set_day;
            4'd6: rtc_set_data_i <= rtc_set_wday;
            4'd7: rtc_set_data_i <= rtc_set_month;
            4'd8: rtc_set_data_i <= rtc_set_year;
            default: ;
        endcase
endmodule
