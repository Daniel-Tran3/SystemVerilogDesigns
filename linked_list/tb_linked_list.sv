//counter testbench code
`timescale 1ns/1ns
module tb_linked_list;

  parameter TB_DATA_WIDTH = 6;
  parameter TB_LL_DEPTH   = 64;
  parameter TB_QUEUE_NUM       = 4;
  parameter TB_QUEUE_NUM_WIDTH = $clog2(TB_QUEUE_NUM);
  parameter TB_READ_DELAY = 3;
  parameter TB_ADDR_WIDTH = $clog2(TB_LL_DEPTH);
  parameter TB_CNT_WIDTH = $clog2(TB_LL_DEPTH + 1);

  logic clock, rst;
  logic init_done;
  logic [TB_DATA_WIDTH - 1 : 0] enq_data_in;
  logic enq_vld_in, deq_vld_in;
  logic [$clog2(TB_LL_NUM) - 1 : 0] enq_id_in;
  logic [$clog2(TB_LL_NUM) - 1 : 0] deq_id_in;
  logic [TB_DATA_WIDTH - 1 : 0] deq_data_out;

  logic [TB_CNT_WIDTH - 1 : 0]                            global_cnt;
  logic [TB_QUEUE_NUM - 1 : 0][TB_CNT_WIDTH - 1 : 0]      queue_cnts;
  logic [TB_LL_DEPTH - 1 : 0]                             addr_vec;
  logic [TB_QUEUE_NUM_WIDTH - 1 : 0]                      output_ll_num;

  logic [(TB_READ_DELAY + 2) - 1 : 0]                     deq_vld_buf;
  logic [(TB_READ_DELAY + 2) - 1 : 0][TB_QUEUE_NUM_WIDTH] deq_queue_num_buf;

  linked_list #(.NUM_QUEUES(TB_QUEUE_NUM), .LL_DEPTH(TB_LL_DEPTH), .DATA_WIDTH(TB_DATA_WIDTH), .READ_DELAY(TB_READ_DELAY)) tb_linked_list(
    .clk(clock),
    .reset(rst),
    .init_done(init_done),
    .enq_data_in(enq_data_in),
    .enq_vld_in(enq_vld_in),
    .deq_vld_in(deq_vld_in),
    .enq_id_in(enq_id_in),
    .deq_id_in(deq_id_in),
    .deq_data_out(deq_data_out)
  );


  initial begin
    #20

    clock    = 0;
    rst      = 1;
    enq_data_in = 'd1;
    enq_vld_in  = 0;
    deq_vld_in  = 0;
    enq_id_in   = 2'b00;
    deq_id_in   = 2'b00;
    deq_vld_buf = 5'd0;
    global_cnt  = 'd0;
    queue_cnts  = 'd0;
    addr_vec    = 'd0;

    #20
    rst      = 0;

    #20

    while (!init_done) begin
      #20
      $display("Waiting for init.");
    end

    $display("Finished init.");

    #20
    enq_vld_in  = 1;
    enq_data_in = 'd1;
    enq_id_in   = 2'b00;

    #20
    enq_vld_in  = 0;

    #20
    enq_vld_in  = 1;
    enq_data_in = 'd2;

    #20
    enq_vld_in  = 0;
    deq_vld_in  = 1;
    deq_id_in   = 2'b00;

    #20
    deq_vld_in  = 0;

    #20
    deq_vld_in  = 1;

    #20
    deq_vld_in  = 0;
    
    #20
    enq_vld_in  = 1;
    deq_vld_in  = 0;
    enq_data_in = 'd1;
    enq_id_in   = 2'b00;

    #20
    enq_vld_in  = 0;

    for (int i = 0; i < 10; i++) begin
      #20
      enq_vld_in  = 1;
      enq_data_in = i;

      #20
      enq_vld_in = 0;

    end

    
    #20
    enq_vld_in  = 1;
    enq_data_in = 'd40;
    enq_id_in   = 2'b01;

    #20
    enq_vld_in  = 0;

    for (int i = 0; i < 20; i++) begin
      #20
      enq_vld_in  = 1;
      enq_data_in = 'd63 - i;

      #20
      enq_vld_in  = 0;
    end

    #20
    enq_vld_in  = 1;
    enq_data_in = 'd50;
    enq_id_in   = 2'b00;

    #20
    enq_vld_in  = 0;

    for (int i = 0; i < 10; i++) begin
      #20
      enq_vld_in = 1;
      enq_data_in = 'd30 + i;

      #20
      enq_vld_in  = 0;
    end


    #20
    enq_vld_in  = 0;
    deq_vld_in  = 1;
    deq_id_in   = 2'b01;

    #20
    deq_vld_in  = 0;

    for (int i = 0; i < 20; i++) begin
      #20
      deq_vld_in = 1;

      #20
      deq_vld_in = 0;
    end

    #20
    enq_vld_in = 0;
    deq_vld_in = 1;
    deq_id_in  = 2'b00;

    #20
    deq_vld_in = 0;

    for (int i = 0; i < 21; i++) begin
      #20
      deq_vld_in = 1;

      #20
      deq_vld_in = 0;
    end

    for (int i = 0; i < TB_LL_DEPTH; i++) begin
      #20
      enq_vld_in  = 1;
      enq_id_in   = 2'b00;
      enq_data_in = i;

      #20
      enq_vld_in  = 0;
    end

    for (int i = 0; i < TB_LL_DEPTH; i++) begin
      #20
      deq_vld_in  = 1;
      deq_id_in   = 2'b00;

      #20
      deq_vld_in  = 0;
    end

    for (int i = 0; i < 10; i++) begin
      #20
      enq_vld_in  = 1;
      if (i != 0) begin
        deq_vld_in  = 1;
      end
      enq_id_in   = 0;
      deq_id_in   = 0;
      enq_data_in = i;

      #20
      enq_vld_in  = 0;
      deq_vld_in  = 0;
    end

    #20
    $display("Finished loop.");
    enq_vld_in  = 0;
    deq_vld_in  = 1;

    #20
    deq_vld_in  = 0;

    #60
    for (int i = 0; i < TB_LL_DEPTH; i++) begin
      #20
      enq_vld_in  = 1;
      enq_id_in   = $urandom_range(TB_QUEUE_NUM - 1);
      enq_data_in = i;
      addr_vec[i] = 1;
      #20
      enq_vld_in  = 0;
      #(20 * $urandom_range(4));
    end 

    if (~addr_vec == 'd0) begin
      $display("Successfully enqueued all items!");
    end else begin
      $display("Items still not enqueued. Addr_vec is %b", addr_vec);
    end

    for (int i = 0; i < TB_LL_DEPTH; i++) begin
      #20
      deq_vld_in  = 1;
      deq_id_in   = $urandom_range(TB_QUEUE_NUM - 1);
      while (queue_cnts[deq_id_in] == 'd0) begin
        deq_id_in = $urandom_range(TB_QUEUE_NUM - 1);
      end
      #20
      deq_vld_in  = 0;
      #(20 * $urandom_range(4));
    end

    #80
    if (addr_vec == 'd0) begin
      $display("Successfully dequeued all items.");
    end else begin
      $display("Items still remaining! Addr_vec is %b", addr_vec);
    end
    $stop();
  end

  

  always@(clock) begin
    #10ns clock <= !clock;
  end

  always@(negedge clock) begin
    for (int i = 1; i < TB_READ_DELAY + 2 - 1; i++) begin
      deq_vld_buf[i]    <= deq_vld_buf[i-1];
      deq_queue_num_buf[i] <= deq_queue_num_buf[i-1];
    end
    if (deq_vld_buf[(TB_READ_DELAY + 2) - 2]) begin
      addr_vec[deq_data_out] = 0;
      $display("Dequeued from linked list %d, output was %d.", output_ll_num, deq_data_out);
    end
    if (enq_vld_in) begin
      queue_cnts[enq_id_in] += 'd1;
      global_cnt            += 'd1;
      $display("Enqueueing to linked list %d, input was %d.", enq_id_in, enq_data_in);
      $display("Queue %d has %d items, out of %d total.", enq_id_in, queue_cnts[enq_id_in], global_cnt);
    end
    if (deq_vld_in) begin
      queue_cnts[deq_id_in] -= 'd1;
      global_cnt            -= 'd1;
      $display("Queue %d has %d items, out of %d total.", deq_id_in, queue_cnts[deq_id_in], global_cnt);
    end
  end

  assign deq_vld_buf[0] = deq_vld_in;
  assign deq_queue_num_buf[0] = deq_id_in;
  assign output_ll_num  = deq_queue_num_buf[(TB_READ_DELAY + 2) - 2];

endmodule