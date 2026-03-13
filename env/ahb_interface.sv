interface ahb_interface;

   ////////////////////////////////////////////////////////////
   // AHB SIGNALS
   ////////////////////////////////////////////////////////////

   logic        clk;
   logic [31:0] hwdata;
   logic [31:0] haddr;
   logic [2:0]  hsize;
   logic [2:0]  hburst;
   logic [1:0]  htrans;
   logic        hresetn;
   logic        hsel;
   logic        hwrite;

   logic [1:0]  hresp;
   logic        hready;
   logic [31:0] hrdata;


   ////////////////////////////////////////////////////////////
   // ASSERTION PASS / FAIL COUNTERS
   ////////////////////////////////////////////////////////////

   int a1_pass = 0, a1_fail = 0;
   int a3_pass = 0, a3_fail = 0;
   int a4_pass = 0, a4_fail = 0;
   int a5_pass = 0, a5_fail = 0;
   int a6_pass = 0, a6_fail = 0;


   ////////////////////////////////////////////////////////////
   // ASSERTION 1
   // BUS MUST BE IDLE AFTER RESET
   ////////////////////////////////////////////////////////////

   property p_reset_to_idle;

      @(posedge clk)
      $rose(hresetn) |-> (htrans == 2'b00);

   endproperty


   A_RESET_TO_IDLE : assert property(p_reset_to_idle)
   begin
      a1_pass++;
      if(a1_pass <= 5)
         $display("[SVA PASS] A_RESET_TO_IDLE pass#%0d time=%0t", a1_pass, $time);
   end
   else
   begin
      a1_fail++;
      if(a1_fail <= 5)
         $error("[SVA FAIL] A_RESET_TO_IDLE fail#%0d time=%0t", a1_fail, $time);
   end


   ////////////////////////////////////////////////////////////
   // ASSERTION 2
   // HRESP MUST BE OKAY FOR VALID ADDRESSES
   ////////////////////////////////////////////////////////////

   property p_hresp_okay;

      @(posedge clk) disable iff(!hresetn)
      (hsel && hready && (haddr < 256)) |-> (hresp == 2'b00);

   endproperty


   A_HRESP_OKAY : assert property(p_hresp_okay)
   begin
      a3_pass++;
      if(a3_pass <= 5)
         $display("[SVA PASS] A_HRESP_OKAY pass#%0d time=%0t", a3_pass, $time);
   end
   else
   begin
      a3_fail++;
      if(a3_fail <= 5)
         $error("[SVA FAIL] A_HRESP_OKAY fail#%0d time=%0t", a3_fail, $time);
   end


   ////////////////////////////////////////////////////////////
   // ASSERTION 3
   // SEQ MUST FOLLOW NONSEQ OR SEQ
   ////////////////////////////////////////////////////////////

   property p_seq_after_nonseq;

      @(posedge clk) disable iff(!hresetn)
      (htrans == 2'b11) |-> $past(htrans inside {2'b10,2'b11});

   endproperty


   A_SEQ_AFTER_NONSEQ : assert property(p_seq_after_nonseq)
   begin
      a4_pass++;
      if(a4_pass <= 5)
         $display("[SVA PASS] A_SEQ_AFTER_NONSEQ pass#%0d time=%0t", a4_pass, $time);
   end
   else
   begin
      a4_fail++;
      if(a4_fail <= 5)
         $error("[SVA FAIL] A_SEQ_AFTER_NONSEQ fail#%0d time=%0t", a4_fail, $time);
   end


   ////////////////////////////////////////////////////////////
   // ASSERTION 4
   // HADDR MUST STAY STABLE WHEN HREADY = 0
   ////////////////////////////////////////////////////////////

   property p_haddr_stable_on_wait;

      @(posedge clk) disable iff(!hresetn)
      (!hready && hsel && (htrans inside {2'b10,2'b11})) |=> $stable(haddr);

   endproperty


   A_HADDR_STABLE : assert property(p_haddr_stable_on_wait)
   begin
      a5_pass++;
      if(a5_pass <= 5)
         $display("[SVA PASS] A_HADDR_STABLE pass#%0d time=%0t", a5_pass, $time);
   end
   else
   begin
      a5_fail++;
      if(a5_fail <= 5)
         $error("[SVA FAIL] A_HADDR_STABLE fail#%0d time=%0t", a5_fail, $time);
   end


   ////////////////////////////////////////////////////////////
   // ASSERTION 5
   // HWRITE MUST REMAIN STABLE DURING BURST
   ////////////////////////////////////////////////////////////

   property p_hwrite_stable_in_burst;

      @(posedge clk) disable iff(!hresetn)
      (hsel && hready && (htrans == 2'b10)) |=> $stable(hwrite) [*1:16];

   endproperty


   A_HWRITE_STABLE : assert property(p_hwrite_stable_in_burst)
   begin
      a6_pass++;
      if(a6_pass <= 5)
         $display("[SVA PASS] A_HWRITE_STABLE pass#%0d time=%0t", a6_pass, $time);
   end
   else
   begin
      a6_fail++;
      if(a6_fail <= 5)
         $error("[SVA FAIL] A_HWRITE_STABLE fail#%0d time=%0t", a6_fail, $time);
   end


   ////////////////////////////////////////////////////////////
   // COVER PROPERTIES
   ////////////////////////////////////////////////////////////

   COV_SINGLE_WRITE :
      cover property(@(posedge clk) disable iff(!hresetn)
      (hsel && hwrite && (htrans==2'b10) && (hburst==3'b000)));

   COV_BURST_WRAP4 :
      cover property(@(posedge clk) disable iff(!hresetn)
      (hsel && (htrans==2'b10) && (hburst==3'b010)));

   COV_BURST_INCR8 :
      cover property(@(posedge clk) disable iff(!hresetn)
      (hsel && (htrans==2'b10) && (hburst==3'b101)));

   COV_READ_AFTER_WRITE :
      cover property(@(posedge clk) disable iff(!hresetn)
      (hsel && hwrite && hready) ##[1:5] (hsel && !hwrite && hready));

endinterface
