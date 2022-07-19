CLASS zak_cl_bp_query_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: gsy_partner_range TYPE RANGE OF zak_a_businesspartner-BusinessPartner,
           gty_business_data TYPE TABLE OF zak_a_businesspartner.

    METHODS get_busspartners
      IMPORTING
        it_filter_cond        TYPE if_rap_query_filter=>tt_name_range_pairs   OPTIONAL
        iv_top                TYPE i OPTIONAL
        iv_skip               TYPE i OPTIONAL
        iv_is_data_requested  TYPE abap_bool
        iv_is_count_requested TYPE abap_bool
      EXPORTING
        et_business_data      TYPE gty_business_data
        ev_count              TYPE int8
      RAISING
        /iwbep/cx_cp_remote
        /iwbep/cx_gateway
        cx_web_http_client_error
        cx_http_dest_provider_error.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zak_cl_bp_query_provider IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA:
      lt_business_data TYPE TABLE OF zak_a_businesspartner,
      lv_count         TYPE int8.

    DATA(lv_top)              = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)             = io_request->get_paging( )->get_offset( ).
    DATA(lt_requested_fields) = io_request->get_requested_elements( ).
    DATA(lt_sort_order)       = io_request->get_sort_elements( ).
    DATA(lv_is_data_requested)   = io_request->is_data_requested( ).
    DATA(lv_is_count_requested)  = io_request->is_total_numb_of_rec_requested(  ).

    TRY.
        DATA(lt_filter_condition) = io_request->get_filter( )->get_as_ranges( ).

        get_busspartners(
          EXPORTING
            it_filter_cond        = lt_filter_condition
            iv_top                = CONV i( lv_top )
            iv_skip               = CONV i( lv_skip )
            iv_is_data_requested  = lv_is_data_requested
            iv_is_count_requested = lv_is_count_requested
          IMPORTING
            et_business_data      = lt_business_data
            ev_count              = lv_count
        ).

        IF lv_is_data_requested = abap_true.
          io_response->set_data( lt_business_data ).
        ENDIF.

        IF lv_is_count_requested = abap_true.
          io_response->set_total_number_of_records( lv_count ).
        ENDIF.

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_exception_message) = cl_message_helper=>get_latest_t100_exception( lx_remote )->if_message~get_longtext( ).
      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_exception_message = cl_message_helper=>get_latest_t100_exception( lx_gateway )->if_message~get_longtext( ).
      CATCH cx_web_http_client_error INTO DATA(lx_http_client).
        lv_exception_message = cl_message_helper=>get_latest_t100_exception( lx_http_client )->if_message~get_longtext( ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_provider).
        lv_exception_message = cl_message_helper=>get_latest_t100_exception( lx_provider )->if_message~get_longtext( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_filter).
        lv_exception_message = cl_message_helper=>get_latest_t100_exception( lx_filter )->if_message~get_longtext( ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_busspartners.

    DATA:
      lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
      lo_filter_node      TYPE REF TO /iwbep/if_cp_filter_node,
      lo_root_filter_node TYPE REF TO /iwbep/if_cp_filter_node,
      lo_http_client      TYPE REF TO if_web_http_client,
      lo_client_proxy     TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request          TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response         TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA(http_destination) = cl_http_destination_provider=>create_by_url( i_url = 'https://my303843.s4hana.ondemand.com:443' ).
    lo_http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = http_destination ).

    lo_http_client->get_http_request( )->set_authorization_basic(
        i_username = 'POSTMAN_USER'
        i_password = 'bLaPPuUkMMmDJGzgklwHQQqfJLlAPSi[5ekDKgxL' ).

    lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
      EXPORTING
        iv_service_definition_name = 'ZAK_SC_BUSINESS_PARTNER'
        io_http_client             = lo_http_client
        iv_relative_service_root   = 'sap/opu/odata/sap/API_BUSINESS_PARTNER' ).

    " Navigate to the resource and create a request for the read operation
    lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_BUSINESSPARTNER' )->create_request_for_read( ).

    " Create the filter tree
    lo_filter_factory = lo_request->create_filter_factory( ).
    LOOP AT  it_filter_cond  ASSIGNING FIELD-SYMBOL(<ls_filter_cond>).
      lo_filter_node = lo_filter_factory->create_by_range( iv_property_path = <ls_filter_cond>-name
                                                           it_range         = <ls_filter_cond>-range ).
      IF lo_root_filter_node IS INITIAL.
        lo_root_filter_node = lo_filter_node.
      ELSE.
        lo_root_filter_node = lo_root_filter_node->and( lo_filter_node ).
      ENDIF.
    ENDLOOP.

    IF lo_root_filter_node IS NOT INITIAL.
      lo_request->set_filter( lo_root_filter_node ).
    ENDIF.

    IF iv_is_data_requested = abap_true.
      lo_request->set_skip( iv_skip ).
      IF iv_top > 0 .
        lo_request->set_top( iv_top ).
      ENDIF.
    ELSE.
      lo_request->request_no_business_data(  ).
    ENDIF.

    IF iv_is_count_requested = abap_true.
      lo_request->request_count(  ).
    ENDIF.

    " Execute the request and retrieve the business data
    lo_response = lo_request->execute( ).

    IF iv_is_data_requested = abap_true.
      lo_response->get_business_data( IMPORTING et_business_data = et_business_data ).
    ENDIF.
    IF iv_is_count_requested = abap_true.
      ev_count = lo_response->get_count(  ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
