module axi4_slave #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 16
)(
    input  logic                    ACLK,
    input  logic                    ARESETn,
    input  logic [ADDR_WIDTH-1:0]   AWADDR,
    input  logic [2:0]              AWPROT,
    input  logic                    AWVALID,
    output logic                    AWREADY,
    input  logic [DATA_WIDTH-1:0]   WDATA,
    input  logic [DATA_WIDTH/8-1:0] WSTRB,
    input  logic                    WVALID,
    output logic                    WREADY,
    output logic [1:0]              BRESP,
    output logic                    BVALID,
    input  logic                    BREADY,
    input  logic [ADDR_WIDTH-1:0]   ARADDR,
    input  logic [2:0]              ARPROT,
    input  logic                    ARVALID,
    output logic                    ARREADY,
    output logic [DATA_WIDTH-1:0]   RDATA,
    output logic [1:0]              RRESP,
    output logic                    RVALID,
    input  logic                    RREADY
);
    localparam RESP_OKAY   = 2'b00;
    localparam RESP_SLVERR = 2'b10;
    logic [DATA_WIDTH-1:0] reg_file [0:MEM_DEPTH-1];
    typedef enum logic [1:0] {IDLE, WDATA_WAIT, WRESP, RDATA_SEND} state_t;
    state_t wr_state, rd_state;
    logic [ADDR_WIDTH-1:0] wr_addr_lat, rd_addr_lat;
    logic addr_err_wr, addr_err_rd;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            wr_state <= IDLE; AWREADY <= 0; WREADY <= 0; BVALID <= 0; BRESP <= RESP_OKAY;
        end else case (wr_state)
            IDLE: begin
                BVALID <= 0; AWREADY <= 1; WREADY <= 0;
                if (AWVALID) begin
                    wr_addr_lat <= AWADDR;
                    addr_err_wr <= (AWADDR[ADDR_WIDTH-1:2] >= MEM_DEPTH);
                    AWREADY <= 0; wr_state <= WDATA_WAIT;
                end
            end
            WDATA_WAIT: begin
                WREADY <= 1;
                if (WVALID) begin
                    WREADY <= 0;
                    if (!addr_err_wr)
                        for (int i = 0; i < DATA_WIDTH/8; i++)
                            if (WSTRB[i]) reg_file[wr_addr_lat[ADDR_WIDTH-1:2]][i*8+:8] <= WDATA[i*8+:8];
                    BRESP <= addr_err_wr ? RESP_SLVERR : RESP_OKAY;
                    BVALID <= 1; wr_state <= WRESP;
                end
            end
            WRESP: if (BREADY) begin BVALID <= 0; wr_state <= IDLE; end
            default: wr_state <= IDLE;
        endcase
    end

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            rd_state <= IDLE; ARREADY <= 0; RVALID <= 0; RDATA <= 0; RRESP <= RESP_OKAY;
        end else case (rd_state)
            IDLE: begin
                ARREADY <= 1; RVALID <= 0;
                if (ARVALID) begin
                    rd_addr_lat <= ARADDR;
                    addr_err_rd <= (ARADDR[ADDR_WIDTH-1:2] >= MEM_DEPTH);
                    ARREADY <= 0; rd_state <= RDATA_SEND;
                end
            end
            RDATA_SEND: begin
                RVALID <= 1;
                RRESP  <= addr_err_rd ? RESP_SLVERR : RESP_OKAY;
                RDATA  <= addr_err_rd ? 32'hDEADBEEF : reg_file[rd_addr_lat[ADDR_WIDTH-1:2]];
                if (RREADY) begin RVALID <= 0; rd_state <= IDLE; end
            end
            default: rd_state <= IDLE;
        endcase
    end

    always_ff @(posedge ACLK or negedge ARESETn)
        if (!ARESETn) for (int i=0;i<MEM_DEPTH;i++) reg_file[i] <= 0;

endmodule
