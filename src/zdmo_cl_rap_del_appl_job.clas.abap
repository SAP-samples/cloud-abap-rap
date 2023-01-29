CLASS zdmo_cl_rap_del_appl_job DEFINITION
INHERITING FROM zdmo_cl_rap_generator_base
  PUBLIC  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES: if_oo_adt_classrun,
      if_apj_rt_exec_object,
      if_apj_dt_exec_object.
    METHODS constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.

**********************************************************************
    DATA delete_objects_in_package TYPE sxco_package.
    DATA demo_mode TYPE abap_boolean VALUE abap_false.
**********************************************************************

    DATA on_prem_xco_lib TYPE REF TO zdmo_cl_rap_xco_lib.

    DATA test_bo_name TYPE zdmo_r_rapgeneratorbo-BoName VALUE 'ZR_SalesOrderTP_AF2'.
    DATA perform_srvb_is_active_check TYPE abap_bool VALUE abap_false.

    "run in background Y/N?
*    DATA run_in_background TYPE abap_bool VALUE abap_true.
    DATA run_in_background TYPE abap_bool VALUE abap_false.

    "run in foreground Y/N?
    DATA run_in_foreground TYPE abap_bool VALUE abap_true.
*    DATA run_in_foreground TYPE abap_bool VALUE abap_false.

    DATA xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.
    DATA generated_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    DATA generated_repository_object TYPE zdmo_cl_rap_generator=>t_generated_repository_object.

    DATA out TYPE REF TO if_oo_adt_classrun_out.
    DATA application_log TYPE REF TO if_bali_log .
    METHODS generated_objects_are_deleted
      IMPORTING
*               i_rap_bo_name                      TYPE sxco_ar_object_name
                i_repository_objects               TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
      EXPORTING r_existing_repository_objects      TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
      RETURNING VALUE(r_objects_have_been_deleted) TYPE abap_bool.

    METHODS get_root_exception
      IMPORTING !ix_exception  TYPE REF TO cx_root
      RETURNING VALUE(rx_root) TYPE REF TO cx_root .
    METHODS add_findings_to_output
      IMPORTING i_findings TYPE REF TO if_xco_gen_o_findings
      RAISING   cx_bali_runtime .
    METHODS add_text_to_app_log_or_console
      IMPORTING i_text     TYPE cl_bali_free_text_setter=>ty_text
                i_severity TYPE cl_bali_free_text_setter=>ty_severity DEFAULT if_bali_constants=>c_severity_status
      RAISING   cx_bali_runtime.
    METHODS get_objects_from_package
      IMPORTING i_package                   TYPE sxco_package
      RETURNING VALUE(r_repository_objects) TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    METHODS get_objects_from_rap_generator
      IMPORTING i_rap_bo_name               TYPE sxco_ar_object_name
      RETURNING VALUE(r_repository_objects) TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    METHODS delete_generated_objects
      IMPORTING i_rap_bo_name        TYPE sxco_ar_object_name
                i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    METHODS get_locking_transport
      IMPORTING i_object_type      TYPE if_xco_gen_o_finding=>tv_object_type
                i_object_name      TYPE if_xco_gen_o_finding=>tv_object_name
      RETURNING VALUE(r_transport) TYPE sxco_transport.
    METHODS service_binding_is_published
      IMPORTING i_object_name         TYPE if_xco_gen_o_finding=>tv_object_name
      RETURNING VALUE(r_is_published) TYPE abap_bool.
    METHODS create_application_log.
    METHODS save_log_handle
      IMPORTING i_rap_bo_name       TYPE sxco_ar_object_name
      RETURNING VALUE(r_log_handle) TYPE if_bali_log=>ty_handle.

    METHODS delete_service_bindings
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS delete_service_definitions
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS delete_behavior_definitions
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS delete_metadata_extensions
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS delete_cds_views
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS delete_classes
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS delete_draft_tables
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS delete_structures
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
      RAISING   cx_bali_runtime.
    METHODS Delete_RAP_Generator_Project
      IMPORTING
        i_rap_bo_name TYPE sxco_ar_object_name
      RAISING
        cx_bali_runtime.
ENDCLASS.



CLASS ZDMO_CL_RAP_DEL_APPL_JOB IMPLEMENTATION.


  METHOD add_findings_to_output.
    DATA text TYPE c LENGTH 200 .
    DATA(finding_texts) = i_findings->get( ).
    IF finding_texts IS NOT INITIAL.
      LOOP AT finding_texts INTO DATA(finding_text).
        text = |{ finding_text->object_type } { finding_text->object_name } { finding_text->message->get_text(  ) }|.
        add_text_to_app_log_or_console(
          i_text     = text
          i_severity = finding_text->message->value-msgty
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD add_text_to_app_log_or_console.

    DATA(application_log_free_text) = cl_bali_free_text_setter=>create(
      severity = i_severity " if_bali_constants=>c_severity_status
      text     = i_text ).
    application_log_free_text->set_detail_level( detail_level = '1' ).
    application_log->add_item( item = application_log_free_text ).
    cl_bali_log_db=>get_instance( )->save_log(
                                               log = application_log
                                               assign_to_current_appl_job = abap_true
                                               ).
*    ELSE.
    IF sy-batch = abap_false.
      out->write( |{ i_severity }:{ i_text }| ).
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).
*    "check if we run in abap language version standard
    on_prem_xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.

    create_application_log(  ).
  ENDMETHOD.


  METHOD create_application_log.
*    DATA(on_prem_xco_lib) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    TRY.
        IF on_prem_xco_lib->on_premise_branch_is_used(  ).
          application_log = cl_bali_log=>create_with_header(
                          header = cl_bali_header_setter=>create( object = 'XCO_DEMO'
                                                                  subobject = 'DEMO'
                                                                  external_id = 'External ID' ) )..
        ELSE.
          application_log = cl_bali_log=>create_with_header(
                          header = cl_bali_header_setter=>create( object = zdmo_cl_rap_node=>application_log_object_name
                                                                  subobject = zdmo_cl_rap_node=>application_log_sub_obj1_name
                                                                  external_id = 'External ID' ) ).
        ENDIF.

      CATCH cx_bali_runtime INTO DATA(application_log_exception).

        DATA(bali_log_exception) = application_log_exception->get_text(  ).

        RAISE EXCEPTION TYPE cx_apj_rt_content
          EXPORTING
            previous = application_log_exception.

    ENDTRY.
  ENDMETHOD.


  METHOD delete_behavior_definitions.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>root_node_object_types-behavior_definition_r.
    DATA object_name TYPE sxco_cds_object_name.
    DATA(delete_operation) = mo_environment->for-bdef->create_delete_operation( ).
    "end change
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( object_name ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD delete_cds_views.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>node_object_types-cds_view_r.
    DATA object_name TYPE sxco_cds_object_name.
    DATA(delete_operation) = mo_environment->for-ddls->create_delete_operation( ).
    "end change
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( object_name ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD delete_classes.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>node_object_types-behavior_implementation.
    DATA object_name TYPE sxco_ad_object_name.
    DATA(delete_operation) = mo_environment->for-clas->create_delete_operation( ).
    "end change
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( object_name ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD delete_draft_tables.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>node_object_types-draft_table.
    DATA object_name TYPE sxco_dbt_object_name .
    DATA(delete_operation) = mo_environment->for-tabl-for-database_table->create_delete_operation( ).
    "end change
    add_text_to_app_log_or_console( |Delete operation - warnings were raised.| ).
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( CONV #( object_name ) ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD delete_generated_objects.

    DATA transport_request TYPE sxco_transport.
    DATA transport_requests TYPE STANDARD TABLE OF sxco_transport.

    DATA repository_objects_in_transprt TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .

    DATA text  TYPE cl_bali_free_text_setter=>ty_text  .

    LOOP AT i_repository_objects INTO DATA(repository_object).
      transport_request = repository_object-transport_request.
*      IF transport_request IS NOT INITIAL.
      COLLECT transport_request INTO transport_requests.
*      ENDIF.
    ENDLOOP.

*    DATA(rap_bo_name_in_upper_case) = to_upper( i_rap_bo_name ).
*    SELECT SINGLE  ABAPPackage FROM I_CustABAPObjDirectoryEntry
*    WHERE ABAPObject = @rap_bo_name_in_upper_case
*      AND ABAPObjectType = @zdmo_cl_rap_node=>root_node_object_types-behavior_definition_r
*    INTO @DATA(package).

    SELECT SINGLE * FROM ZDMO_R_RapGeneratorBO WHERE BoName = @i_rap_bo_name
                                               INTO @DATA(rap_bo_header_data).

    SELECT SINGLE * FROM ZDMO_R_RapGeneratorBONode WHERE HeaderUUID = @rap_bo_header_data-RapNodeUUID
                                                     INTO @DATA(rap_bo_root_node_data).

    DATA(my_bdef) = xco_lib->get_behavior_definition( CONV sxco_cds_object_name( rap_bo_header_data-BoName ) ).
    DATA(my_srvb) = xco_lib->get_service_binding( CONV sxco_srvb_object_name( rap_bo_root_node_data-ServiceBinding ) ).

    "@todo - add more checks
    IF my_srvb->if_xco_ar_object~exists(  ).
      DATA(package) = my_srvb->content(  )->service_binding->if_xco_ar_object~get_package(  )->name.
    ELSEIF my_bdef->if_xco_ar_object~exists( ).
      package = my_bdef->content(  )->behavior_definition->if_xco_ar_object~get_package(  )->name.
    ENDIF.

*    IF lines( transport_requests ) > 1.
*
*      "if several transport requests are used take the first one and delete related objects
*      "deletion has to be run several times until all objects have been deleted.
*
*      transport_request = transport_requests[ 1 ] .
*
*    ELSEIF lines( transport_requests ) = 1.
*
*      transport_request = transport_requests[ 1 ] .
*
*    ELSE.

    IF delete_objects_in_package IS NOT INITIAL.
      package = delete_objects_in_package.
    ENDIF.
    IF xco_lib->get_package( package )->exists( ) = abap_true.
      DATA(package_records_changes) = xco_lib->get_package( package )->read( )-property-record_object_changes.
    ELSE.
      add_text_to_app_log_or_console( |Package { package } does not exist.| ).
      EXIT.
    ENDIF.

    "generate a new transport request
    IF package_records_changes = abap_true.
      DATA(lo_transport_target) = xco_lib->get_package( package
                )->read( )-property-transport_layer->get_transport_target( ).
      DATA(new_transport_object) = xco_cp_cts=>transports->workbench( lo_transport_target->value )->create_request( |Delete RAP Business object - entity name: { i_rap_bo_name } | ).
      DATA(new_transport_request) = new_transport_object->value.
    ENDIF.

    LOOP AT transport_requests INTO transport_request.

      DATA(transport_request_used) = transport_request.

      CLEAR repository_objects_in_transprt.

      LOOP AT i_repository_objects INTO DATA(repository_object_in_transport) WHERE transport_request = transport_request_used.
        APPEND repository_object_in_transport TO repository_objects_in_transprt.
      ENDLOOP.

      IF transport_request_used = ''.
        transport_request_used = new_transport_request.
      ENDIF.

      add_text_to_app_log_or_console( |Use transport request { transport_request_used }| ).

*    DATA(mo_environment) = xco_cp_generation=>environment->dev_system( transport_request )  .

********************************************************************************
      "cloud
      mo_environment = get_environment( transport_request_used ) .

*    mo_environment = xco_cp_generation=>environment->dev_system( transport_request )  .
********************************************************************************

**********************************************************************
      "on premise
*    IF xco_lib->get_package( package  )->read( )-property-record_object_changes = abap_true.
*      mo_environment = xco_generation=>environment->transported( transport_request ).
*    ELSE.
*      mo_environment = xco_generation=>environment->local.
*    ENDIF.
**********************************************************************

      delete_service_bindings( repository_objects_in_transprt ).
      delete_service_definitions( repository_objects_in_transprt ).
      delete_behavior_definitions( repository_objects_in_transprt ).
      delete_metadata_extensions( repository_objects_in_transprt ).
      delete_cds_views( repository_objects_in_transprt ).
      delete_classes( repository_objects_in_transprt ).
      "the tables that are used as a data source will not be deleted since they have not been generated
      delete_draft_tables( repository_objects_in_transprt ).
      delete_structures( repository_objects_in_transprt ).

    ENDLOOP.

  ENDMETHOD.


  METHOD delete_metadata_extensions.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>node_object_types-meta_data_extension.
    DATA object_name TYPE sxco_cds_object_name.
    DATA(delete_operation) = mo_environment->for-ddlx->create_delete_operation( ).
    "end change
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( object_name ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD Delete_RAP_Generator_Project.

    DATA text TYPE cl_bali_free_text_setter=>ty_text.

    DATA delete_child_keys TYPE TABLE FOR DELETE ZDMO_R_RapGeneratorBONode.
    DATA delete_child_key TYPE STRUCTURE FOR DELETE ZDMO_R_RapGeneratorBONode.

    add_text_to_app_log_or_console(
      i_text     = |generated repository objects of { i_rap_bo_name } have been deleted. Delete data in RAP Generator.|
      i_severity = 'S'
    ).

    SELECT SINGLE rapnodeuuid FROM zdmo_r_rapgeneratorbo WHERE BoName = @i_rap_bo_name
                                                  INTO @DATA(rapnodeuuid).
    SELECT * FROM zdmo_r_rapgeneratorbonode WHERE HeaderUUID = @rapnodeuuid
                                             INTO TABLE @DATA(rapbo_childs).

    LOOP AT rapbo_childs INTO DATA(rapbo_child).
      delete_child_key-NodeUUID = rapbo_child-NodeUUID.
      APPEND delete_child_key TO delete_child_keys.
    ENDLOOP.

    MODIFY ENTITIES OF ZDMO_R_RapGeneratorBO
    ENTITY RAPGeneratorBO
    DELETE FROM
    VALUE
    #( ( RapNodeUUID = RapNodeUUID ) )
    ENTITY RAPGeneratorBONode
    DELETE FROM
    delete_child_keys
    FAILED DATA(failed_deletes)
    REPORTED DATA(reported_deletes).

    IF failed_deletes-rapgeneratorbo IS NOT INITIAL.
      LOOP AT failed_deletes-rapgeneratorbo INTO DATA(failed_delete_bo).
        text = failed_delete_bo-%fail-cause.
        add_text_to_app_log_or_console(
          i_text     = |fail modify delete root entity { text }|
          i_severity = 'E'
        ).
      ENDLOOP.
    ENDIF.
    IF failed_deletes-rapgeneratorbonode IS NOT INITIAL.
      LOOP AT failed_deletes-rapgeneratorbo INTO DATA(failed_delete_bonode).
        text = failed_delete_bonode-%fail-cause.
        add_text_to_app_log_or_console(
          i_text     = |fail modify delete child entity { text }|
          i_severity = 'E'
        ).
      ENDLOOP.
    ENDIF.


    COMMIT ENTITIES
    RESPONSE OF zdmo_r_rapgeneratorbo
    FAILED DATA(failed_commits)
    REPORTED DATA(reported_commits).

    IF failed_commits-rapgeneratorbo IS NOT INITIAL.
      LOOP AT failed_deletes-rapgeneratorbo INTO DATA(failed_commit_bo).
        text = failed_delete_bo-%fail-cause.
        add_text_to_app_log_or_console(
          i_text     = |failed commit root entity { text }|
          i_severity = 'E'
        ).
      ENDLOOP.
    ENDIF.
    IF failed_commits-rapgeneratorbonode IS NOT INITIAL.
      LOOP AT failed_deletes-rapgeneratorbo INTO DATA(failed_commit_bonode).
        text = failed_delete_bonode-%fail-cause.
        add_text_to_app_log_or_console(
          i_text     = |failed commit child entity { text }|
          i_severity = if_bali_constants=>c_severity_error
        ).
      ENDLOOP.
    ENDIF.

    IF failed_commits-rapgeneratorbonode IS INITIAL AND
       failed_commits-rapgeneratorbo IS NOT INITIAL.
      add_text_to_app_log_or_console( | Entity { i_rap_bo_name } has been deleted from RAP Generator Projects. | ).
    ENDIF.

  ENDMETHOD.


  METHOD delete_service_bindings.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>root_node_object_types-service_binding.
    DATA object_name TYPE sxco_srvb_object_name.
    DATA(delete_operation) = mo_environment->for-srvb->create_delete_operation( ).
    "end change
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( object_name ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD delete_service_definitions.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>root_node_object_types-service_definition.
    DATA object_name TYPE sxco_srvd_object_name.
    DATA(delete_operation) = mo_environment->for-srvd->create_delete_operation( ).
    "end change
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( object_name ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD delete_structures.
    "begin change
    DATA object_type TYPE if_xco_gen_o_finding=>tv_object_type VALUE zdmo_cl_rap_node=>node_object_types-control_structure.
    DATA object_name TYPE sxco_ad_object_name .
    DATA(delete_operation) = mo_environment->for-tabl-for-structure->create_delete_operation( ).
    "end change
    DATA del_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects  .
    LOOP AT i_repository_objects INTO DATA(repository_object) WHERE object_type = object_type.
      APPEND repository_object TO del_repository_objects.
      object_name = to_upper( repository_object-object_name ).
      delete_operation->add_object( object_name ).
      add_text_to_app_log_or_console( |{ object_type } { object_name } will be deleted.| ).
    ENDLOOP.
    CHECK del_repository_objects IS NOT INITIAL.
    TRY.
        DATA(delete_operation_result) = delete_operation->execute( ).
        IF delete_operation_result->findings->contain_errors(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - errors occured.|
            i_severity = if_bali_constants=>c_severity_error
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_warnings(  ) = abap_true.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation - warnings were raised.|
            i_severity = if_bali_constants=>c_severity_warning
          ).
        ENDIF.
        IF delete_operation_result->findings->contain_errors(  ) = abap_false AND
           delete_operation_result->findings->contain_warnings(  ) = abap_false.
          add_text_to_app_log_or_console(
            i_text     = |Delete operation was successfull.|
            i_severity = if_bali_constants=>c_severity_status
          ).
        ENDIF.
        IF delete_operation_result->findings->get(  ) IS NOT INITIAL.
          add_text_to_app_log_or_console( |Findings.| ).
          add_findings_to_output( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output( xco_delete_exception->findings ).
      CATCH cx_root INTO DATA(srvb_deletion_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        DATA(delete_operation_text) = CONV cl_bali_free_text_setter=>ty_text( get_root_exception( srvb_deletion_exception )->get_longtext(  ) ).
        add_text_to_app_log_or_console(
          i_text     = delete_operation_text
          i_severity = if_bali_constants=>c_severity_error
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD generated_objects_are_deleted.

    DATA object_name TYPE if_xco_gen_o_finding=>tv_object_name .
    DATA object_type  TYPE if_xco_gen_o_finding=>tv_object_type.

    DATA number_of_objects_found TYPE i.


    r_objects_have_been_deleted = abap_false.

    LOOP AT i_repository_objects INTO DATA(repository_object).

      object_name = to_upper( repository_object-object_name ).
      object_type = to_upper( repository_object-object_type ).


      "when an object has been deleted but the transport request has not been released yet
      "it will show up in I_CustABAPObjDirectoryEntry with the flag ABAPObjectIsDeleted = 'X'

      DATA(object_still_exists) = xco_lib->get_abap_obj_directory_entry(
        EXPORTING
          i_abap_object_type            = object_type
          i_abap_object_category        = 'R3TR'
          i_abap_object                 = object_name
      ).

*      SELECT SINGLE * FROM I_CustABAPObjDirectoryEntry
*      WHERE ABAPObject = @object_name
*        AND ABAPObjectType = @object_type
*        AND ABAPObjectIsDeleted = @abap_false
*      INTO @DATA(object_still_exists).
*
*      SELECT SINGLE * FROM I_ABAPObjectDirectoryEntry
*           WHERE ABAPObject = @object_name
*             AND ABAPObjectType = @object_type
*             AND ABAPObjectIsDeleted = @abap_false
*           INTO @DATA(object_still_exists2).

      IF object_still_exists IS NOT INITIAL.
        IF object_still_exists-ABAPObjectIsDeleted = abap_false .
          number_of_objects_found += 1.
          APPEND repository_object TO r_existing_repository_objects.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF number_of_objects_found = 0.
      r_objects_have_been_deleted = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_locking_transport.

* data(ro_service_binding) = xco_cp_abap_repository=>object->srvb->for( i_object_name  ).

    DATA(lo_transport_lock) = xco_cp_abap_repository=>object->for(
      iv_type = i_object_type
      iv_name = i_object_name
    )->if_xco_cts_changeable~get_object( )->get_lock( ).

    " we have not only to retrieve the locking task but the request to which the locking task belongs
    " the transport_lock->get_transport() e.g. delivered the value PMDK900274.
    " But when trying to delete objects like BDEF this failed with an error message such as
    " Object R3TR BDEF ZR_BDTSTRAVELTP is already locked in request PMDK900273 of user CB0000000019

    IF lo_transport_lock->exists( ) EQ abap_true.
      DATA(locking_transport) = lo_transport_lock->get_transport( ).
      r_transport = xco_cp_cts=>transport->for( locking_transport )->get_request(  )->value.
    ENDIF.

  ENDMETHOD.


  METHOD get_objects_from_package.
    DATA generated_repository_object TYPE zdmo_cl_rap_generator=>t_generated_repository_object.

*    SELECT * FROM I_ABAPObjectDirectoryEntry WHERE ABAPPackage = @i_package
*                                              INTO TABLE @DATA(objects_in_package) .

    DATA(objects_in_package) = xco_lib->get_objects_in_package( i_package ).

    LOOP AT objects_in_package INTO DATA(object_in_package).
      generated_repository_object-object_name = object_in_package-ABAPObject.
      generated_repository_object-object_type = object_in_package-ABAPObjectType.
      generated_repository_object-transport_request = get_locking_transport(
      i_object_type = generated_repository_object-object_type
      i_object_name = generated_repository_object-object_name
    ).
      APPEND generated_repository_object TO r_repository_objects.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_objects_from_rap_generator.
    DATA generated_repository_object TYPE zdmo_cl_rap_generator=>t_generated_repository_object.

    SELECT SINGLE RapNodeUUID  FROM ZDMO_R_RapGeneratorBO WHERE BoName = @i_rap_bo_name
                                                    INTO @DATA(rapnodeuuid) .

    SELECT * FROM ZDMO_R_RapGeneratorBONode WHERE HeaderUUID = @RapNodeUUID
                                             INTO TABLE @DATA(bo_generated_objects).

    LOOP AT bo_generated_objects INTO DATA(bo_generated_object).

      generated_repository_object-hierarchy_distance_from_root = bo_generated_object-HierarchyDistanceFromRoot.

      IF bo_generated_object-IsRootNode = abap_true.
        IF bo_generated_object-ServiceBinding IS NOT INITIAL.
          generated_repository_object-object_name = bo_generated_object-ServiceBinding.
          generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-service_binding.
          generated_repository_object-transport_request = get_locking_transport(
            i_object_type = generated_repository_object-object_type
            i_object_name = generated_repository_object-object_name
          ).
          APPEND generated_repository_object TO r_repository_objects.
        ENDIF.
        IF bo_generated_object-ServiceDefinition IS NOT INITIAL.
          generated_repository_object-object_name = bo_generated_object-ServiceDefinition.
          generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-service_definition.
          generated_repository_object-transport_request = get_locking_transport(
            i_object_type = generated_repository_object-object_type
            i_object_name = generated_repository_object-object_name
          ).
          APPEND generated_repository_object TO r_repository_objects.
        ENDIF.
        IF bo_generated_object-CdsRView IS NOT INITIAL.
          "bdef and cds r-view have the same name
          generated_repository_object-object_name = bo_generated_object-CdsRView.
          generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-behavior_definition_r.
          generated_repository_object-transport_request = get_locking_transport(
            i_object_type = generated_repository_object-object_type
            i_object_name = generated_repository_object-object_name
          ).
          generated_repository_object-transport_request = get_locking_transport(
            i_object_type = generated_repository_object-object_type
            i_object_name = generated_repository_object-object_name
          ).
          APPEND generated_repository_object TO r_repository_objects.
        ENDIF.
        IF bo_generated_object-CdsPView IS NOT INITIAL.
          "projection bdef and cds pr-view have the same name
          generated_repository_object-object_name = bo_generated_object-CdsPView.
          generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-behavior_definition_P.
          generated_repository_object-transport_request = get_locking_transport(
            i_object_type = generated_repository_object-object_type
            i_object_name = generated_repository_object-object_name
          ).
          APPEND generated_repository_object TO r_repository_objects.
        ENDIF.
      ENDIF.
      "cds views
      IF bo_generated_object-CdsRView IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-CdsRView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_r.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.
      IF bo_generated_object-CdsiView IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-CdsiView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_i.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.
      "cds projection view and metadata extension
      IF bo_generated_object-CdsPView IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-CdsPView.
        "add entry for projection view
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_p.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
        "add entry for metadata extension
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-meta_data_extension.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.
      "Classes
      IF bo_generated_object-BehaviorImplementationClass IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-BehaviorImplementationClass.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-behavior_implementation.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.
      IF bo_generated_object-QueryImplementationClass IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-QueryImplementationClass.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-query_implementation.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.
      "tables and structures
      IF bo_generated_object-DraftTableName IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-DraftTableName.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-draft_table.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.
      IF bo_generated_object-ControlStructure IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-ControlStructure.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-control_structure.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.


      IF bo_generated_object-BehaviorImplementationClass IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-BehaviorImplementationClass.
        generated_repository_object-object_type = 'CLAS'.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.

    ENDLOOP.

    "remove objects that have been deleted from the list
*
*    generated_objects_are_deleted(
*      EXPORTING
*        i_rap_bo_name                 = i_rap_bo_name
*        i_repository_objects          = r_repository_objects
*      IMPORTING
*        r_existing_repository_objects = r_repository_objects
*      RECEIVING
*        r_objects_have_been_deleted   = DATA(objects_have_been_deleted)
*    ).

    SORT r_repository_objects BY hierarchy_distance_from_root ASCENDING object_type ASCENDING object_type ASCENDING.

  ENDMETHOD.


  METHOD get_root_exception.
    rx_root = ix_exception.
    WHILE rx_root->previous IS BOUND.
      rx_root ?= rx_root->previous.
    ENDWHILE.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = zdmo_cl_rap_node=>job_selection_name kind = if_apj_dt_exec_object=>parameter datatype = 'C' length =  40 param_text = zdmo_cl_rap_node=>job_selection_description changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = zdmo_cl_rap_node=>job_selection_name  kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'ZR_BDTSTravelTPHugo' )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA  exception_text  TYPE cl_bali_free_text_setter=>ty_text .
    TRY.
        IF application_log IS INITIAL.
          create_application_log(  ).
        ENDIF.

        add_text_to_app_log_or_console( 'start method execute()' ).

        "if a package name is provided don't look for the rap bo name
        IF delete_objects_in_package IS INITIAL.

          IF it_parameters IS INITIAL.
            add_text_to_app_log_or_console( |it_parameters: is initial| ).
          ELSE.
            add_text_to_app_log_or_console( 'it_parameters:' ).
          ENDIF.

          LOOP AT it_parameters INTO DATA(parameter).
            add_text_to_app_log_or_console( |Selection name { parameter-selname } low:{ parameter-low }| ).
          ENDLOOP.

          " Getting the actual parameter values
          LOOP AT it_parameters INTO DATA(ls_parameter).
            CASE ls_parameter-selname.
              WHEN zdmo_cl_rap_node=>job_selection_name .

                SELECT SINGLE * FROM zdmo_r_rapgeneratorbo  WHERE boname = @ls_parameter-low
                INTO @DATA(rap_generator_bo).

                IF sy-subrc = 0.
                  save_log_handle( rap_generator_bo-BoName ).
                ELSE.
                  add_text_to_app_log_or_console(
                    i_text     = |BO name { ls_parameter-low } not found in ZDMO_r_rapgeneratorbo |
                    i_severity = if_bali_constants=>c_severity_error
                  ).
                  CONTINUE.
                ENDIF.
            ENDCASE.
          ENDLOOP.

        ENDIF.

        IF delete_objects_in_package IS NOT INITIAL.
          add_text_to_app_log_or_console( |checking package { delete_objects_in_package }| ).
        ELSE.
          add_text_to_app_log_or_console( |checking rap bo { rap_generator_bo-BoName }| ).
        ENDIF.

        IF delete_objects_in_package IS NOT INITIAL.
          DATA(objects_to_be_deleted_1) = get_objects_from_package( delete_objects_in_package ).
        ELSE.
          objects_to_be_deleted_1 = get_objects_from_rap_generator( rap_generator_bo-BoName ).
        ENDIF.

        "remove objects that have been deleted from the list

        generated_objects_are_deleted(
          EXPORTING
*            i_rap_bo_name                 = rap_generator_bo-BoName
            i_repository_objects          = objects_to_be_deleted_1
          IMPORTING
            r_existing_repository_objects = DATA(objects_to_be_deleted)
          RECEIVING
            r_objects_have_been_deleted   = DATA(objects_have_been_deleted)
        ).


        LOOP AT objects_to_be_deleted INTO DATA(object_to_be_deleted).
          add_text_to_app_log_or_console( | Type: { object_to_be_deleted-object_type } Name: { object_to_be_deleted-object_name } locked by cts: { object_to_be_deleted-transport_request }| ).
*        ENDLOOP.

          "unpublish service binding
*        IF line_exists( objects_to_be_deleted[ object_type = zdmo_cl_rap_node=>root_node_object_types-service_binding ]  ).
          IF object_to_be_deleted-object_type = zdmo_cl_rap_node=>root_node_object_types-service_binding.
            DATA(service_binding_to_be_deleted) = objects_to_be_deleted[ object_type = zdmo_cl_rap_node=>root_node_object_types-service_binding ].

            "in cloud we have a validation that checks whether the service binding is still published
            IF xco_lib->service_binding_is_published( CONV sxco_srvb_object_name(  service_binding_to_be_deleted-object_name ) ).
              add_text_to_app_log_or_console( |Service binding { service_binding_to_be_deleted-object_name } is published. | ).
              IF demo_mode = abap_false.
                add_text_to_app_log_or_console( |unpublishing { service_binding_to_be_deleted-object_name }  | ).
                xco_lib->un_publish_service_binding( CONV sxco_srvb_object_name(  service_binding_to_be_deleted-object_name ) ).
              ENDIF.
            ENDIF.

            IF xco_lib->service_binding_is_published( CONV sxco_srvb_object_name(  service_binding_to_be_deleted-object_name ) ) = abap_false.
              add_text_to_app_log_or_console( |Service binding { service_binding_to_be_deleted-object_name } is not published.| ).
            ENDIF.

          ENDIF.
        ENDLOOP.
        "start deletion
        add_text_to_app_log_or_console( |Start deleting generated objects| ).

        IF demo_mode = abap_false.

          delete_generated_objects(
            i_rap_bo_name        = rap_generator_bo-BoName
            i_repository_objects = objects_to_be_deleted
          ).

          IF delete_objects_in_package IS INITIAL.

            IF generated_objects_are_deleted(
*                   i_rap_bo_name        = rap_generator_bo-BoName
                   i_repository_objects = objects_to_be_deleted
                 ) = abap_true.

              add_text_to_app_log_or_console(
                i_text     = |All objects of { rap_generator_bo-BoName } have been deleted. |
                i_severity = if_bali_constants=>c_severity_status
              ).

*                  Delete_RAP_Generator_Project( rap_generator_bo-BoName ).

            ELSE.
              add_text_to_app_log_or_console(
                i_text     = |Not all objects of { rap_generator_bo-BoName } have been deleted. |
                i_severity = if_bali_constants=>c_severity_error
              ).
            ENDIF.
          ENDIF.
        ELSE.
          add_text_to_app_log_or_console(
                              i_text     = |Demo mode. Nothing done. |
                              i_severity = if_bali_constants=>c_severity_status
                            ).
        ENDIF.

*      CATCH cx_bali_runtime INTO DATA(application_log_exception).
      CATCH cx_root INTO DATA(application_log_exception).

        exception_text = application_log_exception->get_text(  ).
        exception_text = |Exception was raised: { exception_text }|.
        add_text_to_app_log_or_console(
          i_text     = exception_text
          i_severity = if_bali_constants=>c_severity_error
        ).

    ENDTRY.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    DATA et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val  .

    DATA ls_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA lt_job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA ls_job_parameters TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA ls_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA lv_jobname TYPE cl_apj_rt_api=>ty_jobname.
    DATA lv_jobcount TYPE cl_apj_rt_api=>ty_jobcount.

    CLEAR delete_objects_in_package.
    demo_mode = abap_false.
    delete_objects_in_package = 'TEST_RAP100_AF1'.

    IF delete_objects_in_package IS NOT INITIAL.

      DATA(existing_object_entry) = xco_lib->get_abap_obj_directory_entry(
        EXPORTING
          i_abap_object_type            = 'DEVC'
          i_abap_object_category        = 'R3TR'
          i_abap_object                 = CONV #( delete_objects_in_package )
      ).
*      SELECT SINGLE * FROM
*      I_ABAPObjectDirectoryEntry "ObjDirectoryEntry
*      WHERE ABAPObjectType = 'DEVC'
*                                                       AND ABAPObjectCategory = 'R3TR'
*                                                       AND ABAPObject = @delete_objects_in_package
*                                                       INTO  @DATA(existing_object_entry) .

      IF existing_object_entry IS INITIAL.
        out->write( |Package { delete_objects_in_package } does not exist. Stop processing| ).
        EXIT.
      ENDIF.
    ENDIF.


    me->out = out.

    et_parameters = VALUE #(
        ( selname = zdmo_cl_rap_node=>job_selection_name
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = test_bo_name )
      ).

    IF run_in_foreground = abap_false AND run_in_background = abap_false.
      out->write( | run_in_foreground is set to abap_false AND  | ).
      out->write( | run_in_background is set to abap_false.  | ).
      out->write( 'do nothing' ).
      EXIT.
    ELSE.
      IF delete_objects_in_package IS NOT INITIAL.
        out->write( |try to delete objects in package: { delete_objects_in_package }| ).
      ELSE.
        out->write( |try to delete the following rap bo: { test_bo_name }| ).
      ENDIF.
    ENDIF.

    IF run_in_foreground = abap_true.
      TRY.
          if_apj_rt_exec_object~execute( it_parameters = et_parameters ).
          out->write( |Finished| ).

        CATCH cx_root INTO DATA(run_via_f9_exception).
          out->write( |Exception has occured: { run_via_f9_exception->get_text(  ) }| ).
      ENDTRY.
    ELSE.
      out->write( | run_in_foreground is set to abap_false. Only schedule application job| ).
    ENDIF.
    " start_immediately MUST NOT BE USED in on premise systems
    " since it performs a commit work which would cause a dump
    ls_start_info-start_immediately = abap_true.

    IF run_in_background = abap_true.

      "use in on prem systems timestamp instead
*    GET TIME STAMP FIELD DATA(start_time_of_job).
*    ls_start_info-timestamp = start_time_of_job.

      ls_job_parameters-name = zdmo_cl_rap_node=>job_selection_name.
      ls_value-sign = 'I'.
      ls_value-option = 'EQ'.
      ls_value-low = test_bo_name.
      APPEND ls_value TO ls_job_parameters-t_value.
      APPEND ls_job_parameters TO lt_job_parameters.
      TRY.
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = zdmo_cl_rap_node=>job_del_template_name
              iv_job_text            = |delete objects from main()|
              is_start_info          = ls_start_info
              it_job_parameter_value = lt_job_parameters
            IMPORTING
              ev_jobname             = lv_jobname
              ev_jobcount            = lv_jobcount
          ).

          out->write( |Job scheduled succssfully. jobname { lv_jobname } jobcount { lv_jobcount }| ).

        CATCH cx_apj_rt INTO DATA(job_scheduling_error).
          "handle exception
          TYPES: BEGIN OF ty_longtext,
                   msgv1(50),
                   msgv2(50),
                   msgv3(50),
                   msgv4(50),
                 END OF ty_longtext.
          DATA: ls_longtext      TYPE ty_longtext.
*        ls_longtext = job_scheduling_error->bapimsg-message .
          out->write( |Job scheduling error: { job_scheduling_error->bapimsg-message }| ).

      ENDTRY.
    ELSE.
      out->write( | run_in_background is set to abap_false. Only run interactively via F9| ).
    ENDIF.

  ENDMETHOD.


  METHOD save_log_handle.

    CHECK application_log IS NOT INITIAL.

    SELECT SINGLE * FROM zdmo_r_rapgeneratorbo  WHERE boname = @i_rap_bo_name
    INTO @DATA(rap_generator_bo).

    CHECK sy-subrc = 0.

    r_log_handle = application_log->get_handle( ).

    DATA update TYPE TABLE FOR UPDATE ZDMO_R_RapGeneratorBO\\RAPGeneratorBO.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RapGeneratorBO\\RAPGeneratorBO.

    update_line-RapNodeUUID = rap_generator_bo-RapNodeUUID.
    update_line-ApplicationJobLogHandle = r_log_handle.
    APPEND update_line TO update.

    IF update IS NOT INITIAL.
      MODIFY ENTITIES OF ZDMO_R_RapGeneratorBO
           ENTITY RAPGeneratorBO
             UPDATE FIELDS (
                            ApplicationJobLogHandle
                            RapNodeUUID
                            ) WITH update
          REPORTED DATA(update_reported)
          FAILED DATA(update_failed)
          .
    ENDIF.

    IF update IS NOT INITIAL AND update_failed IS INITIAL.
      COMMIT ENTITIES RESPONSE OF ZDMO_R_RapGeneratorBO
                      REPORTED DATA(commit_reported)
                      FAILED DATA(commit_failed).
    ENDIF.



  ENDMETHOD.


  METHOD service_binding_is_published.

    r_is_published = abap_false.

    "object names in I_CustABAPObjDirectoryEntry are stored in upper case
    "( ABAPObjectCategory = 'R3TR' ABAPObjectType = 'SIA6' ABAPObject = 'ZUI_BDTSTRAVEL_O4_0001_G4BA_IBS'

    DATA(filter_string) = to_upper( i_object_name && '%' ).

    SELECT * FROM I_CustABAPObjDirectoryEntry WHERE ABAPObject LIKE @filter_string
                                                AND ABAPObjectType = 'SIA6'
                                               INTO TABLE @DATA(published_srvb_entries).

    IF lines( published_srvb_entries ) > 0.
      r_is_published = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
