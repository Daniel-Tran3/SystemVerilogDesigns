# SystemVerilogDesigns
Various SystemVerilog modules, such as a memory module, a round-robin arbiter, a parameterizable counter, and a parameterizable shared-buffer design.

The memory module acts as an SRAM.
The counter and shared-buffer design both utilize the SRAM memory module.

The shared-buffer design uses a linked-list implementation and allows 1 enqueue and 1 dequeue every two cycles.
