module top_module(
    input clk,
    input rst_n,
    input [31:0] io_pad_out,
    output reg V_sync,
    output reg H_sync,
    output reg [7:0] blue,
    output reg [7:0] green,
    output reg [7:0] red
);

    wire reset;
    wire [15:0] data_input;
    wire [14:0] address_adapter;
    wire clk;
    wire rst_n;
    wire [14:0] address_HDMI;
    wire [15:0] data_HDMI;

    assign reset = ~rst_n;

    DPRAM_adapter RAM_adapter(
        .clk(clk),
        .rst_n(reset),
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
        .reseta(reset), //input reseta
        .wrea(1'b1), //input wrea
        .clkb(clk), //input clkb
        .oceb(), //input oceb
        .ceb(1'b1), //input ceb
        .resetb(reset), //input resetb
        .wreb(1'b0), //input wreb
        .ada(address_adapter), //input [14:0] ada
        .dina(data_input), //input [15:0] dina
        .adb(address_HDMI), //input [14:0] adb
        .dinb() //input [15:0] dinb
    );

    HDMI_driver driver1(
        .clk(clk),
        .rst_n(reset),
        .data_HDMI(data_HDMI),
        .H_sync(H_sync),
        .V_sync(V_sync),
        .red(red),
        .green(green),
        .blue(blue),
        .address_HDMI(address_HDMI)
    );


endmodule