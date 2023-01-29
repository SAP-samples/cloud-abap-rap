@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forRAPGeneratorBONode'
//@ObjectModel.semanticKey: [ 'EntityName' ]
@Search.searchable: true

////Hierarchy related annotations are not released yet
//@OData.hierarchy.recursiveHierarchy: [{
//elementWithHierarchy: 'NodeUUID',
//nodeElement: 'NodeUUID',
//parentNodeElement: 'ParentUUID',
//distanceFromRootElement: 'Hierarchydistancefromroot' ,--> root = 0 , child 1,...
//// For root the values are either "expanded" or "collapsed"
////                                         "    When the root has one or more childs it is expanded.
////                                         "    Otherwise it is "collapsed"
////                                         "    For child nodes it is "leaf"
////drillStateElement: 'Hierarchiedrillstate',
//////For leaves without childs = 0, For nodes with childs = number of childs
//descendantCountElement: 'HierarchieDescandantCount' 
//}]


define view entity ZDMO_C_RAPGENERATORBONODE
  as projection on ZDMO_R_RapGeneratorBONode
{
  key NodeUUID,
      HeaderUUID,
      @ObjectModel.text.element: ['ParentEntityName']
      ParentUUID,
      RootUUID,
      NodeNumber,

      IsRootNode,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      EntityName,
      ParentEntityName,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_ABAP_VERS', element: 'language_version' }}]
      _RAPGeneratorBO.ABAPLanguageVersion as ABAPLanguageVersion,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_DSRC_TYPE', element: 'type' }}]
      _RAPGeneratorBO.DataSourceType      as DataSourceType,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_DATA_SRC', element: 'name'},
                   additionalBinding: [
                                    { localElement: 'ABAPLanguageVersion',   element: 'language_version' },
                                    { localElement: 'DataSourceType',   element: 'type' },
                                    { localElement: 'ParentDataSource',   element: 'parent_data_source' },
                                    { localElement: 'IsRootNode',   element: 'is_root_node' },
                                    { localElement: 'PackageName', element: 'package_name' }
                                    ] } ]
      DataSource,
      ParentDataSource,
      _RAPGeneratorBO.PackageName as PackageName,
      ViewTypeValue,

      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                  additionalBinding: [
                   { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                       { localElement: 'DataSourceType',   element: 'type'},
                                       { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameObjectID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                  additionalBinding: [
                                       { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                       { localElement: 'DataSourceType',   element: 'type'},
                                       { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameEtagMaster,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameTotalEtag,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameUUID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameParentUUID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameRootUUID,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameCreatedBy,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameCreatedAt,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameLastChangedBy,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameLastChangedAt,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZDMO_I_RAP_GENERATOR_FIELDS', element: 'field'},
                        additionalBinding: [
                                             { localElement: 'ABAPLanguageVersion',   element: 'language_version'},
                                             { localElement: 'DataSourceType',   element: 'type'},
                                             { localElement: 'DataSource',   element: 'name'} ] } ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      FieldNameLocLastChangedAt,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      CdsIView,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      CdsRView,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      CdsPView,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      MdeView,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      BehaviorImplementationClass,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      ServiceDefinition,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      ServiceBinding,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      ControlStructure,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      QueryImplementationClass,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      DraftTableName,
      HierarchyDistanceFromRoot,
      HierarchyDescendantCount,
      HierarchyDrillState, // leaf, expanded, collapsed
      HierarchyPreorderRank,
      LocalLastChangedAt,
      _RAPGeneratorBO : redirected to parent ZDMO_C_RAPGENERATORBO

}
