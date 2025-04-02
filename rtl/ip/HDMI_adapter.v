//=====================================================================
//
// Designer   : Riccardo Serraino and Giuliano Livi
//
// Description:
//  Example for an e203 icb peripheralS
//
// ====================================================================

module HDMI_adapter(
    input                   clk, //clokc signal
    input                   rst_n, //active-high reset

    input                   HDMI_icb_cmd_valid, //indicates a valid command
    output                  HDMI_icb_cmd_ready, //indicates that the module is ready to accept a command
    input  [32-1:0]         HDMI_icb_cmd_addr, //32-bit address of the command
    input                   HDMI_icb_cmd_read, //indicates whether the command is a read (1) or write (0)
    input  [32-1:0]         HDMI_icb_cmd_wdata, //32-bit data to be written (if it’s a write command)

    output                  HDMI_icb_rsp_valid, //indicates the response data is valid
    input                   HDMI_icb_rsp_ready, //indicates the response is accepted by the master
    output [32-1:0]         HDMI_icb_rsp_rdata, //32-bit data output of the read response

    output                  io_interrupts_0_0, //interrupt output (not used in this module)
    output [32-1:0]         io_pad_out //32-bit output connected to an external pad (reflecting the value of the internal register)
    );

    reg [31:0] io_value_reg; //register to store data

    reg [31:0] icb_data_out; //register to hold the data that will be sent as read response
    reg        icb_rsp_valid; //register to hold the response valid signal status

    wire reset; //active-low reset signal (inverted rst_n)
    wire clock;                                 

    //read enable signal for register reading, this signal asserts when proper address is issued.
    wire io_value_reg_rd_en;                   

    //write enable signal for register writing, this signal asserts when proper address is issued.
    wire io_value_reg_wr_en;             


    //invert rst_n to get active-low reset signal
    assign reset = ~rst_n;
    //assign clock signal to its wire
    assign clock = clk;

    //judge if register is selected for read, 3'h4 is the offset address of the register
    assign io_value_reg_rd_en = HDMI_icb_cmd_valid && HDMI_icb_cmd_read && (HDMI_icb_cmd_addr[11:0] == 3'h4);
    //judge if register is selected for write
    assign io_value_reg_wr_en = HDMI_icb_cmd_valid && (~HDMI_icb_cmd_read) && (HDMI_icb_cmd_addr[11:0] == 3'h4);

    //directly connect valid to ready signal
    assign HDMI_icb_cmd_ready = HDMI_icb_cmd_valid;

    //response valid signal logic
    assign HDMI_icb_rsp_valid = HDMI_icb_rsp_ready && icb_rsp_valid;

    //assign the response read data
    assign HDMI_icb_rsp_rdata = icb_data_out;

    //connect io pad to register
    assign io_pad_out = io_value_reg;



    //always block triggered on the positive edge of clock or reset
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            //on reset, initialize register and response valid signal
            io_value_reg <= 32'h12345678;
            icb_rsp_valid <= 1'b0;
        end 
        else begin
            //if read enable is asserted, prepare data for response
            if (io_value_reg_rd_en) begin
                icb_data_out <= io_value_reg; //assign register value to output data
                icb_rsp_valid <= 1'b1; //assert response valid signal
            end
            else begin
                icb_rsp_valid <= 1'b0; //assert response valid signal
            end
            //if write enable is asserted, update the register
            if(io_value_reg_wr_en) begin
                io_value_reg <= HDMI_icb_cmd_wdata; //update register with write data
                icb_rsp_valid <= 1'b1; //assert response valid signal
            end
        end
    end
endmodule