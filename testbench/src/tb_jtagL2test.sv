module tb_jtagL2test;

    parameter   REF_CLK_PERIOD = 30517ns;

    parameter   WRITE_ADDR = 32'h0000_0000;

    wire    w_clk;
    wire    w_rst_n;

    wire    w_jtag_tck_i;
    wire    w_jtag_trst_ni;
    wire    w_jtag_tms_i;
    wire    w_jtag_tdi_i;
    wire    w_jtag_tdo_o;

    logic [255:0][31:0]   jtag_data;
    logic [8:0] jtag_conf_reg, jtag_conf_rego; //22bits but actually only the last 9bits are used
    
    logic                 s_trstn = 1'b0;
    logic                 s_tck   = 1'b0;
    logic                 s_tdi   = 1'b0;
    logic                 s_tms   = 1'b0;
    logic                 s_tdo;
    logic                 tmp_tdo;

    logic                 s_rst_n;

    jtag_pkg::test_mode_if_t   test_mode_if = new;
    pulp_tap_pkg::pulp_tap_if_soc_t pulp_tap = new;

    jtagL2test i_jtagL2test(

    .clk_i          (w_clk),
    .rst_n          (w_rst_n),


    .jtag_tck_i     (w_jtag_tck_i),
    .jtag_trst_ni   (w_jtag_trst_ni),
    .jtag_tms_i     (w_jtag_tms_i),
    .jtag_tdi_i     (w_jtag_tdi_i),
    .jtag_tdo_o     (w_jtag_tdo_o)

    );

    always_comb begin 
       tmp_tdo = w_jtag_tdo_o;
    end

    assign  s_tdo = tmp_tdo;

    assign  w_jtag_tck_i    = s_tck;
    assign  w_jtag_trst_ni  = s_trstn;
    assign  w_jtag_tms_i    = s_tms;
    assign  w_jtag_tdi_i    = s_tdi;

    assign  w_rst_n         = s_rst_n;

    tb_clk_gen #( .CLK_PERIOD(REF_CLK_PERIOD) ) i_ref_clk_gen (.clk_o(w_clk) );

    initial begin

        // jtag reset needed anyway
        s_rst_n = 1'b0;
        jtag_pkg::jtag_reset(s_tck, s_tms, s_trstn, s_tdi);
        jtag_pkg::jtag_softreset(s_tck, s_tms, s_trstn, s_tdi);
        #5us;

        jtag_pkg::jtag_bypass_test(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
        #5us;

        jtag_pkg::jtag_get_idcode(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
        #5us;

        test_mode_if.init(s_tck, s_tms, s_trstn, s_tdi);

        jtag_conf_reg = {1'b0, 4'b0, 3'b001, 1'b0};//stim from jtag
        test_mode_if.set_confreg(jtag_conf_reg, jtag_conf_rego,
            s_tck, s_tms, s_trstn, s_tdi, s_tdo);

        $display("[TB] %t - jtag_conf_reg set to %x", $realtime, jtag_conf_reg);

        $display("[TB] %t - Releasing hard reset", $realtime);
        s_rst_n = 1'b1;

        pulp_tap.init(s_tck, s_tms, s_trstn, s_tdi);
        $display("[TB] %t - Init PULP TAP", $realtime);

        pulp_tap.write32(WRITE_ADDR, 1, 32'hABBAABBA,
            s_tck, s_tms, s_trstn, s_tdi, s_tdo);

        $display("[TB] %t - Write32 PULP TAP", $realtime);

        #50us;
        pulp_tap.read32(WRITE_ADDR, 1, jtag_data,
            s_tck, s_tms, s_trstn, s_tdi, s_tdo);

        if(jtag_data[0] != 32'hABBAABBA)
            $display("[JTAG] R/W test of L2 failed: %h != %h", jtag_data[0], 32'hABBAABBA);
        else
            $display("[JTAG] R/W test of L2 succeeded");
        
    end

endmodule