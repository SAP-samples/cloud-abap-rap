@EndUserText.label: 'Parameter(s) to create new nodes'
define abstract entity ZDMO_I_RAP_GEN_PARAM_Add_nodeT
{
  @EndUserText.label: 'Entity Name'
  entity_name    : zdmo_rap_gen_entityname;

  @Consumption.valueHelpDefinition: [{ entity:  { name:    'ZDMO_I_RAP_gen_get_tables',
                                                  element: 'name' }
                                                            }]
  @EndUserText.label: 'Data Source Name'
  DataSourceName : abap.char(30);

//  @UI.defaultValue: #('ELEMENT_OF_REFERENCED_ENTITY:DataSource')
//  parent_entity_name          : zdmo_rap_gen_entityname;

}
