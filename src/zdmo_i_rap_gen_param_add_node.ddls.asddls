@EndUserText.label: 'Parameter(s) to create new nodes'
define abstract entity ZDMO_I_RAP_GEN_PARAM_ADD_NODE
{
  @EndUserText.label: 'Entity Name'
  entity_name    : zdmo_rap_gen_entityname;

// 
//       @Consumption.valueHelpDefinition:
//        [{
//          qualifier: 'MyValueHelpA',
//          entity: { name:'ZDMO_I_RAP_GEN_GET_ABSTRCT_ENT', element:'name' },
//          enabled: #(' ELEMENT_OF_REFERENCED_ENTITY: isabstractentity')
//          },
//          {
//          qualifier: 'MyValueHelpB',
//          entity: { name:'C_RAP_MDBU_VALUEHELP_B', element:'CountryAvailability' },
//          enabled: #('ELEMENT_OF_REFERENCED_ENTITY: xxx')
//        }]
////
//  @Consumption.valueHelpDefinition: [{ entity:  { name:    'ZDMO_I_RAP_GENERATOR_DATA_SRC2',
//                                                  element: 'name' }
//                                                  ,
//                                       additionalBinding: [{element:      'type',
//                                                            localElement: #( ' ELEMENT_OF_REFERENCED_ENTITY: DataSourceType'),
//                                                            usage:        #FILTER
//                                                          }]
//                                                            }]

 DataSourceName : abap.char(30);
//  @EndUserText.label     : 'Datasource Type'
//  @UI.defaultValue: #('ELEMENT_OF_REFERENCED_ENTITY:DataSourceType')
  DataSourceType : abap.char(30);
//  @EndUserText.label: 'Data Source Name'
//  @Consumption.valueHelpDefinition: [{ entity:
//  { name         : 'ZDMO_I_RAP_GENERATOR_DATA_SRC2' ,  element: 'name' }
//                                       ,
//                                      additionalBinding: [{ element: 'type',
//                                                            localElement: 'DataSourceType' }]
//                                                            }]
//
//  DataSourceName : abap.char(30);
}
