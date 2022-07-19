CLASS zak_cm_products DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    CONSTANTS:
      BEGIN OF unknown_pg_name,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF unknown_pg_name ,
      BEGIN OF dublicate_prodid,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF dublicate_prodid ,
      BEGIN OF unknown_market,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF unknown_market ,
      BEGIN OF invalid_start_date,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_start_date ,
      BEGIN OF invalid_end_date,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_end_date ,
      BEGIN OF end_date_not_after_start_date,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF end_date_not_after_start_date ,
      BEGIN OF duplicate_market,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF duplicate_market ,
      BEGIN OF delivery_date_less_start_date,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF delivery_date_less_start_date ,
      BEGIN OF delivery_date_greater_end_date,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF delivery_date_greater_end_date ,
      BEGIN OF translation,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'LANGCODE',
        attr2 TYPE scx_attrname VALUE 'TRANSTEXT',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF translation ,
      BEGIN OF business_partner_invalid,
        msgid TYPE symsgid VALUE 'ZAK_CM_PRODUCTS',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE 'BUSINESSPARTNER',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF business_partner_invalid .

    METHODS constructor
      IMPORTING
        severity  TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid    LIKE if_t100_message=>t100key OPTIONAL
        previous  TYPE REF TO cx_root OPTIONAL
        langcode  TYPE zak_lang_code OPTIONAL
        transtext TYPE string OPTIONAL
        businesspartner  TYPE zak_a_businesspartner-BusinessPartner OPTIONAL.

    DATA langcode  TYPE zak_lang_code READ-ONLY.
    DATA transtext TYPE string READ-ONLY.
    DATA businesspartner TYPE zak_a_businesspartner-BusinessPartner READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zak_cm_products IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.
    me->langcode = langcode.
    me->transtext = transtext.
    me->businesspartner = businesspartner.

  ENDMETHOD.
ENDCLASS.
