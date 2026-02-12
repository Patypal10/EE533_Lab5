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

reg [63:0] pc;
reg [63:0] pc_next

// -------------------------- Register Mapped Inputs -----------------------
// software regs
reg [DATA_WIDTH-1:0] cmd;

// hardware regs
reg [DATA_WIDTH-1:0] reg1;
reg [DATA_WIDTH-1:0] reg2;

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
reg ID_EX_wea_register;
reg ID_EX_wea_dmem;
reg [1:0] ID_EX_rs1_addr;
reg [1:0] ID_EX_rs2_addr;
reg [1:0] ID_EX_rd_addr;
reg [7:0] ID_EX_offset;
reg [63:0] ID_EX_rs1_d;
reg [63:0] ID_EX_rs2_d;

// EX MEM pipeline
reg EX_MEM_wea_register;
reg EX_MEM_wea_dmem;
reg [1:0] EX_MEM_rs1_addr;
reg [1:0] EX_MEM_rs2_addr;
reg [1:0] EX_MEM_rd_addr;
reg [7:0] EX_MEM_offset;
reg [7:0] EX_MEM_dmem_addr;

// MEM WB pipeline
reg MEM_WB_wea_register;
reg MEM_WB_wea_dmem;
reg [1:0] MEM_WB_rs1_addr;
reg [1:0] MEM_WB_rs2_addr;
reg [1:0] MEM_WB_rd_addr;
reg [7:0] MEM_WB_offset;
reg [7:0] EX_MEM_dmem_addr;


// Modules
regfile register_file (
    .clk(clk),
    .clr(reset),
    .raddr0(rs1_addr),
    .raddr1(rs2_addr),
    .waddr(),
    .wdata(),
    .wea(wea_register),
    .rdata0(rs1_d),
    .rdata1(rs2_d)
);



// Control Logic
always @(*) begin
    pc_next = pc + 1'b1;
    IF_ID_reg_next = imem_to_ifid;

    // Decoder
    wea_register = 0;
    wea_dmem = 0;
    rd_addr = 0;
    rs1_addr = 0;
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
            offset = 0;
        end
    endcase

    // Execution Unit
    dmem_addr = (IF_ID_reg[5:0] == 6'd1) ? (ID_EX_rd_addr + ID_EX_offset) : (ID_EX_rs2_addr + ID_EX_offset); // load or store

end

always @(posedge clk) begin
    if (rst) begin
        pc <= 0;
    end else if (cmd == 64'd1) begin
        pc <= pc_next;
        IF_ID_reg <= IF_ID_reg_next;

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
        EX_MM_wea_register <= ID_EX_wea_register;
        EX_MM_wea_dmem <= ID_EX_wea_dmem;
        EX_MM_rs1_addr <= ID_EX_rs1_addr;
        EX_MM_rs2_addr <= ID_EX_rs2_addr;
        EX_MM_rd_addr <= ID_EX_rd_addr;
        EX_MM_offset <= ID_EX_offset;
        EX_MM_rs1_d <= ID_EX_rs1_d;
        EX_MM_rs2_d <= ID_EX_rs2_d;
        EX_MEM_dmem_addr <= dmem_addr;

        // MEM WB


    end
end


// -------------------- Register Interface ----------------------------
generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`IDS_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`IDS_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (3),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (3)                  // Number of hw regs
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
      .software_regs    ({cmd,input_data,mem_addr}),

      // --- HW regs interface
      .hardware_regs    ({dmem_data, rs2_data, rs1_data}),

      .clk              (clk),
      .reset            (reset)
    );


endmodule