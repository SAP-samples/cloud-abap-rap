CLASS zdmo_cl_create_fe_packages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_CREATE_FE_PACKAGES IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    DATA group_number_start TYPE i VALUE 1.
     DATA group_number_start TYPE i VALUE 5.
*    DATA group_number_start TYPE i VALUE 10.
*    DATA group_number_start TYPE i VALUE 15.
*    DATA group_number_start TYPE i VALUE 20.

    DATA group_number_end TYPE i.
    DATA number_of_groups TYPE i VALUE 5.
    DATA group_number TYPE i.
    DATA group_number_n(2) TYPE n.
    data group_number_c(6) TYPE c.

   constants location_letter type c length 4 value '0010'.

    "DATA rapxxx_generator TYPE REF TO zdmo_gen_rap630_single.
    "DATA rapxxx_generator TYPE REF TO zdmo_gen_rap110_single.
*    DATA rapxxx_generator TYPE REF TO zdmo_gen_dt261_single.
    data rapxxx_generator type ref to zdmo_cl_fe_travel_generator.

    group_number = group_number_start.
    group_number_end = group_number_start + number_of_groups .

    WHILE group_number < group_number_end.

      group_number_n = group_number.
      group_number_c = location_letter && group_number_n.

      out->write( |start generation with groupnumber { group_number_c }| ).
      rapxxx_generator = NEW #( CONV #( group_number_c ) ).

      rapxxx_generator->if_oo_adt_classrun~main( out  ).
      group_number += 1.

    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
