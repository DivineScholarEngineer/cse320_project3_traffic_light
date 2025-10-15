// Problem 1: Package Sorter
// Design: Combinational currentGrp + sequential counters on negedge clk with async active-high reset.
module package_sorter(
    input  wire        clk,
    input  wire        reset,            // async active-high
    input  wire [11:0] weight,           // grams, 12-bit unsigned
    output reg  [2:0]  currentGrp,       // 0 when weight==0, else 1..6 per ranges
    output reg  [7:0]  Grp1,
    output reg  [7:0]  Grp2,
    output reg  [7:0]  Grp3,
    output reg  [7:0]  Grp4,
    output reg  [7:0]  Grp5,
    output reg  [7:0]  Grp6
);
    reg prev_zero;  // tracks zero gap to detect new item

    // Combinational classification
    always @(*) begin
        if (weight == 12'd0)                   currentGrp = 3'd0;
        else if (weight <= 12'd250)            currentGrp = 3'd1;
        else if (weight <= 12'd500)            currentGrp = 3'd2;
        else if (weight <= 12'd750)            currentGrp = 3'd3;
        else if (weight <= 12'd1500)           currentGrp = 3'd4;
        else if (weight <= 12'd2000)           currentGrp = 3'd5;
        else                                   currentGrp = 3'd6;
    end

    // Sequential: update counts only on falling edge, and only once per object after a zero gap
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            Grp1 <= 8'd0; Grp2 <= 8'd0; Grp3 <= 8'd0;
            Grp4 <= 8'd0; Grp5 <= 8'd0; Grp6 <= 8'd0;
            prev_zero <= 1'b1; // ready for a new object
        end else begin
            if (prev_zero && weight != 12'd0) begin
                case (currentGrp)
                    3'd1: Grp1 <= Grp1 + 1'b1;
                    3'd2: Grp2 <= Grp2 + 1'b1;
                    3'd3: Grp3 <= Grp3 + 1'b1;
                    3'd4: Grp4 <= Grp4 + 1'b1;
                    3'd5: Grp5 <= Grp5 + 1'b1;
                    3'd6: Grp6 <= Grp6 + 1'b1;
                    default: ; // 0 => do nothing
                endcase
            end
            prev_zero <= (weight == 12'd0);
        end
    end
endmodule
