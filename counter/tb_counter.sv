//counter testbench code
`timescale 1ns/1ns
module tb_counter;

  parameter TB_COUNTER_WIDTH = 4;
  parameter TB_NUM_COUNTERS = 8;
  parameter TB_READ_DELAY = 3;
  parameter TB_ADDR_WIDTH = $clog2(TB_NUM_COUNTERS);

  logic clock, rst;
  logic [TB_ADDR_WIDTH - 1 : 0] counter_addr;
  logic counter_vld;
  logic [TB_COUNTER_WIDTH] counter_val;
  logic counter_val_vld;
  logic init_done;

  // Instantiate design
  counter #(.NUM_COUNTERS(TB_NUM_COUNTERS), .COUNTER_WIDTH(TB_COUNTER_WIDTH), .READ_DELAY(TB_READ_DELAY)) counter(
    .clk(clock),
    .reset(rst),
    .cntr_addr_in(counter_addr),
    .cntr_vld_in(counter_vld),
    .cntr_val_out(counter_val),
    .cntr_val_vld(counter_val_vld),
    .init_done(init_done)
  );

  initial begin
    // Input initialization
    rst = 1;
    clock = 0;
    counter_addr = 3'b000;
    counter_vld = 1;

    #20
    rst = 0;

    while (!init_done) begin
      #20
      $display("Waiting for init phase.");
    end

    $display("Init done!");

    #100
    counter_vld = 0;
    #60
    $display("First round of counting on address %4b done. Final count was %d.", counter_addr, counter_val);
    counter_vld = 1;
    counter_addr = 3'b001;
    #200
    counter_vld = 0;
    #60
    $display("Second round of counting on address %4b done. Final count was %d.", counter_addr, counter_val);
    counter_vld = 1;
    counter_addr = 3'b001;
    #20
    counter_addr = 3'b010;
    #20
    counter_addr = 3'b011;
    #20
    counter_addr = 3'b001;
    #20
    counter_vld = 0;
    #60
    $display("Third round of counting on address %4b done. Final count was %d.", counter_addr, counter_val);
    counter_vld = 1;
    counter_addr = 3'b001;
    #20
    counter_addr = 3'b010;
    #20
    counter_addr = 3'b001;
    #20
    counter_vld = 0;
    #60
    $display("Fourth round of counting on address %4b done. Final count was %d.", counter_addr, counter_val);
    counter_vld = 1;
    counter_addr = 3'b001;
    #20
    counter_addr = 3'b010;
    #20
    counter_addr = 3'b011;
    #20
    counter_addr = 3'b100;
    #20
    counter_addr = 3'b001;
    #20
    counter_vld = 0;
    #60
    $display("Fifth round of counting on address %4b done. Final count was %d.", counter_addr, counter_val);



    $stop();
  end

  always@(clock) begin
    #10ns clock <= !clock;
  end

endmodule