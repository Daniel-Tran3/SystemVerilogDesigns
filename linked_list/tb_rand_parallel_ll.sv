//counter testbench code
`timescale 1ns/1ns
module tb_rand_parallel_ll;

  parameter TB_DATA_WIDTH = 6;
  parameter TB_MAX_DATA   = (1 << TB_DATA_WIDTH) - 1;
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
  logic [TB_DATA_WIDTH - 1 : 0] actual_deq_data_out;
  logic [TB_DATA_WIDTH - 1 : 0] correct_deq_data_out;

  logic [TB_CNT_WIDTH - 1 : 0]                            global_cnt;
  logic [TB_CNT_WIDTH - 1 : 0]                            prev_global_cnt;
  logic [TB_QUEUE_NUM - 1 : 0][TB_CNT_WIDTH - 1 : 0]      queue_cnts;
  logic [TB_QUEUE_NUM_WIDTH - 1 : 0]                      output_ll_num;

  logic [TB_READ_DELAY - 1 : 0]                     deq_vld_buf;
  logic [TB_READ_DELAY - 1 : 0][TB_QUEUE_NUM_WIDTH] deq_queue_num_buf;

  logic                                                   rand_en;

  int                                                     enq_wait;
  int                                                     deq_wait;

  int                                                     num_cycles;

  logic [TB_DATA_WIDTH - 1 : 0] queue_data [TB_QUEUE_NUM - 1 : 0][$];

  linked_list #(.NUM_QUEUES(TB_QUEUE_NUM), .LL_DEPTH(TB_LL_DEPTH), .DATA_WIDTH(TB_DATA_WIDTH), .READ_DELAY(TB_READ_DELAY)) tb_linked_list(
    .clk(clock),
    .reset(rst),
    .init_done(init_done),
    .enq_data_in(enq_data_in),
    .enq_vld_in(enq_vld_in),
    .deq_vld_in(deq_vld_in),
    .enq_id_in(enq_id_in),
    .deq_id_in(deq_id_in),
    .deq_data_out(actual_deq_data_out)
  );


  initial begin
    #20

    clock           = 0;
    rst             = 1;
    enq_data_in     = 'd0;
    enq_vld_in      = 0;
    deq_vld_in      = 0;
    enq_id_in       = 2'b00;
    deq_id_in       = 2'b00;
    deq_vld_buf     = 5'd0;
    global_cnt      = 'd0;
    prev_global_cnt = 'd0;
    queue_cnts      = 'd0;
    enq_wait        = 'd0;
    deq_wait        = 'd0;
    num_cycles      = 'd0;
    rand_en         = 'd0;

    #20
    rst      = 0;

    #20

    while (!init_done) begin
      #20
      $display("Waiting for init.");
    end

    $display("Finished init.");

    rand_en    = 'd1;
    num_cycles = 'd500;

    while (num_cycles != 0) begin
      #20;
    end

    rand_en    = 'd0;
    enq_vld_in = 'd0;
    deq_vld_in = 'd0;

    #60
    
    $stop();
  end

  

  always@(clock) begin
    #10ns clock <= !clock;
  end

  always@(negedge clock) begin
    for (int i = 1; i < TB_READ_DELAY; i++) begin
      deq_vld_buf[i]    <= deq_vld_buf[i-1];
      deq_queue_num_buf[i] <= deq_queue_num_buf[i-1];
    end
    if (deq_vld_buf[TB_READ_DELAY - 1]) begin
      // $display("Dequeued from queue %d, output was %d.", output_ll_num, actual_deq_data_out);
      correct_deq_data_out = queue_data[output_ll_num].pop_front();
      if (actual_deq_data_out == correct_deq_data_out) begin
        $display("Dequeued from queue %d, output was %d. Correct!", output_ll_num, actual_deq_data_out);
      end else begin
        $display("Dequeued from queue %d, output was %d. Should have been %d!", output_ll_num, actual_deq_data_out, correct_deq_data_out);
      end
    end
  end

  always@(negedge clock) begin
    if (rand_en) begin
      if (enq_wait == 'd0 && prev_global_cnt < TB_LL_DEPTH - 1) begin
        enq_vld_in  = 1;
        enq_id_in   = $urandom_range(TB_QUEUE_NUM - 1);
        enq_data_in = $urandom_range(TB_MAX_DATA);
        queue_data[enq_id_in].push_back(enq_data_in);
        queue_cnts[enq_id_in] += 'd1;
        global_cnt            += 'd1;
        // $display("Enqueueing to linked list %d, input was %d.", enq_id_in, enq_data_in);
        // $display("Queue %d has %d items, out of %d total.", enq_id_in, queue_cnts[enq_id_in], global_cnt);
        enq_wait    = $urandom_range(1,5);
      end else begin
        enq_vld_in  = 0;
        if (enq_wait > 'd0) begin
          enq_wait   -= 'd1;
        end
      end
    end
  end

  always@(negedge clock) begin
    if (rand_en) begin
      if (deq_wait == 'd0 && prev_global_cnt > 0) begin
        deq_vld_in  = 1;
        deq_id_in   = $urandom_range(TB_QUEUE_NUM - 1);
        while (queue_cnts[deq_id_in] == 'd0) begin
          deq_id_in = $urandom_range(TB_QUEUE_NUM - 1);
        end
        queue_cnts[deq_id_in] -= 'd1;
        global_cnt            -= 'd1;
        // $display("Queue %d has %d items, out of %d total.", deq_id_in, queue_cnts[deq_id_in], global_cnt);
        deq_wait    = $urandom_range(3,7);
      end else begin
        deq_vld_in  = 0;
        if (deq_wait > 'd0) begin
          deq_wait   -= 'd1;
        end
      end
    end
  end

  always@(negedge clock) begin
    if (num_cycles > 0) begin
      num_cycles -= 'd1;
    end
    prev_global_cnt = global_cnt;
  end

  assign deq_vld_buf[0] = deq_vld_in;
  assign deq_queue_num_buf[0] = deq_id_in;
  assign output_ll_num  = deq_queue_num_buf[TB_READ_DELAY - 1];

endmodule