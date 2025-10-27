CLASS lhc_zr_tb_picode_cur DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR PiCodesCurrently
        RESULT result,
      genPiCode FOR DETERMINE ON MODIFY
        IMPORTING keys FOR PiCodesCurrently~genPiCode,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR PiCodesCurrently RESULT result.
ENDCLASS.

CLASS lhc_zr_tb_picode_cur IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD genPiCode.

    DATA: lo_picode TYPE REF TO zcl_next_picode.
    CREATE OBJECT lo_picode.

    READ ENTITIES OF zr_tb_picode_cur
        IN LOCAL MODE
        ENTITY PiCodesCurrently
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data)
        FAILED DATA(lt_fail).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<f_data>).

      lo_picode->getpicode(
        EXPORTING
          i_codes = <f_data>-PiCode
        IMPORTING
          e_codes = <f_data>-NextCode ).

    ENDLOOP.

    MODIFY ENTITIES OF zr_tb_picode_cur IN LOCAL MODE
           ENTITY PiCodesCurrently
           UPDATE FIELDS ( NextCode )
           WITH VALUE #( FOR ls_data IN lt_data
                         ( %tky     = ls_data-%tky
                           NextCode = ls_data-NextCode ) ).

  ENDMETHOD.


  METHOD get_instance_features.
    READ ENTITIES OF zr_tb_picode_cur IN LOCAL MODE
         ENTITY PiCodesCurrently
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT FINAL(lt_header)
         FAILED failed.

    result = VALUE #(
            FOR ls_header IN lt_header
            ( %tky           = ls_header-%tky
              %action-edit   = if_abap_behv=>fc-o-disabled ) ).
  ENDMETHOD.

ENDCLASS.
