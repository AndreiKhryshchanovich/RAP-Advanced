@EndUserText.label: 'Custom entity for Business Partner'
@ObjectModel.query.implementedBy: 'ABAP:ZAK_CL_BP_QUERY_PROVIDER'
define custom entity ZAK_I_BUSINESS_PARTNER_C
{
      @EndUserText.label: 'Business Partner'
  key BusinessPartner                : abap.char( 10 );
      @EndUserText.label: 'Customer'      
      Customer                       : abap.char( 10 );
      @EndUserText.label: 'Business Partner Category'
      BusinessPartnerCategory        : abap.char( 1 );
      @EndUserText.label: 'Business Partner Grouping'
      BusinessPartnerGrouping        : abap.char( 4 );
      @EndUserText.label: 'Business Partner Name'
      BusinessPartnerName            : abap.char( 81 );

}
