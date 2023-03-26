@EndUserText.label: 'RAP Generator - Data Sources'
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_DATA_SRC_2'
@Search.searchable: true
define custom entity ZDMO_I_RAP_GENERATOR_DATA_SRC2
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @EndUserText.label : 'Data Source Name'
  key name               : abap.char( 50 );
      @UI.hidden         : true
  key type               : abap.char( 20 );
      @UI.hidden: true
      parent_data_source : sxco_cds_object_name;

}
