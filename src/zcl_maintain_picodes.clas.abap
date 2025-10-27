CLASS zcl_maintain_picodes DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MAINTAIN_PICODES IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_code TYPE STANDARD TABLE OF ztb_picode.

    lt_code = VALUE #( ( code = 1 pi_code = '0' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 2 pi_code = '1' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 3 pi_code = '2' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 4 pi_code = '3' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 5 pi_code = '4' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 6 pi_code = '5' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 7 pi_code = '6' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 8 pi_code = '7' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 9 pi_code = '8' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 10 pi_code = '9' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 11 pi_code = 'A' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 12 pi_code = 'B' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 13 pi_code = 'C' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 14 pi_code = 'D' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 15 pi_code = 'E' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 16 pi_code = 'F' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 17 pi_code = 'G' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 18 pi_code = 'H' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 19 pi_code = 'I' inactive = abap_true created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 20 pi_code = 'J' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 21 pi_code = 'K' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 22 pi_code = 'L' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 23 pi_code = 'M' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 24 pi_code = 'N' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 25 pi_code = 'O' inactive = abap_true created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 26 pi_code = 'P' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 27 pi_code = 'Q' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 28 pi_code = 'R' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 29 pi_code = 'S' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 30 pi_code = 'T' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 31 pi_code = 'U' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 32 pi_code = 'V' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 33 pi_code = 'W' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 34 pi_code = 'X' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 35 pi_code = 'Y' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) )
                       ( code = 36 pi_code = 'Z' inactive = abap_false created_by = xco_cp=>sy->user( )->name
                                                                      created_at = cl_abap_context_info=>get_system_time( )
                                                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                                                      local_last_changed_at = cl_abap_context_info=>get_system_time( )
                                                                      last_changed_at =  cl_abap_context_info=>get_system_time( ) ) ).
    MODIFY ztb_picode FROM TABLE @lt_code.
    COMMIT WORK.

    DELETE FROM ztb_pi_cc_log.
    COMMIT WORK.


    out->write( 'Update successfully!' ).

  ENDMETHOD.
ENDCLASS.
