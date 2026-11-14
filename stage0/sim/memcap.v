`timescale 1ns/1ps
// Capture every write strobe on the memory bus (P40 falling) with the raw
// pin state, for working out the address map offline (memmap.py).
// Includes a 74HC595 on SRCLK P35, SER P33, RCLK P24.
module memcap;
    reg [7:0] sr = 0, q = 0;
    reg p35 = 0, p24 = 0, pw = 1;
    integer fd;
    initial fd = $fopen("memcap.txt", "w");
    always #1 begin
        if (tb.P35 === 1'b1 && p35 !== 1'b1) sr = {sr[6:0], tb.P33 === 1'b1};
        if (tb.P24 === 1'b1 && p24 !== 1'b1) q = sr;
        if (tb.P40 === 1'b0 && pw === 1'b1)
            $fwrite(fd, "%0d %b%b%b%b%b%b%b%b%b%b%b%b%b %b%b %b%b %h %b%b%b%b%b%b%b%b\n", $time,
                tb.P46, tb.P53, tb.P20, tb.P86, tb.P83, tb.P50, tb.P44, tb.P73, tb.P70, tb.P71, tb.P65, tb.P59, tb.P56,
                tb.P52, tb.P60, tb.P36, tb.P37, q,
                tb.P64, tb.P57, tb.P41, tb.P49, tb.P48, tb.P77, tb.P72, tb.P78);
        p35 = tb.P35; p24 = tb.P24; pw = tb.P40;
    end
endmodule
