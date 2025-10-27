CLASS zcl_next_picode DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_excel,
             uuid               TYPE sysuuid_x16,
             picode             TYPE c LENGTH 4,
             pifirstname        TYPE c LENGTH 100,
             pilastname         TYPE c LENGTH 100,
             uhpiuid            TYPE c LENGTH 50,
             notes              TYPE c LENGTH 100,
             active             TYPE abap_boolean,
             upluuid            TYPE sysuuid_x16,
             enduser            TYPE syuname,
             zcount             TYPE int2,
             filename           TYPE zfilename,
             zindex             TYPE int2,
             createdby          TYPE abp_creation_user,
             createdat          TYPE abp_creation_tstmpl,
             locallastchangedby TYPE abp_locinst_lastchange_user,
             locallastchangedat TYPE abp_locinst_lastchange_tstmpl,
             lastchangedat      TYPE abp_lastchange_tstmpl,
           END OF ty_excel.

    METHODS validate
      IMPORTING ls_data TYPE ty_excel
      EXPORTING !result TYPE string.

    METHODS getPiCode IMPORTING i_codes TYPE ztb_picode_cur-pi_code
                      EXPORTING e_codes TYPE ztb_picode_cur-pi_code.

    METHODS getPiCodeNew RETURNING VALUE(r_code) TYPE ztb_picode_cur-pi_code.

    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    METHODS next_pi IMPORTING lv_c      TYPE c
                              lt_picode TYPE ztt_picode
                    CHANGING  lv_n      TYPE c.

    DATA lv_code TYPE ztb_picode_cur-pi_code.

ENDCLASS.



CLASS ZCL_NEXT_PICODE IMPLEMENTATION.


  METHOD getpicode.
    DATA lv_c_1    TYPE c LENGTH 1.
    DATA lv_c_2    TYPE c LENGTH 1.
    DATA lv_c_3    TYPE c LENGTH 1.
    DATA lv_c_4    TYPE c LENGTH 1.

    DATA lv_n_1    TYPE c LENGTH 1.
    DATA lv_n_2    TYPE c LENGTH 1.
    DATA lv_n_3    TYPE c LENGTH 1.
    DATA lv_n_4    TYPE c LENGTH 1.

    DATA lt_picode TYPE STANDARD TABLE OF ztb_picode.

    lv_c_1 = i_codes+0(1).
    lv_c_2 = i_codes+1(1).
    lv_c_3 = i_codes+2(1).
    lv_c_4 = i_codes+3(1).

    SELECT code,
           pi_code
      FROM ztb_picode
      WHERE inactive = @abap_false
      ORDER BY code ASCENDING
      INTO CORRESPONDING FIELDS OF TABLE @lt_picode.

    CLEAR: lv_n_4,
           lv_n_3,
           lv_n_2,
           lv_n_1.

    IF lv_c_4 = 'Z'.
      lv_n_4 = '0'.
    ELSE.

      next_pi( EXPORTING lv_c      = lv_c_4
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_4 ).

      lv_n_3 = lv_c_3.
      lv_n_2 = lv_c_2.
      lv_n_1 = lv_c_1.
    ENDIF.

    IF lv_c_3 = 'Z' AND lv_c_4 = 'Z'.
      lv_n_3 = '0'.
    ELSEIF lv_c_3 <> 'Z' AND lv_c_4 = 'Z'.

      next_pi( EXPORTING lv_c      = lv_c_3
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_3 ).

      lv_n_2 = lv_c_2.
      lv_n_1 = lv_c_1.
    ENDIF.

    IF lv_c_2 = 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.
      lv_n_2 = '0'.
    ELSEIF lv_c_2 <> 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.

      next_pi( EXPORTING lv_c      = lv_c_2
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_2 ).

      lv_n_1 = lv_c_1.
    ENDIF.

    IF lv_c_1 = 'Z' AND lv_c_2 = 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.
      lv_n_1 = '0'.
    ELSEIF lv_c_1 <> 'Z' AND lv_c_2 = 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.

      next_pi( EXPORTING lv_c      = lv_c_1
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_1 ).
    ENDIF.

    IF     lv_n_1 = '0' AND lv_n_2 = '0'
       AND lv_n_3 = '0' AND lv_n_4 = '0'.

    " Raise Exception

    ELSE.
      e_codes = |{ lv_n_1 }{ lv_n_2 }{ lv_n_3 }{ lv_n_4 }|.
    ENDIF.
  ENDMETHOD.


  METHOD getpicodenew.
    DATA lv_c_1    TYPE c LENGTH 1.
    DATA lv_c_2    TYPE c LENGTH 1.
    DATA lv_c_3    TYPE c LENGTH 1.
    DATA lv_c_4    TYPE c LENGTH 1.

    DATA lv_n_1    TYPE c LENGTH 1.
    DATA lv_n_2    TYPE c LENGTH 1.
    DATA lv_n_3    TYPE c LENGTH 1.
    DATA lv_n_4    TYPE c LENGTH 1.

    DATA lt_picode TYPE STANDARD TABLE OF ztb_picode.

    SELECT SINGLE pi_code FROM ztb_picode_cur WITH
      PRIVILEGED ACCESS
      WHERE code = 0
      INTO @lv_code.

    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    lv_c_1 = lv_code+0(1).
    lv_c_2 = lv_code+1(1).
    lv_c_3 = lv_code+2(1).
    lv_c_4 = lv_code+3(1).

    SELECT code,
           pi_code
      FROM ztb_picode
      WHERE inactive = @abap_false
      ORDER BY code ASCENDING
      INTO CORRESPONDING FIELDS OF TABLE @lt_picode.

    CLEAR: lv_n_4,
           lv_n_3,
           lv_n_2,
           lv_n_1,
           lv_code.

    IF lv_c_4 = 'Z'.
      lv_n_4 = '0'.
    ELSE.

      next_pi( EXPORTING lv_c      = lv_c_4
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_4 ).

      lv_n_3 = lv_c_3.
      lv_n_2 = lv_c_2.
      lv_n_1 = lv_c_1.
    ENDIF.

    IF lv_c_3 = 'Z' AND lv_c_4 = 'Z'.
      lv_n_3 = '0'.
    ELSEIF lv_c_3 <> 'Z' AND lv_c_4 = 'Z'.

      next_pi( EXPORTING lv_c      = lv_c_3
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_3 ).

      lv_n_2 = lv_c_2.
      lv_n_1 = lv_c_1.
    ENDIF.

    IF lv_c_2 = 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.
      lv_n_2 = '0'.
    ELSEIF lv_c_2 <> 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.

      next_pi( EXPORTING lv_c      = lv_c_2
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_2 ).

      lv_n_1 = lv_c_1.
    ENDIF.

    IF lv_c_1 = 'Z' AND lv_c_2 = 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.
      lv_n_1 = '0'.
    ELSEIF lv_c_1 <> 'Z' AND lv_c_2 = 'Z' AND lv_c_3 = 'Z' AND lv_c_4 = 'Z'.

      next_pi( EXPORTING lv_c      = lv_c_1
                         lt_picode = lt_picode
               CHANGING  lv_n      = lv_n_1 ).
    ENDIF.

    IF     lv_n_1 = '0' AND lv_n_2 = '0'
       AND lv_n_3 = '0' AND lv_n_4 = '0'.

    " Raise Exception

    ELSE.
      r_code = |{ lv_n_1 }{ lv_n_2 }{ lv_n_3 }{ lv_n_4 }|.
    ENDIF.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


  METHOD next_pi.
    DATA lv_index TYPE int2.

    LOOP AT lt_picode ASSIGNING FIELD-SYMBOL(<f_code>)
         WHERE pi_code = lv_c.
      lv_index = <f_code>-code + 1.
      EXIT.
    ENDLOOP.

    SELECT SINGLE COUNT( * ) FROM ztb_picode
      WHERE code     = @lv_index
        AND inactive = 'X'.

    IF sy-subrc = 0.
      lv_index += 1.
    ENDIF.

    LOOP AT lt_picode ASSIGNING <f_code>
         WHERE code = lv_index.
      lv_n = <f_code>-pi_code.
    ENDLOOP.

  ENDMETHOD.


  METHOD validate.
    IF ls_data-pifirstname IS INITIAL.
      MESSAGE ID 'Z_PI_MSG' TYPE 'I' NUMBER '001'
              INTO result.
    ELSEIF ls_data-pilastname IS INITIAL.
      MESSAGE ID 'Z_PI_MSG' TYPE 'I' NUMBER '002'
              INTO result.
    ELSEIF ls_data-uhpiuid IS INITIAL.
      MESSAGE ID 'Z_PI_MSG' TYPE 'I' NUMBER '004'
              INTO result.
    ELSEIF ls_data-picode IS INITIAL.
      MESSAGE ID 'Z_PI_MSG' TYPE 'I' NUMBER '008'
              INTO result.
    ELSE.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
