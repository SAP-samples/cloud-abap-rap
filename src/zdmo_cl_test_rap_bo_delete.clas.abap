CLASS zdmo_cl_test_rap_bo_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA package TYPE sxco_package.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA raP_bo_cleaner TYPE REF TO zdmo_cl_rap_bo_delete.

ENDCLASS.



CLASS zdmo_cl_test_rap_bo_delete IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    package = 'ZDT261_199'.
*    data demo_mode type abap_bool VALUE abap_true.
    DATA demo_mode TYPE abap_bool VALUE abap_false.

    raP_bo_cleaner = NEW #( i_demo_mode = demo_mode i_out = out i_package = package ).
    raP_bo_cleaner->start_deletion(  ).

  ENDMETHOD.
ENDCLASS.
