class ahb_scoreboard;

   ////////////////////////////////////////////////////////////
   // MAILBOX
   ////////////////////////////////////////////////////////////

   mailbox #(ahb_transaction) mbxms;

   ////////////////////////////////////////////////////////////
   // TRANSACTION HANDLE
   ////////////////////////////////////////////////////////////

   ahb_transaction tr;

   ////////////////////////////////////////////////////////////
   // REFERENCE MEMORY MODEL
   ////////////////////////////////////////////////////////////

   bit [7:0] mem [256];

   ////////////////////////////////////////////////////////////
   // COVERAGE
   ////////////////////////////////////////////////////////////

   ahb_coverage h_ahb;

   ////////////////////////////////////////////////////////////
   // TEMP READ DATA
   ////////////////////////////////////////////////////////////

   bit [31:0] expected_rdata;


   ////////////////////////////////////////////////////////////
   // CONSTRUCTOR
   ////////////////////////////////////////////////////////////

   function new(mailbox #(ahb_transaction) mbxms);

      this.mbxms = mbxms;

      h_ahb = new();

      foreach(mem[i])
         mem[i] = 8'h00;

   endfunction


   ////////////////////////////////////////////////////////////
   // SCOREBOARD RUN TASK
   ////////////////////////////////////////////////////////////

   task run();

      forever
      begin

         mbxms.get(tr);

         //---------------------------------------------------
         // SAMPLE COVERAGE
         //---------------------------------------------------

         h_ahb.collect(tr);

         $display("[SCO] Packet received");


         //---------------------------------------------------
         // WRITE OPERATION
         //---------------------------------------------------

         if(tr.hwrite)
         begin

            if(tr.haddr < 252)
            begin

               mem[tr.haddr]   = tr.hwdata[7:0];
               mem[tr.haddr+1] = tr.hwdata[15:8];
               mem[tr.haddr+2] = tr.hwdata[23:16];
               mem[tr.haddr+3] = tr.hwdata[31:24];

               $display("[SCO] WRITE addr=%0h data=%0h",
                        tr.haddr,tr.hwdata);

            end
            else
            begin

               $display("[SCO] ERROR: Address out of range");

            end

         end


         //---------------------------------------------------
         // READ OPERATION
         //---------------------------------------------------

         else
         begin

            if(tr.haddr < 252)
            begin

               expected_rdata = {
                  mem[tr.haddr+3],
                  mem[tr.haddr+2],
                  mem[tr.haddr+1],
                  mem[tr.haddr]
               };

               $display("[SCO] READ addr=%0h hrdata=%0h expected=%0h",
                        tr.haddr,tr.hrdata,expected_rdata);

               if(expected_rdata == 32'h00000000)
               begin

                  $display("[SCO] INFO: location not written yet");

               end
               else if(tr.hrdata == expected_rdata)
               begin

                  $display("[SCO] PASS: data matched");

               end
               else
               begin

                  $display("[SCO] FAIL: data mismatch");

               end

            end
            else
            begin

               $display("[SCO] ERROR: Address out of range");

            end

         end


         //---------------------------------------------------
         // DISPLAY COVERAGE
         //---------------------------------------------------

         $display("[SCO] Functional Coverage = %0.2f %% ",
                  h_ahb.ahb_cover.get_coverage());


         //---------------------------------------------------
         // SIGNAL SCOREBOARD COMPLETE
         //---------------------------------------------------

         s_flag = 1;

      end

   endtask


endclass
