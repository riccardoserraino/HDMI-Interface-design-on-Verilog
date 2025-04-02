`include "DPRAM_adapter.v"
`include "HDMI_driver.v"
`include "gowin_dpb.v"
`include "prim_sim.v"


`timescale 1ns/1ps

module testbench_top();


//wire definition

//inputs
reg clk = 1'b0;
reg rst_n = 1'b0;
reg [31:0] io_pad_out;
//connections
wire [14:0] address_adapter;
wire [15:0] data_input;
wire [14:0] address_HDMI;
wire [15:0] data_HDMI;
//outputs
wire [7:0] red;
wire [7:0] blue;
wire [7:0] green;
wire V_sync;
wire H_sync;

//modules instance
    DPRAM_adapter RAM_adapter(
        .clk(clk),
        .rst_n(rst_n),
        .io_pad_out(io_pad_out),
        .address_adapter(address_adapter),
        .data_input(data_input)
    );        

    Gowin_DPB your_instance_name(
        .douta(), //output [15:0] douta
        .doutb(data_HDMI), //output [15:0] doutb
        .clka(clk), //input clka
        .ocea(), //input ocea
        .cea(1'b1), //input cea
        .reseta(rst_n), //input reseta
        .wrea(1'b1), //input wrea
        .clkb(clk), //input clkb
        .oceb(), //input oceb
        .ceb(1'b1), //input ceb
        .resetb(rst_n), //input resetb
        .wreb(1'b0), //input wreb
        .ada(address_adapter), //input [14:0] ada
        .dina(data_input), //input [15:0] dina
        .adb(address_HDMI), //input [14:0] adb
        .dinb() //input [15:0] dinb
    );

    HDMI_driver driver1(
        .clk(clk),
        .rst_n(rst_N),
        .data_HDMI(data_HDMI),
        .H_sync(H_sync),
        .V_sync(V_sync),
        .red(red),
        .green(green),
        .blue(blue),
        .address_HDMI(address_HDMI)
    );

//input definition
initial begin
    #10000
    io_pad_out = 32'b00000000000000001111111100000000;
    #1000
    io_pad_out = 32'b00000000000000010000000000000011;
    #1000
    io_pad_out = 32'b00000000000000001100000000000000;
    #1000
    io_pad_out = 32'b00000000000000010000000011111111;
end


//standard things

initial begin 
    $dumpfile("waveout.vcd");
    $dumpvars(0, testbench_top);
end


initial begin 
    #500000
    $finish;
end


always begin 
    #0.25 clk <= ~clk;
end

endmodule