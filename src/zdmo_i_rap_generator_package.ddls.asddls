@EndUserText.label: 'RAP Generator - Packages'
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_PACKAGE'
@Search.searchable: true
define custom entity ZDMO_I_RAP_GENERATOR_PACKAGE
{

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @EndUserText.label: 'Package Name'
  key name             : abap.char( 50 );
      @UI.hidden       : true
  key language_version : abap.char(30);
}
