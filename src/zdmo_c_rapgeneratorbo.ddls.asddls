@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forRAPGeneratorBO'
@ObjectModel.semanticKey: [ 'BoName' ]
@Search.searchable: true
define root view entity ZDMO_C_RAPGENERATORBO
  provider contract transactional_query
  as projection on ZDMO_R_RapGeneratorBO

{
  key      RapNodeUUID,
           @Search.defaultSearchElement: true
           @Search.fuzzinessThreshold: 0.90
           BoName,
           RootEntityName,
           Namespace,
           @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_PACKAGE', element: 'name' },
               additionalBinding: [ { localElement: 'ABAPLanguageVersion',   element: 'language_version'}
               ]
           }]
           @Search.defaultSearchElement: true
           @Search.fuzzinessThreshold: 0.90
           PackageName,
           TransportRequest,
           SkipActivation,
           @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_IMPL_TYPE', element: 'name' }}]
           ImplementationType,
           @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_DSRC_TYPE', element: 'type' }}]
           DataSourceType,
           @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_ABAP_VERS', element: 'language_version' }}]
           ABAPLanguageVersion,
           @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_BIND_TYPE', element: 'name' }}]
           BindingType,
           PackageLanguageVersion,
           @Consumption.valueHelpDefinition: [{ entity : {name: 'ZDMO_I_RAP_GENERATOR_BOOL_VH', element: 'bool_value'  } }]
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
           BoIsDeleted,
           JobName,
           JobCount,
           ADTLink,
           ApplicationJobLogHandle,
           @EndUserText.label: 'Hide ADT Link'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  HideADTLink          : abap_boolean,
           @EndUserText.label: 'Job Status'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  JobStatus            : abap.char( 1 ),
           @EndUserText.label: 'Generation'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  JobStatusText        : abap.char( 20 ),
           @EndUserText.label: 'Criticality'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
  virtual  JobStatusCriticality : abap.int1,

           _RAPGeneratorBONode : redirected to composition child ZDMO_C_RAPGENERATORBONODE,
           _ApplicationLog
           


}
