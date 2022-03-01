@EndUserText.label: 'contains parameter(s) to create new nodes'
define abstract entity ZDMO_I_RAP_GEN_PARAM_RAPBONODE
{
  @EndUserText.label: 'Root Entity Name'
  entity_name      : zdmo_rap_gen_entityname;
  @EndUserText.label: 'Package'
  @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_PACKAGE', element: 'name' }}]
  package_name     : sxco_package;
//  @EndUserText.label: 'ABAP Language Version'
//  @Consumption.defaultValue : 'abap_for_cloud_development'
//  @Consumption.valueHelpDefinition: [{entity: {name: 'ZDMO_I_RAP_GENERATOR_ABAP_VERS', element: 'language_version' }}]
//  language_version : abap.char( 30 );

}
