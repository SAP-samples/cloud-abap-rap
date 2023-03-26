@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forProject'
define root view entity ZDMO_I_RAPG_ProjectTP
  provider contract transactional_interface
  as projection on ZDMO_R_RAPG_ProjectTP
{
  key RapBoUUID,
  BoName,
  RootEntityName,
  Namespace,
  PackageName,
  TransportRequest,
  SkipActivation,
  ImplementationType,
  AbapLanguageVersion,
  PackageLanguageVersion,
  DataSourceType,
  BindingType,
  DraftEnabled,
  Suffix,
  Prefix,
  MultiInlineEdit,
  CustomizingTable,
  AddToManageBusinessConfig,
  BusinessConfName,
  BusinessConfIdentifier,
  BusinessConfDescription,
  CreatedAt,
  CreatedBy,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  JsonString,
  JsonIsValid,
  BoIsGenerated,
  BoIsDeleted,
  ApplJobLogHandle,
  JobCount,
  JobName,
  ADTLink,
  _Log : redirected to composition child ZDMO_I_RAPG_LogTP,
  _Node : redirected to composition child ZDMO_I_RAPG_NodeTP
  
}
