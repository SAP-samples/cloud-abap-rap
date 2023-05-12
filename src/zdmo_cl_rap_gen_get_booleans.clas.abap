CLASS zdmo_cl_rap_gen_get_booleans DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_GET_BOOLEANS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA business_data TYPE TABLE OF ZDMO_i_rap_generator_bool_vh.
    DATA business_data_line TYPE ZDMO_i_rap_generator_bool_vh .
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).

    TRY.
        DATA(filter_condition) = io_request->get_filter( )->get_as_sql_string( ).

        business_data_line-bool_value = abap_false.
        business_data_line-name = 'No'.
        APPEND business_data_line TO business_data.
        business_data_line-bool_value = abap_true.
        business_data_line-name = 'Yes'.
        APPEND business_data_line TO business_data.

        SELECT * FROM @business_data AS implementation_types
              WHERE (filter_condition) INTO TABLE @business_data.

        io_response->set_total_number_of_records( lines( business_data ) ).
        io_response->set_data( business_data ).

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zdmo_cx_rap_gen_custom_entity
          EXPORTING
            textid   = VALUE scx_t100key( msgid = exception_t100_key-msgid
                                          msgno = exception_t100_key-msgno
                                          attr1 = exception_t100_key-attr1
                                          attr2 = exception_t100_key-attr2
                                          attr3 = exception_t100_key-attr3
                                          attr4 = exception_t100_key-attr4 )
            previous = exception.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
