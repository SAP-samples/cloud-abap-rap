@EndUserText.label: 'RAP Generator - Data Sources'
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_DATA_SRC_2'
@Search.searchable: true
define custom entity ZDMO_I_RAP_GEN_GET_TABLES
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @EndUserText.label: 'Data Source Name'
   
  key name               : abap.char( 50 );

}
