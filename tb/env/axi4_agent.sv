class axi4_agent extends uvm_agent;
    `uvm_component_utils(axi4_agent)

    axi4_driver  driver;
    axi4_monitor monitor;
    uvm_sequencer #(axi4_seq_item) sequencer;

    uvm_analysis_port #(axi4_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor   = axi4_monitor::type_id::create("monitor", this);
        ap        = new("ap", this);
        if (get_is_active() == UVM_ACTIVE) begin
            driver    = axi4_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer #(axi4_seq_item)::type_id::create("sequencer", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        monitor.ap.connect(ap);
        if (get_is_active() == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
