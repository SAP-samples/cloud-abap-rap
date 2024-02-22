@EndUserText.label: 'Parameter(s) to create new nodes'
define abstract entity ZDMO_I_RAP_GEN_PARAM_ADD_NODEA
{
  @EndUserText.label : 'Entity Name'
  entity_name        : zdmo_rap_gen_entityname;

  @Consumption.valueHelpDefinition: [{ entity:  { name:    'ZDMO_I_RAP_GEN_GET_ABSTRCT_ENT',
                                                  element: 'name' }
                                                  ,
                               additionalBinding: [{ element: 'parent_data_source',
                                                  localElement: 'parent_data_source' }]
                                                            }]
  @EndUserText.label : 'Data Source Name'
  DataSourceName     : abap.char(30);

//  @UI.defaultValue   : #('ELEMENT_OF_REFERENCED_ENTITY:DataSource')
  @UI.hidden         : true
  @EndUserText.label: 'Parent Data Source Name'
  parent_data_source : zdmo_rap_gen_entityname;

}
