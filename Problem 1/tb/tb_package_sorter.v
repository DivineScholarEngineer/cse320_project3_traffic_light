`timescale 1ns/1ps
module tb_package_sorter;
    reg clk, reset;
    reg [11:0] weight;
    wire [2:0] currentGrp;
    wire [7:0] Grp1, Grp2, Grp3, Grp4, Grp5, Grp6;

    package_sorter dut(
        .clk(clk), .reset(reset), .weight(weight),
        .currentGrp(currentGrp),
        .Grp1(Grp1), .Grp2(Grp2), .Grp3(Grp3),
        .Grp4(Grp4), .Grp5(Grp5), .Grp6(Grp6)
    );

    // 10ns period clock
    initial clk = 0;
    always #5 clk = ~clk;

    // helper task to hold a weight for N cycles (>=3 cycles recommended)
    task apply_weight(input [11:0] w, input integer cycles);
        integer c;
        begin
            weight = w;
            for (c = 0; c < cycles; c = c + 1) @(negedge clk);
        end
    endtask

    initial begin
        // VCD
        $dumpfile("tb_package_sorter.vcd");
        $dumpvars(0, tb_package_sorter);

        // init
        reset = 1; weight = 0; @(negedge clk);
        reset = 0; @(negedge clk);

        // Example from lab:
        // Reset -> 270 -> 0 -> 300 -> 0 -> 501 -> 1013
        apply_weight(12'd270, 3); // Grp2 new
        apply_weight(12'd0,   2); // zero gap
        apply_weight(12'd300, 3); // Grp2 new
        apply_weight(12'd0,   2); // zero gap
        apply_weight(12'd501, 3); // Grp3 new
        apply_weight(12'd1013,3); // same object, only updates currentGrp (Grp4 NOT incremented)

        // Additional edge cases
        apply_weight(12'd0,   2);
        apply_weight(12'd1,   3);  // lower bound Grp1
        apply_weight(12'd0,   2);
        apply_weight(12'd250, 3);  // upper bound Grp1
        apply_weight(12'd0,   2);
        apply_weight(12'd2001,3);  // Grp6

        // Done
        #50;
        $display("Final counts: G1=%0d G2=%0d G3=%0d G4=%0d G5=%0d G6=%0d curr=%0d",
                 Grp1,Grp2,Grp3,Grp4,Grp5,Grp6,currentGrp);
        $finish;
    end
endmodule
