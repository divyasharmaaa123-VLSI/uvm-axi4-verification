`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic ACLK;
    logic ARESETn;

    // Clock generation
    initial ACLK = 0;
    always #5 ACLK = ~ACLK;

    // Reset generation
    initial begin
        ARESETn = 0;
        repeat(5) @(posedge ACLK);
        ARESETn = 1;
    end

    // Interface instance
    axi4_if #(.ADDR_WIDTH(8), .DATA_WIDTH(32)) axi_if (
        .ACLK(ACLK),
        .ARESETn(ARESETn)
    );

    // DUT instance
    axi4_slave #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32),
        .MEM_DEPTH(16)
    ) dut (
        .ACLK       (ACLK),
        .ARESETn    (ARESETn),
        .AWADDR     (axi_if.AWADDR),
        .AWPROT     (axi_if.AWPROT),
        .AWVALID    (axi_if.AWVALID),
        .AWREADY    (axi_if.AWREADY),
        .WDATA      (axi_if.WDATA),
        .WSTRB      (axi_if.WSTRB),
        .WVALID     (axi_if.WVALID),
        .WREADY     (axi_if.WREADY),
        .BRESP      (axi_if.BRESP),
        .BVALID     (axi_if.BVALID),
        .BREADY     (axi_if.BREADY),
        .ARADDR     (axi_if.ARADDR),
        .ARPROT     (axi_if.ARPROT),
        .ARVALID    (axi_if.ARVALID),
        .ARREADY    (axi_if.ARREADY),
        .RDATA      (axi_if.RDATA),
        .RRESP      (axi_if.RRESP),
        .RVALID     (axi_if.RVALID),
        .RREADY     (axi_if.RREADY)
    );

    // UVM config and start
    initial begin
        uvm_config_db #(virtual axi4_if)::set(null, "uvm_test_top.*", "vif", axi_if);
        run_test("axi4_rand_test");
    end

    // Timeout watchdog
    initial begin
        #1000000;
        `uvm_fatal("TIMEOUT", "Simulation timeout!")
    end

endmodule
