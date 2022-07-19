CLASS zak_cl_order_initial DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zak_cl_order_initial IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_orders             TYPE STANDARD TABLE OF zak_c_mrkt_order WITH DEFAULT KEY,
          lt_markets            TYPE STANDARD TABLE OF zak_c_prod_mrkt WITH DEFAULT KEY,
          lv_total_quantity     TYPE zak_c_prod_mrkt-TotalQuantity,
          lv_total_net_amount   TYPE zak_c_prod_mrkt-TotalNetAmount,
          lv_total_gross_amount TYPE zak_c_prod_mrkt-TotalGrossAmount,
          lv_currency           TYPE zak_c_prod_mrkt-AmountCurrency.

    lt_orders = CORRESPONDING #( it_original_data ).
    lt_markets = CORRESPONDING #( it_original_data ).

    IF lt_orders[ 1 ]-OrderUuid IS NOT INITIAL.
      LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
        <ls_order>-OrderImageURL = 'https://i7.pngguru.com/preview/423/632/57/computer-icons-purchase-order-order-fulfillment-purchasing-order-icon.jpg'.
      ENDLOOP.

      ct_calculated_data = CORRESPONDING #( lt_orders ).
    ELSE.
      LOOP AT lt_markets ASSIGNING FIELD-SYMBOL(<ls_market>).
        SELECT FROM zak_d_mrkt_order
            FIELDS quantity, netamount, grossamount, amountcurr
            WHERE prod_uuid = @<ls_market>-ProdUuid
              AND mrkt_uuid = @<ls_market>-MrktUuid
            INTO TABLE @DATA(lt_market_orders).

        LOOP AT lt_market_orders ASSIGNING FIELD-SYMBOL(<ls_market_order>).
          lv_total_quantity = lv_total_quantity + <ls_market_order>-quantity.
          lv_total_net_amount = lv_total_net_amount + <ls_market_order>-netamount.
          lv_total_gross_amount = lv_total_gross_amount + <ls_market_order>-grossamount.
          lv_currency = <ls_market_order>-amountcurr.
        ENDLOOP.
        <ls_market>-TotalQuantity = lv_total_quantity.
        <ls_market>-TotalNetAmount = lv_total_net_amount.
        <ls_market>-TotalGrossAmount = lv_total_gross_amount.
        <ls_market>-AmountCurrency = lv_currency.
        lv_total_quantity = 0.
        lv_total_net_amount = 0.
        lv_total_gross_amount = 0.
      ENDLOOP.

      ct_calculated_data = CORRESPONDING #( lt_markets ).
    ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
