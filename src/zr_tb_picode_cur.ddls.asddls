@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'The Next PI Code'
define root view entity ZR_TB_PICODE_CUR
  as select from ztb_picode_cur as PiCodesCurrently
{
  key code                  as Code,
      pi_code               as PiCode,
      next_code             as NextCode,
      uuid_upl              as UplUuid,
      end_user              as EndUser,
      filename              as FileName,
      cnt                   as ZCount,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt

}
