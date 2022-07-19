CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer.
    "types used in get_data
    TYPES:
      tt_supplier        TYPE STANDARD TABLE OF zak_supplier_c,
      tt_supplier_in     TYPE TABLE FOR READ IMPORT zak_supplier_c,
      tt_supplier_out    TYPE TABLE FOR READ RESULT zak_supplier_c,
      tt_supplier_failed TYPE TABLE FOR FAILED zak_supplier_c,
      tt_supplier_upd    TYPE TABLE FOR UPDATE zak_supplier_c,
      tt_supplier_mapped TYPE TABLE FOR MAPPED zak_supplier_c.
    METHODS get_data
      IMPORTING it_supplier        TYPE tt_supplier_in OPTIONAL
      EXPORTING et_supplier        TYPE tt_supplier_out
                et_supplier_failed TYPE tt_supplier_failed.
    METHODS put_data
      IMPORTING it_supplier_upd    TYPE tt_supplier_upd
      EXPORTING et_supplier_failed TYPE tt_supplier_failed.
  PRIVATE SECTION.
    CLASS-DATA: go_instance TYPE REF TO lcl_buffer.
    DATA: mt_supplier TYPE tt_supplier.
ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD get_data.
    DATA: lt_supplier TYPE STANDARD TABLE OF zak_suppliers.
    DATA: ls_result LIKE LINE OF et_supplier.
    DATA: lt_supplier_id TYPE STANDARD TABLE OF zak_supplier_c-SupplierID.
    DATA: lt_filter TYPE RANGE OF zak_supplier_c-SupplierID.
    DATA: ls_filter LIKE LINE OF lt_filter.
    DATA: lt_supplier_ce TYPE STANDARD TABLE OF zak_supplier_c.
    DATA: lt_supplier_add TYPE STANDARD TABLE OF zak_d_suppladd.
    FIELD-SYMBOLS: <ls_supplier_ce> LIKE LINE OF lt_supplier_ce.
    IF it_supplier IS SUPPLIED.
      LOOP AT it_supplier ASSIGNING FIELD-SYMBOL(<ls_supplier>).
        IF line_exists( mt_supplier[ SupplierID = <ls_supplier>-SupplierID ] ).
          ls_result = CORRESPONDING #( mt_supplier[ SupplierID = <ls_supplier>-SupplierID ] ).
          " collect from buffer for result
          APPEND ls_result TO et_supplier.
        ELSE.
          " collect to retrieve from persistence
          APPEND <ls_supplier>-SupplierID TO lt_supplier_id.
        ENDIF.
      ENDLOOP.
      IF lt_supplier_id IS NOT INITIAL.
        TRY.
            DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( i_url = 'https://services.odata.org' ).
            DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_http_destination ).

            DATA(lo_client_proxy) = cl_web_odata_client_factory=>create_v4_remote_proxy(
              EXPORTING
                iv_service_definition_name = 'ZAK_SC_SUPPLIERS'
                io_http_client             = lo_http_client
                iv_relative_service_root   = '/V4/Northwind/Northwind.svc/' ).
            DATA(lo_request) = lo_client_proxy->create_resource_for_entity_set( 'SUPPLIERS' )->create_request_for_read( ).
            lt_filter = VALUE #( FOR supplier_id IN lt_supplier_id ( sign = 'I' option = 'EQ' low = supplier_id ) ).
            DATA(lo_filter) = lo_request->create_filter_factory( )->create_by_range( iv_property_path = 'SUPPLIERID'
            it_range = lt_filter ).
            lo_request->set_filter( lo_filter ).
            DATA(lo_response) = lo_request->execute( ).
            " get relevant data sets
            lo_response->get_business_data( IMPORTING et_business_data = lt_supplier ).
            " add local data
            IF lt_supplier IS NOT INITIAL.
              " map OData service to custom entity
              lt_supplier_ce = CORRESPONDING #( lt_supplier ).
              SELECT * FROM zak_d_suppladd FOR ALL ENTRIES IN @lt_supplier_ce WHERE supplierid = @lt_supplier_ce-SupplierID INTO TABLE @lt_supplier_add.
              LOOP AT lt_supplier_id ASSIGNING FIELD-SYMBOL(<ls_supplier_id>).
                IF line_exists( lt_supplier_ce[ SupplierID = <ls_supplier_id> ] ).
                  ASSIGN lt_supplier_ce[ SupplierID = <ls_supplier_id> ] TO <ls_supplier_ce>.
                  IF line_exists( lt_supplier_add[ supplierid = <ls_supplier_ce>-SupplierID ] ).
                    <ls_supplier_ce>-Discount_pct = lt_supplier_add[ supplierid = <ls_supplier_ce>-SupplierID ]-discount_pct.
                    <ls_supplier_ce>-lastchangedat = lt_supplier_add[ supplierid = <ls_supplier_ce>-SupplierID ]-lastchangedat.
                  ELSE.
                    <ls_supplier_ce>-lastchangedat = '20000101120000' . "initial value Jan 1, 2000, 12:00:00 AM
                  ENDIF.
                  ls_result = CORRESPONDING #( <ls_supplier_ce> ).
                  APPEND <ls_supplier_ce> TO mt_supplier.
                  APPEND ls_result TO et_supplier.
                ELSE.
                  APPEND VALUE #( supplierid = <ls_supplier_id> ) TO et_supplier_failed.
                ENDIF.
              ENDLOOP.
            ENDIF.
          CATCH /iwbep/cx_gateway.
            et_supplier_failed = CORRESPONDING #( lt_supplier_id MAPPING SupplierID = table_line ).
        ENDTRY.
      ENDIF.
    ELSE.
      et_supplier = CORRESPONDING #( mt_supplier ).
    ENDIF.
  ENDMETHOD.

  METHOD put_data.
    get_data(
      EXPORTING
        it_supplier        = CORRESPONDING #( it_supplier_upd )
      IMPORTING
        et_supplier        = DATA(lt_supplier)
        et_supplier_failed = DATA(lt_supplier_failed)
    ).
    LOOP AT it_supplier_upd ASSIGNING FIELD-SYMBOL(<ls_supplier_upd>).
      CHECK line_exists( lt_supplier[ KEY entity COMPONENTS SupplierID = <ls_supplier_upd>-SupplierID ] ).
      ASSIGN lt_supplier[ KEY entity COMPONENTS SupplierID = <ls_supplier_upd>-SupplierID ] TO FIELD-SYMBOL(<ls_supplier>).
      IF <ls_supplier_upd>-%control-Discount_pct = if_abap_behv=>mk-on.
        <ls_supplier>-Discount_pct = <ls_supplier_upd>-Discount_pct.
      ELSE.
        <ls_supplier>-LastChangedAt = <ls_supplier_upd>-LastChangedAt.
      ENDIF.
    ENDLOOP.
    "save data in buffer
    mt_supplier = CORRESPONDING #( lt_supplier ) .
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZAK_SUPPLIER_C DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update_discount FOR MODIFY
      IMPORTING it_supplier_update FOR UPDATE Supplier_C.

    METHODS read_supplier FOR READ
      IMPORTING it_supplier_read FOR READ Supplier_C RESULT et_supplieraddifo.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Supplier_C.

ENDCLASS.

CLASS lhc_ZAK_SUPPLIER_C IMPLEMENTATION.

  METHOD update_discount.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    lo_buffer->put_data(
      EXPORTING
        it_supplier_upd    = it_supplier_update
      IMPORTING
        et_supplier_failed = failed-supplier_c
    ).
  ENDMETHOD.

  METHOD read_supplier.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    lo_buffer->get_data(
      EXPORTING
        it_supplier        = it_supplier_read
      IMPORTING
        et_supplier        = et_supplieraddifo
        et_supplier_failed = failed-supplier_c ).
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZAK_SUPPLIER_C DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZAK_SUPPLIER_C IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA: ls_supplieradd  TYPE zak_d_suppladd,
          lt_supplier_upd TYPE TABLE FOR UPDATE zak_supplier_c.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    lo_buffer->get_data(
      IMPORTING
        et_supplier = DATA(lt_supplier)
    ).
    LOOP AT lt_supplier ASSIGNING FIELD-SYMBOL(<ls_supplieraddinfo>).
      ls_supplieradd = CORRESPONDING #( <ls_supplieraddinfo> MAPPING supplierid   = SupplierID
                                                                     discount_pct = Discount_pct ).
      GET TIME STAMP FIELD ls_supplieradd-lastchangedat.
      MODIFY zak_d_suppladd FROM @ls_supplieradd.

      APPEND  CORRESPONDING #( ls_supplieradd ) TO lt_supplier_upd.
      lo_buffer->put_data(
        EXPORTING
          it_supplier_upd = lt_supplier_upd ).

    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
