`timescale 1ns/1ps

module tb_traffic_light;
    reg clk, reset, MAINT;
    wire Ga, Ya, Ra, Gb, Yb, Rb, Gw, Rw;

    // Simulation parameters (faster for testing)
    parameter SIM_CLK_FREQ = 1_000_000;  // 1 MHz
    parameter SIM_TICK_HZ  = 1000;       // 1 kHz tick

    traffic_light #(
        .CLK_FREQ_HZ(SIM_CLK_FREQ),
        .TICK_HZ(SIM_TICK_HZ),
        .A_GREEN_T(3),
        .A_YELLOW_T(2),
        .B_GREEN_T(3),
        .B_YELLOW_T(1),
        .W_GREEN_T(2),
        .W_RFLASH_T(2),
        .W_RSOLID_T(5)
    ) dut (
        .clk(clk), .reset(reset), .MAINT(MAINT),
        .Ga(Ga), .Ya(Ya), .Ra(Ra),
        .Gb(Gb), .Yb(Yb), .Rb(Rb),
        .Gw(Gw), .Rw(Rw)
    );

    // Clock generation
    initial clk = 0;
    always #0.5 clk = ~clk;  // 1 MHz -> 1 us period

    initial begin
        $dumpfile("tb_traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        // Init
        reset = 1; MAINT = 0;
        #5 reset = 0;

        // Normal sequence
        #5000;

        // Maintenance mode
        MAINT = 1;
        #2000;
        MAINT = 0;

        // Back to normal
        #5000;

        $finish;
    end

    initial begin
        $monitor("t=%0t | Ga=%b Ya=%b Ra=%b | Gb=%b Yb=%b Rb=%b | Gw=%b Rw=%b | MAINT=%b",
                  $time, Ga,Ya,Ra, Gb,Yb,Rb, Gw,Rw, MAINT);
    end
endmodule
