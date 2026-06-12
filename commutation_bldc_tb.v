`timescale 1ns / 1ps

module commutation_bldc_tb( );
         wire AH, AL; 
         wire BH, BL; 
         wire CH, CL; 
         reg clk, rst_n, enable;
         reg [15:0]duty;
         reg [2:0] hall;
         
         commutation_bldc uut(.clk(clk), .rst_n(rst_n), .enable(enable), .hall(hall), .duty(duty), 
                               .AH(AH), .AL(AL), .BH(BH), .BL(BL), .CH(CH), .CL(CL) );
                               
        always #5 clk=~clk;
        initial begin
            clk=0;
            rst_n=0;
            hall=3'b001;
            duty=16'd625;
            enable=1;
            
            //resr release
            #40;
            rst_n=1;
            #100;
            hall=3'b101;#1000;
            hall=3'b001;#1000;
            hall=3'b011;#1000;
            hall=3'b010;#1000;             
            hall=3'b110;#1000; 
            hall=3'b100;#1000; 
            
            
           
            $display("simulation finished");
            $finish;
         end
         initial begin
         $monitor("time=%0t |hall=%0b |AH=%0b AL=%0b |BH=%0B BL=%0b |CH=%0b CL=%0b  ", $time, hall, AH, AL, BH, BL, CH, CL);
         end
endmodule
