@EndUserText.label: 'Product Market projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZAK_C_PROD_MRKT
  as projection on ZAK_I_PROD_MRKT
  association [0..*] to ZAK_C_MRKT_ORDER_CHART as _OrderChart on  $projection.MrktUuid = _OrderChart.MrktUuid
                                                              and $projection.ProdUuid = _OrderChart.ProdUuid
{
  key ProdUuid,
  key MrktUuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @Consumption.valueHelpDefinition: [{entity: { name: 'ZAK_I_MARKET', element: 'Mrktid' }}]
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: ['MarketName']
      Mrktid,
      _Country.Mrktname as MarketName,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      Status,
      StatusCriticality,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      Startdate,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      Enddate,
      @EndUserText.label: 'ISO-Code'
      IsoCode,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZAK_CL_ORDER_INITIAL'
      @EndUserText.label: 'Total Quantity'
      virtual TotalQuantity: zak_quantity,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZAK_CL_ORDER_INITIAL'
      @EndUserText.label: 'Total Net Amount'
      @Semantics.amount.currencyCode : 'AmountCurrency'
      virtual TotalNetAmount: zak_netamount,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZAK_CL_ORDER_INITIAL'
      @EndUserText.label: 'Total Gross Amount'
      @Semantics.amount.currencyCode : 'AmountCurrency'
      virtual TotalGrossAmount: zak_grossamount,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZAK_CL_ORDER_INITIAL'
      virtual AmountCurrency: waers_curc,
      _Country.Imageurl as CountryImageUrl,
      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,
      
      _Product : redirected to parent ZAK_C_PRODUCT,
      _Order   : redirected to composition child ZAK_C_MRKT_ORDER,
      _OrderChart
      
}
