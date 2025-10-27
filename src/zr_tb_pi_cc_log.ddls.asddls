@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Principal Investigator Log'
define root view entity ZR_TB_PI_CC_LOG
  as select from ztb_pi_cc_log as PrincipalInvestigatorLog
  association [0..1] to ZI_LOG_TYP as _LogTyp    on  $projection.Type = _LogTyp.LogTyp
                                                 and _LogTyp.language = $session.system_language

  association [0..1] to ZPI_STA_VH as _LogStatus on  $projection.Status  = _LogStatus.Status
                                                 and _LogStatus.language = $session.system_language
{
  key uuid                            as Uuid,
      type                            as Type,
      pi_code                         as PiCode,
      pi_first_name                   as PiFirstName,
      pi_last_name                    as PiLastName,
      rcuh_pi_code                    as RcuhPiCode,
      notes                           as Notes,
      active                          as Active,
      message                         as Message,
      PrincipalInvestigatorLog.status as Status,
      case PrincipalInvestigatorLog.status
        when ' ' then 2
        when 'S' then 3
        when 'U' then 3
        when 'A' then 3
        when 'R' then 1
        when 'F' then 1
        else 0 end                    as Criticality,
      @Semantics.user.createdBy: true
      created_by                      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by           as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at           as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                 as LastChangedAt,
      _LogTyp,
      _LogStatus

}
