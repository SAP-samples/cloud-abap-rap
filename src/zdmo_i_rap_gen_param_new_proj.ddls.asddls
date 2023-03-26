@EndUserText.label: 'Parameter(s) to create new projects'
define abstract entity ZDMO_I_RAP_GEN_PARAM_NEW_PROJ
{

//  @UI.defaultValue       : 'table'
  @EndUserText.label     : 'Datasource Type'
  @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_DSRC_TYPE', element: 'type' }}]
  DataSourceType         : abap.char(30);
//  @UI.defaultValue       : 'managed'
  @EndUserText.label     : 'Implementation type'
  @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_IMPL_TYP2', element: 'name' }}]

  BdefImplementationType : abap.char(50);
//  @UI.defaultValue       : 'odata_v4_ui'
  @EndUserText.label     : 'Binding type'
  @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_BIND_TYPE', element: 'name' }}]
  BindingType            : abap.char(30);
//  @UI.defaultValue       : 'X'
  @EndUserText.label     : 'Draft enabled'
  @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_BOOL_VH', element: 'bool_value' }}]
  DraftEnabled           : abap_boolean;

  @EndUserText.label     : 'Root Entity Name'
  EntityName             : zdmo_rap_gen_entityname;

  @Consumption.valueHelpDefinition: [{ entity:
  { name                 : 'ZDMO_I_RAP_GENERATOR_DATA_SRC2' ,  element: 'name' }
                                       ,
                            additionalBinding: [{ element: 'type',
                                                  localElement: 'DataSourceType' }]
                                                  }]
  @EndUserText.label     : 'Data Source Name'
  data_source_name       : abap.char(30);

  @EndUserText.label     : 'Package'
  @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_PACKAGE', element: 'name' }}]
  package_name           : abap.char(30);

}
