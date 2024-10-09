module counter#(
  parameter int NUM_COUNTERS=8,
  parameter int COUNTER_WIDTH=32,
  parameter int READ_DELAY=3)
(
  input logic clk,
  input logic reset,
  input logic [$clog2(NUM_COUNTERS) - 1 : 0] cntr_addr_in,
  input logic cntr_vld_in,
  output logic [COUNTER_WIDTH - 1 : 0] cntr_val_out,
  output logic cntr_val_vld,
  output logic init_done
);

  localparam int ADDR_WIDTH = $clog2(NUM_COUNTERS);

  logic wr_en, rd_en;
  logic [ADDR_WIDTH - 1 : 0] wr_addr, rd_addr;
  logic [COUNTER_WIDTH - 1 : 0] wr_data_in, rd_data_out;

  logic [READ_DELAY : 1][ADDR_WIDTH - 1 : 0] addr_bypass;
  logic [READ_DELAY : 1][COUNTER_WIDTH - 1 : 0] data_bypass;
  logic [READ_DELAY : 1] bypass_vld;
  logic [READ_DELAY : 1][ADDR_WIDTH - 1 : 0] rd_addr_r;
  logic [READ_DELAY : 1] cntr_vld_r;

  logic bypass_hit;
  logic [COUNTER_WIDTH - 1 : 0] bypass_val;
  logic init;

  logic [ADDR_WIDTH - 1 : 0] init_idx;
  

  // Instantiate design
  memory #(.MEM_DEPTH(NUM_COUNTERS), .DATA_WIDTH(COUNTER_WIDTH), .DELAY_CYCLES(READ_DELAY)) memory(
    .clk(clk),
    .reset(reset),
    .wr_en(wr_en),
    .wr_addr(wr_addr),
    .wr_data(wr_data_in),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .rd_data(rd_data_out)
  );


  // Init Section
  always_ff@(posedge clk) begin
    if (reset) begin
      init     <= 1;
      init_idx <= 0;
    end else if (init) begin
      if (init_idx == NUM_COUNTERS - 1) begin
        init <= 0;
      end
      init_idx <= init_idx + 1;
    end
  end
  

  // Non-init Section
  always_ff@(posedge clk) begin
    assert (reset || cntr_addr_in < NUM_COUNTERS) else $error("Counter address out of bounds.");
    if (reset) begin
      cntr_vld_r <= 0;
    end else if (!init) begin

      // Shift the counter valid and bypass valid vectors left by one.
      // Shift each valid bypass vector index left by one.
      // Shift each valid read address vector index left by one.
      for (int i = 2; i <= READ_DELAY; i++) begin
        bypass_vld[i] <= bypass_vld[i-1];
        if (bypass_vld[i-1]) begin
          addr_bypass[i] <= addr_bypass[i-1];
          data_bypass[i] <= data_bypass[i-1];
        end
        cntr_vld_r[i] <= cntr_vld_r[i-1];
        if (cntr_vld_r[i-1]) begin
          rd_addr_r[i] <= rd_addr_r[i-1];
        end
      end

      // Shift last counter valid vector index into bypass valid vector
      // Shift counter valid input into counter valid vector
      bypass_vld[1] <= cntr_vld_r[READ_DELAY];
      rd_en         <= cntr_vld_in;
      cntr_vld_r[1] <= rd_en;

      if (cntr_vld_r[READ_DELAY]) begin
        addr_bypass[1] <= rd_addr_r[READ_DELAY];
        data_bypass[1] <= wr_data_in;
      end
      if (cntr_vld_in) begin
        rd_addr      <= cntr_addr_in;
      end
      if (rd_en) begin
        rd_addr_r[1] <= rd_addr;
      end

    end
  end

  // Assign statements
  assign wr_en        = cntr_vld_r[READ_DELAY] || (init && !reset);
  assign wr_data_in   = init ? 0 : bypass_hit ? bypass_val + 1 : rd_data_out + 1;
  assign cntr_val_out = wr_en ? wr_data_in : 0;
  assign cntr_val_vld = wr_en && !init;
  assign wr_addr      = init ? init_idx : rd_addr_r[READ_DELAY];
  assign init_done    = !init;

  always_comb begin
    bypass_hit = 0;
    bypass_val = 0;
    for (int i = READ_DELAY; i >= 1; i--) begin
      if (addr_bypass[i] == rd_addr_r[READ_DELAY] && cntr_vld_r[READ_DELAY] && bypass_vld[i]) begin
        bypass_hit = 1;
        bypass_val = data_bypass[i];
      end
    end
  end
    








endmodule:counter