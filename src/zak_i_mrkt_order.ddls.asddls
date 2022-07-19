@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Market order view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZAK_I_MRKT_ORDER
  as select from zak_d_mrkt_order as MrktOrder

  association        to parent ZAK_I_PROD_MRKT as _Market  on  $projection.MrktUuid = _Market.MrktUuid
                                                           and $projection.ProdUuid = _Market.ProdUuid
  association [1..1] to ZAK_I_PRODUCT          as _Product on  $projection.ProdUuid = _Product.ProdUuid
{
  key prod_uuid        as ProdUuid,
  key mrkt_uuid        as MrktUuid,
  key order_uuid       as OrderUuid,
      orderid          as Orderid,
      quantity         as Quantity,
      @EndUserText.label: 'Year'
      calendar_year    as CalendarYear,
      delivery_date    as DeliveryDate,
      @Semantics.amount.currencyCode : 'Amountcurr'
      netamount        as Netamount,
      @Semantics.amount.currencyCode : 'Amountcurr'
      grossamount      as Grossamount,
      amountcurr       as Amountcurr,
      @EndUserText.label: 'Business Partner ID'
      busspartner      as BussPartner,
      busspartnername  as BussPartnerName,
      busspartnergroup as BussPartnerGroup,
      @EndUserText.label: 'Confirmed?'
      status           as Status,
      case status
        when 'X'  then 3  
        when ''   then 1
      else             2  
      end           as StatusCriticality,
      @Semantics.user.createdBy: true
      created_by       as CreatedBy,
      @EndUserText.label: 'Create Time'
      @Semantics.systemDateTime.createdAt: true
      creation_time    as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by       as ChangedBy,
      @EndUserText.label: 'Change Time'
      @Semantics.systemDateTime.lastChangedAt: true
      change_time      as ChangeTime,

      _Market,
      _Product
}
