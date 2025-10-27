CLASS zcl_check_timezone DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS ZCL_CHECK_TIMEZONE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    FINAL(zonlo) = xco_cp_time=>time_zone->user.
*
*    CONVERT UTCLONG utclong_current( )
*            INTO DATE FINAL(datlo)
*                 TIME FINAL(timlo)
*            TIME ZONE zonlo->value.
*
*    out->write( zonlo ).
*    out->write( datlo ).
*    out->write( timlo ).

    DELETE FROM ztb_picode_upl.
    DELETE FROM ztb_picode_upld.
    DELETE FROM ztb_view_picode.
    DELETE FROM ztb_view_picoded.
    COMMIT WORK.


  ENDMETHOD.
ENDCLASS.
