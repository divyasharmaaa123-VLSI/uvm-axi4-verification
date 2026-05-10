class axi4_driver extends uvm_driver #(axi4_seq_item);
    `uvm_component_utils(axi4_driver)

    virtual axi4_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Driver: virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        axi4_seq_item txn;
        reset_signals();
        @(posedge vif.ACLK iff vif.ARESETn);
        forever begin
            seq_item_port.get_next_item(txn);
            drive(txn);
            seq_item_port.item_done();
        end
    endtask

    task reset_signals();
        vif.master_cb.AWVALID <= 0;
        vif.master_cb.WVALID  <= 0;
        vif.master_cb.BREADY  <= 0;
        vif.master_cb.ARVALID <= 0;
        vif.master_cb.RREADY  <= 0;
        vif.master_cb.AWADDR  <= '0;
        vif.master_cb.WDATA   <= '0;
        vif.master_cb.WSTRB   <= '0;
        vif.master_cb.ARADDR  <= '0;
    endtask

    task drive(axi4_seq_item txn);
        if (txn.txn_type == axi4_seq_item::AXI_WRITE)
            do_write(txn);
        else
            do_read(txn);
    endtask

    task do_write(axi4_seq_item txn);
        @(vif.master_cb);
        vif.master_cb.AWADDR  <= txn.addr;
        vif.master_cb.AWVALID <= 1;
        @(vif.master_cb iff vif.master_cb.AWREADY);
        vif.master_cb.AWVALID <= 0;
        vif.master_cb.WDATA   <= txn.data;
        vif.master_cb.WSTRB   <= txn.strb;
        vif.master_cb.WVALID  <= 1;
        @(vif.master_cb iff vif.master_cb.WREADY);
        vif.master_cb.WVALID  <= 0;
        vif.master_cb.BREADY  <= 1;
        @(vif.master_cb iff vif.master_cb.BVALID);
        txn.resp               = vif.master_cb.BRESP;
        vif.master_cb.BREADY  <= 0;
        `uvm_info("DRV", txn.convert2string(), UVM_MEDIUM)
    endtask

    task do_read(axi4_seq_item txn);
        @(vif.master_cb);
        vif.master_cb.ARADDR  <= txn.addr;
        vif.master_cb.ARVALID <= 1;
        @(vif.master_cb iff vif.master_cb.ARREADY);
        vif.master_cb.ARVALID <= 0;
        vif.master_cb.RREADY  <= 1;
        @(vif.master_cb iff vif.master_cb.RVALID);
        txn.rdata              = vif.master_cb.RDATA;
        txn.resp               = vif.master_cb.RRESP;
        vif.master_cb.RREADY  <= 0;
        `uvm_info("DRV", txn.convert2string(), UVM_MEDIUM)
    endtask

endclass
