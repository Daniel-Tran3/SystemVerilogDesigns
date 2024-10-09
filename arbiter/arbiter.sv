module arbiter#(parameter REQ_WIDTH = 4)
(
  input logic [REQ_WIDTH - 1 : 0] req,
  input logic clk,
  input logic reset,
  output logic [REQ_WIDTH - 1 : 0] gnt
);

  logic [REQ_WIDTH - 1 : 0] one_hot_state;
  logic [$clog2(REQ_WIDTH) - 1 : 0] enc_state;
  logic [$clog2(REQ_WIDTH) - 1 : 0] next_state;
  wire [REQ_WIDTH - 1 : 0] mask;
  wire [REQ_WIDTH - 1 : 0] thermometer_req;
  logic [REQ_WIDTH - 1 : 0] req_mask;

  always_ff@(posedge clk) begin
    if (reset) begin
      enc_state <= REQ_WIDTH - 1;
    end else begin
      enc_state <= next_state;
    end
  end

  assign one_hot_state = enc_to_one_hot(enc_state);
  assign mask[0] = one_hot_state[0];
  assign mask[REQ_WIDTH - 1 : 1] = mask[REQ_WIDTH - 2 : 0] | one_hot_state[REQ_WIDTH - 1 : 1];
  assign thermometer_req[0] = req[0];
  assign thermometer_req[REQ_WIDTH - 1 : 1] = thermometer_req[REQ_WIDTH - 2 : 0] | req[REQ_WIDTH - 1 : 1];
  assign req_mask = req & (mask << 1);

  always_comb begin
    gnt = 'd0;
    if (req == 0) begin
      next_state = enc_state;
    end else begin
      if (req_mask != 0) begin
        gnt = ff1(req_mask);
      end else begin
        gnt = ff1(thermometer_req);
      end
      next_state = one_hot_to_enc(gnt);
    end
  end


  // Takes as input a state and returns the or_vec corresponding to that state
  function logic[REQ_WIDTH - 1 : 0] enc_to_one_hot(logic[$clog2(REQ_WIDTH) - 1 : 0] enc_state);
    begin
      logic[REQ_WIDTH - 1 : 0] one_hot_holder;
      one_hot_holder = 'd0;
      one_hot_holder[enc_state] = 'b1;
      enc_to_one_hot = one_hot_holder;
    end
  endfunction

  function logic[$clog2(REQ_WIDTH) - 1 : 0] one_hot_to_enc(logic[REQ_WIDTH - 1 : 0] one_hot_state);
    begin
      logic[$clog2(REQ_WIDTH) - 1 : 0] enc_holder;
      enc_holder = 'd0;
      for (int i = 0; i < REQ_WIDTH; i++) begin
        if (one_hot_state[i]) begin
          enc_holder = i;
        end
      end
      one_hot_to_enc = enc_holder;
    end
  endfunction


  // Goes from LSB to MSB, creates thermometer vector from first 1
  // function logic[REQ_WIDTH - 1 : 0] or_vec(logic[REQ_WIDTH - 1 : 0] or_vec_input);
  //   begin
  //     logic[REQ_WIDTH - 1 : 0] or_vec_holder;
  //     or_vec_holder[0] = or_vec_input[0];
  //     or_vec_holder[REQ_WIDTH - 1 : 1] = or_vec_holder[REQ_WIDTH - 2 : 0] | or_vec_input[REQ_WIDTH - 1 : 1];
      // for (int i = 1; i < REQ_WIDTH; i++) begin
      //   or_vec_holder[i] = or_vec_holder[i-1] | or_vec_input[i];
      // end
  //     or_vec = or_vec_holder;
  //   end
  // endfunction

  // Finds the first 1, prioritizing LSB over MSB
  function logic[REQ_WIDTH - 1 : 0] ff1(logic[REQ_WIDTH - 1 : 0] ff1_input);
    begin
      logic[REQ_WIDTH - 1 : 0] ff1_holder;
      ff1_holder = ff1_input & ~((ff1_input) << 1);
      ff1 = ff1_holder;
    end
  endfunction


endmodule:arbiter