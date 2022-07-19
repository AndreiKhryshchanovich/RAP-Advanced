CLASS lhc_Product DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF phase,
        planning     TYPE zak_d_phase-phase  VALUE 1,
        development  TYPE zak_d_phase-phase  VALUE 2,
        production   TYPE zak_d_phase-phase  VALUE 3,
        out_of_phase TYPE zak_d_phase-phase  VALUE 4,
      END OF phase,
      BEGIN OF status,
        confirmed     TYPE zak_mrkt_status  VALUE 'X',
        not_confirmed TYPE zak_mrkt_status  VALUE '',
      END OF status.

    TYPES:
      BEGIN OF gty_translated_data,
        text TYPE string,
        pos  TYPE string,
        gen  TYPE string,
        fr   TYPE string,
        syn  TYPE string,
        mean TYPE string,
        ex   TYPE string,
      END OF gty_translated_data,
      BEGIN OF gty_retrieved_data,
        text TYPE string,
        pos  TYPE string,
        ts   TYPE string,
        tr   TYPE TABLE OF gty_translated_data WITH DEFAULT KEY,
      END OF gty_retrieved_data,
      BEGIN OF gty_translated_short_data,
        lang        TYPE zak_lang_code,
        transl_text TYPE string,
      END OF gty_translated_short_data.

    METHODS set_first_phase FOR DETERMINE ON MODIFY
      IMPORTING lt_keys FOR Product~set_first_phase.

    METHODS validate_pg FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Product~validate_pg.

    METHODS validate_prodid FOR VALIDATE ON SAVE
      IMPORTING lt_keys FOR Product~validate_prodid.

    METHODS make_copy FOR MODIFY
      IMPORTING lt_keys FOR ACTION Product~make_copy RESULT et_result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING lt_keys REQUEST requested_features FOR Product RESULT et_result.

    METHODS move_to_new_phase FOR MODIFY
      IMPORTING lt_keys FOR ACTION Product~move_to_new_phase RESULT et_result.

    METHODS set_pgname_translation FOR DETERMINE ON SAVE
      IMPORTING lt_keys FOR Product~set_pgname_translation.

    METHODS get_pgname_transl FOR MODIFY
      IMPORTING lt_keys FOR ACTION Product~get_pgname_transl.

ENDCLASS.

CLASS lhc_Product IMPLEMENTATION.

  METHOD set_first_phase.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Product
          ALL FIELDS WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_products).

    LOOP AT lt_products ASSIGNING FIELD-SYMBOL(<ls_product>).
      <ls_product>-PhaseId = phase-planning.
    ENDLOOP.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Product
         UPDATE FIELDS ( PhaseId )
         WITH CORRESPONDING #( lt_products )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD validate_pg.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Product
         FIELDS ( PgId ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_products).

    SELECT FROM zak_i_pg FIELDS Pgid
        INTO TABLE @DATA(lt_pgIds).

    LOOP AT lt_products ASSIGNING FIELD-SYMBOL(<ls_product>).
      APPEND VALUE #(  %tky               = <ls_product>-%tky
                       %state_area        = 'VALIDATE_PG' )
      TO reported-product.

      IF <ls_product>-PgId IS INITIAL OR NOT line_exists( lt_pgIds[ Pgid = <ls_product>-PgId ] ).
        APPEND VALUE #( %tky = <ls_product>-%tky ) TO failed-product.

        APPEND VALUE #( %tky                   = <ls_product>-%tky
                        %state_area            = 'VALIDATE_PG'
                        %msg                   = NEW zak_cm_products(
                                                 severity = if_abap_behv_message=>severity-error
                                                 textid   = zak_cm_products=>unknown_pg_name ) )
      TO reported-product.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_prodid.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Product
         FIELDS ( ProdId ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_products).

    SELECT FROM zak_i_product FIELDS ProdId
      INTO TABLE @DATA(lt_prodids).

    LOOP AT lt_products ASSIGNING FIELD-SYMBOL(<ls_product>).
      APPEND VALUE #(  %tky               = <ls_product>-%tky
                       %state_area        = 'VALIDATE_PRODID' )
      TO reported-product.

      IF line_exists( lt_prodids[ ProdId = <ls_product>-ProdId ] ).
        APPEND VALUE #( %tky = <ls_product>-%tky ) TO failed-product.

        APPEND VALUE #( %tky                   = <ls_product>-%tky
                        %state_area            = 'VALIDATE_PRODID'
                        %msg                   = NEW zak_cm_products(
                                                 severity = if_abap_behv_message=>severity-error
                                                 textid   = zak_cm_products=>dublicate_prodid ) )
      TO reported-product.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD make_copy.

    DATA: lt_new_products TYPE TABLE FOR CREATE zak_i_product\\Product.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Product
        ALL FIELDS WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_products)
      FAILED failed.

    SELECT FROM zak_i_product FIELDS ProdId
        INTO TABLE @DATA(lt_prodids).

    LOOP AT lt_products ASSIGNING FIELD-SYMBOL(<ls_product>).
      APPEND VALUE #( %key     = <ls_product>-%key   %data = CORRESPONDING #( <ls_product> EXCEPT ProdId ProdUuid ) ) TO lt_new_products ASSIGNING FIELD-SYMBOL(<ls_new_product>).
      <ls_new_product>-PhaseId = phase-planning.

      IF line_exists( lt_prodids[ ProdId = lt_keys[ %tky = <ls_product>-%tky ]-%param-product_id ] ).
        APPEND VALUE #( %tky = <ls_product>-%tky ) TO failed-product.

        APPEND VALUE #( %tky                   = <ls_product>-%tky
                        %state_area            = 'VALIDATE_PRODID'
                        %msg                   = NEW zak_cm_products(
                                                 severity = if_abap_behv_message=>severity-error
                                                 textid   = zak_cm_products=>dublicate_prodid ) )
      TO reported-product.
      ENDIF.

      <ls_new_product>-ProdId = lt_keys[ %tky = <ls_product>-%tky ]-%param-product_id.
    ENDLOOP.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Product
            CREATE FIELDS ( ProdId PgId PhaseId Width Depth Height SizeUom Price PriceCurrency Taxrate )
                WITH lt_new_products

      MAPPED mapped
      FAILED DATA(failed_create)
      REPORTED DATA(reported_create).

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Product
        ALL FIELDS WITH CORRESPONDING #( mapped-product )
      RESULT DATA(lt_products_created).

    et_result = VALUE #( FOR ls_product_created IN lt_products_created
                        ( %cid_ref = lt_keys[ 1 ]-%cid_ref
                          %tky     = lt_keys[ 1 ]-%tky
                          %param   = ls_product_created ) ).
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
        ENTITY Product
          FIELDS ( PhaseId ) WITH CORRESPONDING #( lt_keys )
        RESULT DATA(lt_products)
        FAILED failed.

    et_result =
        VALUE #(
                FOR ls_product IN lt_products
                     ( %tky                         = ls_product-%tky
                       %action-move_to_new_phase    = COND #( WHEN ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-o-disabled
                                                                ELSE if_abap_behv=>fc-o-enabled )
                       %field-Prodid                = COND #( WHEN ls_product-PhaseId = phase-planning
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                                ELSE if_abap_behv=>fc-f-read_only )
                       %field-PgId                  = COND #( WHEN ls_product-PhaseId = phase-planning
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                                ELSE if_abap_behv=>fc-f-read_only )
                       %field-Height                = COND #( WHEN ls_product-PhaseId = phase-development
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                              WHEN ls_product-PhaseId = phase-production OR ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-f-read_only
                                                                ELSE if_abap_behv=>fc-f-unrestricted )
                       %field-Width                 = COND #( WHEN ls_product-PhaseId = phase-development
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                              WHEN ls_product-PhaseId = phase-production OR ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-f-read_only
                                                                ELSE if_abap_behv=>fc-f-unrestricted )
                       %field-Depth                 = COND #( WHEN ls_product-PhaseId = phase-development
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                              WHEN ls_product-PhaseId = phase-production OR ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-f-read_only
                                                                ELSE if_abap_behv=>fc-f-unrestricted )
                       %field-SizeUom               = COND #( WHEN ls_product-PhaseId = phase-development
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                              WHEN ls_product-PhaseId = phase-production OR ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-f-read_only
                                                                ELSE if_abap_behv=>fc-f-unrestricted )
                       %field-Price                 = COND #( WHEN ls_product-PhaseId = phase-development
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                              WHEN ls_product-PhaseId = phase-production OR ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-f-read_only
                                                                ELSE if_abap_behv=>fc-f-unrestricted )
                       %field-PriceCurrency         = COND #( WHEN ls_product-PhaseId = phase-development
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                              WHEN ls_product-PhaseId = phase-production OR ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-f-read_only
                                                                ELSE if_abap_behv=>fc-f-unrestricted )
                       %field-Taxrate               = COND #( WHEN ls_product-PhaseId = phase-development
                                                                THEN if_abap_behv=>fc-f-mandatory
                                                              WHEN ls_product-PhaseId = phase-production OR ls_product-PhaseId = phase-out_of_phase
                                                                THEN if_abap_behv=>fc-f-read_only
                                                                ELSE if_abap_behv=>fc-f-unrestricted )
         ) ).

  ENDMETHOD.

  METHOD move_to_new_phase.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
        ENTITY Product
          FIELDS ( PhaseId ) WITH CORRESPONDING #( lt_keys )
        RESULT DATA(lt_products)
        FAILED failed.

    SELECT FROM zak_d_prod_mrkt FIELDS prod_uuid, status, enddate
        INTO TABLE @DATA(lt_markets).

    LOOP AT lt_products ASSIGNING FIELD-SYMBOL(<ls_product>).
      CASE <ls_product>-PhaseId.
        WHEN phase-planning.
          IF line_exists( lt_markets[ prod_uuid = <ls_product>-ProdUuid ] ).
            MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
              ENTITY Product
                 UPDATE
                   FIELDS ( PhaseId )
                      WITH VALUE #( ( %tky    = <ls_product>-%tky
                                      PhaseId = phase-development )  )
              FAILED failed
              REPORTED reported.
          ENDIF.

        WHEN phase-development.
          IF line_exists( lt_markets[ prod_uuid = <ls_product>-ProdUuid status = status-confirmed ] ).
            MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
              ENTITY Product
                 UPDATE
                   FIELDS ( PhaseId )
                      WITH VALUE #( ( %tky    = <ls_product>-%tky
                                      PhaseId = phase-production )  )
              FAILED failed
              REPORTED reported.
          ENDIF.

        WHEN phase-production.
          DATA: lv_not_finished_flag TYPE abap_boolean.
          LOOP AT lt_markets ASSIGNING FIELD-SYMBOL(<ls_market>) WHERE prod_uuid = <ls_product>-ProdUuid.
            IF <ls_market>-enddate IS INITIAL OR <ls_market>-enddate > cl_abap_context_info=>get_system_date( ).
              lv_not_finished_flag = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF lv_not_finished_flag <> 'X'.
            MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
              ENTITY Product
                UPDATE
                  FIELDS ( PhaseId )
                     WITH VALUE #( ( %tky    = <ls_product>-%tky
                                     PhaseId = phase-out_of_phase )  )
              FAILED failed
              REPORTED reported.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Product
          ALL FIELDS WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_products_changed).

    et_result = VALUE #( FOR ls_product_changed IN lt_products_changed
                                ( %tky   = ls_product_changed-%tky
                                  %param = ls_product_changed ) ).
  ENDMETHOD.

  METHOD set_pgname_translation.

    DATA: lt_retrieved_data TYPE TABLE OF gty_retrieved_data.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
       ENTITY Product
          FIELDS ( TransCode PgNameTrans PgId ) WITH CORRESPONDING #( lt_keys )
       RESULT DATA(lt_products).

    SELECT FROM zak_d_prod_group
        FIELDS pgid, pgname
        INTO TABLE @DATA(lt_prod_names).

    DATA(lv_url_path) = 'https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20220614T181830Z.847b2a193b420fe4.d99faeec698b863c5e51950810d6d572bc7f1c93&lang=en-'.

    LOOP AT lt_products ASSIGNING FIELD-SYMBOL(<ls_product>).
      DATA(lv_url) = |{ lv_url_path && to_lower( <ls_product>-TransCode ) && '&text=' && lt_prod_names[ pgid = <ls_product>-PgId ]-pgname }|.

      TRY.
          DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).

          lo_http_client->execute(
            EXPORTING
              i_method   = if_web_http_client=>get
            RECEIVING
              r_response = DATA(lo_response)
          ).

          SPLIT lo_response->get_text( ) AT '[' INTO DATA(lv_string1) DATA(lv_string2).

          lo_http_client->close( ).

          lv_string2 = |{ '[' && lv_string2 }|.
          DATA(lv_text_data) = substring( val = lv_string2 off = 0 len = strlen( lv_string2 ) - 1 ).

          /ui2/cl_json=>deserialize(
            EXPORTING
              json        = lv_text_data
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case
            CHANGING
              data        = lt_retrieved_data
          ).
        CATCH cx_web_http_client_error.
        CATCH cx_http_dest_provider_error.
      ENDTRY.

      IF lt_retrieved_data IS NOT INITIAL.
        <ls_product>-PgNameTrans = lt_retrieved_data[ 1 ]-tr[ 1 ]-text.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Product
         UPDATE FIELDS ( PgNameTrans )
         WITH CORRESPONDING #( lt_products )
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD get_pgname_transl.

    DATA: lt_retrieved_data TYPE TABLE OF gty_retrieved_data.

    READ ENTITIES OF zak_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( PgId ) WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_products)
      FAILED failed.

    SELECT FROM zak_d_prod_group
      FIELDS pgid, pgname
      INTO TABLE @DATA(lt_prod_names).

    SELECT FROM zak_sh_market_code
      FIELDS Code
      INTO TABLE @DATA(lt_lang_codes).

    DATA(lv_url_path) = 'https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20220614T181830Z.847b2a193b420fe4.d99faeec698b863c5e51950810d6d572bc7f1c93&lang=en-'.

    LOOP AT lt_products ASSIGNING FIELD-SYMBOL(<ls_product>).

      LOOP AT lt_lang_codes ASSIGNING FIELD-SYMBOL(<ls_lang_code>).
        DATA(lv_url) = |{ lv_url_path && to_lower( <ls_lang_code>-Code ) && '&text=' && lt_prod_names[ pgid = <ls_product>-PgId ]-pgname }|.

        TRY.
            DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
            DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).

            lo_http_client->execute(
              EXPORTING
                i_method   = if_web_http_client=>get
              RECEIVING
                r_response = DATA(lo_response)
            ).

            SPLIT lo_response->get_text( ) AT '[' INTO DATA(lv_string1) DATA(lv_string2).
            lo_http_client->close( ).
            lv_string2 = |{ '[' && lv_string2 }|.
            DATA(lv_text_data) = substring( val = lv_string2 off = 0 len = strlen( lv_string2 ) - 1 ).

            /ui2/cl_json=>deserialize(
              EXPORTING
                json        = lv_text_data
                pretty_name = /ui2/cl_json=>pretty_mode-camel_case
              CHANGING
                data        = lt_retrieved_data
            ).

            APPEND VALUE #( %msg                   = NEW zak_cm_products(
                            severity               = if_abap_behv_message=>severity-information
                            textid                 = zak_cm_products=>translation
                            langcode               = <ls_lang_code>-Code
                            transtext              = lt_retrieved_data[ 1 ]-tr[ 1 ]-text ) )
            TO reported-product.

          CATCH cx_web_http_client_error.
          CATCH cx_http_dest_provider_error.
        ENDTRY.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
