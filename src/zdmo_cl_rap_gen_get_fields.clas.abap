CLASS zdmo_cl_rap_gen_get_fields DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_GET_FIELDS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA business_data TYPE TABLE OF ZDMO_i_rap_generator_fields .
    DATA business_data_line TYPE ZDMO_i_rap_generator_fields .
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).
    DATA xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.
    TRY.
        DATA(filter_condition_string) = io_request->get_filter( )->get_as_sql_string( ).
        DATA(filter_condition_ranges) = io_request->get_filter( )->get_as_ranges(  ).

        READ TABLE filter_condition_ranges WITH KEY name = 'LANGUAGE_VERSION'
               INTO DATA(filter_condition_language).

        IF filter_condition_language IS NOT INITIAL.
          DATA(abap_language_Version) = filter_condition_language-range[ 1 ]-low.
        ENDIF.


        IF abap_language_version =  ZDMO_cl_rap_node=>abap_language_version-standard." abap_language_version-standard .
          xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).
        ELSE.
          xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
        ENDIF.

        READ TABLE filter_condition_ranges WITH KEY name = 'TYPE'
        INTO DATA(filter_condition_type).

        READ TABLE filter_condition_ranges WITH KEY name = 'NAME'
            INTO DATA(filter_condition_name).
        IF filter_condition_name IS NOT INITIAL and
           filter_condition_type is not initial.
          DATA test_node TYPE REF TO ZDMO_cl_rap_node.
          test_node = NEW ZDMO_cl_rap_node(  ).
          test_node->set_xco_lib( xco_lib ).

          test_node->set_data_source_type( filter_condition_Type-range[ 1 ]-low ).
          test_node->set_data_source( filter_condition_name-range[ 1 ]-low ).

          "test_node->get_fields(  ).

          business_data_line-name = filter_condition_name-range[ 1 ]-low .
          business_data_line-type = filter_condition_Type-range[ 1 ]-low.

          DATA(check_fields) = test_node->lt_fields.

          LOOP AT test_node->lt_fields INTO DATA(ls_fields).
            business_data_line-language_version = abap_language_Version.
            business_data_line-field = ls_fields-name.
            business_data_line-data_element = ls_fields-data_element.
            business_data_line-built_in_type  = ls_fields-built_in_type        .
            business_data_line-built_in_type_length  = ls_fields-built_in_type_length .
            business_data_line-built_in_type_decimals = ls_fields-built_in_type_decimals .

            APPEND business_data_line TO business_Data.
          ENDLOOP.
        ENDIF.

*        SELECT * FROM @business_data AS data_source_fields
*  WHERE (filter_condition_string)
*  "order by (sort_order)
*  INTO TABLE @business_data
*  UP TO @top ROWS.

        IF top IS NOT INITIAL.
          DATA(max_index) = top + skip.
        ELSE.
          max_index = 0.
        ENDIF.

        SELECT * FROM @business_data AS data_source_fields
           WHERE (filter_condition_string)
           INTO TABLE @business_data
           UP TO @max_index ROWS
           .

        IF skip IS NOT INITIAL.
          DELETE business_data TO skip.
        ENDIF.



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
