@EndUserText.label: 'Request from API PI Codes'
define root abstract entity ZA_PI_REQ
{
  key UuidApi                    : sysuuid_x16;
      _PrincipalInvestigatorList : composition [0..*] of ZA_PI_DATA;

}
