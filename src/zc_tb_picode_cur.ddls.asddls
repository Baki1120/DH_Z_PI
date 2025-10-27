@Metadata.allowExtensions: true
@EndUserText.label: 'PI Code Currently'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TB_PICODE_CUR
  provider contract transactional_query
  as projection on ZR_TB_PICODE_CUR
{
  key Code,
      PiCode,
      NextCode,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt

}
