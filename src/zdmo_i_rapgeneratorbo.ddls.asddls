@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View forRAPGeneratorBO'
define root view entity ZDMO_I_RAPGENERATORBO
provider contract transactional_interface
  as projection on ZDMO_R_RAPGENERATORBO  
{
  key RapNodeUUID,
  BoName,
  RootEntityName,
  Namespace,
  PackageName,
  TransportRequest,
  SkipActivation,
  ImplementationType,
  ABAPLanguageVersion,
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
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  JsonString,
  JsonIsValid,
  BoIsGenerated,
  JobCount,
  JobName,
  ADTLink,
  /* Associations */
  _RAPGeneratorBONode : redirected to composition child ZDMO_I_RAPGENERATORBONODE
}
