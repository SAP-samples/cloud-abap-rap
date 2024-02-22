@EndUserText.label: 'RAP Generator - Implementation Types'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_IMPL_TYPE2'
define custom entity ZDMO_I_RAP_GENERATOR_IMPL_TYP2
{
      @EndUserText.label: 'Implementation Type'
  key name : abap.char( 50 );
}
