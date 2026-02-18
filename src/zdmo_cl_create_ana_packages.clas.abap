CLASS zdmo_cl_create_ana_packages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    METHODS constructor
      IMPORTING i_unique_suffix TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS:
      co_zlocal_package TYPE sxco_package     VALUE 'ZLOCAL',
      co_main_package   TYPE sxco_package     VALUE 'ZDEVELOPER'.

    DATA mo_put_operation           TYPE REF TO if_xco_cp_gen_d_o_put.

    DATA package_name_ana           TYPE sxco_package .
    DATA package_name_colldraft     TYPE sxco_package .
    DATA package_name_draftscope    TYPE sxco_package .
    DATA package_name_treeview      TYPE sxco_package .
    DATA package_name_recomm        TYPE sxco_package .
    DATA package_name_dev           TYPE sxco_package .

    "database tables
    DATA table_name        TYPE sxco_dbt_object_name.

    DATA debug_modus            TYPE abap_bool VALUE abap_true.

    DATA lt_findings   TYPE sxco_t_gen_o_findings.
    DATA finding TYPE REF TO if_xco_gen_o_finding.

    TYPES: BEGIN OF t_table_fields,
             field                  TYPE sxco_ad_field_name,
             is_key                 TYPE abap_bool,
             not_null               TYPE abap_bool,
             currencyCode           TYPE sxco_cds_field_name,
             unitOfMeasure          TYPE sxco_cds_field_name,
             data_element           TYPE sxco_ad_object_name,
             built_in_type          TYPE cl_xco_ad_built_in_type=>tv_type,
             built_in_type_length   TYPE cl_xco_ad_built_in_type=>tv_length,
             built_in_type_decimals TYPE cl_xco_ad_built_in_type=>tv_decimals,
           END OF t_table_fields.

    TYPES: tt_fields TYPE STANDARD TABLE OF t_table_fields WITH KEY field.


    METHODS get_table_fields  RETURNING VALUE(table_fields) TYPE tt_fields.
    METHODS generate_table        IMPORTING io_put_operation        LIKE mo_put_operation "  TYPE REF TO if_xco_gen_o_mass_put
                                            table_fields            TYPE tt_fields
                                            table_name              TYPE sxco_dbt_object_name
                                            table_short_description TYPE if_xco_cp_gen_tabl_dbt_s_form=>tv_short_description.

    METHODS generate_package IMPORTING i_put_operation_for_devc TYPE REF TO if_xco_cp_gen_devc_d_o_put

                                       i_package_name           TYPE sxco_package
                                       i_super_package_name     TYPE sxco_package
                                       i_short_description      TYPE if_xco_cp_gen_devc_s_form=>tv_short_description
                             EXPORTING error_message            TYPE string
                                       findings                 TYPE sxco_t_gen_o_findings.

    METHODS write_findings_and_errors IMPORTING i_out           TYPE REF TO if_oo_adt_classrun_out
                                                i_error_message TYPE string
                                                i_findings      TYPE sxco_t_gen_o_findings.



ENDCLASS.



CLASS zdmo_cl_create_ana_packages IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    debug_modus = abap_true.
    DATA group_number       TYPE numc3.

    DATA number_of_groups   TYPE numc3  VALUE 100.
    DATA group_number_start TYPE numc3  VALUE 200.
    DATA group_number_end   TYPE numc3.
    DATA error_message      TYPE string.

    DATA(lo_main_package) = xco_cp_abap_repository=>object->devc->for( CONV #( co_main_package ) ).

    IF lo_main_package->exists( ) = abap_false.
      out->write( |Main package { co_main_package } does not exist| ).
      RETURN.
    ELSE.
      DATA(main_package) = lo_main_package->read( ).
      DATA(swc) = main_package-property-software_component.
      IF swc->name <> co_zlocal_package.
        out->write( |Main package { co_main_package } is not in software component { co_zlocal_package } | ).
        RETURN.
      ENDIF.
    ENDIF.

    SELECT * FROM /dmo/a_trvl_ana INTO TABLE @DATA(dmo_a_trvl_ana_data).

    DATA casting_table TYPE REF TO data.

    group_number = group_number_start.

    group_number_end = group_number_start + number_of_groups.

    WHILE group_number < group_number_end.

      DATA transport TYPE sxco_transport.
      DATA(environment) = xco_cp_generation=>environment->dev_system( transport ).

      DATA(put_operation_for_devc) = environment->for-devc->create_put_operation( ).
      " TODO: variable is assigned but never used (ABAP cleaner)
      DATA(put_operation_for_devc_main) = environment->for-devc->create_put_operation( ).
      DATA(put_operation_for_devc_ana) = environment->for-devc->create_put_operation( ).
      DATA(put_op_for_devc_colldraft) = environment->for-devc->create_put_operation( ).
      DATA(put_op_for_devc_recomm) = environment->for-devc->create_put_operation( ).
      DATA(put_op_for_devc_treeview) = environment->for-devc->create_put_operation( ).
      DATA(put_op_for_devc_draftscope) = environment->for-devc->create_put_operation( ).

      DATA(lo_objects_put_operation) = environment->create_put_operation( ).

      " set package name

      " Package ZDEVELOPER_### with super package ZLOCAL
      package_name_dev = to_upper( |ZDEVELOPER_{ group_number }| ).
      " Package ZDEVELOPER_ANA_### with super package ZDEVELOPER_###
      package_name_ana = to_upper( |ZDEVELOPER_ANA_{ group_number }| ).
      " Package ZDEVELOPER_COLLDRAFT_### with super package ZDEVELOPER_###
      package_name_colldraft = to_upper( |ZDEVELOPER_COLLDRAFT_{ group_number }| ).
      " Package ZDEVELOPER_DRAFTSCOPE_### with super package ZDEVELOPER_###
      package_name_draftscope = to_upper( |ZDEVELOPER_DRAFTSCOPE_{ group_number }| ).
      " Package ZDEVELOPER_TREEVIEW_### with super package ZDEVELOPER_###
      package_name_treeview   = to_upper( |ZDEVELOPER_TREEVIEW_{ group_number }| ).
      " Package ZDEVELOPER_RECOMM_### with super package ZDEVELOPER_###
      package_name_recomm = to_upper( |ZDEVELOPER_RECOMM_{ group_number }| ).

      generate_package( EXPORTING i_put_operation_for_devc = put_operation_for_devc
                                  i_package_name           = package_name_dev
                                  i_super_package_name     = co_main_package
                                  i_short_description      = |#Generated package group number { group_number }|
                        IMPORTING error_message            = error_message
                                  findings                 = lt_findings ).

      write_findings_and_errors( i_out           = out
                                 i_error_message = error_message
                                 i_findings      = lt_findings ).

      generate_package( EXPORTING i_put_operation_for_devc = put_operation_for_devc_ana
                                  i_package_name           = package_name_ana
                                  i_super_package_name     = package_name_dev
                                  i_short_description      = |#Generated package analytical table { group_number }|
                        IMPORTING error_message            = error_message
                                  findings                 = lt_findings ).

      write_findings_and_errors( i_out           = out
                                 i_error_message = error_message
                                 i_findings      = lt_findings ).

      generate_package( EXPORTING i_put_operation_for_devc = put_op_for_devc_colldraft
                                  i_package_name           = package_name_colldraft
                                  i_super_package_name     = package_name_dev
                                  i_short_description      = |#Generated package Collaborative Draft { group_number }|
                        IMPORTING error_message            = error_message
                                  findings                 = lt_findings ).

      write_findings_and_errors( i_out           = out
                                 i_error_message = error_message
                                 i_findings      = lt_findings ).

      generate_package( EXPORTING i_put_operation_for_devc = put_op_for_devc_draftscope
                                  i_package_name           = package_name_draftscope
                                  i_super_package_name     = package_name_dev
                                  i_short_description      = |#Generated package Draft Scope { group_number }|
                        IMPORTING error_message            = error_message
                                  findings                 = lt_findings ).

      write_findings_and_errors( i_out           = out
                                 i_error_message = error_message
                                 i_findings      = lt_findings ).

      generate_package( EXPORTING i_put_operation_for_devc = put_op_for_devc_recomm
                                  i_package_name           = package_name_recomm
                                  i_super_package_name     = package_name_dev
                                  i_short_description      = |#Generated package Recommendations { group_number }|
                        IMPORTING error_message            = error_message
                                  findings                 = lt_findings ).

      write_findings_and_errors( i_out           = out
                                 i_error_message = error_message
                                 i_findings      = lt_findings ).

      generate_package( EXPORTING i_put_operation_for_devc = put_op_for_devc_treeview
                                  i_package_name           = package_name_treeview
                                  i_super_package_name     = package_name_dev
                                  i_short_description      = |#Generated package Treeview { group_number }|
                        IMPORTING error_message            = error_message
                                  findings                 = lt_findings ).

      write_findings_and_errors( i_out           = out
                                 i_error_message = error_message
                                 i_findings      = lt_findings ).

      " create table
      table_name = to_upper( |zatrvl_ana_{ group_number }| ).

      DATA(lo_table) = xco_cp_abap_repository=>object->tabl->for( CONV #( table_name ) ).

      " TODO: variable is assigned but never used (ABAP cleaner)
      DATA table_exists TYPE abap_bool.

      DATA(table_fields) = get_table_fields( ).

      IF lo_table->exists( io_origin = xco_cp_table=>origin->local( ) )
         = abap_false.

        " generate of travel table
        generate_table( io_put_operation        = lo_objects_put_operation
                        table_fields            = table_fields
                        table_name              = table_name
                        table_short_description = |Travel data { group_number }| ).

        TRY.
            " create the tables
            DATA(lo_result_tab_generation) = lo_objects_put_operation->execute( ).
            IF debug_modus = abap_true.
              out->write( | - Table { table_name } has been created.| ).

              " handle findings
              DATA(lo_result_tab_gen_findings) = lo_result_tab_generation->findings.
              lt_findings = lo_result_tab_gen_findings->get( ).
              IF lt_findings IS NOT INITIAL.
                LOOP AT lt_findings INTO finding.
                  out->write( finding->message->get_text( ) ).
                ENDLOOP.
              ENDIF.
            ENDIF.

          CATCH cx_xco_gen_put_exception INTO DATA(table_exception).
            out->write( cl_message_helper=>get_latest_t100_exception( table_exception )->if_message~get_longtext( ) ).
            DATA(table_findings) = table_exception->findings.
            lt_findings = table_findings->get( ).
            IF lt_findings IS NOT INITIAL.
              LOOP AT lt_findings INTO finding.
                out->write( finding->message->get_text( ) ).
              ENDLOOP.
            ENDIF.
            EXIT.
        ENDTRY.
      ELSE.
        table_exists = abap_true.
        out->write( | - Table { table_name } already exists.| ).

      ENDIF.

      DELETE FROM (table_name).
      COMMIT WORK.

      out->write( |modify { table_name }| ).

      CREATE DATA casting_table TYPE STANDARD TABLE OF (table_name) WITH EMPTY KEY.

      casting_table->* = CORRESPONDING #( dmo_a_trvl_ana_data ).

      " check
      INSERT (table_name) FROM TABLE @casting_table->*.
      COMMIT WORK.

      SELECT COUNT( * ) FROM (table_name) INTO @DATA(num_of_ana_rows).
      out->write( |{ num_of_ana_rows } in table { table_name }| ).

      group_number += 1.

    ENDWHILE.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
  ENDMETHOD.

  METHOD get_table_fields.
    table_fields = VALUE tt_fields(
                  ( field         = 'client'
                    data_element  = 'mandt'
                    is_key        = 'X'
                    not_null      = 'X' )
                  ( field         = 'travel_uuid'
                    data_element  = 'sysuuid_x16'
                    is_key        = 'X'
                    not_null      = 'X' )
                  ( field         = 'travel_id'
                    data_element  = '/dmo/travel_id'
                    not_null      = 'X' )
                  ( field         = 'agency_id'
                    data_element  = '/dmo/agency_id' )
                  ( field         = 'customer_id'
                    data_element  = '/dmo/customer_id' )
                  ( field         = 'begin_date'
                    data_element  = '/dmo/begin_date' )
                  ( field         = 'end_date'
                    data_element  = '/dmo/end_date' )
                  ( field         = 'booking_fee'
                    data_element  = '/dmo/booking_fee'
                    currencycode  = 'currency_code' )
                  ( field         = 'total_price'
                    data_element  = '/dmo/total_price'
                    currencycode  = 'currency_code' )
                  ( field         = 'currency_code'
                    data_element  = '/dmo/currency_code' )
                  ( field         = 'description'
                    data_element  = '/dmo/description' )
                  ( field         = 'overall_status'
                    data_element  = '/dmo/overall_status' )
*                  ( field         = 'attachment'
*                    data_element  = '/dmo/attachment' )
*                  ( field         = 'mime_type'
*                    data_element  = '/dmo/mime_type' )
*                  ( field         = 'file_name'
*                    data_element  = '/dmo/filename' )
                  ( field         = 'local_created_by'
                    data_element  = 'abp_creation_user' )
                  ( field         = 'local_created_at'
                    data_element  = 'abp_creation_tstmpl' )
                  ( field         = 'local_last_changed_by'
                    data_element  = 'abp_locinst_lastchange_user' )
                  ( field         = 'local_last_changed_at'
                    data_element  = 'abp_locinst_lastchange_tstmpl' )
                  ( field         = 'last_changed_at'
                    data_element  = 'abp_lastchange_tstmpl' )
                    ).
  ENDMETHOD.

  METHOD generate_table.
    DATA(lo_specification) = io_put_operation->for-tabl-for-database_table->add_object( table_name
                 )->set_package( package_name_ana
                  )->create_form_specification( ).

    lo_specification->set_short_description( table_short_description ).
    lo_specification->set_data_maintenance( xco_cp_database_table=>data_maintenance->allowed_with_restrictions ).
    lo_specification->set_delivery_class( xco_cp_database_table=>delivery_class->c ).

    DATA database_table_field  TYPE REF TO if_xco_gen_tabl_dbt_s_fo_field  .

    LOOP AT table_fields INTO DATA(table_field_line).
      database_table_field = lo_specification->add_field( table_field_line-field  ).

      IF table_field_line-is_key = abap_true.
        database_table_field->set_key_indicator( ).
      ENDIF.
      IF table_field_line-not_null = abap_true.
        database_table_field->set_not_null( ).
      ENDIF.
      IF table_field_line-currencycode IS NOT INITIAL.
        database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( table_name ) ) )->set_reference_field( to_upper( table_field_line-currencycode ) ).
      ENDIF.
      IF table_field_line-unitofmeasure IS NOT INITIAL.
        database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( table_name ) ) )->set_reference_field( to_upper( table_field_line-unitofmeasure ) ).
      ENDIF.
      IF table_field_line-data_element IS NOT INITIAL.
        database_table_field->set_type( xco_cp_abap_dictionary=>data_element( table_field_line-data_element ) ).
      ELSE.
        CASE  to_lower( table_field_line-built_in_type ).
          WHEN 'accp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->accp ).
          WHEN 'clnt'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->clnt ).
          WHEN 'cuky'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->cuky ).
          WHEN 'dats'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dats ).
          WHEN 'df16_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_raw ).
          WHEN 'df34_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_raw ).
          WHEN 'fltp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->fltp ).
          WHEN 'int1'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int1 ).
          WHEN 'int2'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int2 ).
          WHEN 'int4'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int4 ).
          WHEN 'int8'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int8 ).
          WHEN 'lang'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lang ).
          WHEN 'tims'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->tims ).
          WHEN 'char'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->char( table_field_line-built_in_type_length  ) ).
          WHEN 'curr'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->curr(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'dec'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'df16_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'df34_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'lchr' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lchr( table_field_line-built_in_type_length  ) ).
          WHEN 'lraw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lraw( table_field_line-built_in_type_length  ) ).
          WHEN 'numc'   .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->numc( table_field_line-built_in_type_length  ) ).
          WHEN 'quan' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->quan(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                              ) ).
          WHEN 'raw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->raw( table_field_line-built_in_type_length  ) ).
          WHEN 'rawstring'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->rawstring( table_field_line-built_in_type_length  ) ).
          WHEN 'sstring' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->sstring( table_field_line-built_in_type_length  ) ).
          WHEN 'string' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->string( table_field_line-built_in_type_length  ) ).
          WHEN 'unit'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->unit( table_field_line-built_in_type_length  ) ).
          WHEN OTHERS.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->for(
                                              iv_type     = to_upper( table_field_line-built_in_type )
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD generate_package.

    DATA(package)           = xco_cp_abap_repository=>object->devc->for(  i_package_name  ).
    DATA(put_operation_for_devc) = i_put_operation_for_devc.

    IF package->exists(  ) = abap_false.
      TRY.
          DATA(specification_for_devc) = put_operation_for_devc->add_object( i_package_name )->create_form_specification( ).
          specification_for_devc->set_short_description( i_short_description ).
          specification_for_devc->properties->set_super_package( i_super_package_name )->set_software_component( co_zlocal_package ).
          DATA(result_put_operation) = put_operation_for_devc->execute( ).
          lt_findings = result_put_operation->findings->get(  ).
        CATCH cx_xco_gen_put_exception INTO DATA(package_exception).
          error_message = cl_message_helper=>get_latest_t100_exception( package_exception )->if_message~get_longtext( ) .
          lt_findings = package_exception->findings->get( ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD write_findings_and_errors.
    IF i_error_message IS NOT INITIAL.
      i_out->write( i_error_message ).
    ENDIF.

    IF i_findings IS NOT INITIAL.
      LOOP AT i_findings INTO DATA(i_finding).
        i_out->write( i_finding->message->get_text(  ) ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
