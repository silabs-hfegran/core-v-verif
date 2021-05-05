
import "DPI-C" initialize_simulator = function void handcar_initialize_simulator(input string options);
import "DPI-C" step_simulator = function int handcar_step_simulator(input int target_id, input int num_steps, input int stx_failed);
import "DPI-C" simulator_load_elf = function int handcar_simulator_load_elf(input int target_id, input string elf_path);
import "DPI-C" read_simulator_register = function int handcar_read_simulator_register(input int target_id,
                                                                                      input string reg_name,
                                                                                      output bit [127:0] reg_data,
                                                                                      input int length);
import "DPI-C" write_simulator_register = function int handcar_write_simulator_register(input int target_id,
                                                                                        input string reg_name,
                                                                                        input bit [127:0] reg_data,
                                                                                        input int length);
import "DPI-C" get_disassembly_for_target = function int handcar_get_disassembly_for_target(input int target_id,
                                                                                            input bit[63:0] pc,
                                                                                            inout string opcode,
                                                                                            inout string disassembly);

module uvmt_cv32e40x_rvvi_handcar
  import uvm_pkg::*;
  (    
    input clk,
    input reset_n
  );

  localparam SUCCESS = 0;
  localparam FAILED = 1;

  RVVI_control control_if();
  RVVI_state   state_if();

  bit [127:0] pc;
  bit [31:0] x[32];
  string opcode;
  string disassembly;
  int retval;


  string info_tag = "RVVIHANDCAR";
  string elf_file;

  initial begin
    if (!$value$plusargs("elf_file=%s", elf_file)) begin
      `uvm_fatal(info_tag, "%m: Must specify an elf file with +elf_file");
    end
    
    handcar_initialize_simulator("-p1 --hartids=0");
    if (handcar_simulator_load_elf(0, elf_file) == FAILED) begin
      `uvm_fatal(info_tag, $sformatf("%m: Could not load elf: %s", elf_file));
    end

    retval = handcar_write_simulator_register(0, "pc", 128'h80, 8);
    if (retval != SUCCESS) begin
      `uvm_fatal(info_tag, $sformatf("%m: Write to PC failed, retval: %0d", retval));
    end

    opcode      = "*******************************************************************";
    disassembly = "*******************************************************************";

    retval = handcar_get_disassembly_for_target(0, pc[63:0], opcode, disassembly);
    if (retval != SUCCESS) begin
      `uvm_fatal(info_tag, $sformatf("%m: get_disassembly_for_target failed for pc: 0x%08x with return value: %0d", pc, retval));
    end
  end


  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
    end
    else begin
      // Blindly step the simulator
      if (handcar_step_simulator(0, 1, 0) == FAILED) begin
        `uvm_fatal(info_tag, $sformatf("%m: The step_simulator failed"));
      end
      // Read the PC
      retval = handcar_read_simulator_register(0, "pc", pc, 8);
      if (retval != SUCCESS) begin
        `uvm_fatal(info_tag, $sformatf("%m: read PC failed with return value: %0d", retval));
      end
      // Update disassembly
      opcode      = "*******************************************************************";
      disassembly = "*******************************************************************";
      retval = handcar_get_disassembly_for_target(0, pc[63:0], opcode, disassembly);
      if (retval != SUCCESS) begin
        `uvm_fatal(info_tag, $sformatf("%m: get_disassembly_for_target failed for pc: 0x%08x with return value: %0d", pc, retval));
      end
      // Update GPRs
      for (int i = 0;  i < 32; i++) begin
        retval = handcar_read_simulator_register(0, $sformatf("x%0d", i), x[i], 4);
        if (retval != SUCCESS) begin
          `uvm_fatal(info_tag, $sformatf("%m: read x%0d failed with return value: %0d", i, retval));
        end
      end      
    end
  end
endmodule : uvmt_cv32e40x_rvvi_handcar

