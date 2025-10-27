@EndUserText.label: 'Response of API PI Codes'
define root abstract entity ZA_PI_RES
{
  key UuidApi     : sysuuid_x16;
  key Uuid        : sysuuid_x16;
      PiCode      : abap.char(4);
      PiFirstName : abap.char(100);
      PiLastName  : abap.char(100);
      RcuhPiUid   : abap.char(50);
      Note        : abap.char(100);
      Active      : abap_boolean;
      RCUHProject : abap_boolean;
      Status      : abap.char( 1 );
      Message     : abap.char( 255 );

}
