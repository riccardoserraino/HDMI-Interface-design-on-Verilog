`timescale 1ns/100ps

module tb_sirv_uart_top();

  reg                   clk;
  reg                   rst_n;

  reg                   i_icb_cmd_valid;
  wire                  i_icb_cmd_ready;
  reg [32-1:0]          i_icb_cmd_addr;
  reg                   i_icb_cmd_read;
  reg [32-1:0]          i_icb_cmd_wdata;
  
  wire                  i_icb_rsp_valid;
  reg                   i_icb_rsp_ready;
  wire [32-1:0]         i_icb_rsp_rdata;

  wire                  io_interrupts_0_0;                
  wire                  io_port_txd;
  reg                   io_port_rxd;

  // Instantiate the top module
  sirv_uart_top uut (
    .clk(clk),
    .rst_n(rst_n),
    .i_icb_cmd_valid(i_icb_cmd_valid),
    .i_icb_cmd_ready(i_icb_cmd_ready),
    .i_icb_cmd_addr(i_icb_cmd_addr),
    .i_icb_cmd_read(i_icb_cmd_read),
    .i_icb_cmd_wdata(i_icb_cmd_wdata),
    .i_icb_rsp_valid(i_icb_rsp_valid),
    .i_icb_rsp_ready(i_icb_rsp_ready),
    .i_icb_rsp_rdata(i_icb_rsp_rdata),
    .io_interrupts_0_0(io_interrupts_0_0),
    .io_port_txd(io_port_txd),
    .io_port_rxd(io_port_rxd)
    );

    initial begin 
        $dumpfile("waveout.vcd");
        $dumpvars(0, tb_sirv_uart_top);
    end

    // Generate clock signal
    always begin 
        #0.25 clk <= ~clk;
    end

    // Test stimulus
    initial begin
    // Initialize signals
    rst_n = 0;
    i_icb_cmd_valid = 0;
    i_icb_cmd_addr = 0;
    i_icb_cmd_read = 0;
    i_icb_cmd_wdata = 0;
    i_icb_rsp_ready = 0;
    io_port_rxd = 1;

    // Apply reset
    #10;
    rst_n = 1;

    // Write data to UART
    #20;
    i_icb_cmd_valid = 1;
    i_icb_cmd_addr = 32'h00000000; // Address for UART register
    i_icb_cmd_read = 0;
    i_icb_cmd_wdata = 32'h000000A5; // Data to write
    wait(i_icb_cmd_ready);
    i_icb_cmd_valid = 0;

    // Read data from UART
    #20;
    i_icb_cmd_valid = 1;
    i_icb_cmd_addr = 32'h00000000; // Address for UART register
    i_icb_cmd_read = 1;
    wait(i_icb_cmd_ready);
    i_icb_cmd_valid = 0;

    // Wait for response
    i_icb_rsp_ready = 1;
    wait(i_icb_rsp_valid);
    $display("Read Data: %h", i_icb_rsp_rdata);
    i_icb_rsp_ready = 0;

    // Test the UART transmit and receive
    // For simplicity, we'll just loop back the txd to rxd
    #20;
    io_port_rxd = io_port_txd;
    
    #100; // Wait some time for the UART to operate

    // End simulation
    $finish;
  end

  // Monitor UART TXD and RXD signals
  initial begin
    $monitor("Time: %t | TXD: %b | RXD: %b", $time, io_port_txd, io_port_rxd);
  end

endmodule