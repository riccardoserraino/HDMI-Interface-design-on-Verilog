`include "HDMI_adapter.v"

`timescale 1ns/100ps

module HDMI_adapter_tb();

    reg                   clk=0;
    reg                   rst_n;
    reg                   HDMI_icb_cmd_valid;
    wire                  HDMI_icb_cmd_ready;
    reg  [32-1:0]         HDMI_icb_cmd_addr; 
    reg                   HDMI_icb_cmd_read; 
    reg  [32-1:0]         HDMI_icb_cmd_wdata;
    wire                  HDMI_icb_rsp_valid;
    reg                   HDMI_icb_rsp_ready;
    wire [32-1:0]         HDMI_icb_rsp_rdata;
    wire                  io_interrupts_0_0;            
    wire [32-1:0]         io_pad_out;


    initial begin 
    $dumpfile("waveout.vcd");
    $dumpvars(0, HDMI_adapter_tb);
    end

    initial begin 
        #1000
        $finish;
    end

    always begin 
        #0.25 clk <= ~clk;
    end

    initial begin
        #5
        HDMI_icb_cmd_addr[11:0] = 3'h4;
        HDMI_icb_cmd_read = 1'b0;
        HDMI_icb_cmd_valid = 1'b1;
        HDMI_icb_cmd_wdata = 32'b00000000000000011111111100000000;
        #1
        HDMI_icb_cmd_valid = 1'b0;
        #5
        HDMI_icb_cmd_valid = 1'b1;
        HDMI_icb_cmd_read = 1'b1;
    end

    HDMI_adapter uut(
        .clk(clk),
        .rst_n(rst_n),
        .HDMI_icb_cmd_valid(HDMI_icb_cmd_valid),
        .HDMI_icb_cmd_ready(HDMI_icb_cmd_ready),
        .HDMI_icb_cmd_addr(HDMI_icb_cmd_addr),
        .HDMI_icb_cmd_read(HDMI_icb_cmd_read),
        .HDMI_icb_cmd_wdata(HDMI_icb_cmd_wdata),
        .HDMI_icb_rsp_valid(HDMI_icb_rsp_valid),
        .HDMI_icb_rsp_ready(HDMI_icb_rsp_ready),
        .HDMI_icb_rsp_rdata(HDMI_icb_rsp_rdata),
        .io_interrupts_0_0(io_interrupts_0_0),
        .io_pad_out(io_pad_out)
);


endmodule