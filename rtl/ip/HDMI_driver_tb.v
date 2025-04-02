`include "HDMI_driver.v"

`timescale 1ns/100ps

module HDMI_driver_testbench();


    reg                   clk = 0;
    reg                   rst_n;
    wire                  H_sync;
    wire                  V_sync;
    wire [7:0]            red;
    wire [7:0]            green;
    wire [7:0]            blue;
    reg  [32-1:0]         io_pad_out;


initial begin 
    $dumpfile("waveout.vcd");
    $dumpvars(0, HDMI_driver_testbench);
end


initial begin 
    #100000
    $finish;
end


always begin 
    #0.25 clk <= ~clk;
end


HDMI_driver uut(
    .clk(clk),
    .rst_n(rst_n),
    .H_sync(H_sync),
    .V_sync(V_sync),
    .red(red),
    .green(green),
    .blue(blue),
    .io_pad_out(io_pad_out)
);


endmodule