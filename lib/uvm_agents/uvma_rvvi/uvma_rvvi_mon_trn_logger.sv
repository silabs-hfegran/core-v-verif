// Copyright 2020 OpenHW Group
// Copyright 2020 Datum Technology Corporation
// Copyright 2020 Silicon Labs, Inc.
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


`ifndef __UVMA_RVVI_MON_TRN_LOGGER_SV__
`define __UVMA_RVVI_MON_TRN_LOGGER_SV__

`uvm_analysis_imp_decl(_rvvi_state)

/**
 * Component writing Rvvi monitor transactions rvvi data to disk as plain text.
 */
class uvma_rvvi_mon_trn_logger_c#(int ILEN=DEFAULT_ILEN,
                                  int XLEN=DEFAULT_XLEN) extends uvml_logs_mon_trn_logger_c#(
   .T_TRN  (uvml_trn_seq_item_c         ),
   .T_CFG  (uvma_rvvi_cfg_c#(ILEN,XLEN) ),
   .T_CNTXT(uvma_rvvi_cntxt_c#(ILEN,XLEN))
);
      
   uvm_analysis_imp_rvvi_state#(uvma_rvvi_state_seq_item_c, uvma_rvvi_mon_trn_logger_c) state_export;

   `uvm_component_utils(uvma_rvvi_mon_trn_logger_c)
   
   /**
    * Default constructor.
    */
   function new(string name="uvma_rvvi_mon_trn_logger", uvm_component parent=null);
      
      super.new(name, parent);
      
      state_export = new("state_export", this);
   endfunction : new
   
   /**
    * Writes contents of t to disk
    */
   virtual function void write(uvml_trn_seq_item_c t);
      //fwrite($sformatf("%t: %s: %s", $time, agent_name, t.convert2string()));
   endfunction : write
   
   virtual function void write_rvvi_state(uvma_rvvi_state_seq_item_c t);      
      fwrite($sformatf("%t: %s: %s", $time, agent_name, t.convert2string));
   endfunction : write_rvvi_state

   /**
    * Writes log header to disk
    */
   virtual function void print_header();
      
      // TODO Implement uvma_rvvi_mon_trn_logger_c::print_header()
      // Ex: fwrite("----------------------------------------------");
      //     fwrite(" TIME | FIELD A | FIELD B | FIELD C | FIELD D ");
      //     fwrite("----------------------------------------------");
      
   endfunction : print_header
   
endclass : uvma_rvvi_mon_trn_logger_c


/**
 * Component writing RVVI monitor transactions rvvi data to disk as JavaScript Object Notation (JSON).
 */
class uvma_rvvi_mon_trn_logger_json_c extends uvma_rvvi_mon_trn_logger_c;
   
   `uvm_component_utils(uvma_rvvi_mon_trn_logger_json_c)
   
   
   /**
    * Set file extension to '.json'.
    */
   function new(string name="uvma_rvvi_mon_trn_logger_json", uvm_component parent=null);
      
      super.new(name, parent);
      fextension = "json";
      
   endfunction : new
   
   /**
    * Writes contents of t to disk.
    */
   virtual function void write(uvml_trn_seq_item_c t);
      
   endfunction : write
   
   /**
    * Empty function.
    */
   virtual function void print_header();
      
      // Do nothing: JSON files do not use headers.
      
   endfunction : print_header
   

endclass : uvma_rvvi_mon_trn_logger_json_c


`endif // __UVMA_RVVI_MON_TRN_LOGGER_SV__
