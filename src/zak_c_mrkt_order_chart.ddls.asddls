@EndUserText.label: 'Market order charts projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZAK_C_MRKT_ORDER_CHART
  provider contract transactional_query
  as projection on ZAK_I_MRKT_ORDER
{
  key ProdUuid,
  key MrktUuid,
  key OrderUuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      Orderid,
      @Aggregation.default: #SUM
      Quantity,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      CalendarYear,
      DeliveryDate,
      @Aggregation.default: #SUM
      Netamount,
      @Aggregation.default: #SUM
      Grossamount,
      Amountcurr,
      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,
      _Market,
      _Product
}
