CLASS zbgpfcl_exe_send_pi DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES if_bgmc_operation.
    INTERFACES if_bgmc_op_single_tx_uncontr.
    INTERFACES if_bgmc_op_single.

    CLASS-METHODS run_via_bgpf_tx_uncontrolled
      IMPORTING i_rap_bo_entity_key             TYPE zcl_pi_save_log=>tt_header
                i_batch                         TYPE abap_boolean OPTIONAL
      RETURNING VALUE(r_process_monitor_string) TYPE string
      RAISING   cx_bgmc.

    METHODS constructor
      IMPORTING i_rap_bo_entity_key TYPE zcl_pi_save_log=>tt_header
                i_batch             TYPE abap_boolean OPTIONAL.

    CONSTANTS :
      BEGIN OF bgpf_state,
        unknown         TYPE int1 VALUE IS INITIAL,
        erroneous       TYPE int1 VALUE 1,
        new             TYPE int1 VALUE 2,
        running         TYPE int1 VALUE 3,
        successful      TYPE int1 VALUE 4,
        started_from_bo TYPE int1 VALUE 99,
      END OF bgpf_state.

  PRIVATE SECTION.
    DATA transaction_data TYPE zcl_pi_save_log=>tt_header.
    DATA batch            TYPE abap_boolean.

    CONSTANTS wait_time_in_seconds TYPE i          VALUE 5.
    CONSTANTS pi_type              TYPE c LENGTH 2 VALUE 'PI'.

ENDCLASS.



CLASS ZBGPFCL_EXE_SEND_PI IMPLEMENTATION.


  METHOD constructor.
    transaction_data = i_rap_bo_entity_key.
    batch = i_batch.
  ENDMETHOD.


  METHOD if_bgmc_op_single_tx_uncontr~execute.
    DATA lt_log        TYPE STANDARD TABLE OF ztb_pi_cc_log.
    DATA ls_data       TYPE zcl_check_connection_aws=>ts_data.
    DATA lt_data_batch TYPE zcl_check_connection_aws=>ls_data_batch.
    DATA ls_data_batch TYPE zcl_check_connection_aws=>ts_data_batch.
    DATA lv_msg        TYPE string.
    DATA ls_status     TYPE if_web_http_response=>http_status.

    WAIT UP TO wait_time_in_seconds SECONDS.
    " Get Time stamp
    GET TIME STAMP FIELD DATA(ts).

    READ ENTITIES OF zr_tb_pi_cc
         ENTITY PrincipalInvestigator
         ALL FIELDS WITH
         VALUE #( FOR ls_trans IN transaction_data
                  ( %key-Uuid = ls_trans-uuid  ) )
         RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<f_data>).
      ls_data-sap_id      = to_lower( xco_cp=>uuid( <f_data>-uuid )->as(
                                                                      io_format = xco_cp_uuid=>format->c36 )->value ).
      ls_data-description = |{ <f_data>-PiFirstName }, { <f_data>-PiLastName }|.
      ls_data-code        = <f_data>-PiCode.
      ls_data-uh_code     = <f_data>-RcuhPiUid.
      ls_data-type        = pi_type.
      ls_data-active_indicator = <f_data>-Active.

      IF batch = abap_false.
        NEW zcl_check_connection_aws( )->aws_table_masters( EXPORTING is_data   = ls_data
                                                            IMPORTING ev_msg    = lv_msg
                                                                      es_status = ls_status ).

        APPEND VALUE #( uuid                  = xco_cp=>uuid( )->value
                        type                  = 'A'
                        pi_code               = <f_data>-PiCode
                        pi_first_name         = <f_data>-PiFirstName
                        pi_last_name          = <f_data>-PiLastName
                        rcuh_pi_code          = <f_data>-RcuhPiUid
                        notes                 = <f_data>-notes
                        Active                = <f_data>-Active
                        Status                = SWITCH #( ls_status-code WHEN 200 OR 201 THEN 'S' ELSE 'F' )
                        Message               = condense( lv_msg )
                        created_by            = <f_data>-CreatedBy
                        created_at            = ts
                        local_last_changed_at = ts
                        local_last_changed_by = <f_data>-LocalLastChangedBy
                        last_changed_at       = ts ) TO lt_log.
      ELSE.
        MOVE-CORRESPONDING ls_data TO ls_data_batch.
        APPEND ls_data_batch TO lt_data_batch-data.
        APPEND VALUE #( uuid                  = xco_cp=>uuid( )->value
                        type                  = 'A'
                        pi_code               = <f_data>-PiCode
                        pi_first_name         = <f_data>-PiFirstName
                        pi_last_name          = <f_data>-PiLastName
                        rcuh_pi_code          = <f_data>-RcuhPiUid
                        notes                 = <f_data>-notes
                        Active                = <f_data>-Active
                        Status                = ''
                        Message               = ''
                        created_by            = <f_data>-CreatedBy
                        created_at            = ts
                        local_last_changed_at = ts
                        local_last_changed_by = <f_data>-LocalLastChangedBy
                        last_changed_at       = ts ) TO lt_log.
      ENDIF.

      CLEAR: ls_data,
             lv_msg,
             ls_status,
             ls_data_batch.
    ENDLOOP.

    IF lt_data_batch-data IS NOT INITIAL AND batch = abap_true.
      NEW zcl_check_connection_aws( )->aws_table_masters_batch( EXPORTING it_data   = lt_data_batch
                                                                IMPORTING ev_msg    = lv_msg
                                                                          es_status = ls_status ).
      LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<f_log>).
        <f_log>-Status  = SWITCH #( ls_status-code WHEN 200 OR 201 THEN 'S' ELSE 'F' ).
        <f_log>-Message = condense( lv_msg ).
      ENDLOOP.
    ENDIF.

    IF lt_log IS NOT INITIAL.
      MODIFY ztb_pi_cc_log FROM TABLE @lt_log.
    ENDIF.
  ENDMETHOD.


  METHOD if_bgmc_op_single~execute.
  ENDMETHOD.


  METHOD run_via_bgpf_tx_uncontrolled.
    TRY.
        DATA(process_monitor) = cl_bgmc_process_factory=>get_default( )->create(
                                              )->set_name( |Call API AWS to create PI records|
                                              )->set_operation_tx_uncontrolled(
                                                  NEW zbgpfcl_exe_send_pi( i_rap_bo_entity_key = i_rap_bo_entity_key
                                                                           i_batch             = i_batch )
                                              )->save_for_execution( ).

        r_process_monitor_string = process_monitor->to_string( ).

      CATCH cx_bgmc INTO DATA(lx_bgmc). " TODO: variable is assigned but never used (ABAP cleaner)
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
