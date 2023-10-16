//try to implement a jtag, a jtag2axi, a l2 mem and write data into L2 through jtag

`define PULP_JTAG_IDCODE 32'h249511C3

module jtagL2test(

    input logic                 clk_i,
    input logic                 rst_n,


    input logic                           jtag_tck_i,
    input logic                           jtag_trst_ni,
    input logic                           jtag_tms_i,
    input logic                           jtag_tdi_i,
    output logic                          jtag_tdo_o,

);
    // tap to lint wrap
    logic                  s_jtag_shift_dr;
    logic                  s_jtag_update_dr;
    logic                  s_jtag_capture_dr;
    logic                  s_jtag_axireg_sel;
    logic                  s_jtag_axireg_tdi;
    logic                  s_jtag_axireg_tdo;

    XBAR_TCDM_BUS s_lint_pulp_jtag_bus();

    jtag_tap_top  #(
        .IDCODE_VALUE             ( `PULP_JTAG_IDCODE  )
    ) jtag_tap_top_i (
        .tck_i                    ( jtag_tck_i         ),
        .trst_ni                  ( jtag_trst_ni       ),
        .tms_i                    ( jtag_tms_i         ),
        .td_i                     ( jtag_tdi_i         ),
        .td_o                     ( jtag_tdo_o         ),

        .test_clk_i               ( 1'b0               ),
        .test_rstn_i              ( rst_n         ),

        .jtag_shift_dr_o          ( s_jtag_shift_dr    ),
        .jtag_update_dr_o         ( s_jtag_update_dr   ),
        .jtag_capture_dr_o        ( s_jtag_capture_dr  ),

        .axireg_sel_o             ( s_jtag_axireg_sel  ),
        .dbg_axi_scan_in_o        ( s_jtag_axireg_tdi  ),
        .dbg_axi_scan_out_i       ( s_jtag_axireg_tdo  ),
        .soc_jtag_reg_i           (                    ),
        .soc_jtag_reg_o           (                    ),
        .sel_fll_clk_o            (                    )
    );

    lint_jtag_wrap i_lint_jtag (
        .tck_i                    ( jtag_tck_i           ),
        .tdi_i                    ( s_jtag_axireg_tdi    ),
        .trstn_i                  ( jtag_trst_ni         ),
        .tdo_o                    ( s_jtag_axireg_tdo    ),
        .shift_dr_i               ( s_jtag_shift_dr      ),
        .pause_dr_i               ( 1'b0                 ),
        .update_dr_i              ( s_jtag_update_dr     ),
        .capture_dr_i             ( s_jtag_capture_dr    ),
        .lint_select_i            ( s_jtag_axireg_sel    ),
        .clk_i                    ( clk_i            ),
        .rst_ni                   ( rst_n           ),
        .jtag_lint_master         ( s_lint_pulp_jtag_bus )
    );

    l2_ram_multi_bank #(
        .NB_BANKS              ( 1  ),
        .BANK_SIZE_INTL_SRAM   ( 64 )
    ) l2_ram_i (
        .clk_i           ( clk_i          ),
        .rst_ni          ( rst_n         ),
        .init_ni         ( 1'b1               ),
        .test_mode_i     (     ),
        .mem_slave       ( s_lint_pulp_jtag_bus),
        .mem_pri_slave   (    )
    );


endmodule