CLASS zak_cl_suppl_query_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zak_cl_suppl_query_provider IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA:
      lt_supplier           TYPE TABLE OF zak_suppliers,
      lt_supplier_add       TYPE TABLE OF zak_d_suppladd,
      lt_supplier_ce        TYPE TABLE OF zak_supplier_c,
      lo_http_client        TYPE REF TO if_web_http_client,
      lo_odata_client_proxy TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request            TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response           TYPE REF TO /iwbep/if_cp_response_read_lst,
      lo_filter             TYPE REF TO /iwbep/if_cp_filter_node..

    DATA(lv_is_data_requested)   = io_request->is_data_requested( ).
    DATA(lv_is_count_requested)  = io_request->is_total_numb_of_rec_requested(  ).

    TRY.

        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( i_url = 'https://services.odata.org' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_http_destination ).

        lo_odata_client_proxy = cl_web_odata_client_factory=>create_v4_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZAK_SC_SUPPLIERS'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/V4/Northwind/Northwind.svc/' ).

        " Navigate to the resource and create a request for the read operation
        lo_request = lo_odata_client_proxy->create_resource_for_entity_set( 'SUPPLIERS' )->create_request_for_read( ).

        """Request Count
        IF lv_is_count_requested = abap_true.
          lo_request->request_count(  ).
        ENDIF.
        """Request Data
        IF lv_is_data_requested = abap_true.
          """Request Paging
          DATA(ls_paging) = io_request->get_paging( ).
          IF ls_paging->get_offset( ) >= 0.
            lo_request->set_skip( ls_paging->get_offset( ) ).
          ENDIF.
          IF ls_paging->get_page_size( ) <> if_rap_query_paging=>page_size_unlimited.
            lo_request->set_top( ls_paging->get_page_size( ) ).
          ENDIF.
        ENDIF.

        """Request Filtering
        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).
          "create filter factory for read request
          DATA(lo_filter_factory) = lo_request->create_filter_factory( ).

          DATA(lo_filter_for_current_field) = lo_filter_factory->create_by_range( iv_property_path = <ls_filter>-name
                                                                                  it_range         = <ls_filter>-range ).
          "Concatenate filter if more than one filter element
          IF lo_filter IS INITIAL.
            lo_filter = lo_filter_for_current_field.
          ELSE.
            lo_filter = lo_filter->and( lo_filter_for_current_field ).
          ENDIF.
        ENDLOOP.

        "set filter
        IF lo_filter IS NOT INITIAL.
          lo_request->set_filter( lo_filter ).
        ENDIF.

        """Execute the Request
        lo_response = lo_request->execute( ).
        """Set Count
        IF lv_is_count_requested = abap_true.
          io_response->set_total_number_of_records( lo_response->get_count( ) ).
        ENDIF.
        """Set Data
        IF lv_is_data_requested = abap_true.
          lo_response->get_business_data( IMPORTING et_business_data = lt_supplier ).
          IF lt_supplier IS NOT INITIAL.
            lt_supplier_ce = CORRESPONDING #( lt_supplier ).
            SELECT * FROM zak_d_suppladd FOR ALL ENTRIES IN @lt_supplier_ce WHERE supplierid = @lt_supplier_ce-SupplierID INTO TABLE @lt_supplier_add.
            LOOP AT lt_supplier_ce ASSIGNING FIELD-SYMBOL(<ls_supplier_ce>).
              IF line_exists( lt_supplier_add[ supplierid = <ls_supplier_ce>-SupplierID ] ).
                <ls_supplier_ce>-Discount_pct = lt_supplier_add[ supplierid = <ls_supplier_ce>-SupplierID ]-discount_pct.
                <ls_supplier_ce>-LastChangedAt = lt_supplier_add[ supplierid = <ls_supplier_ce>-SupplierID ]-lastchangedat.
              ELSE.
                <ls_supplier_ce>-lastchangedat = '20000101120000' . "initial value Jan 1, 2000, 12:00:00 AM
              ENDIF.
            ENDLOOP.
          ENDIF.
          io_response->set_data( lt_supplier_ce ).
        ENDIF.

      CATCH /iwbep/cx_cp_remote
      /iwbep/cx_gateway
      cx_web_http_client_error
      cx_http_dest_provider_error
      cx_rap_query_filter_no_range
      INTO DATA(lx_exception).
        DATA(lv_exception_message) = cl_message_helper=>get_latest_t100_exception( lx_exception )->if_message~get_longtext( ).

    ENDTRY.
  ENDMETHOD.
ENDCLASS.

