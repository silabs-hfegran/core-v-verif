import "DPI-C" initialize_simulator        = function void handcar_initialize_simulator(input string options);
import "DPI-C" terminate_simulator         = function void handcar_terminate_simulator();
import "DPI-C" set_simulator_parameter     = function int  handcar_set_sim_params(input string, inout longint unsigned value, input string);
import "DPI-C" simulator_load_elf          = function int  handcar_simulator_load_elf(input int target_id, input string elf_path);
import "DPI-C" step_simulator              = function int  handcar_step_simulator(input int target_id, input int num_steps, input int stx_failed);
import "DPI-C" read_simulator_register     = function int  handcar_read_simulator_register(input int target_id, input string reg_name, output bit [127:0] reg_data, input int length);
import "DPI-C" write_simulator_register    = function int  handcar_write_simulator_register(input int target_id, input string reg_name, input bit [127:0] reg_data, input int length);
import "DPI-C" get_disassembly_for_target  = function int  handcar_get_disassembly_for_target(input int target_id, input bit[63:0] pc, inout string opcode, inout string disassembly);
import "DPI-C" get_instruction_for_target  = function int  handcar_get_instruction_for_target(input int target_id, input bit[63:0] pc, inout bit[63:0] instruction);
import "DPI-C" get_isize_for_target        = function int  handcar_get_isize_for_target(input int target_id, input bit[63:0] pc, inout bit[7:0] isize);

module uvmt_cv32e40x_rvvi_handcar(
    uvma_clknrst_if               clknrst_if,
    uvmt_cv32e40x_isa_covg_if     isa_covg_if
  );

  import uvm_pkg::*;
  typedef enum { IDLE, STEPI, STOP, CONT } rvvi_c_e;

  // Set of machine mode registers (TODO FIXME for now...)
  string csr_name[] = '{ "mvendorid",
                         "misa",
                         "marchid",
                         "mimpid",
                         "mie",
                         "mstatus",
                         "mtvec",
                         "mcounteren",
                         "mcountinhibit",
                         "mscratch",
                         "mepc",
                         "mcause",
                         "mtval",
                         "mip"
                       };

  localparam SUCCESS = 0;
  string info_tag = "RVVI_HANDCAR";

  RVVI_control control_if();
  RVVI_state   state_if();

  int retval;

  //
  // Common error checker & handler, depends on retval to be != 0 for errors
  //
  function void check_err(string message, int error_code, int is_fatal = 1);
    if (retval != SUCCESS) begin
      if (is_fatal) begin
        `uvm_fatal(info_tag, $sformatf("%m: %0s, retval: %0d ", message, error_code));
      end else begin
        `uvm_error(info_tag, $sformatf("%m: %0s, retval: %0d ", message, error_code));
      end
    end
  endfunction : check_err

  //
  // Set simulator parameters
  //
  function void set_sim_parameters;
    string nullstring;
    int unsigned nullvar = 0;

    string param_1 = "p";
    longint unsigned pval_1  = 1;
    string param_2 = "hartids";
    string pval_2  = "0";
    string param_3 = "isa";
    string pval_3  = "RV32IMC";
    string param_4 = "priv";
    string pval_4  = "M";
    string param_5 = "disable-dtb";


    retval = handcar_set_sim_params(param_1, pval_1, nullstring);
    check_err("Unable to set \"-p 1\"", retval);
    retval = handcar_set_sim_params(param_2, nullvar, pval_2);
    check_err("Unable to set \"--hartids=0\"", retval);
    retval = handcar_set_sim_params(param_3, nullvar, pval_3);
    check_err("Unable to set \"--isa=RV32IMC\"", retval);
    retval = handcar_set_sim_params(param_4, nullvar, pval_4);
    check_err("Unable to set \"--priv=M\"", retval);
    retval = handcar_set_sim_params(param_5, nullvar, nullstring);
    check_err("Unable to set \"--priv=M\"", retval);
  endfunction : set_sim_parameters

  //
  // Load elf program into handcar
  //
  string elf_file;
  function void load_elf;
    if (!$value$plusargs("elf_file=%s", elf_file)) begin
      check_err("Elf must be supplied with +elf_file", 1);
    end
    retval = handcar_simulator_load_elf(0, elf_file);
    check_err($sformatf("Error loading elf file: %0s", elf_file), retval);
  endfunction : load_elf;

  //
  // Get current PC from handcar
  //
  function automatic bit[63:0] get_pc();
    bit[127:0] pc;
    retval = handcar_read_simulator_register(0, "pc", pc, 8);
    check_err("Could not read pc register", retval);
    return pc[63:0];
  endfunction : get_pc

  //
  // Get numbered GPR register
  //
  function automatic bit[31:0] get_reg(string reg_name);
    bit[63:0] x = 0;
    retval = handcar_read_simulator_register(0, reg_name, x, 8);
    check_err($sformatf("Could not read %0s register", reg_name), retval);
    return x;
  endfunction : get_reg

  function void set_reg(string reg_name, bit[127:0] data);
    retval = handcar_write_simulator_register(0, reg_name, data, 8);
    check_err($sformatf("Could not set %0s register", reg_name), retval);
  endfunction : set_reg

  //
  // Get instruction binary
  //
  function automatic bit[31:0] get_instruction(bit[63:0] pc);
    bit[63:0] instruction = 64'h0;
    retval = handcar_get_instruction_for_target(0, pc, instruction);
    check_err("Could not get instruction", retval);
    return instruction;
  endfunction : get_instruction

  //
  // Get instruction size
  //
  function automatic bit[2:0] get_isize(bit[63:0] pc);
    bit[7:0] isize;
    retval = handcar_get_isize_for_target(0, pc, isize);
    check_err("Could not get instruction size", retval);
    return isize[2:0];
  endfunction : get_isize

  //
  // Step simulator
  //
  function void step_sim;
    retval = handcar_step_simulator(0, 1, 0);
    check_err("Could not step simulator", retval);
  endfunction : step_sim

  //
  // Get disassembly
  //
  function automatic string get_disassembly(bit[63:0] pc);
    string opcode      = "********************************************************************";
    string disassembly = "********************************************************************";

    retval = handcar_get_disassembly_for_target(0, pc, opcode, disassembly);
    check_err("Could not disassemble target", retval);
    return disassembly;
  endfunction : get_disassembly

  //
  // Reg num to x<reg_num>-string
  //
  function string reg_x(int num);
    return $sformatf("x%0d", num);
  endfunction : reg_x

  //
  // RVVI control
  //
  always @(control_if.notify) begin
    case (control_if.cmd)
      STEPI:
        begin
          control_if.idle();

          state_if.trap   = 0;
          state_if.valid  = 1;
          state_if.halt   = 0;

          state_if.intr   = 0;
          state_if.order  = state_if.order + 1; // TODO need to figure out how to set this one appropriately
          state_if.pc     = get_pc();
          state_if.insn   = get_instruction(state_if.pc);
          state_if.decode = get_disassembly(state_if.pc);
          state_if.isize  = get_isize(state_if.pc);
          state_if.mode   = 2'b11; // No other modes supported at the moment....

          step_sim();
          state_if.pcnext = get_pc();

          foreach (csr_name[i]) begin
            state_if.csr[csr_name[i]] = get_reg(csr_name[i]);
          end

          for (int i = 0; i < 32; i++) begin
            state_if.x[i] = get_reg(reg_x(i));
          end

          ->state_if.notify;
        end
      // FIXME Are these actually needed in HC?
      //STOP: // TODO
      //  begin
      //    control_if.idle();
      //  end
      //CONT: // TODO
      //  begin
      //    control_if.idle();
      //  end
      //IDLE: // TODO
      //  begin
      //    control_if.idle();
      //  end
      default : control_if.idle();
    endcase
  end

  //
  // Initialization
  //
  initial begin
    handcar_terminate_simulator();
    set_sim_parameters();
    handcar_initialize_simulator("-p1 --hartids=0 --isa=RV32IMC --priv=m --disable-dtb");
    //handcar_initialize_simulator("");
    load_elf;
    set_reg("pc", 32'h80);
    `uvm_info(info_tag, "Initialized Handcar cosim", UVM_LOW);
  end // initial

  //
  // Cleanup
  //
  final begin
    handcar_terminate_simulator();
  end

endmodule : uvmt_cv32e40x_rvvi_handcar
