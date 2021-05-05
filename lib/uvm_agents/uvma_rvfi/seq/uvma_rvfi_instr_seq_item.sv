// Copyright 2020 OpenHW Group
// Copyright 2020 Datum Technology Corporation
// 
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     https://solderpad.org/licenses/
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


`ifndef __UVMA_RVFI_INSTR_SEQ_ITEM_SV__
`define __UVMA_RVFI_INSTR_SEQ_ITEM_SV__


/**
 * Object created by Rvfi agent sequences extending uvma_rvfi_seq_base_c.
 */
class uvma_rvfi_instr_seq_item_c#(int ILEN=DEFAULT_ILEN,
                                  int XLEN=DEFAULT_XLEN) extends uvml_trn_seq_item_c;

   rand int unsigned             nret_id;
   rand bit [ORDER_WL-1:0]       order;
   rand bit [ILEN-1:0]           insn;
   rand bit                      trap;
   rand bit                      halt;
   rand bit                      intr;
   rand bit [MAX_INTR_ID_WL-1:0] intr_id;
   rand uvma_rvfi_mode           mode;
   rand bit [IXL_WL-1:0]         ixl;

   rand bit [XLEN-1:0]           pc_rdata;
   rand bit [XLEN-1:0]           pc_wdata;

   rand bit [GPR_ADDR_WL-1:0]    rs1_addr;
   rand bit [XLEN-1:0]           rs1_rdata;

   rand bit [GPR_ADDR_WL-1:0]    rs2_addr;
   rand bit [XLEN-1:0]           rs2_rdata;      

   rand bit [GPR_ADDR_WL-1:0]    rs3_addr;
   rand bit [XLEN-1:0]           rs3_rdata;    

   rand bit [GPR_ADDR_WL-1:0]    rd1_addr;
   rand bit [XLEN-1:0]           rd1_wdata;  

   rand bit [GPR_ADDR_WL-1:0]    rd2_addr;
   rand bit [XLEN-1:0]           rd2_wdata;      

   rand bit [XLEN-1:0]           mem_addr;
   rand bit [XLEN-1:0]           mem_rdata;
   rand bit [XLEN-1:0]           mem_rmask;
   rand bit [XLEN-1:0]           mem_wdata;
   rand bit [XLEN-1:0]           mem_wmask;

   static protected string _log_format_string = "0x%08x %s 0x%01x 0x%08x";

   `uvm_object_utils_begin(uvma_rvfi_instr_seq_item_c)
      `uvm_field_int(order, UVM_DEFAULT)
      `uvm_field_int(insn, UVM_DEFAULT)
      `uvm_field_int(trap, UVM_DEFAULT)
      `uvm_field_int(halt, UVM_DEFAULT)
      `uvm_field_int(intr, UVM_DEFAULT)
      `uvm_field_int(intr_id, UVM_DEFAULT)
      `uvm_field_enum(uvma_rvfi_mode, mode, UVM_DEFAULT)
      `uvm_field_int(ixl, UVM_DEFAULT)
      `uvm_field_int(pc_rdata, UVM_DEFAULT)
      `uvm_field_int(pc_wdata, UVM_DEFAULT)
      `uvm_field_int(rs1_addr, UVM_DEFAULT)
      `uvm_field_int(rs1_rdata, UVM_DEFAULT)
      `uvm_field_int(rs2_addr, UVM_DEFAULT)
      `uvm_field_int(rs2_rdata, UVM_DEFAULT)
      `uvm_field_int(rs3_addr, UVM_DEFAULT)
      `uvm_field_int(rs3_rdata, UVM_DEFAULT)
      `uvm_field_int(rd1_addr, UVM_DEFAULT)
      `uvm_field_int(rd1_wdata, UVM_DEFAULT)
      `uvm_field_int(rd2_addr, UVM_DEFAULT)
      `uvm_field_int(rd2_wdata, UVM_DEFAULT)
      `uvm_field_int(mem_addr, UVM_DEFAULT)
      `uvm_field_int(mem_rmask, UVM_DEFAULT)
      `uvm_field_int(mem_rdata, UVM_DEFAULT)
      `uvm_field_int(mem_wmask, UVM_DEFAULT)
      `uvm_field_int(mem_wdata, UVM_DEFAULT)      
   `uvm_object_utils_end
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_rvfi_seq_item");

   /**
    * One-liner log message
    */
   extern function string convert2string();

endclass : uvma_rvfi_instr_seq_item_c

`pragma protect begin

function uvma_rvfi_instr_seq_item_c::new(string name="uvma_rvfi_seq_item");
   
   super.new(name);
   
endfunction : new

function string uvma_rvfi_instr_seq_item_c::convert2string();
   convert2string = $sformatf("Order: %0d, insn: 0x%0x, pc: 0x%08x, nret_id: %0d, mode: %s, ixl: 0x%01x", 
                              order, insn, pc_rdata, this.nret_id, mode.name(), ixl);
   if (rs1_addr)
      convert2string = $sformatf("%s rs1 RD: x%0d = 0x%08x", convert2string, rs1_addr, rs1_rdata);
   if (rs2_addr)
      convert2string = $sformatf("%s rs2 RD: x%0d = 0x%08x", convert2string, rs2_addr, rs2_rdata);
   if (rs3_addr)
      convert2string = $sformatf("%s rs3 RD: x%0d = 0x%08x", convert2string, rs3_addr, rs3_rdata);
   if (rd1_addr)
      convert2string = $sformatf("%s rd WR: x%0d = 0x%08x", convert2string, rd1_addr, rd1_wdata);
   if (rd2_addr)
      convert2string = $sformatf("%s rd WR: x%0d = 0x%08x", convert2string, rd2_addr, rd2_wdata);
   if (trap)
      convert2string = $sformatf("%s TRAP", convert2string);
   if (halt)
      convert2string = $sformatf("%s HALT", convert2string);
   if (intr)
      convert2string = $sformatf("%s INTR: 0x%0x", convert2string, intr_id);
endfunction : convert2string

`pragma protect end


`endif // __UVMA_RVFI_SEQ_ITEM_SV__
