class axi4_seq_item extends uvm_sequence_item;
    `uvm_object_utils(axi4_seq_item)

    typedef enum {AXI_WRITE, AXI_READ} txn_type_e;

    rand txn_type_e  txn_type;
    rand logic [7:0] addr;
    rand logic [31:0] data;
    rand logic [3:0]  strb;
         logic [1:0]  resp;
         logic [31:0] rdata;

    constraint c_addr_align { addr[1:0] == 2'b00; }
    constraint c_addr_range  { addr[7:2] inside {[0:15]}; }
    constraint c_strb_valid  { strb inside {4'b1111, 4'b0011, 4'b1100,
                                             4'b0001, 4'b0010, 4'b0100, 4'b1000}; }
    constraint c_txn_dist    { txn_type dist {AXI_WRITE := 60, AXI_READ := 40}; }

    function new(string name = "axi4_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("[AXI4] %s addr=0x%02h data=0x%08h strb=%04b resp=%02b rdata=0x%08h",
                         txn_type.name(), addr, data, strb, resp, rdata);
    endfunction

    function void do_copy(uvm_object rhs);
        axi4_seq_item rhs_;
        if (!$cast(rhs_, rhs)) `uvm_fatal("CAST","Type mismatch")
        super.do_copy(rhs);
        txn_type = rhs_.txn_type;
        addr     = rhs_.addr;
        data     = rhs_.data;
        strb     = rhs_.strb;
        resp     = rhs_.resp;
        rdata    = rhs_.rdata;
    endfunction

endclass
