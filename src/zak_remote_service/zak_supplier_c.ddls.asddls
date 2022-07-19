@EndUserText.label: 'Custom Entity for Suppliers'
@ObjectModel.query.implementedBy: 'ABAP:ZAK_CL_SUPPL_QUERY_PROVIDER'
@UI.headerInfo:{ typeName: 'Supplier',
                 typeNamePlural: 'Suppliers'}
define root custom entity ZAK_SUPPLIER_C
{
    @UI.facet: [ { id:            'City',
                 purpose:         #HEADER,
                 type:            #DATAPOINT_REFERENCE,
                 position:        10,
                 targetQualifier: 'City' },
               { id:              'Country',
                 purpose:         #HEADER,
                 type:            #DATAPOINT_REFERENCE,
                 position:        20,
                 targetQualifier: 'Country' },
               { id:              'SupplierId',
                 purpose:         #HEADER,
                 type:            #DATAPOINT_REFERENCE,
                 position:        30,
                 targetQualifier: 'SupplierId' },
               { id:              'GeneralInfo',
                 label:           'General Information',
                 type:            #COLLECTION,
                 position:        10 },
               { id:              'GeneralGroup',
                 label:           'General Information',
                 purpose:         #STANDARD,
                 type:            #FIELDGROUP_REFERENCE,
                 parentId:        'GeneralInfo',
                 position:        10,
                 targetQualifier: 'GeneralGroup'} ]      
      @UI: { lineItem:       [{ position: 10, importance: #HIGH }],                 
             fieldGroup:     [{ position: 10, qualifier: 'GeneralGroup' }],
             dataPoint:       { qualifier: 'SupplierId', title: 'Supplier ID' },
             selectionField: [{ position: 10 }] }
      @EndUserText.label: 'Supplier ID'             
  key SupplierID      : abap.int4;
      @UI: { lineItem:       [{ position: 20, importance: #HIGH }],                 
             fieldGroup:     [{ position: 20, qualifier: 'GeneralGroup' }],
             selectionField: [{ position: 20 }] }
      @EndUserText.label: 'Company Name'
      CompanyName     : abap.char( 40 );
//      @OData.property.valueControl: 'ContactName_vc'
      @UI: { lineItem:       [{ position: 30, importance: #HIGH }],                 
             fieldGroup:     [{ position: 30, qualifier: 'GeneralGroup' }],
             selectionField: [{ position: 30 }] }
      @EndUserText.label: 'Contact Name'
      ContactName     : abap.char( 30 );
//      ContactName_vc  : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'ContactTitle_vc'
      @UI: { lineItem:       [{ position: 40, importance: #HIGH }],                 
             fieldGroup:     [{ position: 40, qualifier: 'GeneralGroup' }] }
      @EndUserText.label: 'Contact Title'
      ContactTitle    : abap.char( 30 );
//      ContactTitle_vc : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'Address_vc'
//      @OData.property.valueControl: 'Country_vc'
      @UI: { lineItem:       [{ position: 50, importance: #HIGH }],                 
             fieldGroup:     [{ position: 50, qualifier: 'GeneralGroup' }],
             dataPoint:       { qualifier: 'Country', title: 'Country' },             
             selectionField: [{ position: 40 }] }
      Country         : abap.char( 15 );
//      Country_vc      : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'City_vc'
      @UI: { lineItem:       [{ position: 60, importance: #HIGH }],                 
             fieldGroup:     [{ position: 60, qualifier: 'GeneralGroup' }],
             dataPoint:       { qualifier: 'City', title: 'City' } }
      City            : abap.char( 15 );
//      City_vc         : rap_cp_odata_value_control;      
      @UI: { lineItem:       [{ position: 70, importance: #HIGH }],                 
             fieldGroup:     [{ position: 70, qualifier: 'GeneralGroup' }] }
      Address         : abap.char( 60 );
//      Address_vc      : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'Region_vc'
      @UI: { fieldGroup:     [{ position: 80, qualifier: 'GeneralGroup' }] }
      Region          : abap.char( 15 );
//      Region_vc       : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'PostalCode_vc'
      @UI: { fieldGroup:     [{ position: 90, qualifier: 'GeneralGroup' }] }      
      @EndUserText.label: 'Postal Code'
      PostalCode      : abap.char( 10 );
//      PostalCode_vc   : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'Phone_vc'
      @UI: { lineItem:       [{ position: 80, importance: #HIGH }],                 
             fieldGroup:     [{ position: 100, qualifier: 'GeneralGroup' }] }
      Phone           : abap.char( 24 );
//      Phone_vc        : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'Fax_vc'
      @UI: { fieldGroup:     [{ position: 110, qualifier: 'GeneralGroup' }] }      
      Fax             : abap.char( 24 );
//      Fax_vc          : rap_cp_odata_value_control;
//      @OData.property.valueControl: 'HomePage_vc'
      @UI: { fieldGroup:     [{ position: 120, qualifier: 'GeneralGroup' }] }            
      @EndUserText.label: 'Home Page'
      HomePage        : abap.string( 0 );
//      HomePage_vc     : rap_cp_odata_value_control;
      @UI: { fieldGroup:     [{ position: 130, qualifier: 'GeneralGroup' }] }            
      @EndUserText.label: 'Discount (%)'
      Discount_pct    : abap.dec(3,1);
      @UI: { fieldGroup:     [{ position: 140, qualifier: 'GeneralGroup' }] }            
      @EndUserText.label: 'Last Changed At'
      LastChangedAt   : timestampl;

}
