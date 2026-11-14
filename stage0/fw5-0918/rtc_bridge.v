// FW5-0918's RTC bridge: the FW4 module (stage0/fw4/rtl/rtc_bridge.v, which says
// what the two directions are) on the PicoBlaze's clock instead of the 2x
// clock, read from the design and proved:
//
//   - the readings (port ED index, port EE value) load on the PicoBlaze
//     clock's falling edge and keep only the bits each BCD value uses:
//     seconds and minutes 7, hours and day 6, weekday 3, month 5, year 8
//   - the set values' mux (port F0 index, port B6) runs on its rising edge
//
// Block: built by stage0/tools/simblk.py from stage0/fw4/blocks/rtc_bridge.blk
// (stage0/fw5-0918/rtc_bridge.sim has its arguments), with the names in
// rtc_bridge.names.

module rtc_bridge (
    input clk_pb,
    input write_strobe,             // the core's, every OUTPUT
    input [3:0] rtc_reg_index,      // port ED
    input [7:0] rtc_reg_value,      // port EE
    input [3:0] rtc_set_index,      // port F0
    input [7:0] rtc_set_sec, rtc_set_min, rtc_set_hour, rtc_set_day, rtc_set_wday, rtc_set_month, rtc_set_year,
    output reg [6:0] rtc_sec, rtc_min,
    output reg [5:0] rtc_hour, rtc_day,
    output reg [2:0] rtc_wday,
    output reg [4:0] rtc_month,
    output reg [7:0] rtc_year,
    output reg [7:0] rtc_set_data_i // port B6
);
    initial begin
        rtc_sec = 7'd0; rtc_min = 7'd0; rtc_hour = 6'd0; rtc_day = 6'd0;
        rtc_wday = 3'd0; rtc_month = 5'd0; rtc_year = 8'd0; rtc_set_data_i = 8'd0;
    end

    // ---- the readings
    always @(negedge clk_pb)
        if (write_strobe)
            case (rtc_reg_index)
                4'd2: rtc_sec <= rtc_reg_value[6:0];
                4'd3: rtc_min <= rtc_reg_value[6:0];
                4'd4: rtc_hour <= rtc_reg_value[5:0];
                4'd5: rtc_day <= rtc_reg_value[5:0];
                4'd6: rtc_wday <= rtc_reg_value[2:0];
                4'd7: rtc_month <= rtc_reg_value[4:0];
                4'd8: rtc_year <= rtc_reg_value;
                default: ;
            endcase

    // ---- the set values
    always @(posedge clk_pb)
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
