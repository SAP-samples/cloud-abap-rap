@EndUserText.label: 'value help for boolean values'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_BOOLEANS'
define custom entity zdmo_I_rap_generator_bool_VH
{      
      @ObjectModel.text.element: ['name']
  key bool_value : abap_boolean;
      name : abap.char(10);
}
