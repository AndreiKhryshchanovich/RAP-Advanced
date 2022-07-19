@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Market view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZAK_I_MARKET
  as select from zak_d_market as Market
{
  key mrktid   as Mrktid,
      mrktname as Mrktname,
      code     as Code,
      imageurl as Imageurl
}
