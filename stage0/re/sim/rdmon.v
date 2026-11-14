`timescale 1ns/1ps
// Log each pSRAM access (U9 /CE low) while the GB reads $4000-$7FFF in game
// mode: when it happens relative to the bus clock, the pSRAM address and
// lane, and the data the model returns.
module rdmon;
    reg pce = 1; integer n = 0; realtime tphi = 0;
    always @(posedge tb.phi) tphi = $realtime;
    always #1 begin
        if (tb.P52 === 1'b0 && pce !== 1'b0 && tb.gb_a[15:14] == 2'b01 && n < 60 && $time > 64'd57500000) begin
            n = n + 1;
            #3 $display("%t acc gbA=%h +%0.0fns after phi rise  memA=%h lb/ub=%b%b we=%b 595=%h P51=%b q=%h", $time, tb.gb_a,
                        $realtime - tphi, tb.mem_a, tb.P37, tb.P36, tb.P40, tb.bank, tb.P51, tb.mem_q);
        end
        pce = tb.P52;
    end
endmodule
