@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Upload Pi Code'
@ObjectModel.semanticKey: [ 'EndUser' ]
@Search.searchable: true
define root view entity ZC_PICODE_UPL
  provider contract transactional_query
  as projection on ZR_PICODE_UPL
{

      @Search.defaultSearchElement: true
  key Uuid,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['PersonFullName']
  key EndUser,
  key ZCount,
      @ObjectModel.text.element: ['OverallStatusText']
      Status,
      @EndUserText.label: 'Status'
      _OverallStatus.description as OverallStatusText,
      Attachment,
      Mimetype,
      @Semantics.text: true
      Filename,
      @EndUserText.label: 'User name'
      @Semantics.text: true
      @UI.hidden: true
      _BusinessUser.FullName     as PersonFullName,
      LocalLastChangedAt,
      /* Associations */
      _dataFile      : redirected to composition child ZC_DATA_PICODE,
      _previewData   : redirected to composition child ZC_VIEW_PICODE,
      _picodeCurrent : redirected to composition child ZC_PICODE_CURR,
      _OverallStatus,
      _BusinessUser

}
