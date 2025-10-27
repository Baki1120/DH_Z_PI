@EndUserText.label: 'View data Pi Code'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_VIEW_PICODE
  as projection on ZI_VIEW_PICODE
{
      @Search.defaultSearchElement: true
  key ViewUuid,
      UploadUuid,
      @ObjectModel.text.element: ['PersonFullName']
      EndUser,
      Cnt,
      PiCode,
      PiFirstName,
      PiLastName,
      UhPiUid,
      Notes,
      Active,
      @EndUserText.label: 'User name'
      @Semantics.text: true
      @UI.hidden: true
      _BusinessUser.FullName as PersonFullName,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _File : redirected to parent ZC_PICODE_UPL,
      _BusinessUser
}
