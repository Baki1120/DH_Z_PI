@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage user upload file'
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZR_PICODE_UPL
  as select from ztb_picode_upl as File

  composition [0..*] of ZI_DATA_PICODE   as _dataFile
  composition [0..*] of ZI_VIEW_PICODE   as _previewData
  composition [0..*] of ZI_PICODE_CURR   as _picodeCurrent
  association [0..1] to ZI_STA_UPLOAD_VH as _OverallStatus on  $projection.Status      = _OverallStatus.Status
                                                           and _OverallStatus.language = $session.system_language
  association [0..1] to ZI_USR_PI_VH     as _BusinessUser  on  $projection.EndUser = _BusinessUser.BusinessPartner
{

  key uuid                  as Uuid,
  key end_user              as EndUser,
  key cnt                   as ZCount,
      status                as Status,
      @Semantics.largeObject: { mimeType: 'Mimetype',
                                fileName: 'Filename',
                                contentDispositionPreference: #INLINE }
      attachment            as Attachment,
      @Semantics.mimeType: true
      mimetype              as Mimetype,
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
      _dataFile,
      _previewData,
      _picodeCurrent,
      _OverallStatus,
      _BusinessUser
}
