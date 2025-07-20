`timescale 1ns / 1ps
module smart_vending_machine_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] money_inserted;
    reg [1:0] product_select;
    reg buy_more;

    // Outputs
    wire [7:0] change;
    wire dispense;
    wire insufficient;

    // Instantiate the vending machine
    smart_vending_machine uut (
        .clk(clk),
        .reset(reset),
        .money_inserted(money_inserted),
        .product_select(product_select),
        .buy_more(buy_more),
        .change(change),
        .dispense(dispense),
        .insufficient(insufficient)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        money_inserted = 0;
        product_select = 2'b00;
        buy_more = 0;

        // Wait a bit then release reset
        #10 reset = 0;

        // Test Case 1: Buy ₹25 product with ₹25
        #10 product_select = 2'b00;
        money_inserted = 8'd25;
        buy_more = 0;
        #20;

        // Test Case 2: Try to buy ₹50 product with ₹25 (insufficient)
        #10 product_select = 2'b01;
        money_inserted = 8'd25;
        #20;

        // Test Case 3: Buy ₹75 product with ₹100 (expect change ₹25)
        #10 product_select = 2'b10;
        money_inserted = 8'd100;
        buy_more = 0;
        #20;

        // Test Case 4: Buy ₹50 product twice with ₹50 (second attempt with buy_more)
        #10 product_select = 2'b01;
        money_inserted = 8'd50;
        buy_more = 1;
        #20;

        // Test Case 5: Insert ₹10 (less than ₹25), expect insufficient
        #10 product_select = 2'b00;
        money_inserted = 8'd10;
        buy_more = 0;
        #20;

        // Finish simulation
        #20 $finish;
    end

endmodule