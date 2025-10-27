CLASS zcl_author_act_up DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: checkAuthorize
      IMPORTING
        semantic TYPE zappid
      CHANGING
        c_upload TYPE abap_boolean.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AUTHOR_ACT_UP IMPLEMENTATION.


  METHOD checkauthorize.

    AUTHORITY-CHECK OBJECT 'Z_OBJ_ACT'
        ID 'ACTVT'      FIELD '03'
        ID 'ZAPPID'     FIELD semantic
        ID 'ZACTION'    FIELD '04'.

    IF sy-subrc = 0.
      c_upload = abap_true.
    ELSE.
      c_upload = abap_false.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
