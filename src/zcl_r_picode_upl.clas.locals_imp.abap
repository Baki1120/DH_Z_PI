CLASS lsc_zr_picode_upl DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

ENDCLASS.


CLASS lsc_zr_picode_upl IMPLEMENTATION.
  METHOD save_modified.
    DATA lt_create    TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.
    DATA lt_update    TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.
    DATA lt_delete    TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.
    DATA lt_aws       TYPE TABLE OF ztb_pi_cc WITH EMPTY KEY.

    DATA o_ztb_pi_cc  TYPE ztb_pi_cc.
    DATA n_ztb_pi_cc  TYPE ztb_pi_cc.
    DATA changenumber TYPE if_chdo_object_tools_rel=>ty_cdchangenr.
    CONSTANTS cdoc_upd_object TYPE if_chdo_object_tools_rel=>ty_cdchngindh VALUE 'U'.
    DATA upd_ztb_pi_cc TYPE if_chdo_object_tools_rel=>ty_cdchngindh.

    lt_create = CORRESPONDING #( create-datafile MAPPING FROM ENTITY ).
    lt_update = CORRESPONDING #( update-datafile MAPPING FROM ENTITY ).
    lt_delete = CORRESPONDING #( delete-datafile MAPPING FROM ENTITY ).

    zcl_pi_save_log=>get_instance( )->additional_save( it_create = lt_create
                                                       it_update = lt_update
                                                       it_delete = lt_delete ).

    MOVE-CORRESPONDING lt_create TO lt_aws KEEPING TARGET LINES.
    MOVE-CORRESPONDING lt_update TO lt_aws KEEPING TARGET LINES.
    MOVE-CORRESPONDING lt_delete TO lt_aws KEEPING TARGET LINES.

    IF lt_aws IS NOT INITIAL.
      TRY.
          " TODO: variable is assigned but never used (ABAP cleaner)
          DATA(bgpf_process_name) = zbgpfcl_exe_send_pi=>run_via_bgpf_tx_uncontrolled(
                                        i_rap_bo_entity_key = lt_aws
                                        i_batch             = abap_true ).
        CATCH cx_bgmc.
      ENDTRY.
    ENDIF.

    LOOP AT update-datafile INTO DATA(ls_principalinvestigator).

      READ ENTITIES OF zr_picode_upl
           IN LOCAL MODE
           ENTITY dataFile
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

        IF ls_principalinvestigator-%control-UhPiUid = 01.
          o_ztb_pi_cc-uh_pi_uid = ls_old_data-uh_pi_uid.
          n_ztb_pi_cc-uh_pi_uid = <f_data>-UhPiUid.
        ENDIF.

        IF ls_principalinvestigator-%control-Notes = 01.
          o_ztb_pi_cc-notes = ls_old_data-notes.
          n_ztb_pi_cc-notes = <f_data>-notes.
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
                                                    username                = sy-uname
                                                    object_change_indicator = cdoc_upd_object
                                                    o_ztb_pi_cc             = o_ztb_pi_cc
                                                    n_ztb_pi_cc             = n_ztb_pi_cc
                                                    upd_ztb_pi_cc           = upd_ztb_pi_cc
                                          IMPORTING changenumber            = changenumber ).
          CATCH cx_chdo_write_error.
        ENDTRY.

        CLEAR: o_ztb_pi_cc,
               n_ztb_pi_cc.
      ENDLOOP.
    ENDLOOP.

    IF update-datafile IS NOT INITIAL.
      UPDATE ztb_pi_cc FROM TABLE @update-datafile
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY.
    ENDIF.

    IF delete-datafile IS NOT INITIAL.
      LOOP AT delete-datafile INTO DATA(pi_delete).
        DELETE FROM ztb_pi_cc WHERE uuid = @pi_delete-Uuid.
        DELETE FROM ztb_pi_cc_d WHERE uuid = @pi_delete-Uuid.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_File DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS: BEGIN OF file_status,
                 open         TYPE c LENGTH 1 VALUE 'O', " Open
                 processing   TYPE c LENGTH 1 VALUE 'P', " Processing
                 accepted     TYPE c LENGTH 1 VALUE 'A', " Accepted
                 rejected     TYPE c LENGTH 1 VALUE 'X', " Rejected
                 completed    TYPE c LENGTH 1 VALUE 'D', " Done
                 header_fail  TYPE c LENGTH 1 VALUE '1', " Header fail
                 item_fail    TYPE c LENGTH 1 VALUE '1', " Item fail
                 log_fail     TYPE c LENGTH 1 VALUE '1', " Log fail
                 insert_fail  TYPE c LENGTH 1 VALUE '1', " Insert fail
                 update_fail  TYPE c LENGTH 1 VALUE '1', " Update fail
                 preview_fail TYPE c LENGTH 1 VALUE '1', " Preview fail
               END OF file_status.
    CONSTANTS c_obj TYPE zappid VALUE 'ZPIDATAUPL'.

  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR File RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR File RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE File.

    METHODS setStatusToOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR File~setStatusToOpen.

    METHODS getExcelData FOR DETERMINE ON SAVE
      IMPORTING keys FOR File~getExcelData.
    METHODS validateConnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR File~validateConnection.
    METHODS checkgenPiCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR File~checkgenPiCode.

    TYPES: BEGIN OF ty_excel,
             PiCode TYPE string,
             FName  TYPE string,
             LName  TYPE string,
             Uhid   TYPE string,
             Note   TYPE string,
             Active TYPE string,
             Index  TYPE int2,
           END OF ty_excel,
           tt_row TYPE STANDARD TABLE OF ty_excel.
    TYPES: BEGIN OF ty_data,
             PiCode TYPE ztb_pi_cc-pi_code,
             FName  TYPE ztb_pi_cc-pi_first_name,
             LName  TYPE ztb_pi_cc-pi_last_name,
             Uhid   TYPE ztb_pi_cc-uh_pi_uid,
             Note   TYPE ztb_pi_cc-notes,
             Active TYPE ztb_pi_cc-active,
             Index  TYPE ztb_pi_cc-zindex,
           END OF ty_data,
           tt_data TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY.

    CONSTANTS comm_scenario  TYPE if_com_management=>ty_cscn_id          VALUE 'ZPI_CS_0002'.
    CONSTANTS comm_system_id TYPE if_com_management=>ty_cs_id            VALUE 'AWS'.
    CONSTANTS service_id     TYPE if_com_management=>ty_cscn_outb_srv_id VALUE 'ZAWS_UPSERT_TABLE_MASTERS_REST'.
    CONSTANTS i_name         TYPE string                                 VALUE 'x-api-key'.
    CONSTANTS i_value        TYPE string                                 VALUE 'U0FQOjo6WWlUNzU1aHpENWh6RERZVjl5NVlWOXk1NWh6Vk4='.

ENDCLASS.


CLASS lhc_File IMPLEMENTATION.
  METHOD get_instance_features.
    READ ENTITIES OF zr_picode_upl IN LOCAL MODE
         ENTITY File
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT FINAL(lt_header)
         FAILED failed.

    result = VALUE #( FOR ls_header IN lt_header
                      ( %tky            = ls_header-%tky
                        %action-edit    = COND #( WHEN ls_header-Status = file_status-open
                                                  THEN if_abap_behv=>fc-o-enabled
                                                  ELSE if_abap_behv=>fc-o-disabled )
                        %delete         = COND #( WHEN ls_header-Status = file_status-open
                                                  THEN if_abap_behv=>fc-o-enabled
                                                  ELSE if_abap_behv=>fc-o-disabled )
                        %update         = COND #( WHEN ls_header-Status = file_status-open
                                                  THEN if_abap_behv=>fc-o-enabled
                                                  ELSE if_abap_behv=>fc-o-disabled )

                        %field-Filename = COND #( WHEN ls_header-Filename IS NOT INITIAL
                                                  THEN if_abap_behv=>fc-f-read_only ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    DATA lv_check TYPE abap_boolean.

    IF requested_authorizations-%create <> if_abap_behv=>mk-on.
      RETURN.
    ENDIF.

    NEW zcl_author_act_up( )->checkauthorize( EXPORTING semantic = c_obj
                                              CHANGING  c_upload = lv_check ).

    IF lv_check = abap_false.
      result-%create = if_abap_behv=>auth-unauthorized.
    ELSE.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities
         ASSIGNING FIELD-SYMBOL(<f_entities>)
         WHERE Uuid IS NOT INITIAL.

      APPEND CORRESPONDING #( <f_entities> ) TO mapped-file.

    ENDLOOP.

    DATA(lt_file) = entities.
    DELETE lt_file WHERE Uuid IS NOT INITIAL.

    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_file ASSIGNING <f_entities>.

      TRY.
          <f_entities>-Uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        CATCH cx_uuid_error.
          LOOP AT lt_file ASSIGNING <f_entities>.
            APPEND VALUE #( %cid      = <f_entities>-%cid
                            %key      = <f_entities>-%key
                            %is_draft = <f_entities>-%is_draft )
                   TO reported-file.
            APPEND VALUE #( %cid      = <f_entities>-%cid
                            %key      = <f_entities>-%key
                            %is_draft = <f_entities>-%is_draft )
                   TO failed-file.
          ENDLOOP.
          EXIT.
      ENDTRY.

      <f_entities>-enduser = sy-uname.
      " Get max requirement no
      SELECT SINGLE FROM ztb_picode_upl
        FIELDS MAX( cnt ) + 1
        WHERE end_user = @sy-uname
        INTO @FINAL(max_cnt).

      SELECT SINGLE FROM ztb_picode_upld
        FIELDS MAX( zcount ) + 1
        WHERE enduser = @sy-uname
        INTO @FINAL(max_cnt_d).

      IF max_cnt = max_cnt_d.
        <f_entities>-ZCount = max_cnt.
      ELSEIF max_cnt_d > max_cnt.
        <f_entities>-ZCount = max_cnt_d.
      ELSE.
        <f_entities>-ZCount = max_cnt.
      ENDIF.

      APPEND VALUE #( %cid      = <f_entities>-%cid
                      %key      = <f_entities>-%key
                      %is_draft = <f_entities>-%is_draft )
             TO mapped-file.
    ENDLOOP.
  ENDMETHOD.

  METHOD setStatusToOpen.
    READ ENTITIES OF zr_picode_upl IN LOCAL MODE
         ENTITY File
         FIELDS ( status )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_file).

    " If Status is already set, do nothing
    DELETE lt_file WHERE status IS NOT INITIAL.
    IF lt_file IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_picode_upl IN LOCAL MODE
           ENTITY File
           UPDATE FIELDS ( status )
           WITH VALUE #( FOR ls_file IN lt_file
                         ( %tky   = ls_file-%tky
                           status = file_status-open ) ).
  ENDMETHOD.

  METHOD getExcelData.
    DATA lt_rows           TYPE tt_row.
    DATA lt_data_blank     TYPE tt_row.
    DATA lt_data_not_blank TYPE tt_row.
    DATA lt_data           TYPE HASHED TABLE OF ztb_pi_cc WITH UNIQUE KEY pi_code.
    DATA lt_insert         TYPE TABLE FOR CREATE zr_picode_upl\\file\_datafile.
    DATA lt_update         TYPE TABLE FOR UPDATE zr_picode_upl\\datafile.
    DATA lt_upl_curr       TYPE TABLE FOR UPDATE zr_picode_upl\\picodeCurr.
    DATA ls_upl_curr       TYPE STRUCTURE FOR UPDATE zr_picode_upl\\picodeCurr.
    DATA lt_create_preview TYPE TABLE FOR CREATE zr_picode_upl\\file\_previewdata.
    DATA lv_next_code      TYPE ztb_picode_cur-pi_code.
    DATA lv_last_code      TYPE ztb_picode_cur-pi_code.

    " Read the parent instance
    READ ENTITIES OF zr_picode_upl IN LOCAL MODE
         ENTITY File
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT FINAL(lt_inv).

    " Get attachment value from the instance
    IF lt_inv IS INITIAL.
      RETURN.
    ELSE.
      FINAL(lv_attachment) = lt_inv[ 1 ]-Attachment.
    ENDIF.

    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_attachment )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ). " First worksheet

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_rows ) )->if_xco_xlsx_ra_operation~execute( ).

    LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<f_row>) FROM 2.
      <f_row>-index  = sy-tabix.
      <f_row>-fname  = condense( to_upper( <f_row>-fname ) ).
      <f_row>-lname  = condense( to_upper( <f_row>-lname ) ).
      <f_row>-picode = condense( to_upper( <f_row>-picode ) ).
      <f_row>-uhid   = condense( <f_row>-uhid ).
      <f_row>-active = COND #( WHEN <f_row>-active IS INITIAL
                               THEN abap_false
                               ELSE abap_true ).

      IF <f_row>-picode IS INITIAL.
        APPEND <f_row> TO lt_data_blank.
      ELSE.
        APPEND <f_row> TO lt_data_not_blank.
      ENDIF.
    ENDLOOP.

    SORT lt_data_not_blank BY picode.
    DELETE ADJACENT DUPLICATES FROM lt_data_not_blank COMPARING picode.

    IF lt_data_not_blank IS INITIAL AND lt_data_blank IS INITIAL.
      RETURN.
    ELSE.

      DATA(lt_file) = CORRESPONDING tt_data( lt_data_not_blank ).
      lt_file = CORRESPONDING #( APPENDING ( lt_file ) lt_data_blank ).
      SORT lt_file BY index ASCENDING.

      SELECT uuid,
             pi_code,
             pi_first_name,
             pi_last_name,
             uh_pi_uid
        FROM ztb_pi_cc
        WITH
        PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_file
        WHERE pi_code  = @lt_file-picode
          AND pi_code IS NOT INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @lt_data.

    ENDIF.

    CLEAR: lt_insert,
           lt_update,
           lv_next_code,
           lt_upl_curr,
           lt_create_preview.

    LOOP AT lt_inv INTO DATA(ls_inv).

      LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<f_file>).

        FINAL(lv_tabix) = sy-tabix.
        GET TIME STAMP FIELD DATA(ts).

        ASSIGN lt_data[ pi_code = <f_file>-picode ] TO FIELD-SYMBOL(<f_data>).

        IF sy-subrc <> 0.  " Create a new record

          IF <f_file>-picode IS NOT INITIAL.
            lv_last_code = <f_file>-picode.
          ELSE.
            DO.
              IF lv_next_code IS INITIAL.
                lv_next_code = NEW zcl_next_picode( )->getpicodenew( ).
                lv_last_code = lv_next_code.
              ELSE.
                NEW zcl_next_picode( )->getpicode( EXPORTING i_codes = lv_next_code
                                                   IMPORTING e_codes = lv_last_code ).

                lv_next_code = lv_last_code.
              ENDIF.
              SELECT SINGLE COUNT( * )
                FROM ztb_pi_cc
                WITH
                PRIVILEGED ACCESS
                WHERE pi_code = @lv_last_code.

              IF sy-subrc <> 0.
                ls_upl_curr = VALUE #( %is_draft          = ls_inv-%is_draft
                                       code               = 0
                                       picode             = lv_last_code
                                       nextcode           = space
                                       createdby          = ls_inv-createdby
                                       createdat          = ls_inv-createdat
                                       locallastchangedby = ls_inv-locallastchangedby
                                       locallastchangedat = ls_inv-locallastchangedat
                                       lastchangedat      = ts
                                       uuidupl            = ls_inv-uuid
                                       enduser            = ls_inv-enduser
                                       filename           = ls_inv-filename
                                       cnt                = ls_inv-zcount  ).
                EXIT.
              ENDIF.
            ENDDO.
          ENDIF.

          APPEND VALUE #( %is_draft = ls_inv-%is_draft
                          uuid      = ls_inv-uuid
                          enduser   = ls_inv-enduser
                          zcount    = ls_inv-zcount
                          %target   = VALUE #( ( %cid               = ls_inv-uuid && lv_tabix
                                                 %is_draft          = ls_inv-%is_draft
                                                 picode             = lv_last_code
                                                 pifirstname        = <f_file>-fname
                                                 pilastname         = <f_file>-lname
                                                 uhpiuid            = <f_file>-uhid
                                                 notes              = <f_file>-note
                                                 active             = <f_file>-active
                                                 zindex             = <f_file>-index
                                                 upluuid            = ls_inv-uuid
                                                 enduser            = ls_inv-enduser
                                                 filename           = ls_inv-filename
                                                 zcount             = ls_inv-zcount
                                                 createdby          = ls_inv-createdby
                                                 createdat          = ls_inv-createdat
                                                 locallastchangedby = ls_inv-locallastchangedby
                                                 locallastchangedat = ls_inv-locallastchangedat
                                                 lastchangedat      = ts ) ) ) TO lt_insert.

          APPEND VALUE #( %is_draft = ls_inv-%is_draft
                          uuid      = ls_inv-uuid
                          enduser   = ls_inv-enduser
                          zcount    = ls_inv-zcount
                          %target   = VALUE #( ( %cid               = ls_inv-uuid && lv_tabix
                                                 %is_draft          = ls_inv-%is_draft
                                                 picode             = lv_last_code
                                                 pifirstname        = <f_file>-fname
                                                 pilastname         = <f_file>-lname
                                                 uhpiuid            = <f_file>-uhid
                                                 notes              = <f_file>-note
                                                 active             = <f_file>-active
                                                 uploaduuid         = ls_inv-uuid
                                                 enduser            = ls_inv-enduser
                                                 cnt                = ls_inv-zcount
                                                 createdby          = ls_inv-createdby
                                                 createdat          = ls_inv-createdat
                                                 locallastchangedby = ls_inv-locallastchangedby
                                                 locallastchangedat = ls_inv-locallastchangedat
                                                 lastchangedat      = ts ) ) ) TO lt_create_preview.

        ELSE. " Modify data

          APPEND VALUE #( %is_draft          = ls_inv-%is_draft
                          uuid               = <f_data>-uuid
                          picode             = <f_data>-pi_code
                          pifirstname        = <f_file>-fname
                          pilastname         = <f_file>-lname
                          uhpiuid            = <f_file>-uhid
                          notes              = <f_file>-note
                          active             = <f_file>-active
                          zindex             = <f_file>-index
                          upluuid            = ls_inv-uuid
                          enduser            = ls_inv-enduser
                          filename           = ls_inv-filename
                          zcount             = ls_inv-zcount
                          createdby          = ls_inv-createdby
                          createdat          = ls_inv-createdat
                          locallastchangedby = ls_inv-locallastchangedby
                          locallastchangedat = ls_inv-locallastchangedat
                          lastchangedat      = ts ) TO lt_update.

          APPEND VALUE #( %is_draft = ls_inv-%is_draft
                          uuid      = ls_inv-uuid
                          enduser   = ls_inv-enduser
                          zcount    = ls_inv-zcount
                          %target   = VALUE #( ( %cid               = ls_inv-uuid && lv_tabix
                                                 %is_draft          = ls_inv-%is_draft
                                                 picode             = <f_data>-pi_code
                                                 pifirstname        = <f_file>-fname
                                                 pilastname         = <f_file>-lname
                                                 uhpiuid            = <f_file>-uhid
                                                 notes              = <f_file>-note
                                                 active             = <f_file>-active
                                                 uploaduuid         = ls_inv-uuid
                                                 enduser            = ls_inv-enduser
                                                 cnt                = ls_inv-zcount
                                                 createdby          = ls_inv-createdby
                                                 createdat          = ls_inv-createdat
                                                 locallastchangedby = ls_inv-locallastchangedby
                                                 locallastchangedat = ls_inv-locallastchangedat
                                                 lastchangedat      = ts ) ) ) TO lt_create_preview.

        ENDIF.

      ENDLOOP.
    ENDLOOP.

    IF lt_insert IS NOT INITIAL.
      MODIFY ENTITIES OF zr_picode_upl IN LOCAL MODE
             ENTITY file
             CREATE BY \_datafile
             FIELDS ( PiCode
                      PiFirstName
                      PiLastName
                      UhPiUid
                      Notes
                      Active
                      Zindex
                      UplUuid
                      EndUser
                      Filename
                      Zcount
                      CreatedAt
                      CreatedBy
                      LocalLastChangedAt
                      LocalLastChangedBy )
             WITH lt_insert
             FAILED FINAL(lt_insert_fail).

      IF     lt_insert_fail-datafile IS INITIAL
         AND lv_last_code            IS NOT INITIAL AND ls_upl_curr IS NOT INITIAL.

        CLEAR lv_next_code.

        NEW zcl_next_picode( )->getpicode( EXPORTING i_codes = ls_upl_curr-picode
                                           IMPORTING e_codes = lv_next_code ).

        ls_upl_curr-NextCode = lv_next_code.
        APPEND ls_upl_curr TO lt_upl_curr.
        CLEAR  ls_upl_curr.

        MODIFY ENTITIES OF zr_picode_upl IN LOCAL MODE
               ENTITY picodeCurr
               UPDATE FIELDS ( Code
                               PiCode
                               NextCode
                               UuidUpl
                               EndUser
                               FileName
                               Cnt
                               CreatedAt
                               CreatedBy
                               LocalLastChangedAt
                               LocalLastChangedBy
                               LastChangedAt )
               WITH lt_upl_curr
               " TODO: variable is assigned but never used (ABAP cleaner)
               FAILED FINAL(lt_upl_curr_fail).

      ENDIF.
    ENDIF.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zr_picode_upl IN LOCAL MODE
             ENTITY datafile
             UPDATE FIELDS ( UhPiUid
                             Notes
                             Active
                             Zindex
                             UplUuid
                             EndUser
                             Filename
                             Zcount
                             CreatedAt
                             CreatedBy
                             LocalLastChangedAt
                             LocalLastChangedBy
                             LastChangedAt )
             WITH lt_update
             FAILED FINAL(lt_update_fail).
    ENDIF.

    IF lt_create_preview IS NOT INITIAL.

      MODIFY ENTITIES OF zr_picode_upl IN LOCAL MODE
             ENTITY File
             CREATE BY \_previewdata
             FIELDS ( PiCode
                      PiFirstName
                      PiLastName
                      UhPiUid
                      Notes
                      Active
                      UploadUuid
                      Cnt
                      EndUser
                      CreatedAt
                      CreatedBy
                      LocalLastChangedAt
                      LocalLastChangedBy
                      LastChangedAt )
             WITH lt_create_preview
             FAILED FINAL(lt_preview_fail).

    ENDIF.

    MODIFY ENTITIES OF zr_picode_upl IN LOCAL MODE
           ENTITY file
           UPDATE FIELDS ( status )
           WITH VALUE #(
               FOR ls_inv_n IN lt_inv
               ( %tky   = ls_inv_n-%tky
                 status = COND #( WHEN lt_insert_fail-datafile IS NOT INITIAL     THEN file_status-insert_fail
                                  WHEN lt_update_fail-datafile IS NOT INITIAL     THEN file_status-update_fail
                                  WHEN lt_preview_fail-previewdata IS NOT INITIAL THEN file_status-preview_fail
                                  ELSE                                                 file_status-completed ) ) ).
  ENDMETHOD.

  METHOD validateConnection.
    DATA ls_data_error TYPE zst_aws_upsert_table_error.
    DATA lt_upl        TYPE TABLE FOR READ RESULT zr_picode_upl\\File.
    DATA lv_msg        TYPE string.

    TRY.
        FINAL(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                    comm_scenario  = comm_scenario
                                    service_id     = service_id
                                    comm_system_id = comm_system_id ).

        FINAL(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                                    i_destination = lo_destination ).

        FINAL(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_header_field( i_name  = i_name
                                      i_value = i_value ).

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

      READ ENTITIES OF zr_picode_upl
           IN LOCAL MODE
           ENTITY File
           ALL FIELDS
           WITH CORRESPONDING #( keys )
           RESULT lt_upl.

      LOOP AT lt_upl INTO FINAL(ls_upl).

        APPEND VALUE #( %tky        = ls_upl-%tky
                        %state_area = 'VALIDATE_CONNECTION' ) TO reported-file.

        APPEND VALUE #( %tky = ls_upl-%tky ) TO failed-file.

        APPEND VALUE #( %tky        = ls_upl-%tky
                        %state_area = 'VALIDATE_CONNECTION'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msg ) ) TO reported-file.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD checkgenPiCode.
  ENDMETHOD.
ENDCLASS.
