`timescale 1ns / 1ps
module commutation_bldc(
                    output reg AH, AL, 
                    output reg BH, BL, 
                    output reg CH, CL, 
                    input clk, rst_n, enable,
                    input [15:0]duty,
                    input [2:0] hall
    );
    parameter PWM_MAX=1250;
    parameter DEADTIME=6'd50;;
    reg [15:0]carrier;
    reg direction;
    reg [2:0]hall_sync, hall_last;
    
    //2 - stage synchronisation
    reg [2:0]hall_r, hall_rr; // 3 signals 
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            hall_r<=3'b0;
            hall_rr<=3'b0;
        end else begin
            hall_r<=hall;
            hall_rr<=hall_r; 
        end 
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            carrier<=16'd0;
            direction<=1'b0;
            hall_sync<=3'b0;
            hall_last<=3'b0;
        end else begin
            hall_sync<=hall_rr;
            hall_last<=hall_sync;
            
        // center alligned PWM
        if(direction==1'b0) begin
            if(carrier>=PWM_MAX)
                direction<=1'b1;
            else 
                carrier <=carrier +1'b1;
            end else begin
            if(carrier!=16'd0)
                direction<=1'b0;
            else 
                carrier<=carrier-1'b1;
            end
         end
    end
    
    wire [15:0]duty_limited=(duty>PWM_MAX)?PWM_MAX:duty;
    wire pwm_sig=((carrier<duty_limited)&enable);
    
    reg AH_cmd, AL_cmd, BH_cmd, BL_cmd, CH_cmd, CL_cmd;
    always@(*)begin
         {AH_cmd, AL_cmd, BH_cmd, BL_cmd, CH_cmd, CL_cmd}=6'b0;
         if(enable)begin
            case(hall_sync)
                3'b101:begin AH_cmd=1;BL_cmd=1; end
                3'b001:begin BH_cmd=1;CL_cmd=1; end
                3'b011:begin BH_cmd=1;CL_cmd=1; end
                3'b010:begin AH_cmd=1;CL_cmd=1;end
                3'b110:begin AH_cmd=1;BL_cmd=1; end
                3'b100:begin BH_cmd=1;AL_cmd=1; end
               
                default:;
             endcase
         end
    end
    
    //deadtime
    reg[5:0]dtA, dtB, dtC;
    wire sector_change=(hall_sync!=hall_last);
    //PHASE A control
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n || !enable)begin
            AH<=0; AL<=0;dtA<=0;
            hall_last<=3'b000;
        end else if(sector_change)begin
            AH<=0; AL<=0;dtA<=DEADTIME;
        end else if(dtA!=0)begin
            dtA<=dtA-1'b1;
            AH<=0; AL<=0;
        end else begin
            hall_last<=hall_sync;
            AH<=(AH_cmd && !AL_cmd)?pwm_sig:1'b0;
            AL<=(AL_cmd && !AH_cmd)?1'b1:1'b0;
        end
    end
    
    // PHASE B control
      always@(posedge clk or negedge rst_n)begin
        if(!rst_n || !enable)begin
            BH<=0; BL<=0;dtB<=0;
            hall_last<=3'b000;
        end else if(sector_change)begin
            BH<=0; BL<=0;dtB<=DEADTIME;
        end else if(dtB!=0)begin
            dtB<=dtB-1'b1;
            BH<=0; BL<=0;
        end else begin
            hall_last<=hall_sync;
            BH<=(BH_cmd && !BL_cmd)?pwm_sig:1'b0;
            BL<=(BL_cmd && !BH_cmd)?1'b1:1'b0;
        end
    end        
    
     // PHASE C control
      always@(posedge clk or negedge rst_n)begin
        if(!rst_n || !enable)begin
            CH<=0; CL<=0;dtC<=0;
            hall_last<=3'b000;
        end else if(sector_change)begin
            CH<=0; CL<=0;dtC<=DEADTIME;
        end else if(dtB!=0)begin
            dtC<=dtC-1'b1;
            CH<=0;CL<=0;
        end else begin
            hall_last<=hall_sync;
            CH<=(CH_cmd && !CL_cmd)?pwm_sig:1'b0;
            CL<=(CL_cmd && !CH_cmd)?1'b1:1'b0;
        end
    end    
endmodule
