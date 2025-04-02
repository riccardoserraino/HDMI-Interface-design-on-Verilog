
module HDMI_driver(
    input                   clk,
    input                   rst_n,
    input      [15:0]       data_HDMI,
    output                  H_sync,
    output                  V_sync,
    output reg [7:0]        red,
    output reg [7:0]        green,
    output reg [7:0]        blue,
    output reg [14:0]       address_HDMI
);

    reg [15:0] io_value_reg;
    reg flag = 0;
    reg reset = 1'b0;
   

    //timing control section
    reg H_sync1 = 1'b1;
    reg V_sync1 = 1'b1;
    integer H_pixel_counter = 0;
    integer V_pixel_counter = 0;
    integer H_active = -1;

    assign H_sync = H_sync1;
    assign V_sync = V_sync1;

    always @(posedge clk) begin
        if(H_pixel_counter == 799) begin
            H_sync1 <= 1'b1;
            H_pixel_counter <= 0;

            if(V_pixel_counter == 524) begin
                V_pixel_counter <= 0;
                V_sync1 <= 1'b1;
            end
            else if(V_pixel_counter == 1) begin
                V_sync1 <= 1'b0;
            end


            if(V_pixel_counter != 524) begin
                V_pixel_counter <= V_pixel_counter + 1;
            end
        end
        else if(H_pixel_counter >= 143 && H_pixel_counter <= 781) begin
            if(V_pixel_counter >= 35 && V_pixel_counter <= 514) begin
                H_active <= H_active + 1;
            end
        end
        else if(H_pixel_counter == 142) begin
            if(V_pixel_counter >= 35 && V_pixel_counter <= 514) begin
                H_active <= 0;
            end
        end
        else if(H_pixel_counter == 94) begin
            H_sync1 <= 1'b0;
        end


        if(H_pixel_counter != 799) begin
            H_pixel_counter <= H_pixel_counter + 1;
        end
    end


    //this section is used to change the color of the output every time the pixel counter goes over 80, because every strip is composed
    //of 80 pixels
    integer strip_counter = 0;
    reg [3:0] color = 4'b0000;

    always @(posedge clk) begin
        if((H_pixel_counter >= 144 && H_pixel_counter <= 783) && (V_pixel_counter >= 35 && V_pixel_counter <= 514)) begin
            if (strip_counter == 80) begin 
                case (color)
                4'b0000: color <= 4'b0001;
                4'b0001: color <= 4'b0010;
                4'b0010: color <= 4'b0011;
                4'b0011: color <= 4'b0100;
                4'b0100: color <= 4'b0101;
                4'b0101: color <= 4'b0110;
                4'b0110: color <= 4'b0111;
                4'b0111: color <= 4'b1000;
                4'b1000: color <= 4'b0000;
                default: color <= 4'b0000;
                endcase
                strip_counter = 0;
            end
            else strip_counter = strip_counter + 1;
        end
        else color <= 4'b0000;
    end



    // 8 colors: i need to save 8 colors in 8 registers and then display them a the right time
    localparam	WHITE	= {8'd255 , 8'd255 , 8'd255 };//{B,G,R}
    localparam	YELLOW	= {8'd0   , 8'd255 , 8'd255 };
    localparam	CYAN	= {8'd255 , 8'd255 , 8'd0   };
    localparam	GREEN	= {8'd0   , 8'd255 , 8'd0   };
    localparam	MAGENTA	= {8'd255 , 8'd0   , 8'd255 };
    localparam	RED		= {8'd0   , 8'd0   , 8'd255 };
    localparam	BLUE	= {8'd255 , 8'd0   , 8'd0   };
    localparam	BLACK	= {8'd0   , 8'd0   , 8'd0   };


    //now i can write the code to transfer at the right moment the right color the the screen
    always @(posedge clk) begin
        if(~enable_mode) begin
            if(reset) begin
                {blue, green, red} <= BLACK;
            end
            else begin
                case (color)
                4'b0000: {blue, green, red} <= BLACK;
                4'b0001: {blue, green, red} <= YELLOW;
                4'b0010: {blue, green, red} <= CYAN;
                4'b0011: {blue, green, red} <= GREEN;
                4'b0100: {blue, green, red} <= MAGENTA;
                4'b0101: {blue, green, red} <= RED;
                4'b0110: {blue, green, red} <= BLUE;
                4'b0111: {blue, green, red} <= WHITE;
                default: {blue, green, red} <= BLACK;
                endcase
            end
        end
    end


    //Charachter part
    integer counter_horizontal_char = 0;
    integer counter_char = 0;
    integer counter_vertical_char = 0;
    integer counter_bit = -1;

    always @(H_active) begin
        if(enable_mode) begin         
            if(reset) begin
                address_HDMI <= 15'b000000000000000;
            end
            else begin
                if(counter_bit == 12) begin
                    counter_char <= counter_char + 16;
                    if(counter_char == 624) begin
                        counter_char <= 0;
                        if(counter_horizontal_char == 15) begin
                            counter_horizontal_char <= 0;
                            if(counter_vertical_char == 18560) begin
                                counter_vertical_char <= 0;
                            end
                            else begin
                                counter_vertical_char <= counter_vertical_char + 640;
                            end
                        end
                        else begin
                            counter_horizontal_char <= counter_horizontal_char + 1;
                        end
                    end
                end

                if(counter_bit == 15) begin
                    counter_bit <= 0;
                end
                else begin
                    counter_bit <= counter_bit + 1;
                end

            end
        end
    end


    integer counter_output;
    always @(posedge clk) begin
        if(H_pixel_counter >= 142 && H_pixel_counter <= 781 && V_pixel_counter >= 35 && V_pixel_counter <= 514) begin
            if(data_HDMI[15 - counter_output] == 0) begin
                {blue, green, red} <= BLACK;
            end
            else if(data_HDMI[15 - counter_output] == 1) begin
                {blue, green, red} <= WHITE;
            end
        end

        if((H_pixel_counter == 125 && V_pixel_counter >= 35 && V_pixel_counter <= 514) || counter_output == 15) begin
            counter_output <= 0;
        end
        else begin
            counter_output <= counter_output + 1;
        end

        if(counter_output == 14) begin
            address_HDMI <= (counter_char + counter_horizontal_char + counter_vertical_char);
        end
    end
    



    //mode
    reg enable_mode = 1'b1;
    /*
    integer counter_mode = 0;
    always @(posedge clk) begin
        if(counter_mode == 134999999) begin    //134999999
            enable_mode <= 1'b1;
        end
        else begin
            counter_mode <= counter_mode + 1;
        end
    end
*/
endmodule