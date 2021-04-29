//
// Copyright 2020 OpenHW Group
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
//

`ifndef __UVMT_CV32E40X_ISS_WRAP_SV__
`define __UVMT_CV32E40X_ISS_WRAP_SV__

/**
 * Module wrapper for Imperas OVP.
 * Instanitates "CPU", the OVP wrapper, and "RAM" a spare memory model.
 */
module uvmt_cv32e40x_iss_wrap
  #(
    parameter int ROM_START_ADDR = 'h00000000,
    parameter int ROM_BYTE_SIZE  = 'h0,
    parameter int RAM_BYTE_SIZE  = 'h1B000000,
    parameter int ID = 0
   )

   (
    input realtime            clk_period,
    uvma_clknrst_if           clknrst_if,
    uvmt_cv32e40x_step_compare_if step_compare_if,
    uvmt_cv32e40x_isa_covg_if     isa_covg_if
   );

   bit  use_iss = 0;
   bit  use_rvvi = 0;

   BUS         b1();

   MONITOR     mon(b1);
   RAM         #(
                .ROM_START_ADDR(ROM_START_ADDR),
                .ROM_BYTE_SIZE(ROM_BYTE_SIZE),
                .RAM_BYTE_SIZE(RAM_BYTE_SIZE)) ram(b1);

   CPU #(.ID(ID)) cpu(b1);

   assign b1.Clk = clknrst_if.clk;

  initial begin
    if ($test$plusargs("USE_ISS"))
      use_iss = 1;
    if ($test$plusargs("USE_RVVI"))
      use_rvvi = 1;
  end

   // monitor rvvi updates
   always @(cpu.state.notify) begin
       int i;
       step_compare_if.ovp_cpu_PCr = cpu.state.pc;
       for(i=0; i<32; i++)
           step_compare_if.ovp_cpu_GPR[i] = cpu.state.x[i];

       // generate events
       if (cpu.state.valid) begin
           // $display("Instruction Retired %08X %08X", cpu.state.pc, cpu.state.pcw);
           -> step_compare_if.ovp_cpu_valid;
       end else if (cpu.state.trap) begin
           // $display("Instruction Fault %08X %08X", cpu.state.pc, cpu.state.pcw);
           -> step_compare_if.ovp_cpu_trap;
       end
       
   end

   // monitor debug control updates
   always @(cpu.control.notify) begin
       step_compare_if.ovp_cpu_state_idle  = cpu.control.state_idle;
       step_compare_if.ovp_cpu_state_stepi = cpu.control.state_stepi;
       step_compare_if.ovp_cpu_state_stop  = cpu.control.state_stop;
       step_compare_if.ovp_cpu_state_cont  = cpu.control.state_cont;
   end

    function void split(input string in_s, output string s1, s2);
        automatic int i;
        for (i=0; i<in_s.len(); i++) begin
            if (in_s.getc(i) == ":")
                break;
         end
         if (i==0 ) begin
            $display("ERROR not : found in split '%0s'", in_s);
            $finish(-1);
         end
         s1 = in_s.substr(0,i-1);
         s2 = in_s.substr(i+1,in_s.len()-1);
    endfunction

    function automatic void sample();
        string decode = cpu.state.decode;
        string ins_str, op[4], key, val;
        int i;

        int num = $sscanf (decode, "%s %s %s %s %s", ins_str, op[0], op[1], op[2], op[3]);
        isa_covg_if.ins.ins_str = ins_str;
        isa_covg_if.ins.pc = step_compare_if.ovp_cpu_PCr;
        isa_covg_if.ins.compressed = dut_wrap.cv32e40x_wrapper_i.tracer_i.insn_compressed;
        for (i=0; i<num-1; i++) begin
            split(op[i], key, val);
            isa_covg_if.ins.ops[i].key=key;
            isa_covg_if.ins.ops[i].val=val;
        end
        `uvm_info("OVPSIM", $sformatf("Decoded instr: %s%s pc: 0x%08x",                                       
                                      isa_covg_if.ins.compressed ? "c." : "",
                                      decode,
                                      isa_covg_if.ins.pc), 
                            UVM_DEBUG)
        ->isa_covg_if.ins_valid;
    endfunction

   always @(step_compare_if.ovp_cpu_valid) begin
      if (use_iss && !use_rvvi) begin
         sample();
      end
   end

   initial begin
     clknrst_if.clk = 1'b0;
      #1;  // time for clknrst_if_dut to set the clk_period
      wait (clk_period != 0.0);
      `uvm_info("OVPWRAP", "Starting OVP clock", UVM_LOW)
      clknrst_if.set_period(clk_period);
      clknrst_if.start_clk();
   end

endmodule : uvmt_cv32e40x_iss_wrap

`endif // __UVMT_CV32E40X_ISS_WRAP_SV__

