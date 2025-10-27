CLASS zcl_check_connection_aws DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES: BEGIN OF ts_data,
             sap_id           TYPE c LENGTH 36,
             type             TYPE c LENGTH 2,
             code             TYPE c LENGTH 100,
             uh_code          TYPE c LENGTH 100,
             description      TYPE c LENGTH 100,
             active_indicator TYPE xsdboolean,
           END OF ts_data.

    TYPES: BEGIN OF ts_data_batch,
             sap_id           TYPE c LENGTH 36,
             type             TYPE c LENGTH 2,
             code             TYPE c LENGTH 100,
             uh_code          TYPE c LENGTH 100,
             description      TYPE c LENGTH 100,
             other            TYPE c LENGTH 100,
             active_indicator TYPE xsdboolean,
           END OF ts_data_batch,
           tt_data_batch TYPE STANDARD TABLE OF ts_data_batch WITH EMPTY KEY.

    TYPES: BEGIN OF ls_data_batch,
             data TYPE tt_data_batch,
           END OF ls_data_batch.

    TYPES: BEGIN OF ts_data_subproject,
             sap_id           TYPE c LENGTH 36,
             campus           TYPE zr_sub_proj-CampusCode,
             project_number   TYPE c LENGTH 10,
             number           TYPE zr_sub_proj-SubProjectNumber,
             name             TYPE zr_sub_proj-SubProjectName,
             active_indicator TYPE xsdboolean,
           END OF ts_data_subproject.
    TYPES: BEGIN OF ts_data_sub_budcat,
             sap_id           TYPE c LENGTH 36,
             campus           TYPE zr_sub_bud_cat-CampusCode,
             project_number   TYPE c LENGTH 10,
             category_code    TYPE zr_sub_bud_cat-BudgetCategoryCode,
             subcategory_code TYPE zr_sub_bud_cat-SubBudcatCategory,
             name             TYPE zr_sub_bud_cat-SubBudcatName,
             active_indicator TYPE xsdboolean,
           END OF ts_data_sub_budcat.

    " ---------------------------------------------------------------------

    METHODS aws_table_masters IMPORTING is_data   TYPE ts_data
                              EXPORTING ev_msg    TYPE string
                                        es_status TYPE if_web_http_response=>http_status.

    METHODS aws_table_subproject IMPORTING is_data   TYPE ts_data_subproject
                                 EXPORTING ev_msg    TYPE string
                                           es_status TYPE if_web_http_response=>http_status.

    METHODS aws_table_sub_budcat IMPORTING is_data   TYPE ts_data_sub_budcat
                                 EXPORTING ev_msg    TYPE string
                                           es_status TYPE if_web_http_response=>http_status.

    METHODS aws_table_masters_batch IMPORTING it_data   TYPE ls_data_batch
                                    EXPORTING ev_msg    TYPE string
                                              es_status TYPE if_web_http_response=>http_status.

  PRIVATE SECTION.
    CONSTANTS comm_scenario      TYPE if_com_management=>ty_cscn_id          VALUE 'ZPI_CS_0002'.
    CONSTANTS comm_system_id     TYPE if_com_management=>ty_cs_id            VALUE 'AWS'.
    CONSTANTS service_id         TYPE if_com_management=>ty_cscn_outb_srv_id VALUE 'ZAWS_UPSERT_TABLE_MASTERS_REST'.
    CONSTANTS service_sub_proj   TYPE if_com_management=>ty_cscn_outb_srv_id VALUE 'ZAWS_UPSERT_SUBPROJECT_REST'.
    CONSTANTS service_sub_budcat TYPE if_com_management=>ty_cscn_outb_srv_id VALUE 'ZAWS_UPSERT_SUB_BUDCAT_REST'.
    CONSTANTS i_name             TYPE string                                 VALUE 'x-api-key'.
    CONSTANTS i_value            TYPE string
                                 VALUE 'U0FQOjo6WWlUNzU1aHpENWh6RERZVjl5NVlWOXk1NWh6Vk4='.

ENDCLASS.



CLASS ZCL_CHECK_CONNECTION_AWS IMPLEMENTATION.


  METHOD aws_table_masters.
    DATA ls_data_error   TYPE zst_aws_upsert_table_masters.
    DATA ls_data_success TYPE zst_aws_upsert_table_success.

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

        DATA(ld_json) = /ui2/cl_json=>serialize( data          = is_data
                                                 format_output = abap_true
                                                 pretty_name   = /ui2/cl_json=>pretty_mode-camel_case ).

        lo_request->append_text( ld_json ).
        FINAL(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>put ).

        DATA(lv_results) = lo_response->get_text( ).
        es_status = lo_response->get_status( ).

        CASE es_status-code.
          WHEN 200.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_success ) ).
            ev_msg = ls_data_success-data-id.
          WHEN OTHERS.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_error ) ).

            LOOP AT ls_data_error-message ASSIGNING FIELD-SYMBOL(<f_message>).
              CONCATENATE <f_message> ev_msg INTO ev_msg SEPARATED BY space.
            ENDLOOP.
        ENDCASE.

      CATCH cx_http_dest_provider_error INTO DATA(lo_provider).
        ev_msg = lo_provider->get_text( ).
      CATCH cx_web_http_client_error INTO DATA(lo_client).
        ev_msg = lo_client->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ts_data,
             sap_id      TYPE c LENGTH 36,
             type        TYPE c LENGTH 2,
             code        TYPE ztb_pi_cc-pi_code,
             description TYPE c LENGTH 100,
           END OF ts_data.

    DATA ls_data         TYPE ts_data.
    DATA lv_uuid         TYPE c LENGTH 32.
    DATA ls_data_success TYPE zst_aws_upsert_table_success.
    DATA ls_data_error   TYPE zst_aws_upsert_table_masters.

    TRY.

        " TODO: variable is assigned but never used (ABAP cleaner)
        FINAL(lo_destination_subproj) = cl_http_destination_provider=>create_by_comm_arrangement(
                                            comm_scenario  = comm_scenario
                                            service_id     = service_sub_proj
                                            comm_system_id = comm_system_id ).

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

        lv_uuid = xco_cp=>uuid( )->value.
        ls_data-sap_id      = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.
        ls_data-description = |TEST06, TEST06|.
        ls_data-code        = |PI06|.
        ls_data-type        = 'PI'.

        DATA(ld_json) = /ui2/cl_json=>serialize( data          = ls_data
                                                 format_output = abap_true
                                                 pretty_name   = /ui2/cl_json=>pretty_mode-camel_case ).

        lo_request->append_text( ld_json ).

        FINAL(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>put ).
        FINAL(lv_results) = lo_response->get_text( ).
        FINAL(lv_status) = lo_response->get_status( ).

        CASE lv_status-code.
          WHEN 200 OR 201.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_success ) ).

          WHEN OTHERS.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_error ) ).

            " TODO: variable is assigned but never used (ABAP cleaner)
            LOOP AT ls_data_error-message ASSIGNING FIELD-SYMBOL(<f_message>).

            ENDLOOP.
        ENDCASE.

      CATCH cx_root INTO FINAL(lx_exception).
        out->write( lx_exception->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD aws_table_masters_batch.
    DATA ls_data_error   TYPE zst_aws_upsert_table_masters.
    DATA ls_data_success TYPE zst_aws_upsert_success_batch.

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

        DATA(ld_json) = /ui2/cl_json=>serialize( data          = it_data
                                                 format_output = abap_true
                                                 pretty_name   = /ui2/cl_json=>pretty_mode-camel_case ).

        lo_request->append_text( ld_json ).
        FINAL(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).

        DATA(lv_results) = lo_response->get_text( ).
        es_status = lo_response->get_status( ).

        CASE es_status-code.
          WHEN 200 OR 201.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_success ) ).
            ev_msg = |{ ls_data_success-code } { ls_data_success-success }|.
          WHEN OTHERS.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_error ) ).

            LOOP AT ls_data_error-message ASSIGNING FIELD-SYMBOL(<f_message>).
              CONCATENATE <f_message> ev_msg INTO ev_msg SEPARATED BY space.
            ENDLOOP.
        ENDCASE.

      CATCH cx_http_dest_provider_error INTO DATA(lo_provider).
        ev_msg = lo_provider->get_text( ).
      CATCH cx_web_http_client_error INTO DATA(lo_client).
        ev_msg = lo_client->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD aws_table_subproject.
    DATA ls_data_error   TYPE zst_aws_upsert_table_subproj.
    DATA ls_data_success TYPE zst_aws_upsert_success_batch.

    TRY.

        FINAL(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                    comm_scenario  = comm_scenario
                                    service_id     = service_sub_proj
                                    comm_system_id = comm_system_id ).

        FINAL(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                                    i_destination = lo_destination ).

        FINAL(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_header_field( i_name  = i_name
                                      i_value = i_value ).

        lo_request->set_content_type( content_type = 'application/json' ).

        DATA(ld_json) = /ui2/cl_json=>serialize( data             = is_data
                                                 format_output    = abap_true
                                                 conversion_exits = abap_true
                                                 pretty_name      = /ui2/cl_json=>pretty_mode-camel_case ).

        lo_request->append_text( ld_json ).
        FINAL(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>put ).

        DATA(lv_results) = lo_response->get_text( ).
        es_status = lo_response->get_status( ).

        CASE es_status-code.
          WHEN 200 OR 201.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_success ) ).
            ev_msg = |{ ls_data_success-code } { ls_data_success-success }|.
          WHEN OTHERS.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_error ) ).

            CONCATENATE ls_data_error-message ev_msg INTO ev_msg SEPARATED BY space.

        ENDCASE.

      CATCH cx_http_dest_provider_error INTO DATA(lo_provider).
        ev_msg = lo_provider->get_text( ).
      CATCH cx_web_http_client_error INTO DATA(lo_client).
        ev_msg = lo_client->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD aws_table_sub_budcat.
    DATA ls_data_error   TYPE zst_aws_upsert_table_subproj.
    DATA ls_data_success TYPE zst_aws_upsert_success_batch.

    TRY.

        FINAL(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                    comm_scenario  = comm_scenario
                                    service_id     = service_sub_budcat
                                    comm_system_id = comm_system_id ).

        FINAL(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                                    i_destination = lo_destination ).

        FINAL(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_header_field( i_name  = i_name
                                      i_value = i_value ).

        lo_request->set_content_type( content_type = 'application/json' ).

        DATA(ld_json) = /ui2/cl_json=>serialize( data             = is_data
                                                 format_output    = abap_true
                                                 conversion_exits = abap_true
                                                 pretty_name      = /ui2/cl_json=>pretty_mode-camel_case ).

        lo_request->append_text( ld_json ).
        FINAL(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>put ).

        DATA(lv_results) = lo_response->get_text( ).
        es_status = lo_response->get_status( ).

        CASE es_status-code.
          WHEN 200 OR 201.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_success ) ).
            ev_msg = |{ ls_data_success-code } { ls_data_success-success }|.
          WHEN OTHERS.
            xco_cp_json=>data->from_string( iv_string = lv_results )->apply(
                VALUE #( ( xco_cp_json=>transformation->boolean_to_abap_bool ) )
            )->write_to( ia_data = REF #( ls_data_error ) ).

            CONCATENATE ls_data_error-message ev_msg INTO ev_msg SEPARATED BY space.

        ENDCASE.

      CATCH cx_http_dest_provider_error INTO DATA(lo_provider).
        ev_msg = lo_provider->get_text( ).
      CATCH cx_web_http_client_error INTO DATA(lo_client).
        ev_msg = lo_client->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
