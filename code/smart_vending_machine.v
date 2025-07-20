`timescale 1ns / 1ps

module smart_vending_machine (
    input clk,
    input reset,
    input [7:0] money_inserted,
    input [1:0] product_select,  // 00 - ₹25, 01 - ₹50, 10 - ₹75
    input buy_more,
    output reg [7:0] change,
    output reg dispense,
    output reg insufficient
);

    // Product Prices
    parameter PRICE_25 = 8'd25;
    parameter PRICE_50 = 8'd50;
    parameter PRICE_75 = 8'd75;

    // FSM State Definitions
    parameter IDLE         = 3'b000;
    parameter SELECT       = 3'b001;
    parameter WAIT_MONEY   = 3'b010;
    parameter CHECK        = 3'b011;
    parameter DISPENSE     = 3'b100;
    parameter INSUFFICIENT = 3'b101;

    reg [2:0] state, next_state;
    reg [7:0] selected_price;

    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        case (state)
            IDLE:         next_state = SELECT;

            SELECT:       next_state = WAIT_MONEY;

            WAIT_MONEY:   next_state = CHECK;

            CHECK: begin
                if (money_inserted >= selected_price)
                    next_state = DISPENSE;
                else
                    next_state = INSUFFICIENT;
            end

            DISPENSE:     next_state = (buy_more) ? WAIT_MONEY : IDLE;

            INSUFFICIENT: next_state = IDLE;

            default:      next_state = IDLE;
        endcase
    end

    // Price Selection
    always @(*) begin
        case (product_select)
            2'b00: selected_price = PRICE_25;
            2'b01: selected_price = PRICE_50;
            2'b10: selected_price = PRICE_75;
            default: selected_price = 8'd0;
        endcase
    end

    // Output Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            dispense     <= 0;
            insufficient <= 0;
            change       <= 0;
        end else begin
            case (next_state)
                WAIT_MONEY: begin
                    dispense     <= 0;
                    insufficient <= 0;
                    change       <= 0;
                end

                DISPENSE: begin
                    dispense     <= 1;
                    insufficient <= 0;
                    change       <= money_inserted - selected_price;
                end

                INSUFFICIENT: begin
                    dispense     <= 0;
                    insufficient <= 1;
                    change       <= 0;
                end

                default: begin
                    dispense     <= 0;
                    insufficient <= 0;
                    change       <= 0;
                end
            endcase
        end
    end

endmodule
