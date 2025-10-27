@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage User Data File'
define view entity ZI_DATA_PICODE
  as select from ztb_pi_cc
  association        to parent ZR_PICODE_UPL as _File         on  $projection.UplUuid = _File.Uuid
                                                              and $projection.EndUser = _File.EndUser
                                                              and $projection.Zcount  = _File.ZCount
  association [0..1] to ZI_USR_PI_VH         as _BusinessUser on  $projection.EndUser = _BusinessUser.BusinessPartner
{
  key uuid                  as Uuid,
      pi_code               as PiCode,
      pi_first_name         as PiFirstName,
      pi_last_name          as PiLastName,
      uh_pi_uid             as UhPiUid,
      notes                 as Notes,
      active                as Active,
      uuid_upl              as UplUuid,
      end_user              as EndUser,
      cnt                   as Zcount,
      filename              as FileName,
      zindex                as Zindex,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _File,
      _BusinessUser
}
