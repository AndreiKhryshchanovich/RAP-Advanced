@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Currency view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZAK_I_CURRENCY
  as select from I_Currency
{
  key Currency,
      Decimals,
      CurrencyISOCode,
      AlternativeCurrencyKey,
      IsPrimaryCurrencyForISOCrcy,
      
      _Text
}
