@EndUserText.label: 'RAP Generator - Application Log'
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_SHOW_APPL_LOG'
//@Search.searchable: true

@UI: {
    headerInfo: {
    title: {
      type: #STANDARD,
      label: 'Item Number',
      value: 'Log_item_number'
    },
    typeName: 'AppLogEntry',
    typeNamePlural: 'AppLogEntries'},
    presentationVariant: [{
    maxItems: 20,
    visualizations: [{type: #AS_LINEITEM}]
    }]
    }


define custom entity ZDMO_I_RAP_GENERATOR_appl_log
{
      @UI.facet       : [
        {
          id          : 'idIdentification',
          type        : #IDENTIFICATION_REFERENCE,
          label       : 'General Information',
          position    : 10
        }
        ]
  key Log_handle      : balloghndl;
      @UI.lineItem    : [ {
      position        : 10 ,
      importance      : #HIGH,
      label           : 'Log item number'  } ]
      @UI.identification: [ {
      position        : 10 ,
      importance      : #HIGH,
      label           : 'Log item number'  } ]
      @EndUserText.label: 'Logitemnumber'
      @UI.selectionField: [ { position: 20 } ]
  key Log_item_number : balmnr;

      @UI.lineItem    : [ {
          position    : 10 ,
          importance  : #HIGH,
          criticality : 'criticality',
          label       : 'Severity'  } ]

      severity        : symsgty;
      category        : abap.char(1);
      criticality     : abap.int1;
      @UI.lineItem    : [ {
      position        : 90 ,
      importance      : #HIGH,
      label           : 'Detail level'  } ]
      @UI.identification: [ {
      position        : 90 ,
      importance      : #HIGH,
      label           : 'Detail level'  } ]
      detail_level    : ballevel;
      timestamp       : abap.utclong;
      @UI.lineItem    : [ {
      position        : 100 ,
      importance      : #HIGH,
      label           : 'Message text'  } ]
      @UI.identification: [ {
      position        : 100 ,
      importance      : #HIGH,
      label           : 'Message text'  } ]
      message_text    : abap.sstring( 512 );

}
