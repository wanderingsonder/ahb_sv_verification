class ahb_scoreboard;
   ahb_transaction tr;
   //event sconext,next;
   mailbox #(ahb_transaction)mbxms;
   bit [7:0] mem[256];
   ahb_coverage h_ahb;
   int count = 0;
   int len = 0;
   bit [31:0]rdata;

   function new(mailbox #(ahb_transaction)mbxms);
      this.mbxms=mbxms;
      h_ahb=new();
   endfunction

   task run();
      forever begin
         mbxms.get(tr);
         h_ahb.collect(tr);
         $display("[SCO]:got packet from monitor");
         if(tr.hwrite == 1'b1)begin
         $display("[SCO]: Data Write");
         mem[tr.haddr] = tr.hwdata[7:0];
         mem[tr.haddr+1] = tr.hwdata[15:8];
         mem[tr.haddr+2] = tr.hwdata[23:16];
         mem[tr.haddr+3] = tr.hwdata[31:24];
      end

       if(tr.hwrite ==1'b0)begin
         rdata = {mem[tr.haddr+3],mem[tr.haddr+2],mem[tr.haddr+1],mem[tr.haddr]};

         if(tr.hrdata == 32'h0000_0000) begin
            $display("[SCO]:EMPTY LOCATION");end

         else if(tr.hrdata == rdata) begin
            $display("[SCO]: [PASS] DATA MATCHED");end

         else
            $display("[SCO]: [FAIL] DATA MIS_MATCHED");
      end
        // ->sconext;
    // ->next;
    s_flag=1;
   end
   endtask
endclass
