//Part C v2

// Reciever UART
module uart_reciever (reset, clk, Rx_DATA, baud_select, Rx_EN, Rx_D, Rx_VALID);
input reset, clk;
input [2:0] baud_select;
input Rx_EN;
input Rx_D;

output reg [7:0] Rx_DATA;
output reg Rx_VALID;

reg [4:0] current_state, next_state;

reg [3:0] counter;
reg [3:0] sampling;
reg enable;

wire sample_ENABLE;
reg parity_check;

reg shift;
reg Q1, Q2;
wire Q2_bar;
wire shift_out;

wire [7:0] tmp;

reg data_valid;

parameter r_off = 5'b00000,
    idle = 5'b00001,
    //recieve = 5'b00010,
    r_start_bit = 5'b00010,
    r_data_0 = 5'b00011,
    r_data_1 = 5'b00100,
    r_data_2 = 5'b00101,
    r_data_3 = 5'b00110,
    r_data_4 = 5'b00111,
    r_data_5 = 5'b01000,
    r_data_6 = 5'b01001,
    r_data_7 = 5'b01010,
    r_parity_bit = 5'b01011,
    r_parity_check = 5'b01100,
    r_stop_bit = 5'b01101,
    r_stop_checker = 5'b01110,
    valid = 5'b01111,
    parity_error = 5'b10000,
    frame_error = 5'b10001;


always @(posedge clk)       // kati san antibounce gia na kratiso ton palmo gia ena kiklo rologioy
begin
    Q1 <= shift;
end

always @(posedge clk)
begin
    Q2 <= Q1;
end

assign Q2_bar = ~Q2;
assign shift_out = (Q2_bar & Q1);


always @(posedge clk)
begin
    if(reset)
        current_state <= r_off;
    else
        current_state <= next_state;
end

always @(current_state or Rx_D or counter or sampling or Rx_EN or tmp)
begin
    next_state = current_state;
    enable = 1;
    parity_check = 0;
    Rx_VALID = 0;
    //Rx_DATA = 0;
    shift = 0;
    data_valid = 0;
    case(current_state)
       r_off:
        begin
            //enable = 0;
            if(Rx_EN == 1)
                next_state = idle;
            else
                next_state = r_off;
        end
        
        idle:
        begin
            //enable = 0;
            if(Rx_D == 0)
            begin
                enable = 1;
                next_state = r_start_bit;
            end
            else
                next_state = idle;
        end

        // recieve:
        // begin
        //     if(counter == 4'b1000)
        //     begin
        //         enable = 0;
        //         next_state = r_start_bit;
        //     end
        //     else
        //         next_state = recieve;
        // end

        r_start_bit:    // prepei na elegxo kai an einai ontos 0
            begin
                if(counter == 4'b1000)
                begin
                    next_state = r_data_0;
                    //shift = 1;
                    enable = 0;
                end
                else
                    next_state = r_start_bit;
            
            end

        r_data_0:       // kathe fora poy erxetai to minima sampling me diaforetiko arithmo paei sto epomeno
        begin
            //enable = 1;
            if(sampling == 4'b0001)
            begin
                shift = 1;
                next_state = r_data_1;
            end
            else
                next_state = r_data_0;
        end

        r_data_1:
        begin
            if(sampling == 4'b0010)
            begin
                shift = 1;
                next_state = r_data_2;
            end
            else
                next_state = r_data_1;
        end

        r_data_2:
        begin
            if(sampling == 4'b0011)
            begin
                shift = 1;
                next_state = r_data_3;
            end
            else
                next_state = r_data_2;
        end

        r_data_3:
        begin
            if(sampling == 4'b0100)
            begin
                shift = 1;
                next_state = r_data_4;
            end
            else
                next_state = r_data_3;
        end   

        r_data_4:
        begin
            if(sampling == 4'b0101)
            begin
                shift = 1;
                next_state = r_data_5;
            end
            else
                next_state = r_data_4;
        end     

        r_data_5:
        begin
            if(sampling == 4'b0110)
            begin
                shift = 1;
                next_state = r_data_6;
            end
            else
                next_state = r_data_5;
        end

        r_data_6:
        begin
            if(sampling == 4'b0111)
            begin
                shift = 1;
                next_state = r_data_7;
            end
            else
                next_state = r_data_6;
        end

        r_data_7:
        begin
            if(sampling == 4'b1000)
            begin
                shift = 1;
                next_state = r_parity_bit;
            end
            else
                next_state = r_data_7;
        end

        r_parity_bit:
        begin

            if(sampling == 4'b1001)
            begin
                //if((^tmp) == Rx_D)
                //begin  
                    next_state = r_stop_bit;
                //end
                //else
               // begin
                    //Rx_PERROR = 1;
                    //next_state = parity_error;
                //end
            end
        end

        r_stop_bit:
        begin
            if(sampling == 4'b1010)
            begin
                //if(Rx_D == 1)
                    next_state = valid;
                //else
                  //  next_state = frame_error;
            end
        end
    
        valid:
        begin
            if (Rx_D == 0)
            begin
                enable = 0;
                next_state = r_start_bit;
            end
            else
            begin
                next_state = valid;
                Rx_VALID = 1;
//                Rx_DATA = tmp;
                data_valid = 1;
            end
        end

        parity_error:
        begin
            //Rx_PERROR = 1;
            if(Rx_EN == 0)
            begin
                enable = 0;
                next_state = r_off;
            end
            else
            begin
                next_state = parity_error;
            end
        end

        frame_error:
        begin
            //Rx_FERROR = 1;
            if(Rx_EN == 0)
            begin
                enable = 0;
                next_state = r_off;
            end
            else
            begin
                next_state = frame_error;
            end
        end

        default:
            //$monitor("error");
            next_state = r_off;
    endcase
end

//always @(posedge)



always @(posedge clk)          // counter gia na metrisi 8 kiklous gia tin proti digmatolipsia
begin
    if(reset)
    begin
        counter <= 0;
        sampling <= 0;
    end
    else
    begin
        if(enable == 1)
        begin
            if(sample_ENABLE == 1)
            begin
                counter <= counter + 1;
                if(counter == 4'b1111)
                    sampling <= sampling + 4'b0001;
            end
        end
        else
        begin
            counter <= 0;
            sampling <= 0;
        end
    end
end

always @(posedge clk)
begin
    if(reset)
        Rx_DATA <= 8'b0;
    else
    begin
        if(data_valid)
            Rx_DATA <= tmp;
    end
end


Baud_controller Baud_controller_tx_inst(.reset(reset), .clk(clk), .baud_select(baud_select), .sample_ENABLE(sample_ENABLE));
SIPO Sipo_inst(.clk(clk), .reset(reset), .SI(Rx_D), .shift(shift_out), .PO(tmp));  

endmodule

