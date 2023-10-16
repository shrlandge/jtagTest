// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`define SOC_MEM_MAP_TCDM_START_ADDR          32'h1C01_0000
`define SOC_MEM_MAP_TCDM_END_ADDR            32'h1C09_0000
`define SOC_MEM_MAP_TCDM_ALIAS_START_ADDR    32'h0000_0000
`define SOC_MEM_MAP_TCDM_ALIAS_END_ADDR      32'h0010_0000

`define SOC_MEM_MAP_PRIVATE_BANK0_START_ADDR 32'h1C00_0000
`define SOC_MEM_MAP_PRIVATE_BANK0_END_ADDR   32'h1C00_8000

`define SOC_MEM_MAP_PRIVATE_BANK1_START_ADDR 32'h1C00_8000
`define SOC_MEM_MAP_PRIVATE_BANK1_END_ADDR   32'h1C01_0000

`define SOC_MEM_MAP_BOOT_ROM_START_ADDR      32'h1A00_0000
`define SOC_MEM_MAP_BOOT_ROM_END_ADDR        32'h1A04_0000

`define SOC_MEM_MAP_AXI_PLUG_START_ADDR      32'h1000_0000
`define SOC_MEM_MAP_AXI_PLUG_END_ADDR        32'h1040_0000

`define SOC_MEM_MAP_PERIPHERALS_START_ADDR   32'h1A10_0000
`define SOC_MEM_MAP_PERIPHERALS_END_ADDR     32'h1A40_0000


module l2_ram_multi_bank #(
   parameter NB_BANKS                   = 4,
   parameter int unsigned BANK_SIZE_INTL_SRAM = 32768 //Number of 32-bit words
) (
   input logic             clk_i,
   input logic             rst_ni,
   input logic             init_ni,
   input logic             test_mode_i,
   XBAR_TCDM_BUS.Slave     mem_slave[NB_BANKS]
);
    localparam int unsigned BANK_SIZE_PRI0       = 8192; //Number of 32-bit words
    localparam int unsigned BANK_SIZE_PRI1       = 8192; //Number of 32-bit words

    //Derived parameters
    localparam int unsigned INTL_MEM_ADDR_WIDTH = $clog2(BANK_SIZE_INTL_SRAM);
    localparam int unsigned PRI0_MEM_ADDR_WIDTH = $clog2(BANK_SIZE_PRI0);
    localparam int unsigned PRI1_MEM_ADDR_WIDTH = $clog2(BANK_SIZE_PRI1);

    //Used in testbenches



    //INTERLEAVED Memory
    logic [31:0]           interleaved_addresses[NB_BANKS];
    for(genvar i=0; i<NB_BANKS; i++) begin : CUTS
        //Perform TCDM handshaking for constant 1 cycle latency
        assign mem_slave[i].gnt = mem_slave[i].req;
        assign mem_slave[i].r_opc = 1'b0;
        always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                mem_slave[i].r_valid <= 1'b0;
            end else begin
                mem_slave[i].r_valid <= mem_slave[i].req;
            end
        end
       //Remove Address offset
       assign interleaved_addresses[i] = mem_slave[i].add - `SOC_MEM_MAP_TCDM_START_ADDR;

       tc_sram #(
         .NumWords  ( BANK_SIZE_INTL_SRAM ),
         .DataWidth ( 32                  ),
         .NumPorts  ( 1                   )
       ) bank_i (
         .clk_i,
         .rst_ni,
         .req_i   (  mem_slave[i].req                                  ),
         .we_i    ( ~mem_slave[i].wen                                  ),
         .addr_i  (  interleaved_addresses[i][INTL_MEM_ADDR_WIDTH+2+$clog2(NB_BANKS)-1:2+$clog2(NB_BANKS)] ), // Remove LSBs for byte addressing (2 bits)
                                                                                                              // and bank selection (log2(NB_BANKS) bits)
         .wdata_i (  mem_slave[i].wdata                                ),
         .be_i    (  mem_slave[i].be                                   ),
         .rdata_o (  mem_slave[i].r_rdata                              )
       );

   end


endmodule // l2_ram_multi_bank
