CLASS zcl_conf_picodes_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CONF_PICODES_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_pi_data TYPE STANDARD TABLE OF ztb_pi_cc.

    SELECT *
        FROM ztb_pi_cc
        WHERE pi_code IS INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @lt_pi_data.

    DELETE ztb_pi_cc FROM TABLE @lt_pi_data.
    COMMIT WORK.

    out->write( 'Delete successfully!' ).

  ENDMETHOD.
ENDCLASS.
