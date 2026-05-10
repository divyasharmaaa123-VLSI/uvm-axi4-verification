interface axi4_if #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(input logic ACLK, input logic ARESETn);

    logic [ADDR_WIDTH-1:0]   AWADDR;
    logic [2:0]              AWPROT;
    logic                    AWVALID, AWREADY;
    logic [DATA_WIDTH-1:0]   WDATA;
    logic [DATA_WIDTH/8-1:0] WSTRB;
    logic                    WVALID, WREADY;
    logic [1:0]              BRESP;
    logic                    BVALID, BREADY;
    logic [ADDR_WIDTH-1:0]   ARADDR;
    logic [2:0]              ARPROT;
    logic                    ARVALID, ARREADY;
    logic [DATA_WIDTH-1:0]   RDATA;
    logic [1:0]              RRESP;
    logic                    RVALID, RREADY;

    clocking master_cb @(posedge ACLK);
        default input #1 output #1;
        output AWADDR, AWPROT, AWVALID;
        input  AWREADY;
        output WDATA, WSTRB, WVALID;
        input  WREADY;
        input  BRESP, BVALID;
        output BREADY;
        output ARADDR, ARPROT, ARVALID;
        input  ARREADY;
        input  RDATA, RRESP, RVALID;
        output RREADY;
    endclocking

    clocking monitor_cb @(posedge ACLK);
        default input #1;
        input AWADDR, AWPROT, AWVALID, AWREADY;
        input WDATA, WSTRB, WVALID, WREADY;
        input BRESP, BVALID, BREADY;
        input ARADDR, ARPROT, ARVALID, ARREADY;
        input RDATA, RRESP, RVALID, RREADY;
    endclocking

    modport master_mp (clocking master_cb, input ACLK, ARESETn);
    modport monitor_mp(clocking monitor_cb, input ACLK, ARESETn);

    property p_awvalid_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (AWVALID && !AWREADY) |=> AWVALID;
    endproperty
    assert property (p_awvalid_stable)
        else $error("[SVA] AWVALID deasserted before AWREADY");

    property p_wvalid_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (WVALID && !WREADY) |=> WVALID;
    endproperty
    assert property (p_wvalid_stable)
        else $error("[SVA] WVALID deasserted before WREADY");

    property p_arvalid_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (ARVALID && !ARREADY) |=> ARVALID;
    endproperty
    assert property (p_arvalid_stable)
        else $error("[SVA] ARVALID deasserted before ARREADY");

endinterface
