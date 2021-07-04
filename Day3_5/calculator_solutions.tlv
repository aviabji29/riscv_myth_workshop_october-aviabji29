\m4_TLV_version 1d: tl-x.org
\SV
//Calculator labs solutions here

\m4_TLV_version 1d: tl-x.org
\SV

   // =========================================
   // Welcome!  Try the tutorials via the menu.
   // =========================================

   // Default Makerchip TL-Verilog Code Template
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   
   //cobinational calc
\TLV
   $reset = *reset;

   $sum[31:0]  = $val1[31:0] + $val2[31:0] ;
   $diff[31:0] = $val1[31:0] - $val2[31:0] ;
   $prod[31:0] = $val1[31:0] * $val2[31:0] ;
   $quot[31:0] = $val1[31:0] / $val2[31:0] ;

   $out[31:0] = $op[0] ? ($op[1] ? $quot : $diff ) : ($op[1] ? $prod : $sum ) ;

   $val1[31:0] = $rand1[3:0] ;
   $val2[31:0] = $rand2[3:0] ;

   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule



---------------------------------------------------------------------------------------------------------------------------------------------------------------

   //sequential calc
\TLV
   $reset = *reset;

   $sum[31:0]  = $val1[31:0] + $val2[31:0] ;
   $diff[31:0] = $val1[31:0] - $val2[31:0] ;
   $prod[31:0] = $val1[31:0] * $val2[31:0] ;
   $quot[31:0] = $val1[31:0] / $val2[31:0] ;
   $out[31:0] = $reset ? 0 : $op[0] ? ($op[1] ? $quot : $diff ) : ($op[1] ? $prod : $sum ); 
   $val1[31:0] = >>1$out[31:0] ;
   
   $val2[31:0] = $rand2[3:0] ;
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
   
 -----------------------------------------------------------------------------------------------------------------------  
 //pipeline example(seq_calc + cntr)
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   $reset = *reset;

   |calc
      @1
         $sum[31:0]  = $val1[31:0] + $val2[31:0] ;
         $diff[31:0] = $val1[31:0] - $val2[31:0] ;
         $prod[31:0] = $val1[31:0] * $val2[31:0] ;
         $quot[31:0] = $val1[31:0] / $val2[31:0] ;
         $out[31:0] = $reset ? 0 : $op[0] ? ($op[1] ? $quot : $diff ) : ($op[1] ? $prod : $sum ); 
         $val1[31:0] = >>1$out[31:0] ;
         $val2[31:0] = $rand2[31:0] ;
         $cnt[31:0] = $reset ? 0 : (>>1$cnt+ 1 ) ;

   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
--------------------------------------------------------------------------------------------------------------------------------------------------------------
   
 
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   //cycle_calc
\TLV
   $reset = *reset;

   |calc
      @1
         $sum[31:0]  = $val1[31:0] + $val2[31:0] ;
         $diff[31:0] = $val1[31:0] - $val2[31:0] ;
         $prod[31:0] = $val1[31:0] * $val2[31:0] ;
         $quot[31:0] = $val1[31:0] / $val2[31:0] ;

         $val1[31:0] = >>2$out[31:0] ;
         $val2[31:0] = $rand2[3:0] ;
         
         $cnt = $reset ? 0 : (>>1$cnt+ 1 ) ;
      @2
         $temp = $reset | $cnt ;
         $out[31:0] = $temp ? 0 : $op[0] ? ($op[1] ? $quot : $diff ) : ($op[1] ? $prod : $sum ); 
         
      


   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
   
\TLV
   //program on cycle caluclator with validity
 
   |calc //represents a pipeline
      @0   //stage 0 pipeline--> reset state
         $reset = *reset;
      @1  //stage 1 
         $valid = $reset ? 0 : (>>1$valid+ 1 ) ;   //counter
         $valid_or_reset = $valid || $reset ; 
      ?$valid
         @1 //stage 1 for which valid signal is applicable
            $sum[31:0]  = $val1[31:0] + $val2[31:0] ; //airthemetic_opertions
            $diff[31:0] = $val1[31:0] - $val2[31:0] ;
            $prod[31:0] = $val1[31:0] * $val2[31:0] ;
            $quot[31:0] = $val1[31:0] / $val2[31:0] ;
            $val1[31:0] = >>2$out[31:0] ; //output ahead  by 2
            $val2[31:0] = $rand2[3:0] ;
            
            
      @2 //stage 2 refers output operation
         //in this if valid_or_reset signal is zero ==>output gives previous values else compuated value based on opcode
        $out[31:0] = ($valid_or_reset )==1'b0 ? >>1$out[31:0] : $op[0] ? ($op[1] ? $quot : $diff ) : ($op[1] ? $prod : $sum )   ; 


   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

\TLV
    //cycle_calc_single_mem
   
   |calc      //represents a pipeline
      @0   //stage 0 pipeline--> reset state
         $reset = *reset;
      @1  //stage 1 
         $valid = $reset ? 0 : (>>1$valid+ 1 ) ;   //counter
         $valid_or_reset = $valid || $reset ; 
      ?$valid_or_reset
         @1 //stage 1 for which valid signal is applicable
            $sum[31:0]  = $val1[31:0] + $val2[31:0] ; //airthemetic_opertions
            $diff[31:0] = $val1[31:0] - $val2[31:0] ;
            $prod[31:0] = $val1[31:0] * $val2[31:0] ;
            $quot[31:0] = $val1[31:0] / $val2[31:0] ;
            $val1[31:0] = >>2$out[31:0] ; //output ahead  by 2
            
            $val2[31:0] = $rand2[3:0] ;
            
            
            
      @2 //stage 2 
         $mem[31:0] = $reset ?'0 : $op[2:0]== 3'b100 ?>>2$mem[31:0] : $op[2:0] == 3'b101 ? >>2$out[31:0] : '0 ;
         $out[31:0] = $reset ?'0 :  $op[2:0] == 3'b000 ? $sum  :
                                                   $op[2:0] == 3'b001 ? $diff :
                                                   $op[2:0] == 3'b010 ? $prod :
                                                   $op[2:0] == 3'b011 ? $quot :
                                                   $op[2:0] == 3'b100 ? >>2$mem[31:0] : >>2$out[31:0] ;


   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule

