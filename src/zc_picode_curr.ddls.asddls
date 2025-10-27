@EndUserText.label: 'Pi Code Currently'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_PICODE_CURR
  as projection on ZI_PICODE_CURR
{
      @Search.defaultSearchElement: true
  key Code,
      PiCode,
      NextCode,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      UuidUpl,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['PersonFullName']
      EndUser,
      @EndUserText.label: 'User name'
      @Semantics.text: true
      @UI.hidden: true
      _BusinessUser.FullName as PersonFullName,
      Filename,
      Cnt,
      /* Associations */
      _File : redirected to parent ZC_PICODE_UPL,
      _BusinessUser
}
