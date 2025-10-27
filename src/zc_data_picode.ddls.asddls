@EndUserText.label: 'Data Pi Code'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_DATA_PICODE
  as projection on ZI_DATA_PICODE
{
      @Search.defaultSearchElement: true
  key Uuid,
      PiCode,
      PiFirstName,
      PiLastName,
      UhPiUid,
      Notes,
      Active,
      UplUuid,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['PersonFullName']
      EndUser,
      @EndUserText.label: 'User name'
      @Semantics.text: true
      @UI.hidden: true
      _BusinessUser.FullName as PersonFullName,
      Zcount,
      FileName,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _File : redirected to parent ZC_PICODE_UPL,
      _BusinessUser
}
