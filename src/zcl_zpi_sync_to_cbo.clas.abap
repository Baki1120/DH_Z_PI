CLASS zcl_zpi_sync_to_cbo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZPI_SYNC_TO_CBO IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lv_json_payload TYPE string,
          lv_id           TYPE string,
          lv_piname       TYPE string,
          lv_grant_id     TYPE string.

    CONSTANTS:
      content_type     TYPE string VALUE 'Content-type',
      txt_content      TYPE string VALUE 'plain/txt',
      csrf_token       TYPE string VALUE 'x-csrf-token',
      csrf_token_value TYPE string VALUE 'fetch',
      json_content     TYPE string VALUE 'application/json; charset=UTF-8'.
    TRY.
        " Create HTTP client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                  comm_scenario  = 'YY1_COM_0002'
                                  comm_system_id = '0M5J2B6'
                                  service_id     = 'YY1_CRUD_PI_CODE_REST'
                                ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).

        "Set content format = json
        lo_request->set_header_field( i_name = content_type i_value = json_content ).
        lo_request->set_header_field( i_name = csrf_token i_value = csrf_token_value ).
        "********************************************************************************************************************
        "Request client: => GET
        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).
        DATA(lv_token) = lo_response->get_header_field( i_name = csrf_token ).
        IF lv_token IS INITIAL.

        ELSE.
*******************************************************************
          DATA(lv_status) = lo_response->get_status( ) .
          "Call API Get Token success
          IF lv_status-code = '200'.
            "Parse XML payload **********************************************************
            "XML processing response
            "Creating demo XML data to be used in the example as string. Using the cl_abap_conv_codepage
            "class, you can convert the string to xstring which is required for the example.
            DATA(response_xml) = cl_abap_conv_codepage=>create_out( )->convert( lo_response->get_text( ) ).
            "Creating one factory object of the access class cl_ixml_core using the
            "create method. It is used to access the iXML library.
            DATA(ixml_pa) = cl_ixml_core=>create( ).
            "Creaing an input stream that is used for the input of XML data
            DATA(stream_factory_pa) = ixml_pa->create_stream_factory( ).
            "Creating an XML document stored in DOM format in the memory
            DATA(document_pa) = ixml_pa->create_document( ).
            "Creating a parser. It requires the following input parameters: input stream to be parsed,
            "the XML document to which the stream is parsed, a factory required to create a stream
            DATA(parser_pa) = ixml_pa->create_parser(
                                istream = stream_factory_pa->create_istream_xstring( string = response_xml )
                                document = document_pa
                                stream_factory = stream_factory_pa ).

            "Parsing XML data to a DOM representation in one go. It is put in the memory.
            "Note: You can also parse sequentially, and not in one go.
            DATA(parsing_check) = parser_pa->parse( ).
            IF parsing_check = 0. "Parsing was successful
              "Get root document*********************************************************
              DATA(element_by_name) = document_pa->get_root_element(  ).
              "**************************************************************************
              "Creating an iterator******************************************************
              DATA(iterator_pa) = element_by_name->create_iterator( ).
              "**************************************************************************

              DO.
                "For the iteration, you can use the get_next method to process the nodes one after another.
                "Note: Here, all nodes are respected. You can also create filters to go over specific nodes.
                DATA(node_i) = iterator_pa->get_next( ).
                IF node_i IS INITIAL.
                  "Exiting the loop when there are no more nodes to process.
                  EXIT.
                ELSE.
                  "GET entry node *******************************************************
                  IF node_i->get_name( ) = 'entry' .
                    "Loop in entry node, get Id, content ********************************
                    DATA(iterator_entry) = node_i->create_iterator(  ).
                    DO.
                      DATA(node_entry) = iterator_entry->get_next( ).
                      IF node_entry IS INITIAL.
                        EXIT.
                      ELSE.
                        IF node_entry->get_name( ) = 'content' .
                          DATA(iterator_content) = node_entry->create_iterator( ).
                          DO.
                            DATA(node_content) = iterator_content->get_next( ).
                            IF node_content IS INITIAL.
                              EXIT.
                            ELSE.
                              IF node_content->get_name( ) = 'SAP_UUID'.
                                lv_id = node_content->get_value( ).
                              ENDIF.
                              IF node_content->get_name( ) = 'PrincipalInvestigatorCode'.
                                lv_grant_id = node_content->get_value( ).
                              ENDIF.
                            ENDIF.
                          ENDDO.
                        ENDIF.
                      ENDIF.

                    ENDDO.
******************************************************************************************************
*Process delete data in CBO with SAP_UUID
*Using Update API of CBO
******************************************************************************************************
                    DATA(lv_prefix) = |/sap/opu/odata/sap/YY1_PRINCIPALINVESTIGATOR_CDS/YY1_PRINCIPALINVESTIGATOR(guid'| .
                    DATA(lv_subfix) = |')| .
                    CONCATENATE lv_prefix lv_id lv_subfix  INTO  DATA(lv_service_relarative_url) .
                    lo_request = lo_http_client->get_http_request( )->set_uri_path( i_uri_path =  lv_service_relarative_url ).
                    lo_request->set_header_field( i_name = csrf_token i_value = lv_token ).
                    "Delete all data in CBO
                    lv_json_payload = '' .
                    lo_response = lo_http_client->execute( i_method = if_web_http_client=>delete ).
                    out->write( lo_response->get_status( ) ).


******************************************************************************************************
                  ENDIF.
                ENDIF.
              ENDDO.
            ENDIF.
************************>>>> SYNC ALL DATA 1409 with ACTIVE status to CBO
            lv_service_relarative_url = |/sap/opu/odata/sap/YY1_PRINCIPALINVESTIGATOR_CDS/YY1_PRINCIPALINVESTIGATOR| ..
            lo_request = lo_http_client->get_http_request( )->set_uri_path( i_uri_path =  lv_service_relarative_url ).
            lo_request->set_header_field( i_name = csrf_token i_value = lv_token ).
***********************>>>>> GET DATA FROM 1409 custom app
            SELECT pi_code ,
                  pi_last_name,
                  pi_first_name,
                  uh_pi_uid
                          FROM ztb_pi_cc
                          WHERE inactive <> 'X'
                          INTO TABLE @DATA(lt_fa_table) .
            IF sy-subrc EQ 0 .

            ENDIF.
            LOOP AT lt_fa_table INTO DATA(ls_fa_table) .
              lv_piname = ls_fa_table-pi_last_name && ` ` && ls_fa_table-pi_first_name && ` ` && '|' && ` ` && ls_fa_table-uh_pi_uid .
              CONCATENATE '{ "PrincipalInvestigatorCode" : "' ls_fa_table-pi_code '" , "SAP_Description" :"' lv_piname '"  }' INTO lv_json_payload .
              lo_request->set_text( lv_json_payload ) .
              lo_response = lo_http_client->execute( i_method = if_web_http_client=>post ).

            ENDLOOP.

          ENDIF.

        ENDIF.

      CATCH cx_fp_fdp_error cx_fp_ads_util cx_http_dest_provider_error cx_web_http_client_error INTO DATA(ex) .

        out->write( ex->get_longtext( ) ) .

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
