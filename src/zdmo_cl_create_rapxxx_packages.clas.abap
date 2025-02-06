CLASS zdmo_cl_create_rapxxx_packages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_CREATE_RAPXXX_PACKAGES IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA group_number_start TYPE i VALUE 1.
    DATA group_number_end TYPE i.
    DATA number_of_groups TYPE i VALUE 50.
    DATA group_number TYPE i.
    DATA group_number_n(3) TYPE n.

    DATA rapxxx_generator TYPE REF TO zdmo_gen_rap630_single.
    "DATA rapxxx_generator TYPE REF TO zdmo_gen_rap110_single.

    group_number = group_number_start.
    group_number_end = group_number_start + number_of_groups .

    WHILE group_number < group_number_end.

      group_number_n = group_number.
      out->write( |start generation with groupnumber { group_number_n }| ).

      rapxxx_generator = NEW #( CONV #( group_number_n ) ).
      rapxxx_generator->if_oo_adt_classrun~main( out  ).
      group_number += 1.

    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
