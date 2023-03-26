@EndUserText.label: 'RAP Generator - Data Sources'
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_DATA_SRC_2'
@Search.searchable: true
define custom entity ZDMO_I_RAP_GEN_GET_ABSTRCT_ENT
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @EndUserText.label: 'Data Source Name'
        
  key name               : abap.char( 50 );
  
  @EndUserText.label: 'Parent Data Source Name'
  parent_data_source     :  sxco_cds_object_name; 

}
