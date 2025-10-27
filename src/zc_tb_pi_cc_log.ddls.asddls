@Metadata.allowExtensions: true
@EndUserText.label: 'Principal Investigator Log'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TB_PI_CC_LOG
  provider contract transactional_query
  as projection on ZR_TB_PI_CC_LOG
{
  key Uuid,
      @ObjectModel.text.element: [ 'TypeText' ]
      Type,
      @EndUserText.label: 'Type'
      @Semantics.text: true
      @UI.hidden: true
      _LogTyp.description    as TypeText,
      @EndUserText.label: 'Status'
      @Semantics.text: true
      @UI.hidden: true
      _LogStatus.PiLogStatus as PiLogStatus,
      @ObjectModel.text.element: [ 'PiLogStatus' ]
      Status,
      @UI.hidden: true
      Criticality,
      Message,
      PiCode,
      PiFirstName,
      PiLastName,
      RcuhPiCode,
      Notes,
      Active,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _LogTyp

}
