//4 bit adder
module adder_4bit(input [3:0] A, B, input Cin, Cin_apx, input sel, output C_actual, C_approx, output [3:0] S);
  
  wire [3:0] P,G;
  wire [2:0] C;
  wire Cin_;
  assign P = A ^ B;
  assign G = A & B;
  assign Cin_ = sel? Cin:Cin_apx;
  
  assign S[0] = P[0] ^ Cin;
  assign C[0] = G[0] | (P[0] & Cin_);
  
  assign S[1] = P[1] ^ C[0];
  assign C[1] = G[1] | (P[1] & C[0]);
  
  assign S[2] = P[2] ^ C[1];
  assign C[2] = G[2] | (P[2] & C[1]);
  
  assign S[3] = P[3] ^ C[2];
  assign C_actual = G[3] | (P[3] & C[2]);
  
  assign C_approx = G[3] | (P[3] & (G[2] | (P[2] & (G[1] | (P[1] & G[0])))));
endmodule

//24 bit adder
module adder_24bit(input [23:0] A,B, input Cin, input [4:0] sel, output C_actual_final,C_approx_final, output [23:0] S);
  wire [5:0] C_actual,C_approx;
  wire sel1;
  assign sel1 = 1'b1;
  
  //calling 6 instances of 4 bit adder
  adder_4bit a0(.A(A[3:0]),.B(B[3:0]),.Cin(Cin),.Cin_apx(Cin),.sel(sel1),.C_actual(C_actual[0]),.C_approx(C_approx[0]),.S(S[3:0]));
  adder_4bit a1(.A(A[7:4]),.B(B[7:4]),.Cin(C_actual[0]),.Cin_apx(C_approx[0]),.sel(sel[0]),.C_actual(C_actual[1]),.C_approx(C_approx[1]),.S(S[7:4]));
  adder_4bit a2(.A(A[11:8]),.B(B[11:8]),.Cin(C_actual[1]),.Cin_apx(C_approx[1]),.sel(sel[1]),.C_actual(C_actual[2]),.C_approx(C_approx[2]),.S(S[11:8]));
  adder_4bit a3(.A(A[15:12]),.B(B[15:12]),.Cin(C_actual[2]),.Cin_apx(C_approx[2]),.sel(sel[2]),.C_actual(C_actual[3]),.C_approx(C_approx[3]),.S(S[15:12]));
  adder_4bit a4(.A(A[19:16]),.B(B[19:16]),.Cin(C_actual[3]),.Cin_apx(C_approx[3]),.sel(sel[3]),.C_actual(C_actual[4]),.C_approx(C_approx[4]),.S(S[19:16]));
  adder_4bit a5(.A(A[23:20]),.B(B[23:20]),.Cin(C_actual[4]),.Cin_apx(C_approx[4]),.sel(sel[4]),.C_actual(C_actual[5]),.C_approx(C_approx[5]),.S(S[23:20]));
  
  assign C_actual_final = C_actual[5];
  assign C_approx_final = C_approx[5];
endmodule


//32 bit adder
module adder_32bit(input [31:0] A,B, input Cin, input [6:0] sel, output C_actual_final, C_approx_final, output [31:0] S);
  
  wire [7:0] C_actual, C_approx;
  wire sel1;
  assign sel1 = 1'b1;
  
  // Calling 8 instances of 4 bit adder
  adder_4bit a0 (.A(A[3:0]),   .B(B[3:0]),   .Cin(Cin),         .Cin_apx(Cin),         .sel(sel1),   .C_actual(C_actual[0]), .C_approx(C_approx[0]), .S(S[3:0]));
  adder_4bit a1 (.A(A[7:4]),   .B(B[7:4]),   .Cin(C_actual[0]), .Cin_apx(C_approx[0]), .sel(sel[0]), .C_actual(C_actual[1]), .C_approx(C_approx[1]), .S(S[7:4]));
  adder_4bit a2 (.A(A[11:8]),  .B(B[11:8]),  .Cin(C_actual[1]), .Cin_apx(C_approx[1]), .sel(sel[1]), .C_actual(C_actual[2]), .C_approx(C_approx[2]), .S(S[11:8]));
  adder_4bit a3 (.A(A[15:12]), .B(B[15:12]), .Cin(C_actual[2]), .Cin_apx(C_approx[2]), .sel(sel[2]), .C_actual(C_actual[3]), .C_approx(C_approx[3]), .S(S[15:12]));
  adder_4bit a4 (.A(A[19:16]), .B(B[19:16]), .Cin(C_actual[3]), .Cin_apx(C_approx[3]), .sel(sel[3]), .C_actual(C_actual[4]), .C_approx(C_approx[4]), .S(S[19:16]));
  adder_4bit a5 (.A(A[23:20]), .B(B[23:20]), .Cin(C_actual[4]), .Cin_apx(C_approx[4]), .sel(sel[4]), .C_actual(C_actual[5]), .C_approx(C_approx[5]), .S(S[23:20]));
  adder_4bit a6 (.A(A[27:24]), .B(B[27:24]), .Cin(C_actual[5]), .Cin_apx(C_approx[5]), .sel(sel[5]), .C_actual(C_actual[6]), .C_approx(C_approx[6]), .S(S[27:24]));
  adder_4bit a7 (.A(A[31:28]), .B(B[31:28]), .Cin(C_actual[6]), .Cin_apx(C_approx[6]), .sel(sel[6]), .C_actual(C_actual[7]), .C_approx(C_approx[7]), .S(S[31:28]));
  
  assign C_actual_final = C_actual[7];
  assign C_approx_final = C_approx[7];

endmodule

//48 bit adder
module adder_48bit(input [47:0] A, B, input Cin, input [9:0] sel, output C_actual_final, C_approx_final, output [47:0] S);
  
  wire [11:0] C_actual, C_approx;
  wire sel1;
  assign sel1 = 1'b1;
  
  // Calling 12 instances of 4 bit adder
  adder_4bit a0(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .Cin_apx(Cin), .sel(sel1), .C_actual(C_actual[0]), .C_approx(C_approx[0]), .S(S[3:0]));
  adder_4bit a1(.A(A[7:4]), .B(B[7:4]), .Cin(C_actual[0]), .Cin_apx(C_approx[0]), .sel(sel[0]), .C_actual(C_actual[1]), .C_approx(C_approx[1]), .S(S[7:4]));
  adder_4bit a2(.A(A[11:8]), .B(B[11:8]), .Cin(C_actual[1]), .Cin_apx(C_approx[1]), .sel(sel[1]), .C_actual(C_actual[2]), .C_approx(C_approx[2]), .S(S[11:8]));
  adder_4bit a3(.A(A[15:12]), .B(B[15:12]), .Cin(C_actual[2]), .Cin_apx(C_approx[2]), .sel(sel[2]), .C_actual(C_actual[3]), .C_approx(C_approx[3]), .S(S[15:12]));
  adder_4bit a4(.A(A[19:16]), .B(B[19:16]), .Cin(C_actual[3]), .Cin_apx(C_approx[3]), .sel(sel[3]), .C_actual(C_actual[4]), .C_approx(C_approx[4]), .S(S[19:16]));
  adder_4bit a5(.A(A[23:20]), .B(B[23:20]), .Cin(C_actual[4]), .Cin_apx(C_approx[4]), .sel(sel[4]), .C_actual(C_actual[5]), .C_approx(C_approx[5]), .S(S[23:20]));
  adder_4bit a6(.A(A[27:24]), .B(B[27:24]), .Cin(C_actual[5]), .Cin_apx(C_approx[5]), .sel(sel[5]), .C_actual(C_actual[6]), .C_approx(C_approx[6]), .S(S[27:24]));
  adder_4bit a7(.A(A[31:28]), .B(B[31:28]), .Cin(C_actual[6]), .Cin_apx(C_approx[6]), .sel(sel[6]), .C_actual(C_actual[7]), .C_approx(C_approx[7]), .S(S[31:28]));
  adder_4bit a8(.A(A[35:32]), .B(B[35:32]), .Cin(C_actual[7]), .Cin_apx(C_approx[7]), .sel(sel[7]), .C_actual(C_actual[8]), .C_approx(C_approx[8]), .S(S[35:32]));
  adder_4bit a9(.A(A[39:36]), .B(B[39:36]), .Cin(C_actual[8]), .Cin_apx(C_approx[8]), .sel(sel[8]), .C_actual(C_actual[9]), .C_approx(C_approx[9]), .S(S[39:36]));
  adder_4bit a10(.A(A[43:40]), .B(B[43:40]), .Cin(C_actual[9]), .Cin_apx(C_approx[9]), .sel(sel[9]), .C_actual(C_actual[10]),.C_approx(C_approx[10]),.S(S[43:40]));
  adder_4bit a11(.A(A[47:44]), .B(B[47:44]), .Cin(C_actual[10]),.Cin_apx(C_actual[10]),.sel(sel1),  .C_actual(C_actual[11]),.C_approx(C_approx[11]),.S(S[47:44]));
  
  assign C_actual_final = C_actual[11];
  assign C_approx_final = C_approx[11];

endmodule




//2x2 multiplier
module multiplier_2by2(input [1:0] A,B, output [3:0] P);
  //bit propagate signals
  wire PP00,PP01,PP10,PP11;
  assign PP00 = A[0] & B[0];
  assign PP01 = A[0] & B[1];
  assign PP10 = A[1] & B[0];
  assign PP11 = A[1] & B[1];
  //group propagate signal
  assign P[0] = PP00;
  assign P[1] = PP01 ^ PP10;
  assign P[2] = (PP01 & PP10) ^ PP11;
  assign P[3] = PP01 & PP10 & PP11;
endmodule

//4x4 multiplier
module multiplier_4by4(input [3:0] A,B, output [7:0]AB);
  wire [3:0] ALBL,ALBH,AHBL,AHBH;
  multiplier_2by2 m1(.A(A[1:0]),.B(B[1:0]),.P(ALBL));
  multiplier_2by2 m2(.A(A[1:0]),.B(B[3:2]),.P(ALBH));
  multiplier_2by2 m3(.A(A[3:2]),.B(B[1:0]),.P(AHBL));
  multiplier_2by2 m4(.A(A[3:2]),.B(B[3:2]),.P(AHBH));
  
  wire [4:0] add_out1;
  assign add_out1 = ALBH + AHBL; //exact adder
  
  wire [5:0] add_out2;
  assign add_out2 = {AHBH,ALBL[3:2]} + add_out1; //exact adder
  
  assign AB = {add_out2,ALBL[1:0]};
endmodule

//8x8 multiplier
module multiplier_8by8(input [7:0] A,B, output [15:0] AB);
  wire [7:0] ALBL,ALBH,AHBL,AHBH;
  multiplier_4by4 m1(.A(A[3:0]),.B(B[3:0]),.AB(ALBL));
  multiplier_4by4 m2(.A(A[3:0]),.B(B[7:4]),.AB(ALBH));
  multiplier_4by4 m3(.A(A[7:4]),.B(B[3:0]),.AB(AHBL));
  multiplier_4by4 m4(.A(A[7:4]),.B(B[7:4]),.AB(AHBH));
  
  wire [8:0] add_out1;
  assign add_out1 = ALBH + AHBL; //exact adder
  
  wire [11:0] add_out2;
  assign add_out2 = {AHBH,ALBL[7:4]} + add_out1; //exact adder
  
  assign AB = {add_out2,ALBL[3:0]};
endmodule

//16x16 multiplier
module multiplier_16by16(input [15:0] A,B, input [4:0] sel, output [31:0] AB);
  wire [15:0] ALBL,ALBH,AHBL,AHBH;
  multiplier_8by8 m1(.A(A[7:0]),.B(B[7:0]),.AB(ALBL));
  multiplier_8by8 m2(.A(A[7:0]),.B(B[15:8]),.AB(ALBH));
  multiplier_8by8 m3(.A(A[15:8]),.B(B[7:0]),.AB(AHBL));
  multiplier_8by8 m4(.A(A[15:8]),.B(B[15:8]),.AB(AHBH));
  
  wire [16:0] add_out1;
  assign add_out1 = ALBH + AHBL; //exact adder
  
  wire [23:0] add_out2;
  wire Cout,Cout_apx;
  //apx adder, here sel is the apx selector of 5 stages, 1=exact, 0=apx
  adder_24bit a1(.A({AHBH,ALBL[15:8]}), .B({7'b0,add_out1}), .Cin(0), .sel(sel), .C_actual_final(Cout), .C_approx_final(Cout_apx), .S(add_out2));
  
  assign AB = {add_out2,ALBL[7:0]};
endmodule

//32x32 multiplier
module multiplier_32by32(input [31:0] A,B, input [4:0] sel24, input [6:0] sel32, input [9:0] sel48, output [63:0] AB);
  wire [31:0] ALBL,ALBH,AHBL,AHBH;
  multiplier_16by16 m1(.A(A[15:0]), .B(B[15:0]), .sel(sel24), .AB(ALBL));
  multiplier_16by16 m2(.A(A[15:0]), .B(B[31:16]), .sel(sel24), .AB(ALBH));
  multiplier_16by16 m3(.A(A[31:16]), .B(B[15:0]), .sel(sel24), .AB(AHBL));
  multiplier_16by16 m4(.A(A[31:16]), .B(B[31:16]), .sel(5'b11111), .AB(AHBH)); //24 bit exact adder for AHBH
  
  wire [32:0] add_out1;
  wire Cout_apx;
  //32 bit apx adder here
  adder_32bit a32(.A(ALBH), .B(AHBL), .Cin(0), .sel(sel32), .C_actual_final(add_out1[32]), .C_approx_final(Cout_apx), .S(add_out1[31:0]));
  
  
  wire [47:0] add_out2;
  wire Cout,Cout_apx1;
  //48 bit modified apx adder here
  adder_48bit a48(.A({AHBH,ALBL[31:16]}), .B({15'b0,add_out1}), .Cin(0), .sel(sel48), .C_actual_final(Cout), .C_approx_final(Cout_apx1), .S(add_out2));
  
  assign AB = {add_out2,ALBL[15:0]};
endmodule

//Final Module
module farm(input clk, reset, input [31:0] A, B, input [4:0] sel24, input [6:0] sel32, input [9:0] sel48, output reg [63:0] AB);
    reg [31:0] A_reg;
    reg [31:0] B_reg;
    reg [4:0] sel24_reg;
    reg [6:0] sel32_reg;
    reg [9:0] sel48_reg;

    wire [63:0] mul_result;

    always @(posedge clk) begin
        if (reset) begin
            A_reg     <= 32'b0;
            B_reg     <= 32'b0;
            sel24_reg <= 5'b0;
            sel32_reg <= 7'b0;
            sel48_reg <= 10'b0;
        end else begin
            A_reg     <= A;
            B_reg     <= B;
            sel24_reg <= sel24;
            sel32_reg <= sel32;
            sel48_reg <= sel48;
        end
    end

    multiplier_32by32 my_mult (
        .A(A_reg),
        .B(B_reg),
        .sel24(sel24_reg),
        .sel32(sel32_reg),
        .sel48(sel48_reg),
        .AB(mul_result)
    );

    always @(posedge clk) begin
        if (reset) begin
            AB <= 64'b0;
        end else begin
            AB <= mul_result;
        end
    end

endmodule
