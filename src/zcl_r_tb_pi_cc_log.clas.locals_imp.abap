CLASS lhc_zr_tb_pi_cc_log DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR PrincipalInvestigatorLog
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR PrincipalInvestigatorLog RESULT result.
ENDCLASS.

CLASS lhc_zr_tb_pi_cc_log IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD get_instance_features.

    READ ENTITIES OF zr_tb_pi_cc_log IN LOCAL MODE
         ENTITY PrincipalInvestigatorLog
         ALL FIELDS WITH
         CORRESPONDING #( keys )
         RESULT FINAL(lt_header)
         FAILED failed.

    result = VALUE #(
            FOR ls_header IN lt_header
            ( %tky                      = ls_header-%tky
              %action-edit              = if_abap_behv=>fc-o-disabled ) ).

  ENDMETHOD.

ENDCLASS.
