class axi4_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_monitor)

    virtual axi4_if vif;
    uvm_analysis_port #(axi4_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Monitor: virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        @(posedge vif.ACLK iff vif.ARESETn);
        fork
            monitor_writes();
            monitor_reads();
        join
    endtask

    task monitor_writes();
        forever begin
            axi4_seq_item txn = axi4_seq_item::type_id::create("mon_wr");
            txn.txn_type = axi4_seq_item::AXI_WRITE;
            @(vif.monitor_cb iff (vif.monitor_cb.AWVALID && vif.monitor_cb.AWREADY));
            txn.addr = vif.monitor_cb.AWADDR;
            @(vif.monitor_cb iff (vif.monitor_cb.WVALID && vif.monitor_cb.WREADY));
            txn.data = vif.monitor_cb.WDATA;
            txn.strb = vif.monitor_cb.WSTRB;
            @(vif.monitor_cb iff (vif.monitor_cb.BVALID && vif.monitor_cb.BREADY));
            txn.resp = vif.monitor_cb.BRESP;
            ap.write(txn);
        end
    endtask

    task monitor_reads();
        forever begin
            axi4_seq_item txn = axi4_seq_item::type_id::create("mon_rd");
            txn.txn_type = axi4_seq_item::AXI_READ;
            @(vif.monitor_cb iff (vif.monitor_cb.ARVALID && vif.monitor_cb.ARREADY));
            txn.addr = vif.monitor_cb.ARADDR;
            @(vif.monitor_cb iff (vif.monitor_cb.RVALID && vif.monitor_cb.RREADY));
            txn.rdata = vif.monitor_cb.RDATA;
            txn.resp  = vif.monitor_cb.RRESP;
            ap.write(txn);
        end
    endtask

endclass
