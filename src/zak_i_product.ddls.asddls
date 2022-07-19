@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@AbapCatalog.extensibility.extensible: true
define root view entity ZAK_I_PRODUCT
  as select from zak_d_product as Product

  composition [0..*] of ZAK_I_PROD_MRKT    as _Market
  association [0..1] to ZAK_I_CURRENCY     as _Currency            on $projection.PriceCurrency = _Currency.Currency
  association [1..1] to ZAK_I_PG           as _ProdGroup           on $projection.PgId = _ProdGroup.Pgid
  association [1..1] to ZAK_I_PHASE        as _Phase               on $projection.PhaseId = _Phase.Phaseid
  association [0..*] to ZAK_SH_MARKET_CODE as _MarketCodeValueHelp on $projection.TransCode = _MarketCodeValueHelp.Code
{
  key prod_uuid                                                                                                                                                                         as ProdUuid,
      prodid                                                                                                                                                                              as ProdId,
      pgid                                                                                                                                                                                as PgId,
      pgname_trans                                                                                                                                                                        as PgNameTrans,
      trans_code                                                                                                                                                                          as TransCode,
      phaseid                                                                                                                                                                             as PhaseId,
      case phaseid
        when 1 then 1
        when 2 then 2
        when 3 then 3
        else        0
      end                                                                                                                                                                                 as PhaseCriticality,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      height                                                                                                                                                                              as Height,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      depth                                                                                                                                                                               as Depth,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      width                                                                                                                                                                               as Width,
      size_uom                                                                                                                                                                            as SizeUom,
      @Semantics.amount.currencyCode : 'PriceCurrency'
      price                                                                                                                                                                               as Price,
      price_currency                                                                                                                                                                      as PriceCurrency,
      taxrate                                                                                                                                                                             as Taxrate,
      @Semantics.user.createdBy: true
      created_by                                                                                                                                                                          as CreatedBy,
      @EndUserText.label: 'Create Time'
      @Semantics.systemDateTime.createdAt: true
      creation_time                                                                                                                                                                       as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by                                                                                                                                                                          as ChangedBy,
      @EndUserText.label: 'Change Time'
      @Semantics.systemDateTime.lastChangedAt: true
      change_time                                                                                                                                                                         as ChangeTime,
      @EndUserText.label: 'Size Dimensions'
      concat(cast( height as abap.char( 12 ) ), concat_with_space(' X ', concat(cast( depth as abap.char( 12 ) ), concat_with_space(' X ', cast( width as abap.char( 12 ) ), 1 ) ), 1 ) ) as SizeDimensions,
      _Currency,
      _ProdGroup,
      _Market,
      _Phase,
      _MarketCodeValueHelp
}
