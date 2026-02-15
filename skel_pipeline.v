module skeleton_pipeline #(
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = DATA_WIDTH/8,
    parameter UDP_REG_SRC_WIDTH = 2
)(
    input clk,
    input rst,

    // --- Register interface
      input                               reg_req_in,
      input                               reg_ack_in,
      input                               reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

      output                              reg_req_out,
      output                              reg_ack_out,
      output                              reg_rd_wr_L_out,
      output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,
);

reg [7:0] pc;
reg [7:0] pc_next

// -------------------------- Register Mapped Inputs -----------------------
// software regs
//reg [DATA_WIDTH-1:0] cmd;

// hardware regs
//reg [DATA_WIDTH-1:0] reg1;
//reg [DATA_WIDTH-1:0] reg2;

// ---------------------------- Local connections ---------------------------
// from IMEM to decoder
wire [31:0] imem_to_ifid;

// from decoder -- ctrl signals
reg wea_register;
reg wea_dmem;
reg [1:0] rs1_addr, rs2_addr;
reg [1:0] rd_addr;
reg [7:0] offset;
reg [DATA_WIDTH-1:0] rs1_d, rs2_d;

// from execution unit -- ctrl signals
reg [7:0] dmem_addr;

// ---------------------------- Pipeline Registers --------------------------
// IF ID pipeline
reg [31:0] IF_ID_reg;

// ID EX pipeline
reg [31:0] ID_EX_inst;
reg ID_EX_wea_register;
reg ID_EX_wea_dmem;
reg [1:0] ID_EX_rs1_addr;
reg [1:0] ID_EX_rs2_addr;
reg [1:0] ID_EX_rd_addr;
reg [7:0] ID_EX_offset;
reg [DATA_WIDTH-1:0] ID_EX_rs1_d;
reg [DATA_WIDTH-1:0] ID_EX_rs2_d;

// EX MEM pipeline
reg [31:0] EX_MEM_inst;
reg EX_MEM_wea_register;
reg EX_MEM_wea_dmem;
reg [1:0] EX_MEM_rs1_addr;
reg [1:0] EX_MEM_rs2_addr;
reg [1:0] EX_MEM_rd_addr;
reg [7:0] EX_MEM_offset;
reg [DATA_WIDTH-1:0] EX_MEM_rs1_d;
reg [DATA_WIDTH-1:0] EX_MEM_rs2_d;
reg [7:0] EX_MEM_dmem_addr;

// MEM WB pipeline
reg [31:0] MEM_WB_inst;
reg MEM_WB_wea_register;
reg MEM_WB_wea_dmem;
//reg [1:0] MEM_WB_rs1_addr; --pbanga --maybe add for debug purposes
//reg [1:0] MEM_WB_rs2_addr; --pbanga --maybe add for debug purposes
reg [1:0] MEM_WB_rd_addr;
reg [7:0] MEM_WB_offset;
//reg [DATA_WIDTH-1:0] MEM_WB_rs1_d; --pbanga --maybe add for debug purposes
//reg [DATA_WIDTH-1:0] MEM_WB_rs2_d; --pbanga --maybe add for debug purposes
//reg [7:0] EX_MEM_dmem_addr;  --pbanga --maybe add for debug purposes
//PBANGA
reg [63:0] MEM_WB_dmem_output;
//reg [63:0] MEM_WB_alu_output; -- to be added next week

////pbanga temp placement here-- move to relevant sections
reg[31:0] IF_ID_reg_next;

//---------------------wires--------------------------
wire[1:0] to_reg_rs1_addr, to_reg_rs2_addr;

reg[63:0] MEM_WB_dmem_out_to_regfile;

//wire reg interface
wire[63:0] from_reginterface_to_reg_rs1, from_reginterface_to_reg_rs2, mem_addr, cmd, input_data, imem_addr;

reg[63:0] dmem_data, rs1_data, rs2_data, imem_data; 
wire[63:0] dmem_data_wire;

wire[7:0] to_imem_addr;
// ------------------------------- Modules ---------------------------------------
//mux between rs1_addr from pipeline or from reg interface
M2_1 mux2_0 (.D0(rs1_addr[0]), .D1(from_reginterface_to_reg_rs1[0]), .S0(cmd[5]), .O(to_reg_rs1_addr[0]));
M2_1 mux2_1 (.D0(rs1_addr[1]), .D1(from_reginterface_to_reg_rs1[1]), .S0(cmd[5]), .O(to_reg_rs1_addr[1]));

M2_1 mux2_0 (.D0(rs2_addr[0]), .D1(from_reginterface_to_reg_rs2[0]), .S0(cmd[5]), .O(to_reg_rs2_addr[0]));
M2_1 mux2_1 (.D0(rs2_addr[1]), .D1(from_reginterface_to_reg_rs2[1]), .S0(cmd[5]), .O(to_reg_rs2_addr[1]));

regfile_64bit register_file (
    .clk(clk),
    .clr(reset),
    .raddr0(to_reg_rs1_addr),
    .raddr1(to_reg_rs2_addr),
    .waddr(MEM_WB_rd_addr),
    .wdata(MEM_WB_dmem_out_to_regfile),
    .wea(MEM_WB_wea_register),
    .rdata0(rs1_d),
    .rdata1(rs2_d)
);

M2_1 mux1_0 (.D0(pc[0]), .D1(imem_addr[0]), .S0(cmd[2]), .O(to_imem_addr[0]));
M2_1 mux1_1 (.D0(pc[1]), .D1(imem_addr[1]), .S0(cmd[2]), .O(to_imem_addr[1]));
M2_1 mux1_2 (.D0(pc[2]), .D1(imem_addr[2]), .S0(cmd[2]), .O(to_imem_addr[2]));
M2_1 mux1_3 (.D0(pc[3]), .D1(imem_addr[3]), .S0(cmd[2]), .O(to_imem_addr[3]));
M2_1 mux1_4 (.D0(pc[4]), .D1(imem_addr[4]), .S0(cmd[2]), .O(to_imem_addr[4]));
M2_1 mux1_5 (.D0(pc[5]), .D1(imem_addr[5]), .S0(cmd[2]), .O(to_imem_addr[5]));
M2_1 mux1_6 (.D0(pc[6]), .D1(imem_addr[6]), .S0(cmd[2]), .O(to_imem_addr[6]));
M2_1 mux1_7 (.D0(pc[7]), .D1(imem_addr[7]), .S0(cmd[2]), .O(to_imem_addr[7]));

imem_32x512_v1 imem (
    .clk(clk), 
    .din(input_data), // THIS IS FOR WRITING INSTRUCITONS IN REGISTER INTERFACE? 
    .addr(to_imem_addr), // NEED MUX BASED ON CMD REGISTER FOR WRITING IN ISNT OR RUNNING CPU
    .we(cmd[3]), // NEED MUX BASED ON CMD REGISTER
    .dout(imem_to_ifid)
);

//M2_1 mux2_0 (.D0(pc[0]), .D1(imem_addr[0]), .S0(cmd[2]), .O(to_imem_addr[0]));

dmem_64x256_v1 uut_dmem(
    .addrb(mem_addr), // pbanga -- one port to interface with reg on fgpa
    .addra(EX_MEM_dmem_addr), // pbanga -- second port part of memory
    .clka(clk),
    .clkb(clk),
    .dina(EX_MEM_rs2_d), // MUX THIS FOR CPU FUNCTION AND LOADING IN DATA FROM INTERFACE
    .dinb(input_data), // UNUSED FOR NORMAL CPU ATM pbanga - use this port as reg intrface
    .douta(from_mem_to_MEM_WB),
    .doutb(dmem_data_wire),
    .wea(EX_MEM_wea_dmem), // MUX THIS FOR CPU FUNCTION AND LOADING IN DATA FROM INTERFACE
    .web(cmd[4])  // UNUSED FOR NORMAL CPU ATM
);


// ----------------------------- Control Logic ------------------------------------
always @(*) begin
    pc_next = pc + 1'b1;
//    IF_ID_reg_next = imem_to_ifid;

    // Decode Stage
    wea_register = 0;
    wea_dmem = 0;
    rd_addr = 0;
    rs1_addr = 0;
    rs2_addr = 0
    offset = 0;
    case (IF_ID_reg[5:0])
        6'd1 : begin
            wea_register = 1'b1;
            wea_dmem = 1'b0; // DMEM IS DUAL PORTED!!!!!!!!!!!!!!!!!!!!!!!
            rd_addr = IF_ID_reg[7:6];
            rs1_addr = IF_ID_reg[9:8];
            offset = IF_ID_reg[16:10];
        end
        6'd2 : begin
            wea_register = 1'b0;
            wea_dmem = 1'b1;
            rs1_addr = IF_ID_reg[7:6];
            rs2_addr = IF_ID_reg[9:8];
            offset = IF_ID_reg[16:10];
        end
        default : begin
            wea_register = 0;
            wea_dmem = 0;
            rd_addr = 0;
            rs1_addr = 0;
            rs2_addr = 0;
            offset = 0;
        end
    endcase

    // Execution Stage
    dmem_addr = (ID_EX_inst[5:0] == 6'd1) ? (ID_EX_rd_addr + ID_EX_offset) : (ID_EX_rs2_addr + ID_EX_offset); // load or store

    // Memory Stage
    // Write enable generated in decode stage

    // Writeback Stage
    // RD and reg WE generated in decode stage
end

always @(posedge clk) begin
    if (rst) begin
        pc <= 0;
    end else if (cmd == 64'd1) begin
        pc <= pc_next;
        IF_ID_reg <= imem_to_ifid;

        // ID EX pipeline
        ID_EX_wea_register <= wea_register;
        ID_EX_wea_dmem <= wea_dmem;
        ID_EX_rs1_addr <= rs1_addr;
        ID_EX_rs2_addr <= rs2_addr;
        ID_EX_rd_addr <= rd_addr;
        ID_EX_offset <= offset;
        ID_EX_rs1_d <= rs1_d;
        ID_EX_rs2_d <= rs2_d;

        // EX MEM pipeline
        EX_MEM_wea_register <= ID_EX_wea_register;
        EX_MEM_wea_dmem <= ID_EX_wea_dmem;
        EX_MEM_rs1_addr <= ID_EX_rs1_addr;
        EX_MEM_rs2_addr <= ID_EX_rs2_addr;
        EX_MEM_rd_addr <= ID_EX_rd_addr;
        EX_MEM_offset <= ID_EX_offset;
        EX_MEM_rs1_d <= ID_EX_rs1_d;
        EX_MEM_rs2_d <= ID_EX_rs2_d;
        EX_MEM_dmem_addr <= dmem_addr;

        // MEM WB
        MEM_WB_wea_register <= EX_MEM_wea_register;
        MEM_WB_wea_dmem <= EX_MEM_wea_dmem;
        MEM_WB_rs1_addr <= EX_MEM_rs1_addr;
        MEM_WB_rs2_addr <= EX_MEM_rs2_addr;
        MEM_WB_rd_addr <= EX_MEM_rd_addr;
        MEM_WB_offset <= EX_MEM_offset;
        MEM_WB_rs1_d <= EX_MEM_rs1_d;
        MEM_WB_rs2_d <= EX_MEM_rs2_d;
        MEM_WB_dmem_addr <= EX_MEM_dmem_addr;
	MEM_WB_dmem_output <= from_mem_to_MEM_WB;  

//reginterface
	rs1_data <= rs1_d;
	rs2_data <= rs2_d;
  	dmem_data <= dmem_data_wire;
	imem_data <= IF_ID_reg_next;
    end
end


// -------------------- Register Interface ----------------------------
generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`IDS_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`IDS_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (6),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (4)                  // Number of hw regs
   ) module_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface
      .software_regs    ({cmd, input_data, mem_addr, from_reginterface_to_reg_rs1, from_reginterface_to_reg_rs2, imem_addr}),

      // --- HW regs interface
      .hardware_regs    ({dmem_data, rs2_data, rs1_data, imem_data}),

      .clk              (clk),
      .reset            (reset)
    );


endmodule
