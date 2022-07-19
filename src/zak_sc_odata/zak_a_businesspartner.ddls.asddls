/********** GENERATED on 06/13/2022 at 16:20:50 by CB9980004577**************/
@OData.entitySet.name: 'A_BusinessPartner'
@OData.entityType.name: 'A_BusinessPartnerType'
define root abstract entity ZAK_A_BUSINESSPARTNER
{
  key BusinessPartner                : abap.char( 10 );
      @OData.property.valueControl   : 'Customer_vc'
      Customer                       : abap.char( 10 );
      Customer_vc                    : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'Supplier_vc'
      Supplier                       : abap.char( 10 );
      Supplier_vc                    : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'AcademicTitle_vc'
      AcademicTitle                  : abap.char( 4 );
      AcademicTitle_vc               : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'AuthorizationGroup_vc'
      AuthorizationGroup             : abap.char( 4 );
      AuthorizationGroup_vc          : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerCategory_vc'
      BusinessPartnerCategory        : abap.char( 1 );
      BusinessPartnerCategory_vc     : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerFullName_vc'
      BusinessPartnerFullName        : abap.char( 81 );
      BusinessPartnerFullName_vc     : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerGrouping_vc'
      BusinessPartnerGrouping        : abap.char( 4 );
      BusinessPartnerGrouping_vc     : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerName_vc'
      BusinessPartnerName            : abap.char( 81 );
      BusinessPartnerName_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerUUID_vc'
      BusinessPartnerUUID            : sysuuid_x16;
      BusinessPartnerUUID_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'CorrespondenceLanguage_vc'
      CorrespondenceLanguage         : abap.char( 2 );
      CorrespondenceLanguage_vc      : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'CreatedByUser_vc'
      CreatedByUser                  : abap.char( 12 );
      CreatedByUser_vc               : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'CreationDate_vc'
      CreationDate                   : rap_cp_odata_v2_edm_datetime;
      CreationDate_vc                : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'CreationTime_vc'
      CreationTime                   : rap_cp_odata_v2_edm_time;
      CreationTime_vc                : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'FirstName_vc'
      FirstName                      : abap.char( 40 );
      FirstName_vc                   : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'FormOfAddress_vc'
      FormOfAddress                  : abap.char( 4 );
      FormOfAddress_vc               : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'Industry_vc'
      Industry                       : abap.char( 10 );
      Industry_vc                    : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'InternationalLocationNumber_vc'
      InternationalLocationNumber1   : abap.numc( 7 );
      InternationalLocationNumber_vc : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'InternationalLocationNumber_v1'
      InternationalLocationNumber2   : abap.numc( 5 );
      InternationalLocationNumber_v1 : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'IsFemale_vc'
      IsFemale                       : abap_boolean;
      IsFemale_vc                    : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'IsMale_vc'
      IsMale                         : abap_boolean;
      IsMale_vc                      : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'IsNaturalPerson_vc'
      IsNaturalPerson                : abap.char( 1 );
      IsNaturalPerson_vc             : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'IsSexUnknown_vc'
      IsSexUnknown                   : abap_boolean;
      IsSexUnknown_vc                : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'GenderCodeName_vc'
      GenderCodeName                 : abap.char( 1 );
      GenderCodeName_vc              : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'Language_vc'
      Language                       : abap.char( 2 );
      Language_vc                    : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'LastChangeDate_vc'
      LastChangeDate                 : rap_cp_odata_v2_edm_datetime;
      LastChangeDate_vc              : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'LastChangeTime_vc'
      LastChangeTime                 : rap_cp_odata_v2_edm_time;
      LastChangeTime_vc              : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'LastChangedByUser_vc'
      LastChangedByUser              : abap.char( 12 );
      LastChangedByUser_vc           : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'LastName_vc'
      LastName                       : abap.char( 40 );
      LastName_vc                    : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'LegalForm_vc'
      LegalForm                      : abap.char( 2 );
      LegalForm_vc                   : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'OrganizationBPName1_vc'
      OrganizationBPName1            : abap.char( 40 );
      OrganizationBPName1_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'OrganizationBPName2_vc'
      OrganizationBPName2            : abap.char( 40 );
      OrganizationBPName2_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'OrganizationBPName3_vc'
      OrganizationBPName3            : abap.char( 40 );
      OrganizationBPName3_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'OrganizationBPName4_vc'
      OrganizationBPName4            : abap.char( 40 );
      OrganizationBPName4_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'OrganizationFoundationDate_vc'
      OrganizationFoundationDate     : rap_cp_odata_v2_edm_datetime;
      OrganizationFoundationDate_vc  : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'OrganizationLiquidationDate_vc'
      OrganizationLiquidationDate    : rap_cp_odata_v2_edm_datetime;
      OrganizationLiquidationDate_vc : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'SearchTerm1_vc'
      SearchTerm1                    : abap.char( 20 );
      SearchTerm1_vc                 : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'SearchTerm2_vc'
      SearchTerm2                    : abap.char( 20 );
      SearchTerm2_vc                 : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'AdditionalLastName_vc'
      AdditionalLastName             : abap.char( 40 );
      AdditionalLastName_vc          : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BirthDate_vc'
      BirthDate                      : rap_cp_odata_v2_edm_datetime;
      BirthDate_vc                   : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerBirthplaceNa_vc'
      BusinessPartnerBirthplaceName  : abap.char( 40 );
      BusinessPartnerBirthplaceNa_vc : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerIsBlocked_vc'
      BusinessPartnerIsBlocked       : abap_boolean;
      BusinessPartnerIsBlocked_vc    : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerType_vc'
      BusinessPartnerType            : abap.char( 4 );
      BusinessPartnerType_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'ETag_vc'
      ETag                           : abap.char( 26 );
      ETag_vc                        : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'GroupBusinessPartnerName1_vc'
      GroupBusinessPartnerName1      : abap.char( 40 );
      GroupBusinessPartnerName1_vc   : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'GroupBusinessPartnerName2_vc'
      GroupBusinessPartnerName2      : abap.char( 40 );
      GroupBusinessPartnerName2_vc   : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'IndependentAddressID_vc'
      IndependentAddressID           : abap.char( 10 );
      IndependentAddressID_vc        : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'InternationalLocationNumber_v2'
      InternationalLocationNumber3   : abap.numc( 1 );
      InternationalLocationNumber_v2 : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'MiddleName_vc'
      MiddleName                     : abap.char( 40 );
      MiddleName_vc                  : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'NameCountry_vc'
      NameCountry                    : abap.char( 3 );
      NameCountry_vc                 : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'NameFormat_vc'
      NameFormat                     : abap.char( 2 );
      NameFormat_vc                  : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'PersonFullName_vc'
      PersonFullName                 : abap.char( 80 );
      PersonFullName_vc              : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'PersonNumber_vc'
      PersonNumber                   : abap.char( 10 );
      PersonNumber_vc                : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'IsMarkedForArchiving_vc'
      IsMarkedForArchiving           : abap_boolean;
      IsMarkedForArchiving_vc        : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'BusinessPartnerIDByExtSyste_vc'
      BusinessPartnerIDByExtSystem   : abap.char( 20 );
      BusinessPartnerIDByExtSyste_vc : rap_cp_odata_value_control;
      @OData.property.valueControl   : 'TradingPartner_vc'
      TradingPartner                 : abap.char( 6 );
      TradingPartner_vc              : rap_cp_odata_value_control;

}
