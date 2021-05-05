// 
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
// 

`ifndef __UVMA_RVVI_DRV_SV__
`define __UVMA_RVVI_DRV_SV__

/**
 * Component driving a Clock & Reset virtual interface (uvma_rvvi_if).
 */
class uvma_rvvi_drv_c#(int ILEN=DEFAULT_ILEN, 
                       int XLEN=DEFAULT_XLEN) extends uvm_driver#(
   .REQ(uvma_rvvi_control_seq_item_c#(ILEN,XLEN)),
   .RSP(uvma_rvvi_control_seq_item_c#(ILEN,XLEN))
);
   
   // Ugh...
   uvma_clknrst_sqr_c clknrst_sequencer;

   // Objects
   uvma_rvvi_cfg_c    cfg;
   uvma_rvvi_cntxt_c  cntxt;
   
   // TLM
   uvm_analysis_port#(uvma_rvvi_control_seq_item_c)  ap;   
   
   `uvm_component_utils_begin(uvma_rvvi_drv_c)
      `uvm_field_object(cfg  , UVM_DEFAULT)
      `uvm_field_object(cntxt, UVM_DEFAULT)
   `uvm_component_utils_end
   
   /**
    * Default constructor.
    */
   extern function new(string name="uvma_rvvi_drv", uvm_component parent=null);
   
   /**
    * 1. Ensures cfg & cntxt handles are not null.
    * 2. Builds ap.
    */
   extern virtual function void build_phase(uvm_phase phase);
   
   /**
    * Obtains the reqs from the sequence item port and calls drv_req()
    */
   extern virtual task run_phase(uvm_phase phase);

   /**
    * apply requested action to the RVVI control interface
    */
   extern virtual task drv_req(REQ req);

   extern virtual task stop_clknrst();
   extern virtual task restart_clknrst();
endclass : uvma_rvvi_drv_c

function uvma_rvvi_drv_c::new(string name="uvma_rvvi_drv", uvm_component parent=null);
   
   super.new(name, parent);
   
endfunction : new

function void uvma_rvvi_drv_c::build_phase(uvm_phase phase);
   
   super.build_phase(phase);
   
   void'(uvm_config_db#(uvma_rvvi_cfg_c)::get(this, "", "cfg", cfg));
   if (!cfg) begin
      `uvm_fatal("CFG", "Configuration handle is null")
   end
   uvm_config_db#(uvma_rvvi_cfg_c)::set(this, "*", "cfg", cfg);
   
   void'(uvm_config_db#(uvma_rvvi_cntxt_c)::get(this, "", "cntxt", cntxt));
   if (!cntxt) begin
      `uvm_fatal("CNTXT", "Context handle is null")
   end
   uvm_config_db#(uvma_rvvi_cntxt_c)::set(this, "*", "cntxt", cntxt);
   
   ap = new("ap", this);
   
endfunction : build_phase


task uvma_rvvi_drv_c::run_phase(uvm_phase phase);
   
   super.run_phase(phase);

   forever begin
      seq_item_port.get_next_item(req);
      `uvml_hrtbt()
      drv_req(req);
      ap.write(req);
      seq_item_port.item_done();
   end
   
endtask : run_phase

task uvma_rvvi_drv_c::drv_req(REQ req);
   `uvm_info("RVVIDRV", $sformatf("Driving:\n%s", req.sprint()), UVM_HIGH);
   case (req.action)
      UVMA_RVVI_STEPI: begin
         // Stop the clock, step the ISS
         stop_clknrst();
         cntxt.control_vif.stepi();
         @(cntxt.state_vif.notify);
         // Restart the clock
         restart_clknrst();
      end
      UVMA_RVVI_TRAP: begin
         // Not implemented yet
         `uvm_fatal("RVVIDRV", $sformatf("Action: %s not implemented yet", req.action.name()));
      end
      UVMA_RVVI_TRAP: begin
         // Not implemented yet
         `uvm_fatal("RVVIDRV", $sformatf("Action: %s not implemented yet", req.action.name()));
      end
   endcase

endtask : drv_req

task uvma_rvvi_drv_c::stop_clknrst();
   uvma_clknrst_stop_clk_seq_c stop_clk_seq;
   stop_clk_seq = uvma_clknrst_stop_clk_seq_c::type_id::create("stop_clk_seq");
   assert(stop_clk_seq.randomize());
   stop_clk_seq.start(clknrst_sequencer);
endtask : stop_clknrst

task uvma_rvvi_drv_c::restart_clknrst();
   uvma_clknrst_restart_clk_seq_c restart_clk_seq;
   restart_clk_seq = uvma_clknrst_restart_clk_seq_c::type_id::create("restart_clk_seq");
   assert(restart_clk_seq.randomize());
   restart_clk_seq.start(clknrst_sequencer);
endtask : restart_clknrst

`endif // __UVMA_RVVI_DRV_SV__
