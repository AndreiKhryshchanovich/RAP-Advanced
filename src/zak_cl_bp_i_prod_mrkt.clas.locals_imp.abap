CLASS lhc_market DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF status,
        confirmed     TYPE zak_mrkt_status  VALUE 'X',
        not_confirmed TYPE zak_mrkt_status  VALUE '',
      END OF status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING lt_keys REQUEST requested_features FOR Market RESULT et_result.

    METHODS confirm FOR MODIFY
      IMPORTING lt_keys FOR ACTION Market~confirm RESULT et_result.

    METHODS check_duplicates FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Market~check_duplicates.

    METHODS validate_end_date FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Market~validate_end_date.

    METHODS validate_market FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Market~validate_market.

    METHODS validate_start_date FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Market~validate_start_date.

    METHODS set_iso_code FOR DETERMINE ON MODIFY
      IMPORTING lt_keys FOR Market~set_iso_code.

ENDCLASS.

CLASS lhc_market IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
        ENTITY Market
          FIELDS ( Status ) WITH CORRESPONDING #( lt_keys )
        RESULT DATA(lt_markets)
        FAILED failed.

    et_result =
        VALUE #(
                FOR ls_market IN lt_markets
                     ( %tky             = ls_market-%tky
                       %action-confirm  = COND #( WHEN ls_market-Status = status-confirmed
                                                  THEN if_abap_behv=>fc-o-disabled
                                                  ELSE if_abap_behv=>fc-o-enabled )
                       %assoc-_Order    = COND #( WHEN ls_market-Status = status-confirmed
                                                  THEN if_abap_behv=>fc-o-enabled
                                                  ELSE if_abap_behv=>fc-o-disabled )
         ) ).
  ENDMETHOD.

  METHOD confirm.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market
        UPDATE
          FIELDS ( Status )
            WITH VALUE #( FOR ls_key IN lt_keys
                         ( %tky     = ls_key-%tky
                           Status   = status-confirmed ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market
        ALL FIELDS WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_markets).

    et_result = VALUE #( FOR ls_market IN lt_markets
                        ( %tky   = ls_market-%tky
                          %param = ls_market ) ).
  ENDMETHOD.

  METHOD check_duplicates.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market
         FIELDS ( Mrktid ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_markets).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market BY \_Product
        FROM CORRESPONDING #( lt_markets )
      LINK DATA(lt_market_product_links).

    SELECT FROM zak_d_prod_mrk_d FIELDS Mrktid, ProdUuid
      INTO TABLE @DATA(lt_mrktids).

    LOOP AT lt_markets ASSIGNING FIELD-SYMBOL(<ls_market>).
      APPEND VALUE #(  %tky               = <ls_market>-%tky
                       %state_area        = 'VALIDATE_DUPLICATES' )
      TO reported-product.

      IF line_exists( lt_mrktids[ Mrktid = <ls_market>-Mrktid ProdUuid = <ls_market>-ProdUuid ] ).
        APPEND VALUE #( %tky = <ls_market>-%tky ) TO failed-product.

        APPEND VALUE #( %tky                 = <ls_market>-%tky
                        %state_area          = 'VALIDATE_DUPLICATES'
                        %msg                 = NEW zak_cm_products(
                                               severity = if_abap_behv_message=>severity-error
                                               textid   = zak_cm_products=>duplicate_market )
                        %path                = VALUE #( product-%tky = lt_market_product_links[ source-%tky = <ls_market>-%tky ]-target-%tky ) )
      TO reported-market.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_end_date.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market
        FIELDS ( Startdate Enddate ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_markets).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market BY \_Product
        FROM CORRESPONDING #( lt_markets )
      LINK DATA(lt_market_product_links).

    LOOP AT lt_markets ASSIGNING FIELD-SYMBOL(<ls_market>).
      CHECK <ls_market>-Enddate IS NOT INITIAL.

      APPEND VALUE #(  %tky        = <ls_market>-%tky
                       %state_area = 'VALIDATE_END_DATE' )
        TO reported-market.

      IF <ls_market>-Enddate <= cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky                 = <ls_market>-%tky ) TO failed-market.
        APPEND VALUE #( %tky                 = <ls_market>-%tky
                        %state_area          = 'VALIDATE_END_DATE'
                        %msg                 = NEW zak_cm_products(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zak_cm_products=>invalid_end_date )
                        %path                = VALUE #( product-%tky = lt_market_product_links[ source-%tky = <ls_market>-%tky ]-target-%tky )
                        ) TO reported-market.
      ELSEIF <ls_market>-Enddate <= <ls_market>-Startdate.
        APPEND VALUE #( %tky                 = <ls_market>-%tky ) TO failed-market.
        APPEND VALUE #( %tky                 = <ls_market>-%tky
                        %state_area          = 'VALIDATE_END_DATE'
                        %msg                 = NEW zak_cm_products(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zak_cm_products=>end_date_not_after_start_date )
                        %path                = VALUE #( product-%tky = lt_market_product_links[ source-%tky = <ls_market>-%tky ]-target-%tky )
                        ) TO reported-market.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_market.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market
         FIELDS ( Mrktid ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_markets).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market BY \_Product
        FROM CORRESPONDING #( lt_markets )
      LINK DATA(lt_market_product_links).

    SELECT FROM zak_i_market FIELDS Mrktid
      INTO TABLE @DATA(lt_mrktids).

    LOOP AT lt_markets ASSIGNING FIELD-SYMBOL(<ls_market>).
      APPEND VALUE #(  %tky               = <ls_market>-%tky
                       %state_area        = 'VALIDATE_MARKET' )
      TO reported-product.

      IF NOT line_exists( lt_mrktids[ Mrktid = <ls_market>-Mrktid ] ).
        APPEND VALUE #( %tky = <ls_market>-%tky ) TO failed-product.

        APPEND VALUE #( %tky                 = <ls_market>-%tky
                        %state_area          = 'VALIDATE_MARKET'
                        %msg                 = NEW zak_cm_products(
                                               severity = if_abap_behv_message=>severity-error
                                               textid   = zak_cm_products=>unknown_market )
                        %path                = VALUE #( product-%tky = lt_market_product_links[ source-%tky = <ls_market>-%tky ]-target-%tky ) )
      TO reported-market.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_start_date.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market
        FIELDS ( Startdate ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_markets).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market BY \_Product
        FROM CORRESPONDING #( lt_markets )
      LINK DATA(lt_market_product_links).

    LOOP AT lt_markets ASSIGNING FIELD-SYMBOL(<ls_market>).
      APPEND VALUE #(  %tky        = <ls_market>-%tky
                       %state_area = 'VALIDATE_START_DATE' )
        TO reported-market.

      IF <ls_market>-Startdate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky                 = <ls_market>-%tky ) TO failed-market.
        APPEND VALUE #( %tky                 = <ls_market>-%tky
                        %state_area          = 'VALIDATE_START_DATE'
                        %msg                 = NEW zak_cm_products(
                                                   severity  = if_abap_behv_message=>severity-error
                                                   textid    = zak_cm_products=>invalid_start_date )
                        %path                = VALUE #( product-%tky = lt_market_product_links[ source-%tky = <ls_market>-%tky ]-target-%tky )
                        ) TO reported-market.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_iso_code.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Market
          ALL FIELDS WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_markets).

    SELECT FROM zak_d_market
        FIELDS mrktname, mrktid
        INTO TABLE @DATA(lt_mrkt_names).

    LOOP AT lt_markets ASSIGNING FIELD-SYMBOL(<ls_market>).
      IF line_exists( lt_mrkt_names[ mrktid = <ls_market>-Mrktid ] ).
        TRY.
            DATA(destination) = cl_soap_destination_provider=>create_by_url(
                'http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso' ).
            DATA(proxy) = NEW zak_co_country_info_service_so(
              destination = destination
            ).
            DATA(request) = VALUE zak_country_isocode_soap_reque( s_country_name = lt_mrkt_names[ mrktid = <ls_market>-Mrktid ]-mrktname ).
            proxy->country_isocode(
              EXPORTING
                input  = request
              IMPORTING
                output = DATA(response)
            ).
          CATCH cx_soap_destination_error.
            "handle error
          CATCH cx_ai_system_fault.
            "handle error
        ENDTRY.

        <ls_market>-IsoCode = response-country_isocode_result.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Market
         UPDATE FIELDS ( IsoCode )
         WITH CORRESPONDING #( lt_markets )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

  ENDMETHOD.

ENDCLASS.
