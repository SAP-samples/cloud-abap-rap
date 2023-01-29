CLASS zdmo_cl_rap_gen_get_abap_vers DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_GET_ABAP_VERS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA business_data TYPE TABLE OF ZDMO_i_rap_generator_abap_vers .
    DATA business_data_line TYPE ZDMO_i_rap_generator_abap_Vers .
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).

"check if packages exist that are part of customer software component
select *  from I_CustABAPPackage into table @data(customer_packages_in_swc).

data(xco_on_prem_lib) = new ZDMO_cl_rap_xco_on_prem_lib(  ).


    TRY.
        DATA(filter_condition) = io_request->get_filter( )->get_as_sql_string( ).



        DATA type_definition LIKE ZDMO_cl_rap_node=>abap_language_version.
        DATA(descr_ref_type) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( type_definition ) ) ).
        DATA(components) = descr_ref_type->get_components(  ).
        LOOP AT components INTO DATA(line).

          CASE to_lower( line-name ).
            WHEN ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development .
              if customer_packages_in_swc is not initial.
                business_data_line-language_version = ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development.
              endif.
            WHEN ZDMO_cl_rap_node=>abap_language_version-standard.
              "in the on premise branch this method returns abap_true
              if xco_on_prem_lib->on_premise_branch_is_used(  ) = abap_true.
                business_data_line = ZDMO_cl_rap_node=>abap_language_version-standard.
              endif.
            WHEN OTHERS.
              "@todo(  ).
          ENDCASE.
          APPEND business_data_line TO business_data.
        ENDLOOP.
        SELECT * FROM @business_data AS binding_types
              WHERE (filter_condition) INTO TABLE @business_data.

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
