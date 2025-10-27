@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View data Pi Code'

define view entity ZI_GLACCOUNT
  as select from I_GLAccount
{
  key GLAccount,
  key CompanyCode,
  ChartOfAccounts,
  GLAccountGroup,
  CorporateGroupAccount,
  AccountIsBlockedForPosting,
  AccountIsBlockedForPlanning,
  AccountIsBlockedForCreation,
  IsBalanceSheetAccount,
  AccountIsMarkedForDeletion,
  PartnerCompany,
  FunctionalArea,
  CreationDate,
  SampleGLAccount,
  IsProfitLossAccount,
  GLAccountType,
  CreatedByUser,
  ProfitLossAccountType,
  ReconciliationAccountType,
  LineItemDisplayIsEnabled,
  IsOpenItemManaged,
  AlternativeGLAccount,
  AcctgDocItmDisplaySequenceRule,
  GLAccountExternal,
  CountryChartOfAccounts,
  AuthorizationGroup,
  TaxCategory,
  IsAutomaticallyPosted,
  CompanyCodeName,
  /* Associations */
  _ChartOfAccounts,
  _ChartOfAccountsText,
  _CompanyCode,
  _FunctionalArea,
  _GLAccountHierarchyNode,
  _GLAccountInChartOfAccounts,
  _GLAccountInCompanyCode,
  _Text

}
