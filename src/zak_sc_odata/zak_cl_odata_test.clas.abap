CLASS zak_cl_odata_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    TYPES t_agency_range TYPE RANGE OF zak_z_travel_agency_es5-agencyid.
    TYPES t_business_data TYPE TABLE OF zak_z_travel_agency_es5.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zak_cl_odata_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

**************************TEST FOR RAP ADVANCED PROGRAM TASK***********************
*    DATA:
*      lt_business_data TYPE TABLE OF zak_a_businesspartner,
*      lo_http_client   TYPE REF TO if_web_http_client,
*      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
*      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.
*
*    TRY.
**        " Create http client
*        DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = 'https://my303843.s4hana.ondemand.com:443' ).
*        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
**
*        lo_http_client->get_http_request( )->set_authorization_basic(
*            i_username = 'POSTMAN_USER'
*            i_password = 'bLaPPuUkMMmDJGzgklwHQQqfJLlAPSi[5ekDKgxL'
*        ).
**        CATCH cx_web_message_error..
*
*        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
*          EXPORTING
*            iv_service_definition_name = 'ZAK_SC_BUSINESS_PARTNER'
*            io_http_client             = lo_http_client
*            iv_relative_service_root   = 'sap/opu/odata/sap/API_BUSINESS_PARTNER' ).
*
*        " Navigate to the resource and create a request for the read operation
*        lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_BUSINESSPARTNER' )->create_request_for_read( ).
*
*        lo_request->set_top( 50 )->set_skip( 0 ).
*
*        " Execute the request and retrieve the business data
*        lo_response = lo_request->execute( ).
*
*        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
*        out->write( lt_business_data ).
*      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
*        " Handle remote Exception
*        " It contains details about the problems of your http(s) connection
*
*      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*        " Handle Exception
**
*    ENDTRY.
**************************TEST FOR RAP ADVANCED PROGRAM TASK***********************




***********LIKE IN OPEN SAP COURSE WEEK 5******************************
*    DATA business_data TYPE t_business_data.
*
*    TRY.
*        DATA: http_client        TYPE REF TO if_web_http_client,
*          odata_client_proxy TYPE REF TO /iwbep/if_cp_client_proxy,
*          read_list_request  TYPE REF TO /iwbep/if_cp_request_read_list,
*          read_list_response TYPE REF TO /iwbep/if_cp_response_read_lst.
*
*    DATA(http_destination) = cl_http_destination_provider=>create_by_url( i_url = 'https://sapes5.sapdevcenter.com' ).
*    http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = http_destination ).
*
*    odata_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
*      EXPORTING
*        iv_service_definition_name = 'ZAK_SC_AGENCY'
*        io_http_client             = http_client
*        iv_relative_service_root   = '/sap/opu/odata/sap/ZAGENCYCDS_SRV/' ).
*
*    " Navigate to the resource and create a request for the read operation
*    read_list_request = odata_client_proxy->create_resource_for_entity_set( 'Z_TRAVEL_AGENCY_ES5' )->create_request_for_read( ).
*
*    " Execute the request and retrieve the business data and count if requested
*    read_list_response = read_list_request->execute( ).
*
*    read_list_response->get_business_data( IMPORTING et_business_data = business_data ).
*        out->write( business_data ).
*      CATCH cx_root INTO DATA(exception).
*        out->write( cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ) ).
*    ENDTRY.
***********LIKE IN OPEN SAP COURSE WEEK 5******************************




*************TEST EXTERNAL API (YANDEX DICTIONARY)***************
*    TYPES:
*      BEGIN OF gty_translated_data,
*        text TYPE string,
*        pos  TYPE string,
*        gen  TYPE string,
*        fr   TYPE string,
*        syn  TYPE string,
*        mean TYPE string,
*        ex   TYPE string,
*      END OF GTY_TRANSLATED_DATA,
*      BEGIN OF gty_retrieved_data,
*        text TYPE string,
*        pos  TYPE string,
*        ts   TYPE string,
*        tr   TYPE TABLE of gty_translated_data WITH DEFAULT KEY,
*      END OF gty_retrieved_data.
*
*    DATA: lt_retrieved_data TYPE TABLE OF gty_retrieved_data,
*          lv_url            TYPE string.
*    DATA(lv_lang) = 'RU'.
*    DATA(lv_group_name) = 'Blender'.
*    lv_url = |{ 'https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20220614T181830Z.847b2a193b420fe4.d99faeec698b863c5e51950810d6d572bc7f1c93&lang=en-' && to_lower( lv_lang ) && '&text=' && lv_group_name }|.
*
*    DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
*    DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
*
*    lo_http_client->execute(
*      EXPORTING
*        i_method   = if_web_http_client=>get
**       i_timeout  = 0
*      RECEIVING
*        r_response = DATA(lo_response)
*    ).
*
**    CATCH cx_web_http_client_error.
*
*    SPLIT lo_response->get_text( ) AT '[' INTO DATA(lv_string1) DATA(lv_string2).
*    lo_http_client->close( ).
**    CATCH cx_web_http_client_error.
*    lv_string2 = |{ '[' && lv_string2 }|.
*    DATA(lv_text_data) = substring( val = lv_string2 off = 0 len = strlen( lv_string2 ) - 1 ).
*
*    /ui2/cl_json=>deserialize(
*      EXPORTING
*        json        = lv_text_data
*        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
*      CHANGING
*        data        = lt_retrieved_data
*    ).
*************TEST EXTERNAL API (YANDEX DICTIONARY)***************




***********TEST REMOTE SERVICE SUPPLIER******************************
*    DATA lt_business_data TYPE TABLE OF zak_suppliers.
*
*    TRY.
*        DATA: lo_http_client        TYPE REF TO if_web_http_client,
*              lo_odata_client_proxy TYPE REF TO /iwbep/if_cp_client_proxy,
*              lo_read_list_request  TYPE REF TO /iwbep/if_cp_request_read_list,
*              lo_read_list_response TYPE REF TO /iwbep/if_cp_response_read_lst.
*
*        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( i_url = 'https://services.odata.org' ).
*        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_http_destination ).
*
*        lo_odata_client_proxy = cl_web_odata_client_factory=>create_v4_remote_proxy(
*          EXPORTING
*            iv_service_definition_name = 'ZAK_SC_SUPPLIERS'
*            io_http_client             = lo_http_client
*            iv_relative_service_root   = '/V4/Northwind/Northwind.svc/' ).
*
*        " Navigate to the resource and create a request for the read operation
*        lo_read_list_request = lo_odata_client_proxy->create_resource_for_entity_set( 'SUPPLIERS' )->create_request_for_read( ).
*
*        " Execute the request and retrieve the business data and count if requested
*        lo_read_list_response = lo_read_list_request->execute( ).
*
*        lo_read_list_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
*        out->write( lt_business_data ).
*      CATCH cx_root INTO DATA(exception).
*        out->write( cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ) ).
*    ENDTRY.
***********TEST REMOTE SERVICE SUPPLIER******************************

  ENDMETHOD.
ENDCLASS.
