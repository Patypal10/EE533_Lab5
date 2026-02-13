////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : regfile4reg32bitwide.vf
// /___/   /\     Timestamp : 02/09/2026 21:24:09
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family virtex2p -w "C:/Documents and Settings/student/registerfile/regfile4reg32bitwide.sch" regfile4reg32bitwide.vf
//Design Name: regfile4reg32bitwide
//Device: virtex2p
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module D2_4E_MXILINX_regfile4reg32bitwide(A0, 
                                          A1, 
                                          E, 
                                          D0, 
                                          D1, 
                                          D2, 
                                          D3);

    input A0;
    input A1;
    input E;
   output D0;
   output D1;
   output D2;
   output D3;
   
   
   AND3 I_36_30 (.I0(A1), 
                 .I1(A0), 
                 .I2(E), 
                 .O(D3));
   AND3B1 I_36_31 (.I0(A0), 
                   .I1(A1), 
                   .I2(E), 
                   .O(D2));
   AND3B1 I_36_32 (.I0(A1), 
                   .I1(A0), 
                   .I2(E), 
                   .O(D1));
   AND3B2 I_36_33 (.I0(A0), 
                   .I1(A1), 
                   .I2(E), 
                   .O(D0));
endmodule
`timescale 1ns / 1ps

module regfile4reg32bitwide(clk, 
                            clr, 
                            raddr0, 
                            raddr1, 
                            waddr, 
                            wdata, 
                            wea, 
                            rdata0, 
                            rdata1);

    input clk;
    input clr;
    input [1:0] raddr0;
    input [1:0] raddr1;
    input [1:0] waddr;
    input [31:0] wdata;
    input wea;
   output [31:0] rdata0;
   output [31:0] rdata1;
   
   wire XLXN_3;
   wire XLXN_4;
   wire XLXN_5;
   wire XLXN_6;
   wire [31:0] XLXN_7;
   wire [31:0] XLXN_10;
   wire [31:0] XLXN_11;
   wire [31:0] XLXN_12;
   
   reg32 XLXI_1 (.ce(XLXN_3), 
                 .clk(clk), 
                 .clr(clr), 
                 .d(wdata[31:0]), 
                 .q(XLXN_7[31:0]));
   reg32 XLXI_2 (.ce(XLXN_4), 
                 .clk(clk), 
                 .clr(clr), 
                 .d(wdata[31:0]), 
                 .q(XLXN_10[31:0]));
   reg32 XLXI_3 (.ce(XLXN_5), 
                 .clk(clk), 
                 .clr(clr), 
                 .d(wdata[31:0]), 
                 .q(XLXN_11[31:0]));
   reg32 XLXI_4 (.ce(XLXN_6), 
                 .clk(clk), 
                 .clr(clr), 
                 .d(wdata[31:0]), 
                 .q(XLXN_12[31:0]));
   D2_4E_MXILINX_regfile4reg32bitwide XLXI_6 (.A0(waddr[0]), 
                                              .A1(waddr[1]), 
                                              .E(wea), 
                                              .D0(XLXN_3), 
                                              .D1(XLXN_4), 
                                              .D2(XLXN_5), 
                                              .D3(XLXN_6));
   // synthesis attribute HU_SET of XLXI_6 is "XLXI_6_0"
   mux32bit_4to1 XLXI_7 (.I0(XLXN_7[31:0]), 
                         .I1(XLXN_10[31:0]), 
                         .I2(XLXN_11[31:0]), 
                         .I3(XLXN_12[31:0]), 
                         .S0(raddr0[0]), 
                         .S1(raddr0[1]), 
                         .S(rdata0[31:0]));
   mux32bit_4to1 XLXI_8 (.I0(XLXN_7[31:0]), 
                         .I1(XLXN_10[31:0]), 
                         .I2(XLXN_11[31:0]), 
                         .I3(), 
                         .S0(raddr1[0]), 
                         .S1(raddr1[1]), 
                         .S(rdata1[31:0]));
endmodule
