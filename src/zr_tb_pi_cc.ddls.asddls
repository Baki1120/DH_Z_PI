@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Principal Investigator'
define root view entity ZR_TB_PI_CC
  as select from ztb_pi_cc as PrincipalInvestigator
  association [0..1] to ZI_USR_PI_VH as _BusinessUser on $projection.CreatedBy = _BusinessUser.BusinessPartner
{
  key uuid                  as Uuid,
      pi_code               as PiCode,
      pi_first_name         as PiFirstName,
      pi_last_name          as PiLastName,
      uh_pi_uid             as RcuhPiUid,
      notes                 as Notes,
      active                as Active,
      rcuh_proj             as RCUHProject,
      uuid_upl              as UuidUpl,
      uuid_api              as UuidApi,
      case when uuid_api is not initial
        then cast( 'Created by API' as z_pi_fname )
        else cast( _BusinessUser.FullName as z_pi_fname )
        end                 as CreatedByUser,
      //      case when uuid_api is not initial
      //        then 3
      //        else 1 end          as Criticality,
      end_user              as EndUser,
      cnt                   as Zcount,
      filename              as Filename,
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
      _BusinessUser

}
