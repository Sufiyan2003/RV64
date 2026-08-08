/*------------------------------------------------------------------------------
-- Author: Muhammad Sufiyan Sadiq 
-- Date: 08_08_2026
-- Description: This is the axi4 interface
-- 
------------------------------------------------------------------------------*/

interface axi4_intf #(
    parameter ID_WIDTH   = 2,
    parameter USER_WIDTH = 3,
    parameter DWIDTH     = 64
) (
    input clk,
    input resetn
);

    // ============================================================
    // AW channel
    // ============================================================
    logic                   AWVALID;
    logic                   AWREADY;
    logic [31:0]            AWADDR;
    logic [2:0]             AWSIZE;
    logic [1:0]             AWBURST;
    logic [3:0]             AWCACHE;
    logic [2:0]             AWPROT;
    logic [ID_WIDTH-1:0]    AWID;
    logic [7:0]             AWLEN;
    logic                   AWLOCK;
    logic [3:0]             AWQOS;
    logic [3:0]             AWREGION;
    logic [USER_WIDTH-1:0]  AWUSER;

    // ============================================================
    // W channel
    // ============================================================
    logic                   WVALID;
    logic                   WREADY;
    logic                   WLAST;
    logic [DWIDTH-1:0]      WDATA;
    logic [(DWIDTH/8)-1:0]  WSTRB;
    logic [USER_WIDTH-1:0]  WUSER;

    // ============================================================
    // B channel
    // ============================================================
    logic                   BVALID;
    logic                   BREADY;
    logic [1:0]             BRESP;
    logic [ID_WIDTH-1:0]    BID;
    logic [USER_WIDTH-1:0]  BUSER;

    // ============================================================
    // AR channel
    // ============================================================
    logic                   ARVALID;
    logic                   AREADY;
    logic [31:0]            ARADDR;
    logic [2:0]             ARSIZE;
    logic [1:0]             ARBURST;
    logic [3:0]             ARCACHE;
    logic [2:0]             ARPROT;
    logic [ID_WIDTH-1:0]    ARID;
    logic [7:0]             ARLEN;
    logic                   ARLOCK;
    logic [3:0]             ARREGION;
    logic [USER_WIDTH-1:0]  ARUSER;

    // ============================================================
    // R channel
    // ============================================================
    logic                   RVALID;
    logic                   RREADY;
    logic                   RLAST;
    logic [DWIDTH-1:0]      RDATA;
    logic [1:0]             RRESP;
    logic [ID_WIDTH-1:0]    RID;
    logic [USER_WIDTH-1:0]  RUSER;


    // ============================================================
    // MASTER MODPORT
    // ============================================================
    modport master (
        input  clk,
        input  resetn,

        // AW - Master -> Slave
        output AWVALID,
        output AWADDR,
        output AWSIZE,
        output AWBURST,
        output AWCACHE,
        output AWPROT,
        output AWID,
        output AWLEN,
        output AWLOCK,
        output AWQOS,
        output AWREGION,
        output AWUSER,

        input  AWREADY,

        // W - Master -> Slave
        output WVALID,
        output WLAST,
        output WDATA,
        output WSTRB,
        output WUSER,

        input  WREADY,

        // B - Slave -> Master
        input  BVALID,
        input  BRESP,
        input  BID,
        input  BUSER,

        output BREADY,

        // AR - Master -> Slave
        output ARVALID,
        output ARADDR,
        output ARSIZE,
        output ARBURST,
        output ARCACHE,
        output ARPROT,
        output ARID,
        output ARLEN,
        output ARLOCK,
        output ARREGION,
        output ARUSER,

        input AREADY,

        // R - Slave -> Master
        input RVALID,
        input RLAST,
        input RDATA,
        input RRESP,
        input RID,
        input RUSER,

        output RREADY
    );


    // ============================================================
    // SLAVE MODPORT
    // ============================================================
    modport slave (
        input  clk,
        input  resetn,

        // AW - Master -> Slave
        input AWVALID,
        input AWADDR,
        input AWSIZE,
        input AWBURST,
        input AWCACHE,
        input AWPROT,
        input AWID,
        input AWLEN,
        input AWLOCK,
        input AWQOS,
        input AWREGION,
        input AWUSER,

        output AWREADY,

        // W - Master -> Slave
        input WVALID,
        input WLAST,
        input WDATA,
        input WSTRB,
        input WUSER,

        output WREADY,

        // B - Slave -> Master
        output BVALID,
        output BRESP,
        output BID,
        output BUSER,

        input BREADY,

        // AR - Master -> Slave
        input ARVALID,
        input ARADDR,
        input ARSIZE,
        input ARBURST,
        input ARCACHE,
        input ARPROT,
        input ARID,
        input ARLEN,
        input ARLOCK,
        input ARREGION,
        input ARUSER,

        output AREADY,

        // R - Slave -> Master
        output RVALID,
        output RLAST,
        output RDATA,
        output RRESP,
        output RID,
        output RUSER,

        input RREADY
    );

endinterface : axi4_intf
