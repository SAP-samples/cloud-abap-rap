@EndUserText.label: 'RAP Generator - Datasource Type'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_DSRC_TYPE'
define custom entity ZDMO_I_RAP_GENERATOR_DSRC_TYPE 
{
  @EndUserText.label: 'Data Source Type'
  key type : abap.char( 50 );  
}
