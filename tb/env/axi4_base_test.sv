class axi4_base_test extends uvm_test;
    `uvm_component_utils(axi4_base_test)

    axi4_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi4_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST", "Base test running", UVM_NONE)
        #100;
        phase.drop_objection(this);
    endtask

endclass

class axi4_rand_test extends axi4_base_test;
    `uvm_component_utils(axi4_rand_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        uvm_sequence #(axi4_seq_item) seq;
        phase.raise_objection(this);
        repeat(20) begin
            axi4_seq_item txn;
            txn = axi4_seq_item::type_id::create("txn");
            if (!txn.randomize())
                `uvm_fatal("RAND", "Randomization failed")
            `uvm_info("TEST", $sformatf("Generated: %s", txn.convert2string()), UVM_MEDIUM)
        end
        #200;
        phase.drop_objection(this);
    endtask

endclass
