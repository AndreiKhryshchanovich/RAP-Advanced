@EndUserText.label: 'Product projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['ProdId']
define root view entity ZAK_C_PRODUCT
  provider contract transactional_query
  as projection on ZAK_I_PRODUCT
{
  key ProdUuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      ProdId,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZAK_I_PG', element: 'Pgid' }}]
      @UI.textArrangement: #TEXT_ONLY
      @EndUserText.label: 'Product Group'
      @ObjectModel.text.element: ['PgName']
      PgId,
      @EndUserText.label: 'Product Group (trans.)'
      PgNameTrans,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZAK_SH_MARKET_CODE', element: 'Code' }}]
      @EndUserText.label: 'Trans. Lang.'
      TransCode,
      _ProdGroup.Pgname as PgName,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZAK_I_PHASE', element: 'Phaseid' }}]
      @UI.textArrangement: #TEXT_ONLY
      @EndUserText.label: 'Phase'
      @ObjectModel.text.element: ['PhaseName']
      PhaseId,
      _Phase.Phase as PhaseName,
      PhaseCriticality,
      _ProdGroup.Imageurl as ProdGroupImageUrl,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      Height,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      Depth,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      Width,
      SizeUom,
      SizeDimensions,
      @Semantics.amount.currencyCode: 'PriceCurrency'
      Price,
      PriceCurrency,
      Taxrate,
      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,
      
      _Market : redirected to composition child ZAK_C_PROD_MRKT
}
