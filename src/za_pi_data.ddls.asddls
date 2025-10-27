@EndUserText.label: 'Principal Investigator Data'
define abstract entity ZA_PI_DATA
{
  key Uuid                          : sysuuid_x16;
      PiFirstName                   : abap.char(100);
      PiLastName                    : abap.char(100);
      RcuhPiUid                     : abap.char(50);
      Note                          : abap.char(100);
      Active                        : abap_boolean;
      RCUHProject                   : abap_boolean;
      UuidApi                       : sysuuid_x16;
      _PrincipalInvestigatorRequest : association to parent ZA_PI_REQ on $projection.UuidApi = _PrincipalInvestigatorRequest.UuidApi;

}
