@EndUserText.label: 'Market order projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZAK_C_MRKT_ORDER
  as projection on ZAK_I_MRKT_ORDER
{
  key ProdUuid,
  key MrktUuid,
  key OrderUuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      Orderid,
      Quantity,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      CalendarYear,
      DeliveryDate,
      Netamount,
      Grossamount,
      Amountcurr,
      @Consumption.valueHelpDefinition: [{entity: { name: 'ZAK_I_BUSINESS_PARTNER_C', element: 'BusinessPartner' }}]
      BussPartner,
      BussPartnerName,
      BussPartnerGroup,
      Status,
      StatusCriticality,
      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZAK_CL_ORDER_INITIAL'
      virtual OrderImageURL: abap.string( 256 ),
    
      _Product : redirected to ZAK_C_PRODUCT,
      _Market  : redirected to parent ZAK_C_PROD_MRKT
}
