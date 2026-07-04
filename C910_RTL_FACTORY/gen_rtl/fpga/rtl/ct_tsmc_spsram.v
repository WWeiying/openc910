/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

`ifdef C910_USE_TSMC_SRAM

`define C910_TSMC_SPSRAM_PORTS(AW, DW, D_SIG, BWEB_SIG, Q_SIG, WEB_SIG) \
  .SLP   (1'b0),                 \
  .SD    (1'b0),                 \
  .CLK   (CLK),                  \
  .CEB   (CEN),                  \
  .WEB   (WEB_SIG),              \
  .CEBM  (1'b1),                 \
  .WEBM  (1'b1),                 \
  .A     (A),                    \
  .D     (D_SIG),                \
  .BWEB  (BWEB_SIG),             \
  .AM    ({AW{1'b0}}),           \
  .DM    ({DW{1'b0}}),           \
  .BWEBM ({DW{1'b1}}),           \
  .BIST  (1'b0),                 \
  .RTSEL (2'b01),                \
  .WTSEL (2'b00),                \
  .Q     (Q_SIG)

// Adapter from the C910 SRAM wrapper interface to the generated TSMC 28nm PUHD
// single-port bit-write SRAM macros. C910 uses active-low CEN/GWEN/WEN; TSMC
// macros use active-low CEB/WEB/BWEB.
module ct_tsmc_spsram #(
  parameter ADDR_WIDTH  = 1,
  parameter DATA_WIDTH  = 1,
  parameter MACRO_WIDTH = 1,
  parameter MUX         = 1,
  parameter SLICES      = 1
) (
  input  [ADDR_WIDTH-1:0] A,
  input                   CEN,
  input                   CLK,
  input  [DATA_WIDTH-1:0] D,
  input                   GWEN,
  output [DATA_WIDTH-1:0] Q,
  input  [DATA_WIDTH-1:0] WEN
);

generate
  if (SLICES == 1) begin : gen_one_slice
    reg  [MACRO_WIDTH-1:0] macro_d;
    reg  [MACRO_WIDTH-1:0] macro_bweb;
    wire [MACRO_WIDTH-1:0] macro_q;
    wire                   macro_web;

    always @* begin
      macro_d = {MACRO_WIDTH{1'b0}};
      macro_d[DATA_WIDTH-1:0] = D;
      macro_bweb = {MACRO_WIDTH{1'b1}};
      macro_bweb[DATA_WIDTH-1:0] = WEN | {DATA_WIDTH{GWEN}};
    end

    assign macro_web = GWEN | (&WEN);
    assign Q         = macro_q[DATA_WIDTH-1:0];

    if (ADDR_WIDTH == 7 && DATA_WIDTH == 16 && MACRO_WIDTH == 16 && MUX == 1) begin : gen_128x16m1
      TS1N28HPCPUHDSVTB128X16M1SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(7, 16, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 8 && DATA_WIDTH == 23 && MACRO_WIDTH == 24 && MUX == 2) begin : gen_256x24m2
      TS1N28HPCPUHDSVTB256X24M2SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(8, 24, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 8 && DATA_WIDTH == 84 && MACRO_WIDTH == 88 && MUX == 2) begin : gen_256x88m2
      TS1N28HPCPUHDSVTB256X88M2SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(8, 88, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 9 && DATA_WIDTH == 7 && MACRO_WIDTH == 8 && MUX == 4) begin : gen_512x8m4
      TS1N28HPCPUHDSVTB512X8M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(9, 8, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 9 && DATA_WIDTH == 22 && MACRO_WIDTH == 24 && MUX == 4) begin : gen_512x24m4
      TS1N28HPCPUHDSVTB512X24M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(9, 24, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 9 && DATA_WIDTH == 44 && MACRO_WIDTH == 48 && MUX == 4) begin : gen_512x48m4
      TS1N28HPCPUHDSVTB512X48M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(9, 48, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 9 && DATA_WIDTH == 52 && MACRO_WIDTH == 56 && MUX == 4) begin : gen_512x56m4_w52
      TS1N28HPCPUHDSVTB512X56M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(9, 56, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 9 && DATA_WIDTH == 54 && MACRO_WIDTH == 56 && MUX == 4) begin : gen_512x56m4_w54
      TS1N28HPCPUHDSVTB512X56M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(9, 56, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 9 && DATA_WIDTH == 59 && MACRO_WIDTH == 64 && MUX == 4) begin : gen_512x64m4
      TS1N28HPCPUHDSVTB512X64M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(9, 64, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 10 && DATA_WIDTH == 64 && MACRO_WIDTH == 64 && MUX == 4) begin : gen_1024x64m4
      TS1N28HPCPUHDSVTB1024X64M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(10, 64, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
    else if (ADDR_WIDTH == 11 && DATA_WIDTH == 32 && MACRO_WIDTH == 32 && MUX == 4) begin : gen_2048x32m4
      TS1N28HPCPUHDSVTB2048X32M4SWBSO u_sram (
        `C910_TSMC_SPSRAM_PORTS(11, 32, macro_d, macro_bweb, macro_q, macro_web)
      );
    end
  end
  else if (ADDR_WIDTH == 8 && DATA_WIDTH == 196 && MACRO_WIDTH == 104 && MUX == 2 && SLICES == 2) begin : gen_256x196_2x104
    reg  [103:0] macro0_d;
    reg  [103:0] macro1_d;
    reg  [103:0] macro0_bweb;
    reg  [103:0] macro1_bweb;
    wire [103:0] macro0_q;
    wire [103:0] macro1_q;
    wire         macro0_web;
    wire         macro1_web;

    always @* begin
      macro0_d = D[103:0];
      macro1_d = 104'b0;
      macro1_d[91:0] = D[195:104];

      macro0_bweb = WEN[103:0] | {104{GWEN}};
      macro1_bweb = {104{1'b1}};
      macro1_bweb[91:0] = WEN[195:104] | {92{GWEN}};
    end

    assign macro0_web = GWEN | (&WEN[103:0]);
    assign macro1_web = GWEN | (&WEN[195:104]);
    assign Q[103:0]   = macro0_q;
    assign Q[195:104] = macro1_q[91:0];

    TS1N28HPCPUHDSVTB256X104M2SWBSO u_sram0 (
      `C910_TSMC_SPSRAM_PORTS(8, 104, macro0_d, macro0_bweb, macro0_q, macro0_web)
    );

    TS1N28HPCPUHDSVTB256X104M2SWBSO u_sram1 (
      `C910_TSMC_SPSRAM_PORTS(8, 104, macro1_d, macro1_bweb, macro1_q, macro1_web)
    );
  end
endgenerate

endmodule

`undef C910_TSMC_SPSRAM_PORTS

`endif
