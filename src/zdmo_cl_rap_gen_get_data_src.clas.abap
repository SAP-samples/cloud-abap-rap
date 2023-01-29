CLASS zdmo_cl_rap_gen_get_data_src DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_GET_DATA_SRC IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA business_data TYPE TABLE OF ZDMO_i_rap_generator_data_src .
    DATA business_data_line TYPE ZDMO_i_rap_generator_data_src .
    DATA xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.
    DATA lt_cds_views TYPE sxco_t_data_definitions .
    DATA lt_tables TYPE sxco_t_database_tables .
    DATA lt_structures TYPE sxco_t_ad_structures  .

    TRY.
        DATA(top)     = io_request->get_paging( )->get_page_size( ).
        DATA(skip)    = io_request->get_paging( )->get_offset( ).
        DATA(requested_fields)  = io_request->get_requested_elements( ).
        DATA(sort_order)    = io_request->get_sort_elements( ).
        DATA(filter_condition_string) = io_request->get_filter( )->get_as_sql_string( ).
        DATA(filter_condition_ranges) = io_request->get_filter( )->get_as_ranges(  ).
        DATA(search_string) = to_upper( io_request->get_search_expression( ) ).

        READ TABLE filter_condition_ranges WITH KEY name = 'LANGUAGE_VERSION'
           INTO DATA(filter_condition_language).

        IF filter_condition_language IS NOT INITIAL.
          DATA(abap_language_version) = filter_condition_language-range[ 1 ]-low.
        ENDIF.

        READ TABLE filter_condition_ranges WITH KEY name = 'PARENT_DATA_SOURCE'
              INTO DATA(filter_condition_par_dat_src).

        IF filter_condition_par_dat_src IS NOT INITIAL.
          DATA(parent_data_source) = filter_condition_par_dat_src-range[ 1 ]-low.
        ENDIF.

        READ TABLE filter_condition_ranges WITH KEY name = 'IS_ROOT_NODE'
               INTO DATA(filter_condition_is_root_node).

        IF filter_condition_is_root_node IS NOT INITIAL.
          DATA(is_root_node) = filter_condition_is_root_node-range[ 1 ]-low.
        ENDIF.

        IF abap_language_version =  ZDMO_cl_rap_node=>abap_language_version-standard .
          xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).
        ELSE.
          xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
        ENDIF.

        READ TABLE filter_condition_ranges WITH KEY name = 'TYPE'
             INTO DATA(filter_condition_type).

        IF filter_condition_type IS NOT INITIAL.
          DATA(data_source_type) = filter_condition_type-range[ 1 ]-low.
        ENDIF.

        READ TABLE filter_condition_ranges WITH KEY name = 'PACKAGE_NAME'
             INTO DATA(filter_condition_package_name).

        "if no package name is provided no data can be returned.
        IF filter_condition_package_name IS INITIAL.
          CLEAR business_data.
          io_response->set_total_number_of_records( lines( business_data ) ).
          io_response->set_data( business_data ).
          EXIT.
        ELSE.
          DATA(package_name) = filter_condition_package_name-range[ 1 ]-low.
        ENDIF.

        "if data source is a CDS view we can simply show those views that can be reached via association / composition

        IF is_root_node <> abap_true AND
           parent_data_source IS NOT INITIAL AND
           ( data_source_type = ZDMO_cl_rap_node=>data_source_types-cds_view or
             data_source_type = ZDMO_cl_rap_node=>data_source_types-abstract_entity ).

                    data(my_node) = NEW ZDMO_cl_rap_node( xco_lib ).
            my_node->set_data_source_type( data_source_type ).
            my_node->set_data_source( parent_data_source ).

            IF my_node IS NOT INITIAL.
              LOOP AT my_node->composition_targets INTO DATA(composition_target).
                business_data_line-name = composition_target.

                business_data_line-package_name = package_name.
                business_data_line-language_version = abap_language_version.
                business_data_line-type = data_source_type .
                business_data_line-is_root_node = is_root_node.
                business_data_line-parent_data_source = parent_data_source.
                APPEND business_data_line TO business_data.
              ENDLOOP.
              LOOP AT my_node->association_targets INTO DATA(association_target).
                business_data_line-name = association_target.
                business_data_line-package_name = package_name.
                business_data_line-language_version = abap_language_version.
                business_data_line-type = data_source_type .
                business_data_line-is_root_node = is_root_node.
                business_data_line-parent_data_source = parent_data_source.
                APPEND business_data_line TO business_data.
              ENDLOOP.
            ENDIF.
            io_response->set_total_number_of_records( lines( business_data ) ).
            io_response->set_data( business_data ).
            EXIT.
          ENDIF.

        "start search only if more than minimal_search_string_length characters are provided

        "search string also contains a leading and a trailing quotation mark
        DATA(length_of_search_string) = numofchar( search_string ) - 2.

        IF length_of_search_string < ZDMO_cl_rap_node=>minimal_search_string_length.
          CLEAR business_data.
          io_response->set_total_number_of_records( lines( business_data ) ).
          io_response->set_data( business_data ).
          EXIT.
        ENDIF.



        DATA(package) = xco_lib->get_package( CONV  sxco_package( package_name ) ).
        DATA(package_properties) = package->read(  )-property.
        DATA(software_component) = package_properties-software_component->name.
        DATA(package_abap_language_version) = xco_lib->get_abap_language_version( package->name ).

        "In an on premise system it is possible to select data sources from other software components
        "if the package is using ABAP language version "standard"
        "
        "If the package uses language version 5 (abap_for_cloud_development) only data sources from the same software component
        "or C1 released CDS views may be used

        IF package_abap_language_version = ZDMO_cl_rap_node=>package_abap_language_version-standard.
          DATA(software_component_filter) = xco_cp_system=>software_component->get_filter( xco_cp_abap_sql=>constraint->contains_pattern( '%' ) ) .
        ELSE.


*   " Get all data elements in package S_XCO_HOME_DEMO.
*   DATA(lt_data_elements) = xco_abap_repository=>objects->dtel->all->in( lo_package )->get( ).
*   When a package with language version 5 is used in an on premise system without
*   customer software components you run into the problem that tables might use
*   data elements that must not be used in your package.
*   hence the genration fails.
*   Workaround: If package has language version 5 and and on prem system < 2022 is used
*   take only data sources from the same package.

          DATA(filter_1) = xco_cp_system=>software_component->get_filter( xco_cp_abap_sql=>constraint->equal( software_component ) ) .
          "used to avoid replacement of string slashDMOslash
          "when moving from namespace slashDMOslash to zetDMOunderscore
          DATA(filter_2) = xco_cp_system=>software_component->get_filter( xco_cp_abap_sql=>constraint->equal( '/' && 'DMO' && '/' && 'SAP' ) ) .

          IF software_component = 'ZLOCAL'.
            software_component_filter = xco_cp_abap_repository=>filter->union( it_filters = VALUE #( ( filter_1 ) ( filter_2 ) ) ).
          ELSE.
            software_component_filter = filter_1.
          ENDIF.


        ENDIF.





        READ TABLE filter_condition_ranges WITH KEY name = 'NAME'
              INTO DATA(filter_condition_name).

        "check if data_source_type is cds_view (abstract entity) and if we are dealing with a child node
        "in this case the value help shall only offer cds views (or abstract entities) that can be reached
        "via association / composition of the cds view that is used as a data source of the parent entity.




        IF filter_condition_name IS NOT INITIAL.
          LOOP AT filter_condition_name-range INTO DATA(range).
            REPLACE ALL OCCURRENCES OF '*' IN range-low WITH '%'.
            DATA(lo_name_filter) = xco_cp_abap_repository=>object_name->get_filter(
              xco_cp_abap_sql=>constraint->contains_pattern( range-low )
               ).
            CASE  data_source_type.
              WHEN ZDMO_cl_rap_node=>data_source_types-cds_view.
                DATA(lt_cds_views_add) = xco_lib->get_views( VALUE #(
                                            ( lo_name_filter )
                                            ( software_component_filter )
                                            ) ).
                APPEND LINES OF lt_cds_views_add TO lt_cds_views.
              WHEN ZDMO_cl_rap_node=>data_source_types-table.
                DATA(lt_tables_add) = xco_lib->get_tables( VALUE #(
                                            ( lo_name_filter )
                                            ( software_component_filter )
                                            ) ).
                APPEND LINES OF lt_tables_add TO lt_tables.
              WHEN ZDMO_cl_rap_node=>data_source_types-structure.
                DATA(lt_structures_add) = xco_lib->get_structures(  VALUE #(
                                            ( lo_name_filter )
                                            ( software_component_filter )
                                            )  ).
                APPEND LINES OF lt_structures_add TO lt_structures.
            ENDCASE.
          ENDLOOP.

        ENDIF.

        IF search_string IS NOT INITIAL.
          search_string = substring( val = search_string  off = 1 len = strlen( search_string ) - 2  ) .
          search_string = '%' && search_string && '%'.
          "search_string = to_upper( search_string ).
          lo_name_filter = xco_cp_abap_repository=>object_name->get_filter(
                 xco_cp_abap_sql=>constraint->contains_pattern( search_string  )
                  ).
          CASE  data_source_type.
            WHEN ZDMO_cl_rap_node=>data_source_types-cds_view OR ZDMO_cl_rap_node=>data_source_types-abstract_entity.
              "lt_cds_views = xco_cp_abap_repository=>objects->ddls->all->in( xco_cp_abap=>repository )->get( ).
              lt_cds_views = xco_lib->get_views( VALUE #(
                                            ( lo_name_filter )
                                            ( software_component_filter )
                                            ) ).
            WHEN ZDMO_cl_rap_node=>data_source_types-table.
              "lt_tables = xco_cp_abap_repository=>objects->tabl->database_tables->all->in( xco_cp_abap=>repository )->get( ).
              lt_tables = xco_lib->get_tables( VALUE #(
                                            ( lo_name_filter )
                                            ( software_component_filter )
                                            ) ).
            WHEN ZDMO_cl_rap_node=>data_source_types-structure.
              "lt_structures = xco_cp_abap_repository=>objects->tabl->structures->all->in( xco_cp_abap=>repository )->get( ).
              lt_structures = xco_lib->get_structures( VALUE #(
                                            ( lo_name_filter )
                                            ( software_component_filter )
                                            ) ).
          ENDCASE.



*            CASE  filter_condition_Type-range[ 1 ]-low.
*              WHEN ZDMO_cl_rap_node=>data_source_types-cds_view.
*                "lt_cds_views = xco_cp_abap_repository=>objects->ddls->all->in( xco_cp_abap=>repository )->get( ).
*                lt_cds_views = xco_lib->get_views( lo_filter ).
*              WHEN ZDMO_cl_rap_node=>data_source_types-table.
*                "lt_tables = xco_cp_abap_repository=>objects->tabl->database_tables->all->in( xco_cp_abap=>repository )->get( ).
*                lt_tables = xco_lib->get_tables( ).
*              WHEN ZDMO_cl_rap_node=>data_source_types-structure.
*                "lt_structures = xco_cp_abap_repository=>objects->tabl->structures->all->in( xco_cp_abap=>repository )->get( ).
*                lt_structures = xco_lib->get_structures( ).
*            ENDCASE.

        ENDIF.

        "todo: select




        CASE  data_source_type.
          WHEN ZDMO_cl_rap_node=>data_source_types-cds_view OR ZDMO_cl_rap_node=>data_source_types-abstract_entity .
            "first add cds views from software component
            LOOP AT lt_cds_views INTO DATA(ls_cds_view).
              DATA(view_type) = ls_cds_view->get_type( ).
              IF view_type = xco_cp_data_definition=>type->view_entity OR
                 view_type = xco_cp_data_definition=>type->view OR
                 view_type = xco_cp_data_definition=>type->abstract_entity.
                business_data_line-package_name = package_name.
                business_data_line-name = ls_cds_view->name.
                business_data_line-language_version = abap_language_version.
                business_data_line-type = data_source_type .
                business_data_line-is_root_node = is_root_node.
                business_data_line-parent_data_source = parent_data_source.
                APPEND business_data_line TO business_data.
              ENDIF.
            ENDLOOP.

            "get c1-released cds views
            SELECT * FROM i_apisforclouddevelopment
                                    WHERE objectdirectorytype = 'DDLS' AND
                                          releasedobjectname LIKE @search_string
                                    INTO TABLE @DATA(released_cds_views).

            LOOP AT released_cds_views INTO DATA(released_cds_view).
              DATA(lo_data_definition) = xco_lib->get_data_definition( CONV #( released_cds_view-releasedobjectname ) ).
              view_type = lo_data_definition->get_type( ).

              IF view_type = xco_cp_data_definition=>type->view_entity OR
                           view_type = xco_cp_data_definition=>type->view OR
                           view_type = xco_cp_data_definition=>type->abstract_entity.
                business_data_line-package_name = package_name.
                business_data_line-name = released_cds_view-releasedobjectname.
                business_data_line-language_version = abap_language_version.
                business_data_line-type = data_source_type .
                business_data_line-is_root_node = is_root_node.
                business_data_line-parent_data_source = parent_data_source.
                APPEND business_data_line TO business_data.
              ENDIF.
            ENDLOOP.

          WHEN ZDMO_cl_rap_node=>data_source_types-table.
            LOOP AT lt_tables INTO DATA(ls_table).
              business_data_line-package_name = package_name.
              business_data_line-name = ls_table->name.
              business_data_line-language_version = abap_language_version.
              business_data_line-type = data_source_type .
              business_data_line-is_root_node = is_root_node.
              business_data_line-parent_data_source = parent_data_source.
              APPEND business_data_line TO business_data.
            ENDLOOP.
          WHEN ZDMO_cl_rap_node=>data_source_types-structure.
            LOOP AT lt_structures INTO DATA(ls_structure).
              business_data_line-package_name = package_name.
              business_data_line-name = ls_structure->name.
              business_data_line-language_version = abap_language_version.
              business_data_line-type = data_source_type .
              business_data_line-is_root_node = is_root_node.
              business_data_line-parent_data_source = parent_data_source.
              APPEND business_data_line TO business_data.
            ENDLOOP.
        ENDCASE.






        IF top IS NOT INITIAL.
          DATA(max_index) = top + skip.
        ELSE.
          max_index = 0.
        ENDIF.

        SELECT * FROM @business_data AS datasource_names
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
