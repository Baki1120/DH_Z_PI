@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pi Code Currently'

define view entity ZI_PICODE_CURR
  as select from ztb_picode_cur
  association        to parent ZR_PICODE_UPL as _File         on  $projection.UuidUpl = _File.Uuid
                                                              and $projection.EndUser = _File.EndUser
                                                              and $projection.Cnt     = _File.ZCount
  association [0..1] to ZI_USR_PI_VH         as _BusinessUser on  $projection.EndUser = _BusinessUser.BusinessPartner
{
  key ztb_picode_cur.code                  as Code,
      ztb_picode_cur.pi_code               as PiCode,
      ztb_picode_cur.next_code             as NextCode,
      @Semantics.user.createdBy: true
      ztb_picode_cur.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ztb_picode_cur.created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      ztb_picode_cur.local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ztb_picode_cur.local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      ztb_picode_cur.last_changed_at       as LastChangedAt,
      ztb_picode_cur.uuid_upl              as UuidUpl,
      ztb_picode_cur.end_user              as EndUser,
      ztb_picode_cur.filename              as Filename,
      ztb_picode_cur.cnt                   as Cnt,
      _File,
      _BusinessUser

}
