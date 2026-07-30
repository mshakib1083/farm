module farm_tb();

  reg clk;
  reg reset;
  reg [31:0] A, B;
  reg [4:0]  sel24;
  reg [6:0]  sel32;
  reg [9:0]  sel48;
  wire [63:0] AB;

  integer error_count;
  integer approx_count;
  integer vector_count;
  integer csv;
  reg [63:0] expected_AB;

  parameter N_VEC = 2000;

  farm dut (
    .clk(clk),
    .reset(reset),
    .A(A),
    .B(B),
    .sel24(sel24),
    .sel32(sel32),
    .sel48(sel48),
    .AB(AB)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  task test_multiplier;
    input [31:0] val_A;
    input [31:0] val_B;
    input [4:0]  val_sel24;
    input [6:0]  val_sel32;
    input [9:0]  val_sel48;
    input        is_exact_mode;
    begin
      @(negedge clk);
      A     = val_A;
      B     = val_B;
      sel24 = val_sel24;
      sel32 = val_sel32;
      sel48 = val_sel48;

      @(negedge clk);
      @(negedge clk);

      expected_AB = val_A;
      expected_AB = expected_AB * val_B;

      $fdisplay(csv, "%h,%h,%h,%h,%h,%h",
                val_A, val_B, val_sel24, val_sel32, val_sel48, AB);
      vector_count = vector_count + 1;

      if (AB !== expected_AB) begin
        if (is_exact_mode) begin
          $display("  MISMATCH | A=%0d B=%0d", val_A, val_B);
          $display("           Expected: %0d", expected_AB);
          $display("           Got     : %0d", AB);
          error_count = error_count + 1;
        end else begin
          approx_count = approx_count + 1;
        end
      end
    end
  endtask

  task run_config;
    input [4:0] c24;
    input [6:0] c32;
    input [9:0] c48;
    input       is_exact_mode;
    integer i;
    begin
      error_count  = 0;
      approx_count = 0;
      $display("sel24=%h sel32=%h sel48=%h  (%0d vectors)",
               c24, c32, c48, N_VEC);
      for (i = 0; i < N_VEC; i = i + 1) begin
        test_multiplier($random, $random, c24, c32, c48, is_exact_mode);
      end
      if (is_exact_mode) begin
        if (error_count == 0)
          $display("exact mode: 0 errors");
        else
          $display("exact mode: %0d ERRORS", error_count);
      end else begin
        $display("%0d of %0d vectors deviate from the exact product",
                 approx_count, N_VEC);
      end
    end
  endtask

  initial begin
    csv = $fopen("rtl_vectors.csv", "w");
    if (csv == 0) begin
      $display("cannot open csv for writing");
      $finish;
    end

    A = 0; B = 0;
    sel24 = 0; sel32 = 0; sel48 = 0;
    error_count = 0; approx_count = 0; vector_count = 0;

    reset = 1;
    @(negedge clk);
    @(negedge clk);
    reset = 0;
    // Reset complete

    // C0 exact (=V4)
    run_config(5'h1F, 7'h7F, 10'h3FF, 1'b1);
    // C1 all-zeros (=V1)
    run_config(5'h00, 7'h00, 10'h000, 1'b0);
    // C2 (=V2)
    run_config(5'h1B, 7'h00, 10'h000, 1'b0);
    // C3 (=V3)
    run_config(5'h1B, 7'h55, 10'h155, 1'b0);
    // C4 32/48 exact, 24-bit approximate
    run_config(5'h00, 7'h7F, 10'h3FF, 1'b0);

    $fclose(csv);
    $finish;
  end

endmodule