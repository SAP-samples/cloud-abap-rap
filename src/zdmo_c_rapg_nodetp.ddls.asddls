@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forNode'
@ObjectModel.semanticKey: [ 'EntityName' ]
@Search.searchable: true
define view entity ZDMO_C_RAPG_NodeTP
  as projection on ZDMO_R_RAPG_NodeTP
{
  key NodeUUID,
      RapBoUUID,
      ParentUUID,
      RootUUID,
      NodeNumber,
      IsRootNode,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      EntityName,
      //      @Consumption.valueHelpDefinition: [{ association : '_Entity' }]
      //      @Consumption.valueHelp: '_Entity'

      @Consumption.valueHelpDefinition: [{ entity:
      { name         : 'ZDMO_C_RAPG_NodeTP' ,  element: 'EntityName' }
       ,
                                      additionalBinding: [{ element: 'RapBoUUID',
                                                            localElement: 'RapBoUUID' }]
                                                            }]
      ParentEntityName,
      @Consumption.valueHelpDefinition: [{ entity:
      { name         : 'ZDMO_I_RAP_GENERATOR_DATA_SRC2' ,  element: 'name' }
                                       ,
                                      additionalBinding: [{ element: 'type',
                                                            localElement: 'DataSourceType' }]
                                                            }]
      DataSource,


      ParentDataSource,
      ViewTypeValue,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameObjectID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
               additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                    { localElement: 'DataSourceType', element: 'type'},
                                    { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameEtagMaster,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
               additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                    { localElement: 'DataSourceType', element: 'type'},
                                    { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameTotalEtag,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameUUID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameParentUUID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameRootUUID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameCreatedBy,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameCreatedAt,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameLastChangedBy,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameLastChangedAt,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                     additionalBinding: [ { localElement: 'ABAPLanguageVersion', element: 'language_version'},
                                          { localElement: 'DataSourceType', element: 'type'},
                                          { localElement: 'DataSource', element: 'name'} ] } ]
      FieldNameLocLastChangedAt,
      CdsIView,
      CdsRView,
      CdsPView,
      MdeView,
      BehaviorImplementationClass,
      ServiceDefinition,
      ServiceBinding,
      ControlStructure,
      QueryImplementationClass,
      DraftTableName,
      HierarchyDistanceFromRoot,
      HierarchyDescendantCount,
      HierarchyDrillState,
      HierarchyPreorderRank,
      LocalLastChangedAt,
      isChildNode,
      _Project.isManaged                               as isManaged,
      _Project.hasSematicKey                           as hasSemanticKey,
      _Project.doesNotUseUnmanagedQuery                as doesNotUseUnmanagedQuery,
      _Project.DataSourceType                          as DataSourceType,
      _Project.AbapLanguageVersion                     as ABAPLanguageVersion,
      _Project.PackageName                             as PackageName,
      _Field   : redirected to composition child ZDMO_C_RAPG_FieldTP,
      _Project : redirected to parent ZDMO_C_RAPG_ProjectTP
      //      ,
      //      _Entity

}
