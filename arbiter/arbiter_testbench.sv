//arbiter testbench code
`timescale 1ns/1ns
module arbiter_testbench;

  parameter TB_WIDTH = 8;

  logic clock, rst;
  logic [TB_WIDTH - 1 : 0] req_in;
  logic [TB_WIDTH - 1 : 0] gnt_out;

  // Instantiate design
  arbiter #(.REQ_WIDTH(TB_WIDTH)) arb(
    .clk(clock),
    .reset(rst),
    .req(req_in),
    .gnt(gnt_out)
  );

  initial begin
    // Input initialization
    rst = 1;
    clock = 0;
    req_in = 0;

    #20;
    rst = 0;
    req_in = 8'b00000001;
    #20;
    req_in = 8'b00000101;
    #20;
    req_in = 8'b00001001;
    #20;
    req_in = 8'b00111001;
    #60;
    req_in = 8'b00001001;
    #20

    $stop();
  end

  always@(clock) begin
    #10ns clock <= !clock;
  end

endmodule