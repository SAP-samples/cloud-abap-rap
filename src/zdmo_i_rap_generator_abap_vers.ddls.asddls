@EndUserText.label: 'RAP Generator - ABAP Language Version'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_ABAP_VERS'
define custom entity ZDMO_I_RAP_GENERATOR_ABAP_VERS 
{
  key language_version : abap.char( 30 );  
}
