/*
* IR recevier
*
* Viktor Prutyanov, 2021
*/

module ir_rx #(
    parameter CNT_WIDTH = 25
)(
    input clk,
    input rx,

    output rx_edge,
    output reg pulse,
    output reg [CNT_WIDTH-1:0]cnt
);

initial pulse = 1'b0;
initial cnt = 0;

wire rise = ~pulse && rx;
wire fall = pulse && ~rx;

assign rx_edge = rise || fall;

always @(posedge clk) begin
    if (rise)
        pulse <= 1'b1;
    else if (fall)
        pulse <= 1'b0;

    if (rx_edge)
        cnt <= 0;
    else
        cnt <= cnt + 1;
end

endmodule
