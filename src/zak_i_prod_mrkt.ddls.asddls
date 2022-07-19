@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Market view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZAK_I_PROD_MRKT
  as select from zak_d_prod_mrkt as Market
  
  composition [0..*] of ZAK_I_MRKT_ORDER  as _Order
  association to parent ZAK_I_PRODUCT as _Product on $projection.ProdUuid = _Product.ProdUuid
  association [1..1] to ZAK_I_MARKET  as _Country on $projection.Mrktid = _Country.Mrktid
{
  key prod_uuid     as ProdUuid,
  key mrkt_uuid     as MrktUuid,
      @EndUserText.label: 'Market'
      mrktid        as Mrktid,
      @EndUserText.label: 'Confirmed?'
      status        as Status,
      case status
        when 'X'  then 3  
        when ''   then 1
      else             2  
      end           as StatusCriticality,
      startdate     as Startdate,
      enddate       as Enddate,
      isocode       as IsoCode,
      @Semantics.user.createdBy: true
      created_by    as CreatedBy,
      @EndUserText.label: 'Create Time'
      @Semantics.systemDateTime.createdAt: true
      creation_time as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by    as ChangedBy,
      @EndUserText.label: 'Change Time'
      @Semantics.systemDateTime.lastChangedAt: true
      change_time   as ChangeTime,
      
      _Product,
      _Country,
      _Order

}
