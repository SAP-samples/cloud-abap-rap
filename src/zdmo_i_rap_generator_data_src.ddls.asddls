@EndUserText.label: 'RAP Generator - Data Sources'
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_DATA_SRC'
@Search.searchable: true
define custom entity ZDMO_I_RAP_GENERATOR_DATA_SRC
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @EndUserText.label: 'Data Source Name'
  key name               : abap.char( 50 );
      @UI.hidden         : true
  key type               : abap.char( 20 );
      @UI.hidden         : true
  key language_version   : abap.char(30);
      @UI.hidden         : true
  key parent_data_source : abap.char(30);
      @UI.hidden         : true
  key is_root_node       : abap_boolean;
      @UI.hidden         : true
  key package_name       : sxco_package;
}
