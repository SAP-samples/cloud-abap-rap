CLASS zcl_rap_generator DEFINITION
  PUBLIC
  FINAL
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  CREATE PUBLIC .

  PUBLIC SECTION.

  PROTECTED SECTION.
    METHODS main REDEFINITION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_rap_generator IMPLEMENTATION.

  METHOD main.

    DATA rap_bo_visitor TYPE  REF TO zcl_rap_xco_json_visitor .

    DATA(json_string) = '<enter your json string here>'.

    rap_bo_visitor = NEW zcl_rap_xco_json_visitor(  ).
    DATA(json_data) = xco_cp_json=>data->from_string( json_string ).
    json_data->traverse( rap_bo_visitor ).

    out->write( 'finished' ).

  ENDMETHOD.
ENDCLASS.
