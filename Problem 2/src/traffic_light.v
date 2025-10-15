// Problem 2: Traffic Light Controller (Verilog-2001, no SystemVerilog)

module traffic_light #(
    parameter CLK_FREQ_HZ = 100_000_000, // board clock
    parameter TICK_HZ     = 1,           // tick frequency
    // Durations in ticks (not seconds)
    parameter A_GREEN_T   = 3,
    parameter A_YELLOW_T  = 2,
    parameter B_GREEN_T   = 3,
    parameter B_YELLOW_T  = 1,
    parameter W_GREEN_T   = 2,
    parameter W_RFLASH_T  = 2,
    parameter W_RSOLID_T  = 9
)(
    input  wire clk,
    input  wire reset,   // async active-high
    input  wire MAINT,
    output reg Ga, Ya, Ra,
    output reg Gb, Yb, Rb,
    output reg Gw, Rw
);

    // Tick generator
    localparam DIVISOR = CLK_FREQ_HZ / TICK_HZ;
    reg [31:0] div_cnt = 0;
    reg tick = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_cnt <= 0;
            tick    <= 0;
        end else begin
            if (div_cnt == DIVISOR-1) begin
                div_cnt <= 0;
                tick    <= 1;
            end else begin
                div_cnt <= div_cnt + 1;
                tick    <= 0;
            end
        end
    end

    // Flash generator (approx 1Hz for maintenance, 2Hz for pedestrian flash)
    reg [7:0] flash_cnt = 0;
    reg flash = 0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            flash_cnt <= 0;
            flash <= 0;
        end else if (tick) begin
            flash_cnt <= flash_cnt + 1;
            if (flash_cnt >= 1) begin
                flash <= ~flash;
                flash_cnt <= 0;
            end
        end
    end

    // FSM states (localparams instead of typedef)
    localparam S_A_G      = 3'd0,
               S_A_Y      = 3'd1,
               S_B_G      = 3'd2,
               S_B_Y      = 3'd3,
               S_W_G      = 3'd4,
               S_W_RFLASH = 3'd5,
               S_W_RSOLID = 3'd6,
               S_MAINT    = 3'd7;

    reg [2:0] state, next_state;
    reg [15:0] tcnt;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_A_G;
            tcnt <= 0;
        end else if (tick) begin
            state <= next_state;
            if (state == next_state)
                tcnt <= tcnt + 1;
            else
                tcnt <= 0;
        end
    end

    // Next-state logic
    always @(*) begin
        if (MAINT) begin
            next_state = S_MAINT;
        end else begin
            case (state)
                S_A_G:       next_state = (tcnt >= A_GREEN_T-1)  ? S_A_Y      : S_A_G;
                S_A_Y:       next_state = (tcnt >= A_YELLOW_T-1) ? S_B_G      : S_A_Y;
                S_B_G:       next_state = (tcnt >= B_GREEN_T-1)  ? S_B_Y      : S_B_G;
                S_B_Y:       next_state = (tcnt >= B_YELLOW_T-1) ? S_W_G      : S_B_Y;
                S_W_G:       next_state = (tcnt >= W_GREEN_T-1)  ? S_W_RFLASH : S_W_G;
                S_W_RFLASH:  next_state = (tcnt >= W_RFLASH_T-1) ? S_W_RSOLID : S_W_RFLASH;
                S_W_RSOLID:  next_state = (tcnt >= W_RSOLID_T-1) ? S_A_G      : S_W_RSOLID;
                S_MAINT:     next_state = (MAINT ? S_MAINT : S_A_G);
                default:     next_state = S_A_G;
            endcase
        end
    end

    // Output logic
    always @(*) begin
        // defaults off
        Ga=0; Ya=0; Ra=0;
        Gb=0; Yb=0; Rb=0;
        Gw=0; Rw=0;

        if (MAINT) begin
            Ra = flash;
            Rb = flash;
            Rw = flash;
        end else begin
            case (state)
                S_A_G:      begin Ga=1; Rb=1; Rw=1; end
                S_A_Y:      begin Ya=1; Rb=1; Rw=1; end
                S_B_G:      begin Ra=1; Gb=1; Rw=1; end
                S_B_Y:      begin Ra=1; Yb=1; Rw=1; end
                S_W_G:      begin Ra=1; Rb=1; Gw=1; end
                S_W_RFLASH: begin Ra=1; Rb=1; Rw=flash; end
                S_W_RSOLID: begin Ra=1; Rb=1; Rw=1; end
                default:    ;
            endcase
        end
    end

endmodule
