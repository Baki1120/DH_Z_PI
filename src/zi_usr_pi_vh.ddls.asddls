@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Name'
@Search.searchable: true
@ObjectModel : { resultSet.sizeCategory: #XS }
@Consumption.semanticObject: 'BusinessUserBasic'

@UI.headerInfo: {
  typeName: 'BusinessUserBasic',
  typeNamePlural: 'BusinessUserBasic',
  title.value: 'FullName',
  description.value: 'FullName',
  typeImageUrl: 'sap-icon://blank-tag'
}

/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZI_USR_PI_VH
  as select from I_BusinessUserBasic as BusinessUserBasic
{

      @UI.facet: [
        {
          type: #FIELDGROUP_REFERENCE,
          label: 'User Information',
          targetQualifier: 'data',
          purpose: #QUICK_VIEW
        },
        {
          type: #IDENTIFICATION_REFERENCE,
          label: 'User Information'
        }
      ]

      @Search.defaultSearchElement: true
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: ['FullName']
      @EndUserText.label : 'User ID'
  key BusinessUserBasic.UserID                                as BusinessPartner,
      @Semantics.text: true
      @UI.fieldGroup: [{ qualifier: 'data', position: 10 }]
      @EndUserText.label : 'Full Name'
      BusinessUserBasic.PersonFullName                        as FullName,
      @UI.fieldGroup: [{ qualifier: 'data', position: 20 }]
      @EndUserText.label : 'First Name'
      BusinessUserBasic.FirstName                             as FirstName,
      @UI.fieldGroup: [{ qualifier: 'data', position: 30 }]
      @EndUserText.label : 'Last Name'
      BusinessUserBasic.LastName                              as LastName,
      @UI.fieldGroup: [{ qualifier: 'data', position: 40 }]
      @EndUserText.label : 'Mobile Phone Number'
      BusinessUserBasic._WorkplaceAddress.MobilePhoneNumber   as MobilePhoneNumber,
      @UI.fieldGroup: [{ qualifier: 'data', position: 50 }]
      @EndUserText.label : 'Email Address'
      BusinessUserBasic._WorkplaceAddress.DefaultEmailAddress as EmailAddress,
      @UI.fieldGroup: [{ qualifier: 'data', position: 60 }]
      @EndUserText.label : 'Phone Number'
      BusinessUserBasic._WorkplaceAddress.PhoneNumber         as PhoneNumber


}
