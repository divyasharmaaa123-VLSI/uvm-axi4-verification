class axi4_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi4_scoreboard)

    uvm_analysis_imp #(axi4_seq_item, axi4_scoreboard) analysis_export;

    logic [31:0] shadow_mem [0:15];
    int pass_count, fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
        foreach (shadow_mem[i]) shadow_mem[i] = 32'h0;
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void write(axi4_seq_item txn);
        if (txn.txn_type == axi4_seq_item::AXI_WRITE) begin
            if (txn.resp == 2'b00) begin
                int idx = txn.addr[7:2];
                for (int i = 0; i < 4; i++)
                    if (txn.strb[i])
                        shadow_mem[idx][i*8 +: 8] = txn.data[i*8 +: 8];
                `uvm_info("SB", $sformatf("WRITE PASS: addr=0x%02h data=0x%08h",
                          txn.addr, txn.data), UVM_MEDIUM)
                pass_count++;
            end else begin
                `uvm_info("SB", $sformatf("WRITE ERROR RESP (expected): addr=0x%02h",
                          txn.addr), UVM_MEDIUM)
                pass_count++;
            end
        end else begin
            int idx = txn.addr[7:2];
            if (txn.resp == 2'b10) begin
                if (txn.rdata == 32'hDEADBEEF) begin
                    `uvm_info("SB", "READ ERROR RESP PASS", UVM_MEDIUM)
                    pass_count++;
                end else begin
                    `uvm_error("SB", "READ ERROR RESP but wrong data")
                    fail_count++;
                end
            end else begin
                if (txn.rdata === shadow_mem[idx]) begin
                    `uvm_info("SB", $sformatf("READ PASS: addr=0x%02h exp=0x%08h got=0x%08h",
                              txn.addr, shadow_mem[idx], txn.rdata), UVM_MEDIUM)
                    pass_count++;
                end else begin
                    `uvm_error("SB", $sformatf("READ FAIL: addr=0x%02h exp=0x%08h got=0x%08h",
                               txn.addr, shadow_mem[idx], txn.rdata))
                    fail_count++;
                end
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", $sformatf("=== SCOREBOARD: PASS=%0d FAIL=%0d ===",
                  pass_count, fail_count), UVM_NONE)
        if (fail_count > 0)
            `uvm_fatal("SB", "TEST FAILED")
    endfunction

endclass
