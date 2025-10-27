CLASS lhc_dataFile DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS checkData FOR VALIDATE ON SAVE
      IMPORTING keys FOR dataFile~checkData.

ENDCLASS.

CLASS lhc_dataFile IMPLEMENTATION.

  METHOD checkData.
*    DATA: msg      TYPE string,
*          ls_data  TYPE zcl_next_picode=>ty_excel.
*
*    READ ENTITIES OF zr_picode_upl IN LOCAL MODE
*        ENTITY dataFile
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_dataFile).
*
*    LOOP AT lt_dataFile ASSIGNING FIELD-SYMBOL(<f_data>).
*      ls_data = CORRESPONDING #( <f_data>-%data ).
*      NEW zcl_next_picode( )->validate(
*        EXPORTING
*          ls_data = ls_data
*        IMPORTING
*          result  = msg ).
*
*      IF msg IS NOT INITIAL.
*        APPEND VALUE #( %key      = <f_data>-%key
*                        %is_draft = <f_data>-%is_draft ) TO failed-datafile.
*
*        APPEND VALUE #( %key      = <f_data>-%key
*                        %msg      = new_message_with_text(
*                                    text = |Error at line { <f_data>-Zindex }: { msg }|
*                                    severity = if_abap_behv_message=>severity-error )
*                        %is_draft = <f_data>-%is_draft ) TO reported-datafile.
*      ENDIF.
*
*      CLEAR msg.
*    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
