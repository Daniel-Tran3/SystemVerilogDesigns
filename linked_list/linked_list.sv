module linked_list#(
  parameter int NUM_QUEUES=4,
  parameter int LL_DEPTH=16,
  parameter int DATA_WIDTH=4,
  // READ_DELAY refers to latency of memory module - due to registering
  // the input and output, the actual latency of this module is READ_DELAY + 2 cycles
  parameter int READ_DELAY=3)
(
  input logic clk,
  input logic reset,
  
  output logic init_done,
  
  input logic                              enq_vld_in,
  input logic [$clog2(NUM_QUEUES) - 1 : 0] enq_id_in,
  input logic [DATA_WIDTH - 1 : 0]         enq_data_in,
  
  input logic                              deq_vld_in,
  input logic [$clog2(NUM_QUEUES) - 1 : 0] deq_id_in,
  output logic [DATA_WIDTH - 1 : 0]        deq_data_out
);

  // Localparams
  localparam int ADDR_WIDTH      = $clog2(LL_DEPTH);
  localparam int CNT_WIDTH       = $clog2(LL_DEPTH + 1);
  localparam int LL_NUM          = READ_DELAY + 2;
  localparam int MAX_LL_NUM      = LL_NUM - 1;
  localparam int QUEUE_NUM_WIDTH = $clog2(NUM_QUEUES);
  localparam int LL_NUM_WIDTH    = $clog2(LL_NUM);

  

  // Internal Enq/Deq Vars
  logic                           enq_vld;
  logic [QUEUE_NUM_WIDTH - 1 : 0] enq_id;
  logic [DATA_WIDTH - 1 : 0]      enq_data;
  logic                           deq_vld;
  logic [QUEUE_NUM_WIDTH - 1 : 0] deq_id;

  // Enq Buffer Vars
  logic                           enq_vld_buf;
  logic [QUEUE_NUM_WIDTH - 1 : 0] enq_id_buf;
  logic [DATA_WIDTH - 1 : 0]      enq_data_buf;

  // Init Vars
  logic                           init;
  logic                           init_next_ptr_mem_wr_en;
  logic [ADDR_WIDTH - 1 : 0]      init_next_ptr_mem_wr_addr;
  logic [ADDR_WIDTH - 1 : 0]      init_next_ptr_mem_wr_data;
  logic [CNT_WIDTH - 1 : 0]       init_free_list_cnt;
  logic [CNT_WIDTH - 1 : 0]       init_free_list_ll_cnt;
  logic [LL_NUM_WIDTH - 1 : 0]    init_free_list_ll_num;
  logic [ADDR_WIDTH - 1 : 0]      init_free_list_head_ptr;
  logic [ADDR_WIDTH - 1 : 0]      init_free_list_tail_ptr;

  // Enq Linked List State Vars
  logic [CNT_WIDTH - 1 : 0]       enq_queue_cnt;
  logic [CNT_WIDTH - 1 : 0]       enq_queue_ll_cnt;
  logic [LL_NUM_WIDTH - 1 : 0]    enq_queue_ll_num;
  logic [ADDR_WIDTH - 1 : 0]      enq_queue_head_ptr;
  logic [ADDR_WIDTH - 1 : 0]      enq_queue_tail_ptr;
  logic [DATA_WIDTH - 1 : 0]      enq_queue_head_data;

  // Enq Free List State Vars
  logic [CNT_WIDTH - 1 : 0]       enq_free_list_cnt;
  logic [CNT_WIDTH - 1 : 0]       enq_free_list_ll_cnt;
  logic [LL_NUM_WIDTH - 1 : 0]    enq_free_list_ll_num;
  logic                           enq_rd_free_list_vld;
  logic [LL_NUM_WIDTH - 1 : 0]    enq_rd_ll_num;

  // Enq Memory Input Vars
  logic                           enq_next_ptr_mem_wr_en;
  logic [ADDR_WIDTH - 1 : 0]      enq_next_ptr_mem_wr_addr;
  logic [ADDR_WIDTH - 1 : 0]      enq_next_ptr_mem_wr_data;
  logic                           enq_next_ptr_mem_rd_en;
  logic [ADDR_WIDTH - 1 : 0]      enq_next_ptr_mem_rd_addr;
  logic                           enq_data_mem_wr_en;
  logic [ADDR_WIDTH - 1 : 0]      enq_data_mem_wr_addr;
  logic [DATA_WIDTH - 1 : 0]      enq_data_mem_wr_data;

  // Deq Linked List State Vars
  logic [CNT_WIDTH - 1 : 0]       deq_queue_cnt;
  logic [CNT_WIDTH - 1 : 0]       deq_queue_ll_cnt;
  logic [LL_NUM_WIDTH - 1 : 0]    deq_queue_ll_num;
  logic                           deq_rd_queue_vld;
  logic [QUEUE_NUM_WIDTH - 1 : 0] deq_rd_queue_num;
  logic [LL_NUM_WIDTH - 1 : 0]    deq_rd_ll_num;

  // Deq Free List State Vars
  logic [CNT_WIDTH - 1 : 0]       deq_free_list_cnt;
  logic [CNT_WIDTH - 1 : 0]       deq_free_list_ll_cnt;
  logic [LL_NUM_WIDTH - 1 : 0]    deq_free_list_ll_num;
  logic [ADDR_WIDTH - 1 : 0]      deq_free_list_head_ptr;
  logic [ADDR_WIDTH - 1 : 0]      deq_free_list_tail_ptr;

  // Deq Memory Input Vars
  logic                           deq_next_ptr_mem_wr_en;
  logic [ADDR_WIDTH - 1 : 0]      deq_next_ptr_mem_wr_addr;
  logic [ADDR_WIDTH - 1 : 0]      deq_next_ptr_mem_wr_data;
  logic                           deq_next_ptr_mem_rd_en;
  logic [ADDR_WIDTH - 1 : 0]      deq_next_ptr_mem_rd_addr;
  logic                           deq_data_mem_rd_en;
  logic [ADDR_WIDTH - 1 : 0]      deq_data_mem_rd_addr;

  // Memory Input Vars
  logic                           next_ptr_mem_wr_en;
  logic [ADDR_WIDTH - 1 : 0]      next_ptr_mem_wr_addr;
  logic [ADDR_WIDTH - 1 : 0]      next_ptr_mem_wr_data;
  logic                           next_ptr_mem_rd_en;
  logic [ADDR_WIDTH - 1 : 0]      next_ptr_mem_rd_addr;
  logic [ADDR_WIDTH - 1 : 0]      next_ptr_mem_rd_data;
  logic                           data_mem_wr_en;
  logic [ADDR_WIDTH - 1 : 0]      data_mem_wr_addr;
  logic [DATA_WIDTH - 1 : 0]      data_mem_wr_data;
  logic                           data_mem_rd_en;
  logic [ADDR_WIDTH - 1 : 0]      data_mem_rd_addr;
  logic [DATA_WIDTH - 1 : 0]      data_mem_rd_data;

  // Queue Vars
  logic [NUM_QUEUES - 1 : 0][LL_NUM - 1 : 0][ADDR_WIDTH - 1 : 0] queue_head_ptrs;
  logic [NUM_QUEUES - 1 : 0][LL_NUM - 1 : 0][ADDR_WIDTH - 1 : 0] queue_tail_ptrs;
  logic [NUM_QUEUES - 1 : 0][LL_NUM_WIDTH - 1 : 0]               queue_head_lls;
  logic [NUM_QUEUES - 1 : 0][LL_NUM_WIDTH - 1 : 0]               queue_tail_lls;
  logic [NUM_QUEUES - 1 : 0][CNT_WIDTH - 1 : 0]                  queue_cnts;
  logic [NUM_QUEUES - 1 : 0][LL_NUM - 1 : 0][CNT_WIDTH - 1 : 0]  queue_ll_cnts;

  // Read Buffer Vars
  logic [READ_DELAY - 1 : 0][QUEUE_NUM_WIDTH - 1 : 0]       rd_queue_num_buffer;
  logic [READ_DELAY - 1 : 0][LL_NUM_WIDTH - 1 : 0]          rd_ll_num_buffer;
  logic [READ_DELAY - 1 : 0]                                rd_queue_vld_buffer;
  logic [READ_DELAY - 1 : 0]                                rd_free_list_vld_buffer;
  logic [ADDR_WIDTH - 1 : 0]                                rd_next_free_list_head_addr;
  logic [ADDR_WIDTH - 1 : 0]                                rd_next_queue_head_ptr;

  // Free List Vars
  logic [LL_NUM - 1 : 0][ADDR_WIDTH - 1 : 0] free_list_head_ptrs;
  logic [LL_NUM - 1 : 0][ADDR_WIDTH - 1 : 0] free_list_tail_ptrs;
  logic [LL_NUM_WIDTH - 1 : 0]               free_list_head_ll;
  logic [LL_NUM_WIDTH - 1 : 0]               free_list_tail_ll;
  logic [CNT_WIDTH - 1 : 0]                  free_list_cnt;
  logic [LL_NUM - 1 : 0][CNT_WIDTH - 1 : 0]  free_list_ll_cnts;  

  memory #(.MEM_DEPTH(LL_DEPTH), .DATA_WIDTH(ADDR_WIDTH), .DELAY_CYCLES(READ_DELAY)) next_ptr_mem(
    .clk(clk),
    .reset(reset),
    .wr_en(next_ptr_mem_wr_en),
    .wr_addr(next_ptr_mem_wr_addr),
    .wr_data(next_ptr_mem_wr_data),
    .rd_en(next_ptr_mem_rd_en),
    .rd_addr(next_ptr_mem_rd_addr),
    .rd_data(next_ptr_mem_rd_data)
  );

  memory #(.MEM_DEPTH(LL_DEPTH), .DATA_WIDTH(DATA_WIDTH), .DELAY_CYCLES(READ_DELAY)) data_mem(
    .clk(clk),
    .reset(reset),
    .wr_en(data_mem_wr_en),
    .wr_addr(data_mem_wr_addr),
    .wr_data(data_mem_wr_data),
    .rd_en(data_mem_rd_en),
    .rd_addr(data_mem_rd_addr),
    .rd_data(data_mem_rd_data)
  );

  // Init Comb Section
  always_comb begin
    init_free_list_cnt        = 0;
    init_free_list_ll_cnt     = 0;
    init_free_list_head_ptr   = 0;
    init_free_list_tail_ptr   = 0;
    init_free_list_ll_num     = 0;
    init_next_ptr_mem_wr_en   = 0;
    init_next_ptr_mem_wr_addr = 0;
    init_next_ptr_mem_wr_data = 0;
    if (init) begin
      init_free_list_cnt        = free_list_cnt + 'd1;
      init_free_list_ll_cnt     = free_list_ll_cnts[free_list_tail_ll] + 'd1;
      init_free_list_tail_ptr   = free_list_cnt;
      init_free_list_ll_num     = (free_list_tail_ll < MAX_LL_NUM) ? (free_list_tail_ll + 'd1) : 'd0;
      if (free_list_ll_cnts[free_list_tail_ll] == 0) begin
        init_free_list_head_ptr   = free_list_cnt;
      end else begin
        init_next_ptr_mem_wr_en   = 1;
        init_next_ptr_mem_wr_addr = free_list_tail_ptrs[free_list_tail_ll];
        init_next_ptr_mem_wr_data = free_list_cnt;
      end
    end
  end

  // Init_done Management
  assign init_done            = !init;

  // Enq Linked List Comb Section
  always_comb begin
    enq_next_ptr_mem_wr_en   = 0;
    enq_next_ptr_mem_wr_addr = 0;
    enq_next_ptr_mem_wr_data = 0;
    enq_data_mem_wr_en       = 0;
    enq_data_mem_wr_addr     = 0;
    enq_data_mem_wr_data     = 0;
    enq_queue_cnt            = 0;
    enq_queue_ll_cnt         = 0;
    enq_queue_ll_num         = 0;
    enq_queue_head_ptr       = 0;
    enq_queue_tail_ptr       = 0;
    if (!init) begin
      if (enq_vld) begin
        enq_data_mem_wr_en       = 1;
        enq_data_mem_wr_addr     = free_list_head_ptrs[free_list_head_ll];
        enq_data_mem_wr_data     = enq_data;
        enq_queue_cnt            = queue_cnts[enq_id] + 'd1;
        enq_queue_ll_cnt         = queue_ll_cnts[enq_id][queue_tail_lls[enq_id]] + 'd1;
        enq_queue_ll_num         = (queue_tail_lls[enq_id] < MAX_LL_NUM) ? (queue_tail_lls[enq_id] + 'd1) : 'd0;
        enq_queue_tail_ptr       = free_list_head_ptrs[free_list_head_ll];
        if (queue_ll_cnts[enq_id][queue_tail_lls[enq_id]] == 0) begin
          enq_queue_head_ptr       = free_list_head_ptrs[free_list_head_ll];
        end else begin
          enq_next_ptr_mem_wr_en   = 1;
          enq_next_ptr_mem_wr_addr = queue_tail_ptrs[enq_id][queue_tail_lls[enq_id]];
          enq_next_ptr_mem_wr_data = free_list_head_ptrs[free_list_head_ll];
        end
      end
    end
  end

  // Deq Linked List Comb Section
  always_comb begin
    deq_data_mem_rd_en       = 0;
    deq_data_mem_rd_addr     = 0;
    deq_next_ptr_mem_rd_en   = 0;
    deq_next_ptr_mem_rd_addr = 0;
    deq_queue_cnt            = 0;
    deq_queue_ll_cnt         = 0;
    deq_queue_ll_num         = 0;
    deq_rd_queue_vld         = 0;
    deq_rd_queue_num         = 0;
    deq_rd_ll_num            = 0;
    if (!init) begin
      if (deq_vld) begin
        deq_data_mem_rd_en       = 1;
        deq_data_mem_rd_addr     = queue_head_ptrs[deq_id][queue_head_lls[deq_id]];
        deq_queue_cnt            = queue_cnts[deq_id] - 'd1;
        deq_queue_ll_cnt         = queue_ll_cnts[deq_id][queue_head_lls[deq_id]] - 'd1;
        deq_queue_ll_num         = (queue_head_lls[deq_id] < MAX_LL_NUM) ? (queue_head_lls[deq_id] + 'd1) : 'd0;
        if (queue_ll_cnts[deq_id][queue_head_lls[deq_id]] > 1) begin
          deq_next_ptr_mem_rd_en   = 1;
          deq_next_ptr_mem_rd_addr = queue_head_ptrs[deq_id][queue_head_lls[deq_id]];
          deq_rd_queue_vld         = 1;
          deq_rd_queue_num         = deq_id;
          deq_rd_ll_num            = queue_head_lls[deq_id];
        end
      end
    end
  end

  // Queue State Management
  always_ff@(posedge clk) begin
    if (reset) begin
      queue_cnts     <= 0;
      queue_ll_cnts  <= 0;
      queue_head_lls <= 0;
      queue_tail_lls <= 0;
    end else if (!init) begin
      if (enq_vld || deq_vld) begin
        if (enq_vld) begin
          queue_cnts[enq_id]                                   <= enq_queue_cnt;
          queue_tail_lls[enq_id]                               <= enq_queue_ll_num;
          queue_ll_cnts[enq_id][queue_tail_lls[enq_id]]        <= enq_queue_ll_cnt;
          queue_tail_ptrs[enq_id][queue_tail_lls[enq_id]]      <= enq_queue_tail_ptr;
          if (queue_ll_cnts[enq_id][queue_tail_lls[enq_id]] == 0) begin
            queue_head_ptrs[enq_id][queue_tail_lls[enq_id]] <= enq_queue_head_ptr;
          end
        end else begin // Deq_vld must be true
          queue_cnts[deq_id]                            <= deq_queue_cnt;
          queue_ll_cnts[deq_id][queue_head_lls[deq_id]] <= deq_queue_ll_cnt;
          queue_head_lls[deq_id]                        <= deq_queue_ll_num;
        end
      end
      if (rd_queue_vld_buffer[READ_DELAY - 1]) begin
        queue_head_ptrs[rd_queue_num_buffer[READ_DELAY - 1]][rd_ll_num_buffer[READ_DELAY - 1]] <= next_ptr_mem_rd_data;
      end
    end
  end

  // Enq Free List Comb Section
  always_comb begin
    enq_next_ptr_mem_rd_en   = 0;
    enq_next_ptr_mem_rd_addr = 0;
    enq_rd_free_list_vld     = 0;
    enq_rd_ll_num            = 0;
    enq_free_list_ll_num     = 0;
    enq_free_list_cnt        = 0;
    enq_free_list_ll_cnt     = 0;
    if (!init) begin
      if (enq_vld) begin
        enq_free_list_ll_num     = (free_list_head_ll < MAX_LL_NUM) ? (free_list_head_ll + 'd1) : 'd0;
        enq_free_list_cnt        = free_list_cnt - 'd1;
        enq_free_list_ll_cnt     = free_list_ll_cnts[free_list_head_ll] - 'd1;
        if (free_list_ll_cnts[free_list_head_ll] > 1) begin
          enq_next_ptr_mem_rd_en   = 1;
          enq_next_ptr_mem_rd_addr = free_list_head_ptrs[free_list_head_ll];
          enq_rd_free_list_vld     = 1;
          enq_rd_ll_num            = free_list_head_ll;
        end
      end
    end
  end

  // Deq Free List Comb Section
  always_comb begin
    deq_next_ptr_mem_wr_en   = 0;
    deq_next_ptr_mem_wr_addr = 0;
    deq_next_ptr_mem_wr_data = 0;
    deq_free_list_cnt        = 0;
    deq_free_list_ll_cnt     = 0;
    deq_free_list_ll_num     = 0;
    deq_free_list_head_ptr   = 0;
    deq_free_list_tail_ptr   = 0;
    if (!init) begin
      if (deq_vld) begin
          deq_free_list_cnt        = free_list_cnt + 'd1;
          deq_free_list_ll_cnt     = free_list_ll_cnts[free_list_tail_ll] + 'd1;
          deq_free_list_ll_num     = (free_list_tail_ll < MAX_LL_NUM) ? (free_list_tail_ll + 'd1) : 'd0;
          deq_free_list_tail_ptr   = queue_head_ptrs[deq_id][queue_head_lls[deq_id]];
        if (free_list_ll_cnts[free_list_tail_ll] == 0) begin
          deq_free_list_head_ptr   = queue_head_ptrs[deq_id][queue_head_lls[deq_id]];
        end else begin
          deq_next_ptr_mem_wr_en   = 1;
          deq_next_ptr_mem_wr_addr = free_list_tail_ptrs[free_list_tail_ll];
          deq_next_ptr_mem_wr_data = queue_head_ptrs[deq_id][queue_head_lls[deq_id]];
        end
      end
    end
  end

  // Free List State Management
  always_ff@(posedge clk) begin
    if (reset) begin
      init                 <= 1;
      free_list_cnt        <= 0;
      free_list_ll_cnts    <= 0;
      free_list_head_ll    <= 0;
      free_list_tail_ll    <= 0;
    end else if (init) begin
      free_list_cnt                                  <= init_free_list_cnt;
      free_list_tail_ll                              <= init_free_list_ll_num;
      free_list_ll_cnts[free_list_tail_ll]           <= init_free_list_ll_cnt;
      free_list_tail_ptrs[free_list_tail_ll]         <= init_free_list_tail_ptr;
      if (free_list_ll_cnts[free_list_tail_ll] == 0) begin
        free_list_head_ptrs[free_list_tail_ll]       <= init_free_list_head_ptr;
      end
      if (free_list_cnt == LL_DEPTH - 1) begin
        init                                         <= 0;
      end
    end else begin
      if (enq_vld || deq_vld) begin
        if (enq_vld) begin
          free_list_cnt                            <= enq_free_list_cnt;
          free_list_ll_cnts[free_list_head_ll]     <= enq_free_list_ll_cnt;
          free_list_head_ll                        <= enq_free_list_ll_num;
        end
        else begin  // Deq_vld must be true
          free_list_cnt                                  <= deq_free_list_cnt;
          free_list_tail_ll                              <= deq_free_list_ll_num;
          free_list_ll_cnts[free_list_tail_ll]           <= deq_free_list_ll_cnt;
          free_list_tail_ptrs[free_list_tail_ll]         <= deq_free_list_tail_ptr;
          if (free_list_ll_cnts[free_list_tail_ll] == 0) begin
            free_list_head_ptrs[free_list_tail_ll]       <= deq_free_list_head_ptr;
          end
        end
      end
      if (rd_free_list_vld_buffer[READ_DELAY - 1]) begin
        free_list_head_ptrs[rd_ll_num_buffer[READ_DELAY - 1]] <= next_ptr_mem_rd_data;
      end
    end
  end

  // Ptr Mem Input Management
  assign next_ptr_mem_wr_en   = init    ? init_next_ptr_mem_wr_en :
                                enq_vld ? enq_next_ptr_mem_wr_en  :
                                deq_vld ? deq_next_ptr_mem_wr_en  :
                                          '0;
  // assign next_ptr_mem_wr_addr = init    ? init_next_ptr_mem_wr_addr : 
  //                               enq_vld ? enq_next_ptr_mem_wr_addr  : 
  //                               deq_vld ? deq_next_ptr_mem_wr_addr  : 
  //                                         '0;
  assign next_ptr_mem_wr_addr = ({ADDR_WIDTH{init}}                        & init_next_ptr_mem_wr_addr) |
                                ({ADDR_WIDTH{enq_vld}}                     & enq_next_ptr_mem_wr_addr)  |
                                ({ADDR_WIDTH{deq_vld}}                     & deq_next_ptr_mem_wr_addr)  |
                                ({ADDR_WIDTH{~init & ~enq_vld & ~deq_vld}} & ADDR_WIDTH'(0));
  assign next_ptr_mem_wr_data = ({DATA_WIDTH{init}}                        & init_next_ptr_mem_wr_data) |
                                ({DATA_WIDTH{enq_vld}}                     & enq_next_ptr_mem_wr_data)  |
                                ({DATA_WIDTH{deq_vld}}                     & deq_next_ptr_mem_wr_data)  | 
                                ({DATA_WIDTH{~init & ~enq_vld & ~deq_vld}} & DATA_WIDTH'(0));
  assign next_ptr_mem_rd_en   = enq_vld ? enq_next_ptr_mem_rd_en : 
                                deq_vld ? deq_next_ptr_mem_rd_en : 
                                          '0;
  assign next_ptr_mem_rd_addr = enq_vld ? enq_next_ptr_mem_rd_addr :
                                deq_vld ? deq_next_ptr_mem_rd_addr : 
                                          '0;

  // Data Mem Input Management
  assign data_mem_wr_en       = enq_vld ? enq_data_mem_wr_en : 0;
  assign data_mem_wr_addr     = enq_vld ? enq_data_mem_wr_addr : 0;
  assign data_mem_wr_data     = enq_vld ? enq_data_mem_wr_data : 0;
  assign data_mem_rd_en       = deq_data_mem_rd_en;
  assign data_mem_rd_addr     = deq_data_mem_rd_addr;


  // Output Management
  assign deq_data_out         = data_mem_rd_data;

  // Enq / Deq value Assignment
  assign enq_vld              = ((enq_vld_in) && !(deq_vld_in)) || (enq_vld_buf);
  assign deq_vld              = deq_vld_in;
  assign enq_id               = enq_vld_buf ? enq_id_buf   : enq_id_in;
  assign deq_id               = deq_id_in;
  assign enq_data             = enq_vld_buf ? enq_data_buf : enq_data_in;

  // Enq / Deq Buffer State Management
  always_ff@(posedge clk) begin
    if (reset) begin
      enq_vld_buf  <= 0;
    end else if (!init) begin
      enq_vld_buf  <= enq_vld_in && deq_vld_in;
      if (enq_vld_in && deq_vld_in) begin
        enq_data_buf <= enq_data_in;
        enq_id_buf   <= enq_id_in;
      end
    end
  end

  // Read Data Pipeline Management
  always_ff@(posedge clk) begin
    if (reset) begin
      rd_free_list_vld_buffer <= 0;
      rd_ll_num_buffer        <= 0;
      rd_queue_vld_buffer     <= 0;
      rd_queue_num_buffer     <= 0;
    end else if (!init) begin
      rd_free_list_vld_buffer <= {rd_free_list_vld_buffer[READ_DELAY-2:0], enq_rd_free_list_vld};
      rd_queue_vld_buffer     <= {rd_queue_vld_buffer[READ_DELAY-2:0], deq_rd_queue_vld};
      rd_ll_num_buffer        <= {rd_ll_num_buffer[READ_DELAY-2:0], ({LL_NUM_WIDTH{enq_vld}} & enq_rd_ll_num) | ({LL_NUM_WIDTH{deq_vld}} & deq_rd_ll_num)};
      rd_queue_num_buffer     <= {rd_queue_num_buffer[READ_DELAY-2:0], deq_rd_queue_num};
    end
  end
  
  // Assertions

  // State Vars
  // Track whether deq or enq was requested on last cycle
  logic                           enq_vld_in_r1;
  logic                           deq_vld_in_r1;

  // Previous Enq / Deq State Management
  always_ff@(posedge clk) begin
    if (reset) begin
      enq_vld_in_r1 <= 0;
      deq_vld_in_r1 <= 0;
    end else if (!init) begin
      enq_vld_in_r1 <= enq_vld_in;
      deq_vld_in_r1 <= deq_vld_in;
    end
  end

  always@(posedge clk) begin
    // assert (init || (!enq_vld || !deq_vld)) else $error("Tried to enqueue and dequeue on same cycle.");
    assert (reset || init || (!(enq_vld_in && enq_vld_in_r1))) else $error("Enqueue'd two cycles in a row.");
    assert (reset || init || (!(deq_vld_in && deq_vld_in_r1))) else $error("Dequeue'd two cycles in a row.");
    assert (reset || init || !(deq_vld && enq_vld)) else $error("Enqueue and dequeue collision (should not happen!).");
    assert (reset || init || (!(enq_vld && free_list_cnt == 0))) else $error("Tried to enqueue with no free addresses.");
    assert (reset || init || (!(deq_vld && queue_cnts[deq_id] == 0))) else $error("Tried to dequeue from empty linked list.");
    assert (reset || init || (!(enq_vld && free_list_ll_cnts[free_list_head_ll] == 0))) else $error("Tried to enqueue, current free list queue is empty.");
    assert (reset || init || (!(deq_vld && queue_ll_cnts[deq_id][queue_head_lls[deq_id]] == 0))) else $error("Tried to dequeue, current linked list queue is empty.");
  end

endmodule:linked_list