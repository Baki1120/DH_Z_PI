@Metadata.allowExtensions: true
@EndUserText.label: 'Principal Investigator'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
define root view entity ZC_TB_PI_CC
  provider contract transactional_query
  as projection on ZR_TB_PI_CC as PrincipalInvestigator
  association [0..*] to ZC_PI_CC_LOG as _ChangeDocs on $projection.PiCode = _ChangeDocs.objectid
{
  key PrincipalInvestigator.Uuid,
      PrincipalInvestigator.PiCode,
      PrincipalInvestigator.PiFirstName,
      PrincipalInvestigator.PiLastName,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      PrincipalInvestigator.RcuhPiUid,
      PrincipalInvestigator.Notes,
      PrincipalInvestigator.Active,
      PrincipalInvestigator.RCUHProject,
      PrincipalInvestigator.UuidApi,
      PrincipalInvestigator.CreatedByUser,
//      PrincipalInvestigator.Criticality,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['PersonFullName']
      PrincipalInvestigator.CreatedBy,
      PrincipalInvestigator.CreatedAt,
      PrincipalInvestigator.LocalLastChangedBy,
      PrincipalInvestigator.LocalLastChangedAt,
      PrincipalInvestigator.LastChangedAt,
      @EndUserText.label: 'User name'
      @Semantics.text: true
      @UI.hidden: true
      _BusinessUser.FullName as PersonFullName,
      _ChangeDocs,
      _BusinessUser
}
