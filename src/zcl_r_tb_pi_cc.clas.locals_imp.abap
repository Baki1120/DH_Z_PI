CLASS lsc_zr_tb_pi_cc DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

ENDCLASS.


CLASS lsc_zr_tb_pi_cc IMPLEMENTATION.
  METHOD save_modified.
    DATA lt_create TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.
    DATA lt_update TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.
    DATA lt_delete TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.
    DATA lt_aws    TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.

    DATA(chk_api)     = zcl_pi_save_log=>get_instance( )->check_api( ).
    DATA(chk_success) = zcl_pi_save_log=>get_instance( )->check_success( ).
    DATA lt_data      TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.

    DATA o_ztb_pi_cc  TYPE ztb_pi_cc.
    DATA n_ztb_pi_cc  TYPE ztb_pi_cc.
    DATA changenumber TYPE if_chdo_object_tools_rel=>ty_cdchangenr.
    CONSTANTS cdoc_upd_object TYPE if_chdo_object_tools_rel=>ty_cdchngindh VALUE 'U'.
    DATA upd_ztb_pi_cc TYPE if_chdo_object_tools_rel=>ty_cdchngindh.

    CLEAR: lt_create,
           lt_update,
           lt_delete.

    lt_create = CORRESPONDING #( create-principalinvestigator MAPPING FROM ENTITY ).
    lt_update = CORRESPONDING #( update-principalinvestigator MAPPING FROM ENTITY ).
    lt_delete = CORRESPONDING #( delete-principalinvestigator MAPPING FROM ENTITY ).

    IF chk_api = abap_true AND chk_success = abap_true.
      lt_data = zcl_pi_save_log=>get_instance( )->convert_temp_to_data( ).

      zcl_pi_save_log=>get_instance( )->additional_save( it_create = lt_create
                                                         it_update = lt_update
                                                         it_delete = lt_delete
                                                         it_data   = lt_data
                                                         is_api    = chk_api ).
    ELSE.
      zcl_pi_save_log=>get_instance( )->additional_save( it_create = lt_create
                                                         it_update = lt_update
                                                         it_delete = lt_delete ).

      MOVE-CORRESPONDING lt_create TO lt_aws KEEPING TARGET LINES.
      MOVE-CORRESPONDING lt_update TO lt_aws KEEPING TARGET LINES.
      MOVE-CORRESPONDING lt_delete TO lt_aws KEEPING TARGET LINES.

      IF lt_aws IS NOT INITIAL.
        TRY.
            " TODO: variable is assigned but never used (ABAP cleaner)
            DATA(bgpf_process_name) = zbgpfcl_exe_send_pi=>run_via_bgpf_tx_uncontrolled( i_rap_bo_entity_key = lt_aws ).
          CATCH cx_bgmc.
        ENDTRY.
      ENDIF.

    ENDIF.

    LOOP AT update-principalinvestigator INTO DATA(ls_principalinvestigator).

      READ ENTITIES OF zr_tb_pi_cc
           IN LOCAL MODE
           ENTITY PrincipalInvestigator
           ALL FIELDS WITH VALUE #( ( %key-Uuid = ls_principalinvestigator-Uuid ) )
           RESULT DATA(l_data).

      LOOP AT l_data ASSIGNING FIELD-SYMBOL(<f_data>).

        SELECT SINGLE *
          FROM ztb_pi_cc
          WITH
          PRIVILEGED ACCESS
          WHERE pi_code = @<f_data>-PiCode
          INTO @DATA(ls_old_data).

        IF ls_principalinvestigator-%control-PiFirstName = 01.
          o_ztb_pi_cc-pi_first_name = ls_old_data-pi_first_name.
          n_ztb_pi_cc-pi_first_name = <f_data>-PiFirstName.
        ENDIF.

        IF ls_principalinvestigator-%control-PiLastName = 01.
          o_ztb_pi_cc-pi_last_name = ls_old_data-pi_last_name.
          n_ztb_pi_cc-pi_last_name = <f_data>-PiLastName.
        ENDIF.

        IF ls_principalinvestigator-%control-RcuhPiUid = 01.
          o_ztb_pi_cc-uh_pi_uid = ls_old_data-uh_pi_uid.
          n_ztb_pi_cc-uh_pi_uid = <f_data>-RcuhPiUid.
        ENDIF.

        IF ls_principalinvestigator-%control-Notes = 01.
          o_ztb_pi_cc-notes = ls_old_data-notes.
          n_ztb_pi_cc-notes = <f_data>-notes.
        ENDIF.

        IF ls_principalinvestigator-%control-RCUHProject = 01.
          o_ztb_pi_cc-rcuh_proj = ls_old_data-rcuh_proj.
          n_ztb_pi_cc-rcuh_proj = <f_data>-RCUHProject.
        ENDIF.

        IF ls_principalinvestigator-%control-Active = 01.
          o_ztb_pi_cc-active = ls_old_data-active.
          n_ztb_pi_cc-active = <f_data>-active.
        ENDIF.

        upd_ztb_pi_cc = 'U'.
        n_ztb_pi_cc-pi_code = <f_data>-PiCode.
        o_ztb_pi_cc-pi_code = ls_old_data-pi_code.
        n_ztb_pi_cc-uuid    = <f_data>-Uuid.
        o_ztb_pi_cc-uuid    = ls_old_data-uuid.

        CONVERT UTCLONG utclong_current( )
                INTO DATE FINAL(datlo)
                TIME FINAL(timlo)
                TIME ZONE xco_cp_time=>time_zone->user->value.

        TRY.
            zcl_zcdoc_obj_pi_chdo=>write( EXPORTING objectid                = CONV #( <f_data>-PiCode )
                                                    utime                   = timlo
                                                    udate                   = datlo
                                                    username                = xco_cp=>sy->user( )->name
                                                    object_change_indicator = cdoc_upd_object
                                                    o_ztb_pi_cc             = o_ztb_pi_cc
                                                    n_ztb_pi_cc             = n_ztb_pi_cc
                                                    upd_ztb_pi_cc           = upd_ztb_pi_cc
                                          IMPORTING changenumber            = changenumber ).
          CATCH cx_chdo_write_error.
        ENDTRY.

        CLEAR: o_ztb_pi_cc,
               n_ztb_pi_cc,
               ls_old_data.
      ENDLOOP.
    ENDLOOP.

    IF update-principalinvestigator IS NOT INITIAL.
      UPDATE ztb_pi_cc FROM TABLE @update-principalinvestigator
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY.
    ENDIF.

    IF delete-principalinvestigator IS NOT INITIAL.
      LOOP AT delete-principalinvestigator INTO DATA(pi_delete).
        DELETE FROM ztb_pi_cc WHERE uuid = @pi_delete-Uuid.
        DELETE FROM ztb_pi_cc_d WHERE uuid = @pi_delete-Uuid.
      ENDLOOP.
    ENDIF.

    zcl_pi_save_log=>get_instance( )->clean_up( ).
  ENDMETHOD.
ENDCLASS.


CLASS lhc_zr_tb_pi_cc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR PrincipalInvestigator
      RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR PrincipalInvestigator RESULT result.
*
*    METHODS validatePiName FOR VALIDATE ON SAVE
*      IMPORTING keys FOR PrincipalInvestigator~validatePiName.
    METHODS genPiCode FOR DETERMINE ON SAVE
      IMPORTING keys FOR PrincipalInvestigator~genPiCode.
    METHODS upperCaseText FOR DETERMINE ON SAVE
      IMPORTING keys FOR PrincipalInvestigator~upperCaseText.
    METHODS setActive FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PrincipalInvestigator~setActive.
    METHODS apiCreatePICodes FOR MODIFY
      IMPORTING keys FOR ACTION PrincipalInvestigator~apiCreatePICodes RESULT result.
    METHODS validateConnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR PrincipalInvestigator~validateConnection.
    METHODS checkgenPiCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR PrincipalInvestigator~checkgenPiCode.
    METHODS validateRcuhPiUid FOR VALIDATE ON SAVE
      IMPORTING keys FOR PrincipalInvestigator~validateRcuhPiUid.

ENDCLASS.


CLASS lhc_zr_tb_pi_cc IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_tb_pi_cc IN LOCAL MODE
         ENTITY PrincipalInvestigator
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT FINAL(lt_header)
         FAILED failed.

    result = VALUE #(
        FOR ls_header IN lt_header
        ( %tky               = ls_header-%tky
          %delete            = if_abap_behv=>fc-o-disabled

*          %field-PiCode      = COND #( WHEN ls_header-Active = abap_false OR ls_header-PiCode IS NOT INITIAL
*                                       THEN if_abap_behv=>fc-f-read_only
*                                       ELSE if_abap_behv=>fc-f-mandatory )

          %field-PiFirstName = COND #( WHEN ls_header-Active = abap_false " OR ls_header-PiCode IS NOT INITIAL "Change from Active --> Active
                                       THEN if_abap_behv=>fc-f-read_only )
*                                       ELSE if_abap_behv=>fc-f-mandatory )
          %field-PiLastName  = COND #( WHEN ls_header-Active = abap_false " OR ls_header-PiCode IS NOT INITIAL
                                       THEN if_abap_behv=>fc-f-read_only )
*                                       ELSE if_abap_behv=>fc-f-mandatory )
          %field-RcuhPiUid   = COND #( WHEN ls_header-Active = abap_false     THEN if_abap_behv=>fc-f-read_only
                                       ELSE                                        if_abap_behv=>fc-f-unrestricted )

          %field-Notes       = COND #( WHEN ls_header-Active = abap_false
                                       THEN if_abap_behv=>fc-f-read_only
                                       ELSE if_abap_behv=>fc-f-unrestricted ) ) ).
  ENDMETHOD.

*  METHOD validatePiName.
*    DATA lt_name  TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.
*    DATA lt_check TYPE zcl_pi_save_log=>lt_msg.
*
*    READ ENTITIES OF zr_tb_pi_cc
*         IN LOCAL MODE
*         ENTITY PrincipalInvestigator
*         FIELDS ( PiFirstName PiLastName RcuhPiUid RCUHProject )
*         WITH CORRESPONDING #( keys )
*         RESULT lt_name.
*
*    LOOP AT lt_name INTO FINAL(ls_name).
*
*      APPEND VALUE #( %tky        = ls_name-%tky
*                      %state_area = 'VALIDATE_PINAME' ) TO reported-principalinvestigator.
*
*      zcl_pi_save_log=>get_instance( )->validatepiname( EXPORTING is_check = ls_name
*                                                        IMPORTING et_check = lt_check ).
*
*      LOOP AT lt_check ASSIGNING FIELD-SYMBOL(<f_check>).
*        APPEND VALUE #( %tky = ls_name-%tky ) TO failed-principalinvestigator.
*
*        APPEND VALUE #( %tky                 = ls_name-%tky
*                        %state_area          = 'VALIDATE_PINAME'
*                        %msg                 = new_message( id       = <f_check>-id
*                                                            number   = <f_check>-number
*                                                            v1       = ls_name-PiFirstName
*                                                            v2       = ls_name-PiLastName
*                                                            v3       = ls_name-RcuhPiUid
*                                                            severity = if_abap_behv_message=>severity-error )
*                        %element-PiFirstName = if_abap_behv=>mk-on
*                        %element-PiLastName  = if_abap_behv=>mk-on
*                        %element-RcuhPiUid   = if_abap_behv=>mk-on ) TO reported-principalinvestigator.
*
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.

  METHOD genPiCode.
    DATA lt_data TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.

    READ ENTITIES OF zr_tb_pi_cc
         IN LOCAL MODE
         ENTITY PrincipalInvestigator
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT lt_data
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED DATA(lt_fail).

    DELETE lt_data WHERE PiCode IS NOT INITIAL.

    IF lt_data IS INITIAL.
      " Set gencode
      zcl_pi_save_log=>get_instance( )->set_return_check_gencode( is_check = abap_false ).
      RETURN.
    ENDIF.

    zcl_pi_save_log=>get_instance( )->genpicode( CHANGING ct_data = lt_data ).

    MODIFY ENTITIES OF zr_tb_pi_cc IN LOCAL MODE
           ENTITY PrincipalInvestigator
           UPDATE FIELDS ( PiCode )
           WITH VALUE #( FOR ls_data IN lt_data
                         ( %tky   = ls_data-%tky
                           PiCode = ls_data-PiCode ) ).

    " Set gencode
    zcl_pi_save_log=>get_instance( )->set_return_check_gencode( is_check = abap_true ).
  ENDMETHOD.

  METHOD upperCaseText.
    DATA lt_data TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.

    READ ENTITIES OF zr_tb_pi_cc
         IN LOCAL MODE
         ENTITY PrincipalInvestigator
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT lt_data
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED DATA(lt_fail).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<f_data>).
      <f_data>-PiFirstName = condense( to_upper( <f_data>-PiFirstName ) ).
      <f_data>-PiLastName  = condense( to_upper( <f_data>-PiLastName ) ).
      <f_data>-RcuhPiUid   = condense( <f_data>-RcuhPiUid ).
    ENDLOOP.

    MODIFY ENTITIES OF zr_tb_pi_cc IN LOCAL MODE
           ENTITY PrincipalInvestigator
           UPDATE FIELDS ( PiFirstName PiLastName RcuhPiUid )
           WITH VALUE #( FOR ls_data IN lt_data
                         ( %tky        = ls_data-%tky
                           PiFirstName = ls_data-PiFirstName
                           PiLastName  = ls_data-PiLastName
                           RcuhPiUid   = ls_data-RcuhPiUid ) ).
  ENDMETHOD.

  METHOD setActive.
    DATA lt_data TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.

    READ ENTITIES OF zr_tb_pi_cc IN LOCAL MODE
         ENTITY PrincipalInvestigator
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT lt_data.

    " If Status is already set, do nothing
    DELETE lt_data WHERE Active IS NOT INITIAL.

    IF lt_data IS INITIAL.
      RETURN.
    ENDIF.

    zcl_pi_save_log=>get_instance( )->setactive( CHANGING ct_data = lt_data ).

    MODIFY ENTITIES OF zr_tb_pi_cc IN LOCAL MODE
           ENTITY PrincipalInvestigator
           UPDATE FIELDS ( Active )
           WITH CORRESPONDING #( lt_data ).
  ENDMETHOD.

  METHOD apiCreatePICodes.
    DATA ls_data      TYPE STRUCTURE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.
    DATA lt_data      TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.
    DATA lt_check     TYPE zcl_pi_save_log=>lt_msg.
    DATA lv_false     TYPE abap_boolean VALUE abap_false.
    DATA lv_code      TYPE ztb_picode_cur-pi_code.
    DATA lv_next_code TYPE ztb_picode_cur-next_code.
    DATA lo_msg       TYPE REF TO if_abap_behv_message.

    " Set indicator for calling from API
    zcl_pi_save_log=>get_instance( )->set_return_check_api( is_check = abap_true ).

    " Get PI Codes
    SELECT SINGLE pi_code
      FROM ztb_picode_cur
      WITH
      PRIVILEGED ACCESS
      WHERE code = 0
      INTO @lv_code.

    IF lv_code IS INITIAL.
      lv_false = abap_true.
    ENDIF.

    " Get data
    LOOP AT keys INTO DATA(ls_key).
      LOOP AT ls_key-%param-_principalinvestigatorlist ASSIGNING FIELD-SYMBOL(<f_data>).

        " Check UUID
        IF ls_key-%param-UuidApi = '00000000000000000000000000000000'.
          lv_false = abap_true.
          lo_msg = new_message( id       = 'Z_PI_MSG'
                                number   = 007
                                severity = if_abap_behv_message=>severity-error
                                v1       = ls_data-PiFirstName
                                v2       = ls_data-PiLastName
                                v3       = ls_data-RcuhPiUid ).

          zcl_pi_save_log=>get_instance( )->getresult( EXPORTING is_data   = <f_data>
                                                                 is_key    = ls_key
                                                                 io_msg    = lo_msg
                                                       CHANGING  ct_result = result ).

          EXIT.
        ENDIF.

        " Get Time stamp
        GET TIME STAMP FIELD DATA(ts).

        ls_data = VALUE #( %is_draft          = if_abap_behv=>mk-off
                           uuid               = xco_cp=>uuid( )->value
                           PiFirstName        = condense( to_upper( <f_data>-PiFirstName ) )
                           PiLastName         = condense( to_upper( <f_data>-PiLastName ) )
                           RcuhPiUid          = condense( <f_data>-RcuhPiUid )
                           Notes              = <f_data>-Note
                           Active             = abap_true
                           RCUHProject        = <f_data>-RCUHProject
                           UuidApi            = ls_key-%param-UuidApi
                           CreatedAt          = ts
                           CreatedBy          = xco_cp=>sy->user( )->name
                           locallastchangedby = xco_cp=>sy->user( )->name
                           locallastchangedat = ts
                           lastchangedat      = ts  ).

        zcl_pi_save_log=>get_instance( )->validatepiname( EXPORTING is_check = ls_data
                                                          IMPORTING et_check = lt_check ).

        LOOP AT lt_check ASSIGNING FIELD-SYMBOL(<f_check>).
          lv_false = abap_true.
          lo_msg = new_message( id       = <f_check>-id
                                number   = <f_check>-number
                                severity = if_abap_behv_message=>severity-error
                                v1       = ls_data-PiFirstName
                                v2       = ls_data-PiLastName
                                v3       = ls_data-RcuhPiUid ).

          zcl_pi_save_log=>get_instance( )->getresult( EXPORTING is_data   = <f_data>
                                                                 is_key    = ls_key
                                                                 io_msg    = lo_msg
                                                       CHANGING  ct_result = result ).
        ENDLOOP.

        IF lv_false = abap_true.
          EXIT.
        ELSE.

          zcl_pi_save_log=>get_instance( )->genonepicode( EXPORTING iv_code      = lv_code
                                                          IMPORTING ev_next_code = lv_next_code
                                                          CHANGING  cs_data      = ls_data ).

          IF ls_data-PiCode IS NOT INITIAL.
            APPEND ls_data TO lt_data.
            lv_code = lv_next_code.
          ELSE.
            lv_false = abap_true.
            lo_msg = new_message( id       = 'Z_PI_MSG'
                                  number   = 006
                                  severity = if_abap_behv_message=>severity-error
                                  v1       = ls_data-PiFirstName
                                  v2       = ls_data-PiLastName
                                  v3       = ls_data-RcuhPiUid ).

            zcl_pi_save_log=>get_instance( )->getresult( EXPORTING is_data   = <f_data>
                                                                   is_key    = ls_key
                                                                   io_msg    = lo_msg
                                                         CHANGING  ct_result = result ).
            EXIT.
          ENDIF.

        ENDIF.

        CLEAR: ls_data,
               lt_check,
               lv_next_code.
      ENDLOOP.
    ENDLOOP.

    " Get success message
    IF lv_false = abap_false.
      LOOP AT keys INTO ls_key.
        LOOP AT lt_data INTO ls_data.
          zcl_pi_save_log=>get_instance( )->set_return_data( is_data = CORRESPONDING #( ls_data ) ).
          APPEND VALUE #( %cid               = ls_key-%cid
                          %param-PiCode      = ls_data-PiCode
                          %param-UuidApi     = ls_data-UuidApi
                          %param-Uuid        = ls_data-Uuid
                          %param-PiFirstName = ls_data-PiFirstName
                          %param-PiLastName  = ls_data-PiLastName
                          %param-RcuhPiUid   = ls_data-RcuhPiUid
                          %param-Note        = ls_data-Notes
                          %param-Active      = ls_data-Active
                          %param-RCUHProject = ls_data-RCUHProject
                          %param-Status      = 'S'
                          %param-Message     = 'Created successfully.'  ) TO result.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    " Set indicator for Success
    zcl_pi_save_log=>get_instance( )->set_return_check_success( is_check = SWITCH #( lv_false
                                                                                     WHEN abap_true
                                                                                     THEN abap_false
                                                                                     ELSE abap_true ) ).
  ENDMETHOD.

  METHOD validateConnection.
    DATA ls_data_error TYPE zst_aws_upsert_table_error.
    DATA lt_name       TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.
    DATA lv_msg        TYPE string.

    TRY.
        FINAL(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                    comm_scenario  = 'ZPI_CS_0002'
                                    service_id     = 'ZAWS_UPSERT_TABLE_MASTERS_REST'
                                    comm_system_id = 'AWS' ).

        FINAL(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                                    i_destination = lo_destination ).

        FINAL(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_header_field( i_name  = 'x-api-key'
                                      i_value = 'U0FQOjo6WWlUNzU1aHpENWh6RERZVjl5NVlWOXk1NWh6Vk4=' ).

        lo_request->set_content_type( content_type = 'application/json' ).

        FINAL(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>put ).
        FINAL(lv_results) = lo_response->get_text( ).
        FINAL(lv_status) = lo_response->get_status( ).

        IF lv_status-code <> 400 AND lv_status-code <> 200.

          xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
              VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
          )->write_to( ia_data = REF #( ls_data_error ) ).

          lv_msg = ls_data_error-message.

        ELSE.
          CLEAR lv_msg.
        ENDIF.

      CATCH cx_http_dest_provider_error INTO DATA(lo_provider).
        lv_msg = lo_provider->get_text( ).
      CATCH cx_web_http_client_error INTO DATA(lo_client).
        lv_msg = lo_client->get_text( ).
    ENDTRY.

    IF lv_msg IS NOT INITIAL.

      READ ENTITIES OF zr_tb_pi_cc
           IN LOCAL MODE
           ENTITY PrincipalInvestigator
           FIELDS ( PiFirstName PiLastName RcuhPiUid RCUHProject )
           WITH CORRESPONDING #( keys )
           RESULT lt_name.

      LOOP AT lt_name INTO FINAL(ls_name).

        APPEND VALUE #( %tky        = ls_name-%tky
                        %state_area = 'VALIDATE_CONNECTION' ) TO reported-principalinvestigator.

        APPEND VALUE #( %tky = ls_name-%tky ) TO failed-principalinvestigator.

        APPEND VALUE #( %tky                 = ls_name-%tky
                        %state_area          = 'VALIDATE_CONNECTION'
                        %msg                 = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                      text     = lv_msg )
                        %element-PiFirstName = if_abap_behv=>mk-on
                        %element-PiLastName  = if_abap_behv=>mk-on
                        %element-RcuhPiUid   = if_abap_behv=>mk-on ) TO reported-principalinvestigator.

      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD checkgenPiCode.
    DATA lt_data TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.

    DATA(chk_gencode) = zcl_pi_save_log=>get_instance( )->check_gencode( ).

    IF chk_gencode = abap_false.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_tb_pi_cc
         IN LOCAL MODE
         ENTITY PrincipalInvestigator
         FIELDS ( PiCode )
         WITH CORRESPONDING #( keys )
         RESULT lt_data.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<f_data>)
         WHERE PiCode IS INITIAL.

      APPEND VALUE #( %tky        = <f_data>-%tky
                      %state_area = 'VALIDATE_PICODE' ) TO reported-principalinvestigator.

      APPEND VALUE #( %tky = <f_data>-%tky ) TO failed-principalinvestigator.

      APPEND VALUE #( %tky                 = <f_data>-%tky
                      %state_area          = 'VALIDATE_PICODE'
                      %msg                 = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                    text     = 'Cannot generate PI code.' )
                      %element-PiFirstName = if_abap_behv=>mk-on
                      %element-PiLastName  = if_abap_behv=>mk-on
                      %element-RcuhPiUid   = if_abap_behv=>mk-on ) TO reported-principalinvestigator.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateRcuhPiUid.
    DATA lt_data TYPE TABLE FOR READ RESULT zr_tb_pi_cc\\principalinvestigator.

    READ ENTITIES OF zr_tb_pi_cc
         IN LOCAL MODE
         ENTITY PrincipalInvestigator
         FIELDS ( RCUHProject RcuhPiUid )
         WITH CORRESPONDING #( keys )
         RESULT lt_data.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<f_data>)
         WHERE RCUHProject = abap_true AND RcuhPiUid IS INITIAL.

      APPEND VALUE #( %tky        = <f_data>-%tky
                      %state_area = 'VALIDATE_RCUHPIUID' ) TO reported-principalinvestigator.

      APPEND VALUE #( %tky = <f_data>-%tky ) TO failed-principalinvestigator.

      APPEND VALUE #( %tky                 = <f_data>-%tky
                      %state_area          = 'VALIDATE_RCUHPIUID'
                      %msg                 = new_message( id       = 'Z_PI_MSG'
                                                          number   = 009
                                                          severity = if_abap_behv_message=>severity-error )
                      %element-RCUHProject = if_abap_behv=>mk-on
                      %element-RcuhPiUid   = if_abap_behv=>mk-on ) TO reported-principalinvestigator.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
