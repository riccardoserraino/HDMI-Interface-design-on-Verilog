
module DPRAM_adapter(
    input             clk,
    input             rst_n,
    input      [31:0] io_pad_out,
    output     [14:0] address_adapter,
    output reg [15:0] data_input
);
    //this adapter takes the data from the bus and takes it intp the DPRAM 
    reg flag;
    reg [14:0] address_DPRAM;
    integer counter = -1;
    reg reset = 1'b0;
    always @(posedge clk) begin
        flag <= io_pad_out[16];
        if(counter == 0) begin
                address_DPRAM <= 15'd0;
        end
    end

    always @(flag) begin
        if(reset) begin
            address_DPRAM <= 15'b000000000000000;
        end
        else begin
            if(counter == 19199) begin
                counter <= 0;
                address_DPRAM <= 15'b000000000000000;
            end
            else begin
                counter <= counter + 1;
                address_DPRAM <= address_DPRAM + 1'b1;
            end
        end
    end

    assign address_adapter = address_DPRAM;

    always @(address_DPRAM) begin
        data_input <= io_pad_out[15:0];
    end

endmodule