@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forProject'
@ObjectModel.semanticKey: [ 'BoName' ]
@Search.searchable: true
define root view entity ZDMO_C_RAPG_ProjectTP
  provider contract transactional_query
  as projection on ZDMO_R_RAPG_ProjectTP
{
  key      RapBoUUID,
           @Search.defaultSearchElement: true
           @Search.fuzzinessThreshold: 0.90
           BoName,
           RootEntityName,
           Namespace,
           @EndUserText.label: 'Package'
           @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_PACKAGE', element: 'name' }}]
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
           isManaged,
           doesNotUseUnmanagedQuery,
           hasSematicKey,

           @EndUserText.label: 'Hide ADT Link'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  HideADTLink            : abap_boolean,
           @EndUserText.label: 'Job Status'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  JobStatus              : abap.char( 1 ),
           @EndUserText.label: 'Generation'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  JobStatusText          : abap.char( 20 ),
           @EndUserText.label: 'Criticality'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  JobStatusCriticality   : abap.int1,
           @EndUserText.label: 'Repository objects exist'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  RepositoryObjectsExist : abap_boolean,



           _Log  : redirected to composition child ZDMO_C_RAPG_LogTP,
           _Node : redirected to composition child ZDMO_C_RAPG_NodeTP

}
