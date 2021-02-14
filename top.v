/*
*   IR receiver with UART interface
*
*   Top level module
*
*   Viktor Prutyanov, 2021
*/

module top (
    /* 50 MHz clock */
    input CLK,
    /* IR input */
    input IRDA,
    /* 7-segment LED display */
    output DS_EN1, DS_EN2, DS_EN3, DS_EN4,
    output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G,
    /* UART TX */
    output TXD
);

assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4} = ~anodes;
assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = segments;

reg [15:0]hd_data = 16'b0;
wire [3:0]anodes;
wire [6:0]segments;
hex_display hex_display (
    .clk(CLK),
    .data(hd_data),
    .anodes(anodes),
    .segments(segments)
);

reg uart_start = 1'b0;
reg [7:0]uart_data = 8'b0;
wire uart_idle;
uart_tx #(.BAUDRATE(5_000_000)) uart_tx (
    .clk(CLK),
    .start(uart_start),
    .data(uart_data),
    .idle(uart_idle),
    .q(TXD)
);

reg ir_in = 1'b0;
always @(posedge CLK)
    ir_in <= ~IRDA;

wire ir_edge;
wire ir_pulse;
wire [24:0]ir_cnt;
ir_rx ir_rx (
    .clk(CLK),
    .rx(ir_in),
    .rx_edge(ir_edge),
    .pulse(ir_pulse),
    .cnt(ir_cnt)
);

reg [19:0]ir_cnt_buf = 20'b0;
wire [39:0]dur_chars;
cnt_to_chars ctc(
    .cnt(ir_cnt_buf / 50),
    .chars(dur_chars)
);

reg pulse_buf = 1'b0;
always @(posedge CLK) begin
    if (ir_edge) begin
        ir_cnt_buf <= ir_cnt;
        pulse_buf <= ir_pulse;
    end
end

reg [2:0]idle_cnt = 0;
always @(posedge CLK) begin
    if (uart_idle)
        idle_cnt <= idle_cnt + 1;
    else
        idle_cnt <= 0;
end

reg [2:0]char_cnt = 0;
always @(posedge CLK) begin
    if (ir_edge)
        char_cnt <= 3'h1;

    if (idle_cnt == 3'b111) begin
        if (char_cnt)
            uart_start <= 1'b1;

        case (char_cnt)
        'h0: begin uart_data <= 8'h2b; end
        'h1: begin char_cnt <= 3'h2; uart_data <= pulse_buf ? 8'h2b : 8'h2d; end
        'h2: begin char_cnt <= 3'h3; uart_data <= dur_chars[31:24]; end
        'h3: begin char_cnt <= 3'h4; uart_data <= dur_chars[23:16]; end
        'h4: begin char_cnt <= 3'h5; uart_data <= dur_chars[15:8]; end
        'h5: begin char_cnt <= 3'h6; uart_data <= dur_chars[7:0]; end
        'h6: begin char_cnt <= 3'h7; uart_data <= 8'b00001101; end
        'h7: begin char_cnt <= 3'h0; uart_data <= 8'b00001010; end
        endcase
    end
    else
        uart_start <= 1'b0;
end

endmodule

module cnt_to_chars (
    input [19:0]cnt,

    output [39:0]chars
);

genvar i;

generate
    for (i = 0; i < 5; i = i + 1) begin : genchar
        assign chars[i * 8 +: 8] = ((cnt[i * 4 +: 4] < 10) ? 8'h30 : 8'h57) + cnt[i * 4 +: 4];
    end
endgenerate

endmodule
