CLASS zcl_conf_picodes_cur DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CONF_PICODES_CUR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_code_cur TYPE STANDARD TABLE OF ztb_picode_cur.
    DATA lo_picode    TYPE REF TO zcl_next_picode.
    DATA lv_next_code TYPE ztb_picode_cur-next_code.

    DELETE FROM ztb_picode_cur.
    COMMIT WORK.

    GET TIME STAMP FIELD DATA(ts).


    lo_picode = NEW #( ).
    lo_picode->getpicode( EXPORTING i_codes = 'PI3E'
                          IMPORTING e_codes = lv_next_code ).

    lt_code_cur = VALUE #( ( code = 0 pi_code = 'PI3E'
                                      next_code = lv_next_code
                                      created_by = xco_cp=>sy->user( )->name
                                      created_at = ts
                                      local_last_changed_by = xco_cp=>sy->user( )->name
                                      local_last_changed_at = ts
                                      last_changed_at =  ts ) ).

    MODIFY ztb_picode_cur FROM TABLE @lt_code_cur.
    COMMIT WORK.

    out->write( 'Update successfully!' ).

  ENDMETHOD.
ENDCLASS.
