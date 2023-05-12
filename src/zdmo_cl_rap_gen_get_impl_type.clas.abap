CLASS zdmo_cl_rap_gen_get_impl_type DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_GET_IMPL_TYPE IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA business_data TYPE TABLE OF ZDMO_i_rap_generator_impl_type .
    DATA business_data_line TYPE ZDMO_i_rap_generator_impl_type .
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).

    TRY.
        DATA(filter_condition) = io_request->get_filter( )->get_as_sql_string( ).




        DATA type_definition LIKE ZDMO_cl_rap_node=>implementation_type.
        DATA(descr_ref_type) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( type_definition ) ) ).
        DATA(components) = descr_ref_type->get_components(  ).
        LOOP AT components INTO DATA(line).
        data(implementation_type) = to_lower( line-name ).
          CASE implementation_type.
            WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.
              APPEND ZDMO_cl_rap_node=>implementation_type-managed_uuid TO business_data.
            WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic.
              APPEND ZDMO_cl_rap_node=>implementation_type-managed_semantic TO business_data.
            WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
              APPEND ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic TO business_data.
            WHEN OTHERS.
              RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
                EXPORTING
                  textid   = ZDMO_cx_rap_generator=>implementation_type_not_valid
                  mv_value = CONV #( line-name ).
          ENDCASE.

*          append ZDMO_cl_rap_node=>implementation_type- (line-name) to business_data.
        ENDLOOP.
        SELECT * FROM @business_data AS implementation_types
              WHERE (filter_condition) INTO TABLE @business_data
               "UP TO @top ROWS
               .

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
