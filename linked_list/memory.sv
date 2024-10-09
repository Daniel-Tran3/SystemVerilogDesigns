module memory#(
  parameter int MEM_DEPTH=8, 
  parameter int DATA_WIDTH=32, 
  parameter int DELAY_CYCLES=3)
(
  input logic clk,
  input logic reset,
  input logic wr_en,
  input logic [$clog2(MEM_DEPTH) - 1 : 0] wr_addr,
  input logic [DATA_WIDTH - 1 : 0] wr_data,
  input logic rd_en,
  input logic [$clog2(MEM_DEPTH) - 1 : 0] rd_addr,
  output logic [DATA_WIDTH - 1 : 0] rd_data
);


  localparam int ADDR_WIDTH = $clog2(MEM_DEPTH);

  logic [MEM_DEPTH - 1 : 0][DATA_WIDTH - 1 : 0] mem;
  logic [DELAY_CYCLES - 1 : 0][DATA_WIDTH - 1 : 0] rd_data_buf;
  

  always_ff@(posedge clk) begin
    assert (wr_addr < MEM_DEPTH || wr_addr === {ADDR_WIDTH{1'bx}}) else $error("Write address %b out of bounds.", wr_addr);
    assert (rd_addr < MEM_DEPTH || rd_addr === {ADDR_WIDTH{1'bx}}) else $error("Read address %b out of bounds.", rd_addr);

    if (reset) begin
      for (int i = 0; i < DELAY_CYCLES; i++) begin
        rd_data_buf[i] <= {DATA_WIDTH{1'bx}};
      end
      for (int i = 0; i < MEM_DEPTH; i++) begin
        mem[i] <= {DATA_WIDTH{1'b0}};
      end
    end else begin
      for (int i = 1; i < DELAY_CYCLES; i++) begin
        rd_data_buf[i] <= rd_data_buf[i-1];
      end
      if (wr_en) begin
        mem[wr_addr] <= wr_data;
      end
      rd_data <= rd_data_buf[DELAY_CYCLES - 1];
    end
  end

  always_comb begin
    if (rd_en && !(wr_en && (wr_addr == rd_addr))) begin
      rd_data_buf[0] = mem[rd_addr];
    end else begin
      rd_data_buf[0] = {DATA_WIDTH{1'bx}};
    end
  end

endmodule:memory