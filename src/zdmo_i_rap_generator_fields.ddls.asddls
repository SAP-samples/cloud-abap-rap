@EndUserText.label: 'RAP Generator - Datsource Fields'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_FIELDS'
define custom entity ZDMO_I_RAP_GENERATOR_FIELDS
{
      @EndUserText.label     : 'Field Name'
  key field                  : abap.char( 30 );
      @UI.hidden             : true
  key name                   : abap.char( 50 );
      @UI.hidden             : true
  key type                   : abap.char( 20 );
      @UI.hidden             : true
  key language_version       : abap.char(30);
      @EndUserText.label     : 'Data element'
      data_element           : sxco_ad_object_name;
      @EndUserText.label     : 'Built in type'
      built_in_type          : abap.char( 4 );
      @EndUserText.label     : 'Length'
      built_in_type_length   : abap.numc( 6 );
      @EndUserText.label     : 'Decimals'
      built_in_type_decimals : abap.numc( 6 );


}
