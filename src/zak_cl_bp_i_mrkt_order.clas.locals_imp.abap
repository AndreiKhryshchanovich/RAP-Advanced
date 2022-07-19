CLASS lhc_Order DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validate_delivery_date FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Order~validate_delivery_date.

    METHODS validate_business_partner FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Order~validate_business_partner.

    METHODS calculate_order_id FOR DETERMINE ON MODIFY
      IMPORTING lt_keys FOR Order~calculate_order_id.

    METHODS set_calendar_year FOR DETERMINE ON MODIFY
      IMPORTING lt_keys FOR Order~set_calendar_year.

    METHODS calculate_amount FOR DETERMINE ON MODIFY
      IMPORTING lt_keys FOR Order~calculate_amount.

    METHODS set_busspartner_fields FOR DETERMINE ON MODIFY
      IMPORTING lt_keys FOR Order~set_busspartner_fields.


ENDCLASS.

CLASS lhc_Order IMPLEMENTATION.

  METHOD calculate_order_id.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Order
        FIELDS ( Orderid ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_orders).

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      DATA: lv_max_order_id TYPE zak_order_id VALUE 0.

      SELECT FROM zak_d_mrkt_ord_d
             FIELDS MAX( orderid ) AS MaxOrderId
             WHERE mrktuuid = @<ls_order>-MrktUuid
        INTO @lv_max_order_id.

      IF <ls_order>-Orderid IS INITIAL.
        <ls_order>-Orderid = lv_max_order_id + 1.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          UPDATE FIELDS ( Orderid ) WITH CORRESPONDING #( lt_orders )
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD set_calendar_year.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          FIELDS ( DeliveryDate ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_orders).

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      <ls_order>-CalendarYear = <ls_order>-DeliveryDate+0(4).
    ENDLOOP.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          UPDATE FIELDS ( CalendarYear ) WITH CORRESPONDING #( lt_orders )
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD validate_delivery_date.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          FIELDS ( DeliveryDate ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_orders).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Market
          FIELDS ( Startdate Enddate ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_markets).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Order BY \_Product
        FROM CORRESPONDING #( lt_orders )
      LINK DATA(lt_order_product_links).

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      APPEND VALUE #(  %tky        = <ls_order>-%tky
                       %state_area = 'VALIDATE_DELIVERY_DATE' )
        TO reported-order.

      IF <ls_order>-DeliveryDate <= lt_markets[ MrktUuid = <ls_order>-MrktUuid ]-Startdate.
        APPEND VALUE #( %tky                 = <ls_order>-%tky ) TO failed-order.
        APPEND VALUE #( %tky                 = <ls_order>-%tky
                        %state_area          = 'VALIDATE_DELIVERY_DATE'
                        %msg                 = NEW zak_cm_products(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zak_cm_products=>delivery_date_less_start_date )
                        %path                = VALUE #( product-%tky = lt_order_product_links[ source-%tky = <ls_order>-%tky ]-target-%tky )
                        ) TO reported-order.
      ELSEIF lt_markets[ MrktUuid = <ls_order>-MrktUuid ]-Enddate IS NOT INITIAL AND
             <ls_order>-DeliveryDate > lt_markets[ MrktUuid = <ls_order>-MrktUuid ]-Enddate.
        APPEND VALUE #( %tky                 = <ls_order>-%tky ) TO failed-order.
        APPEND VALUE #( %tky                 = <ls_order>-%tky
                        %state_area          = 'VALIDATE_DELIVERY_DATE'
                        %msg                 = NEW zak_cm_products(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zak_cm_products=>delivery_date_greater_end_date )
                        %path                = VALUE #( product-%tky = lt_order_product_links[ source-%tky = <ls_order>-%tky ]-target-%tky )
                        ) TO reported-order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate_amount.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          FIELDS ( Quantity ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_orders).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Product
          FIELDS ( Price Taxrate PriceCurrency ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_products).

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      <ls_order>-Amountcurr = lt_products[ ProdUuid = <ls_order>-ProdUuid ]-PriceCurrency.
      <ls_order>-Netamount = <ls_order>-Quantity * lt_products[ ProdUuid = <ls_order>-ProdUuid ]-Price.
      <ls_order>-Grossamount = <ls_order>-Netamount + ( <ls_order>-Netamount * lt_products[ ProdUuid = <ls_order>-ProdUuid ]-Taxrate / 100 ).
    ENDLOOP.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          UPDATE FIELDS ( Amountcurr Netamount Grossamount ) WITH CORRESPONDING #( lt_orders )
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD set_busspartner_fields.

    DATA:
      lt_filter_conditions TYPE if_rap_query_filter=>tt_name_range_pairs,
      lt_ranges_table      TYPE if_rap_query_filter=>tt_range_option,
      lt_business_data     TYPE TABLE OF zak_a_businesspartner.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          FIELDS ( BussPartner ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_orders).

    lt_ranges_table = VALUE #( FOR ls_order IN lt_orders (  sign = 'I' option = 'EQ' low = ls_order-BussPartner ) ).
    lt_filter_conditions = VALUE #( ( name = 'BUSINESSPARTNER'  range = lt_ranges_table ) ).

    TRY.
        NEW zak_cl_bp_query_provider( )->get_busspartners(
          EXPORTING
            it_filter_cond        = lt_filter_conditions
            iv_is_data_requested  = abap_true
            iv_is_count_requested = abap_false
          IMPORTING
            et_business_data      = lt_business_data ).
      CATCH /iwbep/cx_cp_remote
              /iwbep/cx_gateway
              cx_web_http_client_error
              cx_http_dest_provider_error
              cx_rap_query_filter_no_range
      INTO DATA(lx_exception).
        DATA(lv_exception_message) = cl_message_helper=>get_latest_t100_exception( lx_exception )->if_message~get_longtext( ).
    ENDTRY.

    IF lt_business_data IS NOT INITIAL.

      LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
        <ls_order>-BussPartnerName = lt_business_data[ BusinessPartner = <ls_order>-BussPartner ]-BusinessPartnerName.
        <ls_order>-BussPartnerGroup = lt_business_data[ BusinessPartner = <ls_order>-BussPartner ]-BusinessPartnerGrouping.
      ENDLOOP.

      MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
         ENTITY Order
            UPDATE FIELDS ( BussPartnerName BussPartnerGroup ) WITH CORRESPONDING #( lt_orders )
         FAILED DATA(lt_failed)
         REPORTED DATA(lt_reported).
    ENDIF.

  ENDMETHOD.

  METHOD validate_business_partner.

    DATA:
      lt_filter_conditions TYPE if_rap_query_filter=>tt_name_range_pairs,
      lt_ranges_table      TYPE if_rap_query_filter=>tt_range_option,
      lt_business_data     TYPE TABLE OF zak_a_businesspartner.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Order
          FIELDS ( BussPartner ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_orders).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Order BY \_Product
        FROM CORRESPONDING #( lt_orders )
      LINK DATA(lt_order_product_links).

    lt_ranges_table = VALUE #( FOR ls_order IN lt_orders (  sign = 'I' option = 'EQ' low = ls_order-BussPartner ) ).
    lt_filter_conditions = VALUE #( ( name = 'BUSINESSPARTNER'  range = lt_ranges_table ) ).

    TRY.
        NEW zak_cl_bp_query_provider( )->get_busspartners(
          EXPORTING
            it_filter_cond        = lt_filter_conditions
            iv_is_data_requested  = abap_true
            iv_is_count_requested = abap_false
          IMPORTING
            et_business_data      = lt_business_data ).
      CATCH /iwbep/cx_cp_remote
              /iwbep/cx_gateway
              cx_web_http_client_error
              cx_http_dest_provider_error
              cx_rap_query_filter_no_range
      INTO DATA(lx_exception).
        DATA(lv_exception_message) = cl_message_helper=>get_latest_t100_exception( lx_exception )->if_message~get_longtext( ).
    ENDTRY.

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      APPEND VALUE #( %tky        = <ls_order>-%tky
                      %state_area = 'VALIDATE_BUSINESS_PARTNER'
                    ) TO reported-order.

      IF <ls_order>-BussPartner IS INITIAL OR NOT line_exists( lt_business_data[ BusinessPartner = <ls_order>-BussPartner ] ).
        APPEND VALUE #( %tky                 = <ls_order>-%tky ) TO failed-order.
        APPEND VALUE #( %tky                 = <ls_order>-%tky
                        %state_area          = 'VALIDATE_BUSINESS_PARTNER'
                        %msg                 = NEW zak_cm_products(
                                               severity        = if_abap_behv_message=>severity-error
                                               textid          = zak_cm_products=>business_partner_invalid
                                               businesspartner = <ls_order>-BussPartner )
                        %path                = VALUE #( product-%tky = lt_order_product_links[ source-%tky = <ls_order>-%tky ]-target-%tky )
                        %element-BussPartner = if_abap_behv=>mk-on
                      ) TO reported-order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
