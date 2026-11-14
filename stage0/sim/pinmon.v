`timescale 1ns/1ps
// Pin activity without a waveform: every pin sampled every 10 ns; per pin
// the toggle count and the first and last toggle times, printed by
// tb.pinmon.report. Sampling (not @(pin)) keeps Verilator happy with
// tri-state nets.
module pinmon;
    reg tick = 0;
    always #5 tick = !tick;
    reg v3; integer n3 = 0; time f3 = 0, l3 = 0;
    reg v4; integer n4 = 0; time f4 = 0, l4 = 0;
    reg v5; integer n5 = 0; time f5 = 0, l5 = 0;
    reg v6; integer n6 = 0; time f6 = 0, l6 = 0;
    reg v7; integer n7 = 0; time f7 = 0, l7 = 0;
    reg v9; integer n9 = 0; time f9 = 0, l9 = 0;
    reg v10; integer n10 = 0; time f10 = 0, l10 = 0;
    reg v12; integer n12 = 0; time f12 = 0, l12 = 0;
    reg v13; integer n13 = 0; time f13 = 0, l13 = 0;
    reg v15; integer n15 = 0; time f15 = 0, l15 = 0;
    reg v16; integer n16 = 0; time f16 = 0, l16 = 0;
    reg v19; integer n19 = 0; time f19 = 0, l19 = 0;
    reg v20; integer n20 = 0; time f20 = 0, l20 = 0;
    reg v21; integer n21 = 0; time f21 = 0, l21 = 0;
    reg v23; integer n23 = 0; time f23 = 0, l23 = 0;
    reg v24; integer n24 = 0; time f24 = 0, l24 = 0;
    reg v25; integer n25 = 0; time f25 = 0, l25 = 0;
    reg v27; integer n27 = 0; time f27 = 0, l27 = 0;
    reg v28; integer n28 = 0; time f28 = 0, l28 = 0;
    reg v29; integer n29 = 0; time f29 = 0, l29 = 0;
    reg v30; integer n30 = 0; time f30 = 0, l30 = 0;
    reg v31; integer n31 = 0; time f31 = 0, l31 = 0;
    reg v32; integer n32 = 0; time f32 = 0, l32 = 0;
    reg v33; integer n33 = 0; time f33 = 0, l33 = 0;
    reg v34; integer n34 = 0; time f34 = 0, l34 = 0;
    reg v35; integer n35 = 0; time f35 = 0, l35 = 0;
    reg v36; integer n36 = 0; time f36 = 0, l36 = 0;
    reg v37; integer n37 = 0; time f37 = 0, l37 = 0;
    reg v39; integer n39 = 0; time f39 = 0, l39 = 0;
    reg v40; integer n40 = 0; time f40 = 0, l40 = 0;
    reg v41; integer n41 = 0; time f41 = 0, l41 = 0;
    reg v43; integer n43 = 0; time f43 = 0, l43 = 0;
    reg v44; integer n44 = 0; time f44 = 0, l44 = 0;
    reg v46; integer n46 = 0; time f46 = 0, l46 = 0;
    reg v48; integer n48 = 0; time f48 = 0, l48 = 0;
    reg v49; integer n49 = 0; time f49 = 0, l49 = 0;
    reg v50; integer n50 = 0; time f50 = 0, l50 = 0;
    reg v51; integer n51 = 0; time f51 = 0, l51 = 0;
    reg v52; integer n52 = 0; time f52 = 0, l52 = 0;
    reg v53; integer n53 = 0; time f53 = 0, l53 = 0;
    reg v56; integer n56 = 0; time f56 = 0, l56 = 0;
    reg v57; integer n57 = 0; time f57 = 0, l57 = 0;
    reg v59; integer n59 = 0; time f59 = 0, l59 = 0;
    reg v60; integer n60 = 0; time f60 = 0, l60 = 0;
    reg v61; integer n61 = 0; time f61 = 0, l61 = 0;
    reg v62; integer n62 = 0; time f62 = 0, l62 = 0;
    reg v64; integer n64 = 0; time f64 = 0, l64 = 0;
    reg v65; integer n65 = 0; time f65 = 0, l65 = 0;
    reg v68; integer n68 = 0; time f68 = 0, l68 = 0;
    reg v70; integer n70 = 0; time f70 = 0, l70 = 0;
    reg v71; integer n71 = 0; time f71 = 0, l71 = 0;
    reg v72; integer n72 = 0; time f72 = 0, l72 = 0;
    reg v73; integer n73 = 0; time f73 = 0, l73 = 0;
    reg v77; integer n77 = 0; time f77 = 0, l77 = 0;
    reg v78; integer n78 = 0; time f78 = 0, l78 = 0;
    reg v82; integer n82 = 0; time f82 = 0, l82 = 0;
    reg v83; integer n83 = 0; time f83 = 0, l83 = 0;
    reg v84; integer n84 = 0; time f84 = 0, l84 = 0;
    reg v85; integer n85 = 0; time f85 = 0, l85 = 0;
    reg v86; integer n86 = 0; time f86 = 0, l86 = 0;
    reg v88; integer n88 = 0; time f88 = 0, l88 = 0;
    reg v89; integer n89 = 0; time f89 = 0, l89 = 0;
    reg v90; integer n90 = 0; time f90 = 0, l90 = 0;
    reg v93; integer n93 = 0; time f93 = 0, l93 = 0;
    reg v94; integer n94 = 0; time f94 = 0, l94 = 0;
    reg v97; integer n97 = 0; time f97 = 0, l97 = 0;
    reg v98; integer n98 = 0; time f98 = 0, l98 = 0;
    reg v99; integer n99 = 0; time f99 = 0, l99 = 0;
    always @(posedge tick) begin
        if (tb.P3 !== v3) begin if (n3 == 0) f3 = $time; l3 = $time; n3 = n3 + 1; v3 = tb.P3; end
        if (tb.P4 !== v4) begin if (n4 == 0) f4 = $time; l4 = $time; n4 = n4 + 1; v4 = tb.P4; end
        if (tb.P5 !== v5) begin if (n5 == 0) f5 = $time; l5 = $time; n5 = n5 + 1; v5 = tb.P5; end
        if (tb.P6 !== v6) begin if (n6 == 0) f6 = $time; l6 = $time; n6 = n6 + 1; v6 = tb.P6; end
        if (tb.P7 !== v7) begin if (n7 == 0) f7 = $time; l7 = $time; n7 = n7 + 1; v7 = tb.P7; end
        if (tb.P9 !== v9) begin if (n9 == 0) f9 = $time; l9 = $time; n9 = n9 + 1; v9 = tb.P9; end
        if (tb.P10 !== v10) begin if (n10 == 0) f10 = $time; l10 = $time; n10 = n10 + 1; v10 = tb.P10; end
        if (tb.P12 !== v12) begin if (n12 == 0) f12 = $time; l12 = $time; n12 = n12 + 1; v12 = tb.P12; end
        if (tb.P13 !== v13) begin if (n13 == 0) f13 = $time; l13 = $time; n13 = n13 + 1; v13 = tb.P13; end
        if (tb.P15 !== v15) begin if (n15 == 0) f15 = $time; l15 = $time; n15 = n15 + 1; v15 = tb.P15; end
        if (tb.P16 !== v16) begin if (n16 == 0) f16 = $time; l16 = $time; n16 = n16 + 1; v16 = tb.P16; end
        if (tb.P19 !== v19) begin if (n19 == 0) f19 = $time; l19 = $time; n19 = n19 + 1; v19 = tb.P19; end
        if (tb.P20 !== v20) begin if (n20 == 0) f20 = $time; l20 = $time; n20 = n20 + 1; v20 = tb.P20; end
        if (tb.P21 !== v21) begin if (n21 == 0) f21 = $time; l21 = $time; n21 = n21 + 1; v21 = tb.P21; end
        if (tb.P23 !== v23) begin if (n23 == 0) f23 = $time; l23 = $time; n23 = n23 + 1; v23 = tb.P23; end
        if (tb.P24 !== v24) begin if (n24 == 0) f24 = $time; l24 = $time; n24 = n24 + 1; v24 = tb.P24; end
        if (tb.P25 !== v25) begin if (n25 == 0) f25 = $time; l25 = $time; n25 = n25 + 1; v25 = tb.P25; end
        if (tb.P27 !== v27) begin if (n27 == 0) f27 = $time; l27 = $time; n27 = n27 + 1; v27 = tb.P27; end
        if (tb.P28 !== v28) begin if (n28 == 0) f28 = $time; l28 = $time; n28 = n28 + 1; v28 = tb.P28; end
        if (tb.P29 !== v29) begin if (n29 == 0) f29 = $time; l29 = $time; n29 = n29 + 1; v29 = tb.P29; end
        if (tb.P30 !== v30) begin if (n30 == 0) f30 = $time; l30 = $time; n30 = n30 + 1; v30 = tb.P30; end
        if (tb.P31 !== v31) begin if (n31 == 0) f31 = $time; l31 = $time; n31 = n31 + 1; v31 = tb.P31; end
        if (tb.P32 !== v32) begin if (n32 == 0) f32 = $time; l32 = $time; n32 = n32 + 1; v32 = tb.P32; end
        if (tb.P33 !== v33) begin if (n33 == 0) f33 = $time; l33 = $time; n33 = n33 + 1; v33 = tb.P33; end
        if (tb.P34 !== v34) begin if (n34 == 0) f34 = $time; l34 = $time; n34 = n34 + 1; v34 = tb.P34; end
        if (tb.P35 !== v35) begin if (n35 == 0) f35 = $time; l35 = $time; n35 = n35 + 1; v35 = tb.P35; end
        if (tb.P36 !== v36) begin if (n36 == 0) f36 = $time; l36 = $time; n36 = n36 + 1; v36 = tb.P36; end
        if (tb.P37 !== v37) begin if (n37 == 0) f37 = $time; l37 = $time; n37 = n37 + 1; v37 = tb.P37; end
        if (tb.P39 !== v39) begin if (n39 == 0) f39 = $time; l39 = $time; n39 = n39 + 1; v39 = tb.P39; end
        if (tb.P40 !== v40) begin if (n40 == 0) f40 = $time; l40 = $time; n40 = n40 + 1; v40 = tb.P40; end
        if (tb.P41 !== v41) begin if (n41 == 0) f41 = $time; l41 = $time; n41 = n41 + 1; v41 = tb.P41; end
        if (tb.P43 !== v43) begin if (n43 == 0) f43 = $time; l43 = $time; n43 = n43 + 1; v43 = tb.P43; end
        if (tb.P44 !== v44) begin if (n44 == 0) f44 = $time; l44 = $time; n44 = n44 + 1; v44 = tb.P44; end
        if (tb.P46 !== v46) begin if (n46 == 0) f46 = $time; l46 = $time; n46 = n46 + 1; v46 = tb.P46; end
        if (tb.P48 !== v48) begin if (n48 == 0) f48 = $time; l48 = $time; n48 = n48 + 1; v48 = tb.P48; end
        if (tb.P49 !== v49) begin if (n49 == 0) f49 = $time; l49 = $time; n49 = n49 + 1; v49 = tb.P49; end
        if (tb.P50 !== v50) begin if (n50 == 0) f50 = $time; l50 = $time; n50 = n50 + 1; v50 = tb.P50; end
        if (tb.P51 !== v51) begin if (n51 == 0) f51 = $time; l51 = $time; n51 = n51 + 1; v51 = tb.P51; end
        if (tb.P52 !== v52) begin if (n52 == 0) f52 = $time; l52 = $time; n52 = n52 + 1; v52 = tb.P52; end
        if (tb.P53 !== v53) begin if (n53 == 0) f53 = $time; l53 = $time; n53 = n53 + 1; v53 = tb.P53; end
        if (tb.P56 !== v56) begin if (n56 == 0) f56 = $time; l56 = $time; n56 = n56 + 1; v56 = tb.P56; end
        if (tb.P57 !== v57) begin if (n57 == 0) f57 = $time; l57 = $time; n57 = n57 + 1; v57 = tb.P57; end
        if (tb.P59 !== v59) begin if (n59 == 0) f59 = $time; l59 = $time; n59 = n59 + 1; v59 = tb.P59; end
        if (tb.P60 !== v60) begin if (n60 == 0) f60 = $time; l60 = $time; n60 = n60 + 1; v60 = tb.P60; end
        if (tb.P61 !== v61) begin if (n61 == 0) f61 = $time; l61 = $time; n61 = n61 + 1; v61 = tb.P61; end
        if (tb.P62 !== v62) begin if (n62 == 0) f62 = $time; l62 = $time; n62 = n62 + 1; v62 = tb.P62; end
        if (tb.P64 !== v64) begin if (n64 == 0) f64 = $time; l64 = $time; n64 = n64 + 1; v64 = tb.P64; end
        if (tb.P65 !== v65) begin if (n65 == 0) f65 = $time; l65 = $time; n65 = n65 + 1; v65 = tb.P65; end
        if (tb.P68 !== v68) begin if (n68 == 0) f68 = $time; l68 = $time; n68 = n68 + 1; v68 = tb.P68; end
        if (tb.P70 !== v70) begin if (n70 == 0) f70 = $time; l70 = $time; n70 = n70 + 1; v70 = tb.P70; end
        if (tb.P71 !== v71) begin if (n71 == 0) f71 = $time; l71 = $time; n71 = n71 + 1; v71 = tb.P71; end
        if (tb.P72 !== v72) begin if (n72 == 0) f72 = $time; l72 = $time; n72 = n72 + 1; v72 = tb.P72; end
        if (tb.P73 !== v73) begin if (n73 == 0) f73 = $time; l73 = $time; n73 = n73 + 1; v73 = tb.P73; end
        if (tb.P77 !== v77) begin if (n77 == 0) f77 = $time; l77 = $time; n77 = n77 + 1; v77 = tb.P77; end
        if (tb.P78 !== v78) begin if (n78 == 0) f78 = $time; l78 = $time; n78 = n78 + 1; v78 = tb.P78; end
        if (tb.P82 !== v82) begin if (n82 == 0) f82 = $time; l82 = $time; n82 = n82 + 1; v82 = tb.P82; end
        if (tb.P83 !== v83) begin if (n83 == 0) f83 = $time; l83 = $time; n83 = n83 + 1; v83 = tb.P83; end
        if (tb.P84 !== v84) begin if (n84 == 0) f84 = $time; l84 = $time; n84 = n84 + 1; v84 = tb.P84; end
        if (tb.P85 !== v85) begin if (n85 == 0) f85 = $time; l85 = $time; n85 = n85 + 1; v85 = tb.P85; end
        if (tb.P86 !== v86) begin if (n86 == 0) f86 = $time; l86 = $time; n86 = n86 + 1; v86 = tb.P86; end
        if (tb.P88 !== v88) begin if (n88 == 0) f88 = $time; l88 = $time; n88 = n88 + 1; v88 = tb.P88; end
        if (tb.P89 !== v89) begin if (n89 == 0) f89 = $time; l89 = $time; n89 = n89 + 1; v89 = tb.P89; end
        if (tb.P90 !== v90) begin if (n90 == 0) f90 = $time; l90 = $time; n90 = n90 + 1; v90 = tb.P90; end
        if (tb.P93 !== v93) begin if (n93 == 0) f93 = $time; l93 = $time; n93 = n93 + 1; v93 = tb.P93; end
        if (tb.P94 !== v94) begin if (n94 == 0) f94 = $time; l94 = $time; n94 = n94 + 1; v94 = tb.P94; end
        if (tb.P97 !== v97) begin if (n97 == 0) f97 = $time; l97 = $time; n97 = n97 + 1; v97 = tb.P97; end
        if (tb.P98 !== v98) begin if (n98 == 0) f98 = $time; l98 = $time; n98 = n98 + 1; v98 = tb.P98; end
        if (tb.P99 !== v99) begin if (n99 == 0) f99 = $time; l99 = $time; n99 = n99 + 1; v99 = tb.P99; end
    end
    task report;
    begin
        if (n3 > 2) $display("pin P3: %0d toggles, first %0t ns, last %0t ns", n3 - 1, f3, l3);
        if (n4 > 2) $display("pin P4: %0d toggles, first %0t ns, last %0t ns", n4 - 1, f4, l4);
        if (n5 > 2) $display("pin P5: %0d toggles, first %0t ns, last %0t ns", n5 - 1, f5, l5);
        if (n6 > 2) $display("pin P6: %0d toggles, first %0t ns, last %0t ns", n6 - 1, f6, l6);
        if (n7 > 2) $display("pin P7: %0d toggles, first %0t ns, last %0t ns", n7 - 1, f7, l7);
        if (n9 > 2) $display("pin P9: %0d toggles, first %0t ns, last %0t ns", n9 - 1, f9, l9);
        if (n10 > 2) $display("pin P10: %0d toggles, first %0t ns, last %0t ns", n10 - 1, f10, l10);
        if (n12 > 2) $display("pin P12: %0d toggles, first %0t ns, last %0t ns", n12 - 1, f12, l12);
        if (n13 > 2) $display("pin P13: %0d toggles, first %0t ns, last %0t ns", n13 - 1, f13, l13);
        if (n15 > 2) $display("pin P15: %0d toggles, first %0t ns, last %0t ns", n15 - 1, f15, l15);
        if (n16 > 2) $display("pin P16: %0d toggles, first %0t ns, last %0t ns", n16 - 1, f16, l16);
        if (n19 > 2) $display("pin P19: %0d toggles, first %0t ns, last %0t ns", n19 - 1, f19, l19);
        if (n20 > 2) $display("pin P20: %0d toggles, first %0t ns, last %0t ns", n20 - 1, f20, l20);
        if (n21 > 2) $display("pin P21: %0d toggles, first %0t ns, last %0t ns", n21 - 1, f21, l21);
        if (n23 > 2) $display("pin P23: %0d toggles, first %0t ns, last %0t ns", n23 - 1, f23, l23);
        if (n24 > 2) $display("pin P24: %0d toggles, first %0t ns, last %0t ns", n24 - 1, f24, l24);
        if (n25 > 2) $display("pin P25: %0d toggles, first %0t ns, last %0t ns", n25 - 1, f25, l25);
        if (n27 > 2) $display("pin P27: %0d toggles, first %0t ns, last %0t ns", n27 - 1, f27, l27);
        if (n28 > 2) $display("pin P28: %0d toggles, first %0t ns, last %0t ns", n28 - 1, f28, l28);
        if (n29 > 2) $display("pin P29: %0d toggles, first %0t ns, last %0t ns", n29 - 1, f29, l29);
        if (n30 > 2) $display("pin P30: %0d toggles, first %0t ns, last %0t ns", n30 - 1, f30, l30);
        if (n31 > 2) $display("pin P31: %0d toggles, first %0t ns, last %0t ns", n31 - 1, f31, l31);
        if (n32 > 2) $display("pin P32: %0d toggles, first %0t ns, last %0t ns", n32 - 1, f32, l32);
        if (n33 > 2) $display("pin P33: %0d toggles, first %0t ns, last %0t ns", n33 - 1, f33, l33);
        if (n34 > 2) $display("pin P34: %0d toggles, first %0t ns, last %0t ns", n34 - 1, f34, l34);
        if (n35 > 2) $display("pin P35: %0d toggles, first %0t ns, last %0t ns", n35 - 1, f35, l35);
        if (n36 > 2) $display("pin P36: %0d toggles, first %0t ns, last %0t ns", n36 - 1, f36, l36);
        if (n37 > 2) $display("pin P37: %0d toggles, first %0t ns, last %0t ns", n37 - 1, f37, l37);
        if (n39 > 2) $display("pin P39: %0d toggles, first %0t ns, last %0t ns", n39 - 1, f39, l39);
        if (n40 > 2) $display("pin P40: %0d toggles, first %0t ns, last %0t ns", n40 - 1, f40, l40);
        if (n41 > 2) $display("pin P41: %0d toggles, first %0t ns, last %0t ns", n41 - 1, f41, l41);
        if (n43 > 2) $display("pin P43: %0d toggles, first %0t ns, last %0t ns", n43 - 1, f43, l43);
        if (n44 > 2) $display("pin P44: %0d toggles, first %0t ns, last %0t ns", n44 - 1, f44, l44);
        if (n46 > 2) $display("pin P46: %0d toggles, first %0t ns, last %0t ns", n46 - 1, f46, l46);
        if (n48 > 2) $display("pin P48: %0d toggles, first %0t ns, last %0t ns", n48 - 1, f48, l48);
        if (n49 > 2) $display("pin P49: %0d toggles, first %0t ns, last %0t ns", n49 - 1, f49, l49);
        if (n50 > 2) $display("pin P50: %0d toggles, first %0t ns, last %0t ns", n50 - 1, f50, l50);
        if (n51 > 2) $display("pin P51: %0d toggles, first %0t ns, last %0t ns", n51 - 1, f51, l51);
        if (n52 > 2) $display("pin P52: %0d toggles, first %0t ns, last %0t ns", n52 - 1, f52, l52);
        if (n53 > 2) $display("pin P53: %0d toggles, first %0t ns, last %0t ns", n53 - 1, f53, l53);
        if (n56 > 2) $display("pin P56: %0d toggles, first %0t ns, last %0t ns", n56 - 1, f56, l56);
        if (n57 > 2) $display("pin P57: %0d toggles, first %0t ns, last %0t ns", n57 - 1, f57, l57);
        if (n59 > 2) $display("pin P59: %0d toggles, first %0t ns, last %0t ns", n59 - 1, f59, l59);
        if (n60 > 2) $display("pin P60: %0d toggles, first %0t ns, last %0t ns", n60 - 1, f60, l60);
        if (n61 > 2) $display("pin P61: %0d toggles, first %0t ns, last %0t ns", n61 - 1, f61, l61);
        if (n62 > 2) $display("pin P62: %0d toggles, first %0t ns, last %0t ns", n62 - 1, f62, l62);
        if (n64 > 2) $display("pin P64: %0d toggles, first %0t ns, last %0t ns", n64 - 1, f64, l64);
        if (n65 > 2) $display("pin P65: %0d toggles, first %0t ns, last %0t ns", n65 - 1, f65, l65);
        if (n68 > 2) $display("pin P68: %0d toggles, first %0t ns, last %0t ns", n68 - 1, f68, l68);
        if (n70 > 2) $display("pin P70: %0d toggles, first %0t ns, last %0t ns", n70 - 1, f70, l70);
        if (n71 > 2) $display("pin P71: %0d toggles, first %0t ns, last %0t ns", n71 - 1, f71, l71);
        if (n72 > 2) $display("pin P72: %0d toggles, first %0t ns, last %0t ns", n72 - 1, f72, l72);
        if (n73 > 2) $display("pin P73: %0d toggles, first %0t ns, last %0t ns", n73 - 1, f73, l73);
        if (n77 > 2) $display("pin P77: %0d toggles, first %0t ns, last %0t ns", n77 - 1, f77, l77);
        if (n78 > 2) $display("pin P78: %0d toggles, first %0t ns, last %0t ns", n78 - 1, f78, l78);
        if (n82 > 2) $display("pin P82: %0d toggles, first %0t ns, last %0t ns", n82 - 1, f82, l82);
        if (n83 > 2) $display("pin P83: %0d toggles, first %0t ns, last %0t ns", n83 - 1, f83, l83);
        if (n84 > 2) $display("pin P84: %0d toggles, first %0t ns, last %0t ns", n84 - 1, f84, l84);
        if (n85 > 2) $display("pin P85: %0d toggles, first %0t ns, last %0t ns", n85 - 1, f85, l85);
        if (n86 > 2) $display("pin P86: %0d toggles, first %0t ns, last %0t ns", n86 - 1, f86, l86);
        if (n88 > 2) $display("pin P88: %0d toggles, first %0t ns, last %0t ns", n88 - 1, f88, l88);
        if (n89 > 2) $display("pin P89: %0d toggles, first %0t ns, last %0t ns", n89 - 1, f89, l89);
        if (n90 > 2) $display("pin P90: %0d toggles, first %0t ns, last %0t ns", n90 - 1, f90, l90);
        if (n93 > 2) $display("pin P93: %0d toggles, first %0t ns, last %0t ns", n93 - 1, f93, l93);
        if (n94 > 2) $display("pin P94: %0d toggles, first %0t ns, last %0t ns", n94 - 1, f94, l94);
        if (n97 > 2) $display("pin P97: %0d toggles, first %0t ns, last %0t ns", n97 - 1, f97, l97);
        if (n98 > 2) $display("pin P98: %0d toggles, first %0t ns, last %0t ns", n98 - 1, f98, l98);
        if (n99 > 2) $display("pin P99: %0d toggles, first %0t ns, last %0t ns", n99 - 1, f99, l99);
    end
    endtask
endmodule
