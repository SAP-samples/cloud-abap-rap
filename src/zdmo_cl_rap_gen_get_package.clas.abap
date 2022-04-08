CLASS zdmo_cl_rap_gen_get_package DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_GET_PACKAGE IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA business_data TYPE TABLE OF ZDMO_i_rap_generator_data_src .
    DATA business_data_line TYPE ZDMO_i_rap_generator_data_src .
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).
    DATA xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.

    DATA lt_package TYPE sxco_t_packages  .

    DATA(xco_on_prem_library) = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).

    TRY.        DATA(filter_condition_string) = io_request->get_filter( )->get_as_sql_string( ).
        DATA(filter_condition_ranges) = io_request->get_filter( )->get_as_ranges(  ).
        DATA(search_string) = io_request->get_search_expression( ).

        "search string also contains a leading and a trailing quotation mark
        DATA(length_of_search_string) = numofchar( search_string ) - 2.

        IF length_of_search_string < ZDMO_cl_rap_node=>minimal_search_string_length.
          CLEAR business_data.
          io_response->set_total_number_of_records( lines( business_data ) ).
          io_response->set_data( business_data ).
          EXIT.
        ENDIF.

*        READ TABLE filter_condition_ranges WITH KEY name = 'LANGUAGE_VERSION'
*               INTO DATA(filter_condition_language).
*
*        IF filter_condition_language IS NOT INITIAL.
*          DATA(abap_language_Version) =   filter_condition_language-range[ 1 ]-low .
*        ELSE.
*          abap_language_version =  ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development.
*        ENDIF.
*
*        IF abap_language_version =  ZDMO_cl_rap_node=>abap_language_version-standard .
        IF xco_on_prem_library->on_premise_branch_is_used(  ).
          xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).
          DATA(abap_language_version) = ZDMO_cl_rap_node=>abap_language_version-standard.
        ELSE.
          xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
          abap_language_version = ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development.
        ENDIF.

        DATA filter_for_name_provided TYPE abap_bool.

        READ TABLE filter_condition_ranges WITH KEY name = 'NAME'
              INTO DATA(filter_condition_range).

        IF sy-subrc = 0.

          LOOP AT filter_condition_range-range INTO DATA(range).
            REPLACE ALL OCCURRENCES OF '*' IN range-low WITH '%'.
            DATA(lo_filter) = xco_cp_abap_repository=>object_name->get_filter(
              xco_cp_abap_sql=>constraint->contains_pattern( range-low )
               ).

            DATA(lt_package_add) = xco_lib->get_packages( VALUE #( ( lo_filter ) ) ).

            APPEND LINES OF lt_package_add TO lt_package.

          ENDLOOP.

        ELSEIF search_string IS NOT INITIAL.
          search_string = substring( val = search_string  off = 1 len = strlen( search_string ) - 2  ) .
          search_string = '%' && search_string && '%'.
          search_string = to_upper( search_string ).
          lo_filter = xco_cp_abap_repository=>object_name->get_filter(
                 xco_cp_abap_sql=>constraint->contains_pattern( search_string  )
                  ).
          lt_package = xco_lib->get_packages( VALUE #( ( lo_filter ) ) ).

        ELSE.

          lt_package = xco_lib->get_packages(  ).

        ENDIF.


        LOOP AT lt_package INTO DATA(ls_package).
          business_data_line-name = ls_package->name.
          business_data_line-language_version = abap_language_version.
          APPEND business_data_line TO business_data.
        ENDLOOP.


        IF top IS NOT INITIAL.
          DATA(max_index) = top + skip.
        ELSE.
          max_index = 0.
        ENDIF.

        SELECT * FROM @business_data AS package_names
           WHERE (filter_condition_string)
           INTO TABLE @business_data
           UP TO @max_index ROWS
           .

        IF skip IS NOT INITIAL.
          DELETE business_data TO skip.
        ENDIF.

*          DATA(package_type) = ls_package->read( )-property-package_type->value.
*          IF package_type = ZDMO_cl_rap_node=>package_type-development_package.


        io_response->set_total_number_of_records( lines( business_data ) ).
        io_response->set_data( business_data ).

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
        data(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

         raise EXCEPTION TYPE zdmo_cx_rap_gen_custom_entity
              exporting
                                  textid  = VALUE scx_t100key( msgid = exception_t100_key-msgid
                                                               msgno = exception_t100_key-msgno
                                                               attr1 = exception_t100_key-attr1
                                                               attr2 = exception_t100_key-attr2
                                                               attr3 = exception_t100_key-attr3
                                                               attr4 = exception_t100_key-attr4 )

                                  previous = exception .
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
