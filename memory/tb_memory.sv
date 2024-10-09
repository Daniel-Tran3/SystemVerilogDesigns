//memory testbench code
`timescale 1ns/1ns
module tb_memory;

  parameter TB_DATA_WIDTH = 4;
  parameter TB_MEM_DEPTH = 3;
  parameter TB_DELAY_CYCLES = 3;
  parameter TB_ADDR_WIDTH = $clog2(TB_MEM_DEPTH);

  logic clock, rst;
  logic [TB_DATA_WIDTH - 1 : 0] wr_data_in;
  logic [TB_DATA_WIDTH - 1 : 0] rd_data_out;
  logic [TB_ADDR_WIDTH - 1 : 0] wr_addr;
  logic [TB_ADDR_WIDTH - 1 : 0] rd_addr;
  logic wr_en;
  logic rd_en;

  // Instantiate design
  memory #(.MEM_DEPTH(TB_MEM_DEPTH), .DATA_WIDTH(TB_DATA_WIDTH)) memory(
    .clk(clock),
    .reset(rst),
    .wr_en(wr_en),
    .wr_addr(wr_addr),
    .wr_data(wr_data_in),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .rd_data(rd_data_out)
  );

  initial begin
    // Input initialization
    rst = 1;
    clock = 0;
    wr_en = 0;
    wr_addr = 2'b00;
    wr_data_in = 4'b0001;
    rd_en = 0;
    rd_addr = 2'b01;

    #20
    rst = 0;

    #20
    wr_en = 1;

    #80
    wr_en = 0;
    rd_addr = 2'b00;
    rd_en = 1;

    #100
    rd_en = 0;

    #60
    wr_en = 1;
    wr_addr = 2'b01;
    wr_data_in = 4'b0010;
    
    #20
    wr_addr = 2'b10;
    wr_data_in = 4'b0100;

    #20
    // wr_addr = 2'b11;
    // wr_data_in = 4'b1000;
    rd_addr = 2'b11;
    rd_en = 1;

    #60


    $stop();
  end

  always@(clock) begin
    #10ns clock <= !clock;
  end

endmodule