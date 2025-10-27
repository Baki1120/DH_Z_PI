CLASS zcl_pi_save_log DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_pi_save_log.

    CLASS-METHODS get_instance RETURNING VALUE(result) TYPE REF TO zcl_pi_save_log.

    TYPES: BEGIN OF lst_msg,
             id     TYPE symsgid,
             number TYPE symsgno,
           END OF lst_msg.

    TYPES tt_header TYPE STANDARD TABLE OF ztb_pi_cc WITH EMPTY KEY.
    TYPES lt_data   TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.
    TYPES ls_data   TYPE STRUCTURE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.
    TYPES lt_msg    TYPE STANDARD TABLE OF lst_msg.
    TYPES lt_result TYPE TABLE FOR ACTION RESULT zr_tb_pi_cc\\principalinvestigator~apicreatepicodes.
    TYPES ls_result TYPE STRUCTURE FOR HIERARCHY za_pi_req\\principalinvestigatorlist.
    TYPES ls_key    TYPE STRUCTURE FOR ACTION IMPORT zr_tb_pi_cc\\principalinvestigator~apicreatepicodes.

    DATA Chk_Api     TYPE abap_boolean.
    DATA Chk_Success TYPE abap_boolean.
    DATA Chk_GenCode TYPE abap_boolean.
    DATA temp_data   TYPE STRUCTURE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.
    DATA real_data   TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.

    METHODS additional_save IMPORTING it_create TYPE tt_header
                                      it_update TYPE tt_header
                                      it_delete TYPE tt_header
                                      it_data   TYPE lt_data      OPTIONAL
                                      is_api    TYPE abap_boolean OPTIONAL.

    METHODS additional_save_new IMPORTING it_create TYPE tt_header
                                          it_update TYPE tt_header
                                          it_delete TYPE tt_header.

    METHODS check_api                RETURNING VALUE(r_check) TYPE abap_boolean.
    METHODS check_success            RETURNING VALUE(r_check) TYPE abap_boolean.
    METHODS check_gencode            RETURNING VALUE(r_check) TYPE abap_boolean.
    METHODS set_return_check_api     IMPORTING is_check       TYPE abap_boolean.
    METHODS set_return_check_success IMPORTING is_check       TYPE abap_boolean.
    METHODS set_return_check_gencode IMPORTING is_check       TYPE abap_boolean.
    METHODS set_return_data          IMPORTING is_data        TYPE ls_data.

    METHODS set_modify_data IMPORTING is_data  TYPE ls_data
                                      is_index TYPE sy-index.

    METHODS convert_temp_to_data RETURNING VALUE(et_data) TYPE lt_data.

    METHODS validatePiName IMPORTING is_check TYPE ls_data
                           EXPORTING et_check TYPE lt_msg.

    METHODS setActive CHANGING ct_data TYPE lt_data.
    METHODS genPiCode CHANGING ct_data TYPE lt_data.

    METHODS genOnePiCode
      IMPORTING iv_code      TYPE ztb_picode_cur-pi_code
      EXPORTING ev_next_code TYPE ztb_picode_cur-next_code
      CHANGING  cs_data      TYPE ls_data.

    METHODS getResult IMPORTING is_data   TYPE ls_result
                                is_key    TYPE ls_key
                                io_msg    TYPE REF TO if_abap_behv_message
                      CHANGING  ct_result TYPE lt_result.

    METHODS clean_up.
ENDCLASS.



CLASS ZCL_PI_SAVE_LOG IMPLEMENTATION.


  METHOD additional_save.
    DATA lt_log    TYPE STANDARD TABLE OF ztb_pi_cc_log.
    DATA lt_code   TYPE STANDARD TABLE OF ztb_picode_cur.
    DATA lv_code   TYPE ztb_picode_cur-next_code.
    DATA lt_create TYPE tt_header.

    MOVE-CORRESPONDING it_create TO lt_create.

    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<f_data>).

      APPEND VALUE #( uuid                  = <f_data>-Uuid
                      pi_code               = <f_data>-PiCode
                      pi_first_name         = <f_data>-PiFirstName
                      pi_last_name          = <f_data>-PiLastName
                      uh_pi_uid             = <f_data>-RcuhPiUid
                      notes                 = <f_data>-Notes
                      rcuh_proj             = <f_data>-RCUHProject
                      Active                = <f_data>-Active
                      created_by            = <f_data>-CreatedBy
                      created_at            = <f_data>-CreatedAt
                      local_last_changed_by = <f_data>-LocalLastChangedBy
                      local_last_changed_at = <f_data>-LocalLastChangedAt
                      last_changed_at       = <f_data>-LastChangedAt
                      uuid_api              = <f_data>-UuidApi )
             TO lt_create.

    ENDLOOP.

    IF lt_create IS NOT INITIAL.
      TRY.
          lt_log = VALUE #( FOR ls_crt IN lt_create
                            ( uuid                  = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )
                              type                  = 'C'
                              pi_code               = ls_crt-pi_code
                              pi_first_name         = ls_crt-pi_first_name
                              pi_last_name          = ls_crt-pi_last_name
                              rcuh_pi_code          = ls_crt-uh_pi_uid
                              notes                 = ls_crt-notes
                              Active                = ls_crt-Active
                              Status                = 'S'
                              message               = ls_crt-uuid
                              created_by            = ls_crt-created_by
                              created_at            = ls_crt-created_at
                              local_last_changed_at = ls_crt-local_last_changed_at
                              local_last_changed_by = ls_crt-local_last_changed_by
                              last_changed_at       = ls_crt-last_changed_at ) ).
        CATCH cx_uuid_error.
          ASSERT 1 = 2.
      ENDTRY.

      " Update PI code
      LOOP AT lt_create ASSIGNING FIELD-SYMBOL(<f_crt>).
        NEW zcl_next_picode( )->getpicode( EXPORTING i_codes = <f_crt>-pi_code
                                           IMPORTING e_codes = lv_code ).

        APPEND VALUE #( code                  = 0
                        pi_code               = <f_crt>-pi_code
                        next_code             = lv_code
                        created_by            = <f_crt>-created_by
                        created_at            = <f_crt>-created_at
                        local_last_changed_at = <f_crt>-local_last_changed_at
                        local_last_changed_by = <f_crt>-local_last_changed_by
                        last_changed_at       = <f_crt>-last_changed_at ) TO lt_code.

      ENDLOOP.
    ENDIF.

    IF it_update IS NOT INITIAL.

      READ ENTITIES OF zr_tb_pi_cc
           ENTITY PrincipalInvestigator
           ALL FIELDS WITH
           VALUE #( FOR ls_update IN it_update
                    ( %key-Uuid = ls_update-uuid ) )
           RESULT DATA(lt_update).

      LOOP AT lt_update ASSIGNING FIELD-SYMBOL(<f_update>).
        APPEND VALUE #( uuid                  = xco_cp=>uuid( )->value
                        type                  = 'U'
                        pi_code               = <f_update>-PiCode
                        pi_first_name         = <f_update>-PiFirstName
                        pi_last_name          = <f_update>-PiLastName
                        rcuh_pi_code          = <f_update>-RcuhPiUid
                        notes                 = <f_update>-notes
                        Active                = <f_update>-Active
                        Status                = 'S'
                        message               = <f_update>-uuid
                        created_by            = <f_update>-CreatedBy
                        created_at            = <f_update>-CreatedAt
                        local_last_changed_at = <f_update>-LocalLastChangedAt
                        local_last_changed_by = <f_update>-LocalLastChangedBy
                        last_changed_at       = <f_update>-LastChangedAt ) TO lt_log.
      ENDLOOP.

*      SELECT 'U'                     AS type,
*             a~uuid,
*             a~pi_code,
*             b~pi_first_name,
*             b~pi_last_name,
*             b~uh_pi_uid             AS rcuh_pi_code,
*             b~notes,
*             b~Active,
*             b~created_by,
*             b~created_at,
*             b~local_last_changed_at,
*             b~local_last_changed_by,
*             b~last_changed_at
*        FROM ztb_pi_cc WITH
*        PRIVILEGED ACCESS AS a
*               INNER JOIN
*                 @it_update AS b ON a~uuid = b~uuid
*        INTO CORRESPONDING FIELDS OF TABLE @lt_log.
*
*      LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<f_log>).
*        TRY.
*            <f_log>-message = <f_log>-uuid.
*            CLEAR <f_log>-uuid. <f_log>-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
*          CATCH cx_uuid_error.
*            ASSERT 1 = 2.
*        ENDTRY.
*      ENDLOOP.

    ENDIF.

    IF it_delete IS NOT INITIAL.
      TRY.
          lt_log = VALUE #( FOR ls_crt IN it_delete
                            ( uuid                  = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )
                              type                  = 'D'
                              pi_code               = ls_crt-pi_code
                              pi_first_name         = ls_crt-pi_first_name
                              pi_last_name          = ls_crt-pi_last_name
                              rcuh_pi_code          = ls_crt-uh_pi_uid
                              notes                 = ls_crt-notes
                              Active                = ls_crt-Active
                              Status                = 'S'
                              message               = ls_crt-uuid
                              created_by            = ls_crt-created_by
                              created_at            = ls_crt-created_at
                              local_last_changed_at = ls_crt-local_last_changed_at
                              local_last_changed_by = ls_crt-local_last_changed_by
                              last_changed_at       = ls_crt-last_changed_at ) ).
        CATCH cx_uuid_error.
          ASSERT 1 = 2.
      ENDTRY.
    ENDIF.

    IF lt_log IS NOT INITIAL.
      MODIFY ztb_pi_cc_log FROM TABLE @lt_log.
    ENDIF.

    IF lt_code IS NOT INITIAL.
      MODIFY ztb_picode_cur FROM TABLE @lt_code.
    ENDIF.

    IF is_api = abap_true AND lt_create IS NOT INITIAL.
      MODIFY ztb_pi_cc FROM TABLE @lt_create.
    ENDIF.
  ENDMETHOD.


  METHOD additional_save_new.
    DATA lt_log  TYPE STANDARD TABLE OF ztb_pi_cc_log.
    DATA lt_code TYPE STANDARD TABLE OF ztb_picode_cur.
    DATA lv_code TYPE ztb_picode_cur-next_code.

    IF it_create IS NOT INITIAL.
      TRY.
          lt_log = VALUE #( FOR ls_crt IN it_create
                            ( uuid                  = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )
                              type                  = 'C'
                              pi_code               = ls_crt-pi_code
                              pi_first_name         = ls_crt-pi_first_name
                              pi_last_name          = ls_crt-pi_last_name
                              rcuh_pi_code          = ls_crt-uh_pi_uid
                              notes                 = ls_crt-notes
                              Active                = ls_crt-Active
                              Status                = 'S'
                              message               = ls_crt-uuid_api
                              created_by            = ls_crt-created_by
                              created_at            = ls_crt-created_at
                              local_last_changed_at = ls_crt-local_last_changed_at
                              local_last_changed_by = ls_crt-local_last_changed_by
                              last_changed_at       = ls_crt-last_changed_at ) ).
        CATCH cx_uuid_error.
          ASSERT 1 = 2.
      ENDTRY.

      " Update PI code
      LOOP AT it_create ASSIGNING FIELD-SYMBOL(<f_crt>).

        lv_code = NEW zcl_next_picode( )->getpicodenew( ).

        APPEND VALUE #( code                  = 0
                        pi_code               = <f_crt>-pi_code
                        next_code             = lv_code
                        created_by            = <f_crt>-created_by
                        created_at            = <f_crt>-created_at
                        local_last_changed_at = <f_crt>-local_last_changed_at
                        local_last_changed_by = <f_crt>-local_last_changed_by
                        last_changed_at       = <f_crt>-last_changed_at ) TO lt_code.

      ENDLOOP.
    ENDIF.

    IF it_update IS NOT INITIAL.

      SELECT 'U'                     AS type,
             a~pi_code,
             b~pi_first_name,
             b~pi_last_name,
             b~uh_pi_uid             AS rcuh_pi_code,
             b~notes,
             b~Active,
             b~created_by,
             b~created_at,
             b~local_last_changed_at,
             b~local_last_changed_by,
             b~last_changed_at
        FROM ztb_pi_cc WITH
        PRIVILEGED ACCESS AS a
               INNER JOIN
                 @it_update AS b ON a~uuid = b~uuid
        INTO CORRESPONDING FIELDS OF TABLE @lt_log.

      LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<f_log>).
        TRY.
            <f_log>-uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          CATCH cx_uuid_error.
            ASSERT 1 = 2.
        ENDTRY.
      ENDLOOP.

    ENDIF.

    IF it_delete IS NOT INITIAL.
      TRY.
          lt_log = VALUE #( FOR ls_crt IN it_delete
                            ( uuid                  = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )
                              type                  = 'D'
                              pi_code               = ls_crt-pi_code
                              pi_first_name         = ls_crt-pi_first_name
                              pi_last_name          = ls_crt-pi_last_name
                              rcuh_pi_code          = ls_crt-uh_pi_uid
                              notes                 = ls_crt-notes
                              Active                = ls_crt-Active
                              Status                = 'S'
                              message               = ls_crt-uuid_api
                              created_by            = ls_crt-created_by
                              created_at            = ls_crt-created_at
                              local_last_changed_at = ls_crt-local_last_changed_at
                              local_last_changed_by = ls_crt-local_last_changed_by
                              last_changed_at       = ls_crt-last_changed_at ) ).
        CATCH cx_uuid_error.
          ASSERT 1 = 2.
      ENDTRY.
    ENDIF.

    IF lt_log IS NOT INITIAL.
      MODIFY ztb_pi_cc_log FROM TABLE @lt_log.
    ENDIF.

    IF lt_code IS NOT INITIAL.
      MODIFY ztb_picode_cur FROM TABLE @lt_code.
    ENDIF.
  ENDMETHOD.


  METHOD check_api.
    r_check = chk_api.
  ENDMETHOD.


  METHOD check_gencode.
    r_check = chk_gencode.
  ENDMETHOD.


  METHOD check_success.
    r_check = chk_success.
  ENDMETHOD.


  METHOD clean_up.
    CLEAR: chk_api,
           chk_success,
           chk_gencode,
           temp_data,
           real_data.
  ENDMETHOD.


  METHOD convert_temp_to_data.
    IF real_data IS INITIAL.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING real_data TO et_data.
  ENDMETHOD.


  METHOD genonepicode.
    DATA lo_picode TYPE REF TO zcl_next_picode.

    SELECT pi_code
      FROM ztb_pi_cc
      WITH
      PRIVILEGED ACCESS
      ORDER BY pi_code ASCENDING
      INTO TABLE @DATA(lt_codes).

    " Create Object
    lo_picode = NEW #( ).

    " Call Method
    lo_picode->getpicode( EXPORTING i_codes = iv_code
                          IMPORTING e_codes = ev_next_code ).

    READ TABLE lt_codes
         TRANSPORTING NO FIELDS
         WITH KEY pi_code = ev_next_code BINARY SEARCH.

    IF sy-subrc <> 0.
      cs_data-PiCode = ev_next_code.
    ENDIF.
  ENDMETHOD.


  METHOD genpicode.
    DATA lo_picode    TYPE REF TO zcl_next_picode.
    DATA lv_code      TYPE ztb_picode_cur-pi_code.
    DATA lv_next_code TYPE ztb_picode_cur-next_code.
    DATA lv_false     TYPE abap_boolean.

    SELECT SINGLE pi_code
      FROM ztb_picode_cur
      WITH
      PRIVILEGED ACCESS
      WHERE code = 0
      INTO @lv_code.

    IF lv_code IS INITIAL.
      RETURN.
    ENDIF.

    SELECT pi_code
      FROM ztb_pi_cc
      WITH
      PRIVILEGED ACCESS
      ORDER BY pi_code ASCENDING
      INTO TABLE @DATA(lt_codes).

    " Create Object
    lo_picode = NEW #( ).

    " Call Method
    DO.
      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<f_data>).

        lo_picode->getpicode( EXPORTING i_codes = lv_code
                              IMPORTING e_codes = lv_next_code ).

        READ TABLE lt_codes
             TRANSPORTING NO FIELDS
             WITH KEY pi_code = lv_next_code BINARY SEARCH.

        IF sy-subrc = 0.
          lv_false = abap_true.
        ELSE.
          lv_false = abap_false.
          <f_data>-PiCode = lv_next_code.
        ENDIF.

        lv_code = lv_next_code.
      ENDLOOP.

      IF lv_false = abap_false.
        EXIT.
      ELSE.
        lv_code = lv_next_code.
      ENDIF.

    ENDDO.
  ENDMETHOD.


  METHOD getresult.
    DATA lv_msg TYPE c LENGTH 255.

    IF io_msg IS NOT INITIAL.
      lv_msg = condense( |{ io_msg->if_message~get_text( ) }| ).
    ENDIF.

    APPEND VALUE #( %cid               = is_key-%cid
                    %param-UuidApi     = is_key-%param-UuidApi
                    %param-PiFirstName = is_data-PiFirstName
                    %param-PiLastName  = is_data-PiLastName
                    %param-RcuhPiUid   = is_data-RcuhPiUid
                    %param-Note        = is_data-Note
                    %param-Active      = is_data-Active
                    %param-RCUHProject = is_data-RCUHProject
                    %param-Status      = 'F'
                    %param-Message     = lv_msg  ) TO ct_result.
  ENDMETHOD.


  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    result = go_instance.
  ENDMETHOD.


  METHOD setactive.
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<f_data>).
      <f_data>-Active = abap_true.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_modify_data.
    MODIFY real_data FROM is_data INDEX is_index.
  ENDMETHOD.


  METHOD set_return_check_api.
    chk_api = is_check.
  ENDMETHOD.


  METHOD set_return_check_gencode.
    chk_gencode = is_check.
  ENDMETHOD.


  METHOD set_return_check_success.
    chk_success = is_check.
  ENDMETHOD.


  METHOD set_return_data.
    temp_data = is_data.
    APPEND temp_data TO real_data.
    CLEAR temp_data.
  ENDMETHOD.


  METHOD validatepiname.
*    IF is_check-PiFirstName IS INITIAL.
*      APPEND VALUE #( id     = 'Z_PI_MSG'
*                      number = 001 ) TO et_check.
*    ENDIF.
*
*    IF is_check-PiLastName IS INITIAL.
*      APPEND VALUE #( id     = 'Z_PI_MSG'
*                      number = 002 ) TO et_check.
*    ENDIF.

    IF is_check-RcuhPiUid IS INITIAL AND is_check-RCUHProject = abap_false.
      APPEND VALUE #( id     = 'Z_PI_MSG'
                      number = 004 ) TO et_check.
    ENDIF.

*    IF is_check-PiFirstName IS NOT INITIAL AND is_check-PiLastName IS NOT INITIAL AND is_check-RcuhPiUid IS NOT INITIAL.
*
*      SELECT SINGLE COUNT( * )
*        FROM ztb_pi_cc
*        WITH
*        PRIVILEGED ACCESS
*        WHERE pi_first_name = @is_check-PiFirstName
*          AND pi_last_name  = @is_check-PiLastName
*          AND uh_pi_uid     = @is_check-RcuhPiUid.
*
*      IF sy-subrc = 0.
*        APPEND VALUE #( id     = 'Z_PI_MSG'
*                        number = 005 ) TO et_check.
*      ENDIF.
*
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
