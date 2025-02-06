CLASS zdmo_cl_rap_generator_del DEFINITION
INHERITING FROM zdmo_cl_rap_generator_base
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        i_boname TYPE ZDMO_R_RAPG_ProjectTP-BoName.

    METHODS rap_gen_project_objects_exist
      IMPORTING
        i_rap_generator_project           TYPE ZDMO_R_RAPG_ProjectTP
      RETURNING
        VALUE(r_repository_objects_exist) TYPE abap_bool.

    METHODS start_deletion.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES : BEGIN OF t_log_entry,
              DetailLevel TYPE ballevel,
              Severity    TYPE symsgty,
              Text        TYPE  bapi_msg,
              TimeStamp   TYPE timestamp,
            END OF t_log_entry.
    TYPES : t_log_entries TYPE STANDARD TABLE OF t_log_entry.

    DATA boname TYPE zdmo_rap_gen_entityname.
    DATA bo_data TYPE ZDMO_R_RAPG_ProjectTP.

    DATA json_string TYPE ZDMO_R_RAPG_ProjectTP-JsonString.
    DATA package_language_version TYPE ZDMO_R_RAPG_ProjectTP-PackageLanguageVersion.
    DATA rap_bo_uuid TYPE  ZDMO_R_RAPG_ProjectTP-RapBoUUID.
    DATA xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.

    DATA delete_objects_in_package TYPE sxco_package.
    DATA demo_mode TYPE abap_boolean VALUE abap_false.



    DATA test_bo_name TYPE ZDMO_R_RAPG_ProjectTP-BoName VALUE 'ZR_SalesOrderTP_LOG3'.
*    DATA rap_bo_name TYPE ZDMO_R_RAPG_ProjectTP-BoName.
    DATA perform_srvb_is_active_check TYPE abap_bool VALUE abap_false.

    "run in background Y/N?
*    DATA run_in_background TYPE abap_bool VALUE abap_true.
    DATA run_in_background TYPE abap_bool VALUE abap_false.

    "run in foreground Y/N?
    DATA run_in_foreground TYPE abap_bool VALUE abap_true.
*    DATA run_in_foreground TYPE abap_bool VALUE abap_false.

*    DATA xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.
    DATA generated_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    DATA generated_repository_object TYPE zdmo_cl_rap_generator=>t_generated_repository_object.

    DATA out TYPE REF TO if_oo_adt_classrun_out.
*    DATA application_log TYPE REF TO if_bali_log .

    METHODS add_log_entries_for_rap_bo IMPORTING i_rap_bo_name    TYPE sxco_cds_object_name OPTIONAL
                                                 i_log_entries    TYPE t_log_entries
                                       RETURNING VALUE(r_success) TYPE abap_boolean.

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
      IMPORTING i_task_name      TYPE bapi_msg
                i_findings       TYPE REF TO if_xco_gen_o_findings
      RETURNING VALUE(r_success) TYPE abap_bool
*      RAISING   cx_bali_runtime
      .
    METHODS add_text_to_app_log_or_console
      IMPORTING i_text     TYPE cl_bali_free_text_setter=>ty_text
                i_severity TYPE cl_bali_free_text_setter=>ty_severity DEFAULT if_bali_constants=>c_severity_status
*      RAISING   cx_bali_runtime
      .
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


    METHODS delete_service_bindings
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS delete_service_definitions
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS delete_behavior_definitions
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS delete_metadata_extensions
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS delete_cds_views
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS delete_classes
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS delete_draft_tables
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS delete_structures
      IMPORTING i_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects
*                i_environment        TYPE REF TO if_xco_cp_gen_env_dev_system
*      RAISING   cx_bali_runtime
      .
    METHODS Delete_RAP_Generator_Project
      IMPORTING
        i_rap_bo_name TYPE sxco_ar_object_name
*      RAISING
*        cx_bali_runtime
      .

    METHODS delete_release_state
      IMPORTING object_type                       TYPE if_abap_api_state=>ty_object_directory_type
                object_name                       TYPE if_abap_api_state=>ty_object_directory_name
                sub_object_type                   TYPE if_abap_api_state=>ty_sub_object_type  OPTIONAL
                sub_object_name                   TYPE if_abap_api_state=>ty_sub_object_name  OPTIONAL
*                release_contract                  TYPE if_abap_api_state=>ty_release_contract
                request                           TYPE if_abap_api_state=>ty_request
      RETURNING VALUE(r_release_state_is_deleted) TYPE abap_bool.

ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_DEL IMPLEMENTATION.


  METHOD add_findings_to_output.

    DATA text TYPE c LENGTH 200 .
    DATA(finding_texts) = i_findings->get( ).

**********************************************************************

    IF finding_texts IS NOT INITIAL.
      LOOP AT finding_texts INTO DATA(finding_text).
        text = |{ finding_text->object_type } { finding_text->object_name } { finding_text->message->get_text(  ) }|.
        add_text_to_app_log_or_console(
          i_text     = text
          i_severity = finding_text->message->value-msgty
        ).
      ENDLOOP.
    ENDIF.

**********************************************************************


    DATA log_entry TYPE t_log_entry.
    DATA log_entries TYPE t_log_entries.

    log_entry-text = i_task_name.
    log_entry-detaillevel = 1.
    log_entry-severity = 'S'.

    IF i_findings->contain_warnings(  ).
      log_entry-severity = 'W'.
    ENDIF.

    IF i_findings->contain_errors(  ).
      log_entry-severity = 'E'.
    ENDIF.

    APPEND log_entry TO log_entries.

    finding_texts = i_findings->get( ).

    IF finding_texts IS NOT INITIAL.
      LOOP AT finding_texts INTO finding_text.
        log_entry-text = |{ finding_text->object_type } { finding_text->object_name } { finding_text->message->get_text(  ) }|.
        log_entry-severity = finding_text->message->value-msgty.
        log_entry-detaillevel = 2.
        APPEND log_entry TO log_entries.
      ENDLOOP.
    ENDIF.

    r_success = add_log_entries_for_rap_bo(
           i_rap_bo_name = CONV #( boname )
           i_log_entries = log_entries
         ).




  ENDMETHOD.


  METHOD add_log_entries_for_rap_bo.

    DATA create_rapbolog_cba TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Log.

    DATA create_raplog_cba_line TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Log.
    DATA log_entries LIKE create_raplog_cba_line-%target.
    DATA log_entry LIKE LINE OF log_entries.
*    DATA log_entries TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\\log   .
*    DATA log_entry TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_ProjectTP\\log   .
    DATA n TYPE i.
    DATA time_stamp TYPE timestampl.

    GET TIME STAMP FIELD time_stamp.

    SELECT SINGLE * FROM ZDMO_R_RAPG_ProjectTP  WHERE boname = @boname
          INTO @DATA(rap_generator_bo).

    CHECK sy-subrc = 0.

    LOOP AT i_log_entries INTO DATA(my_log_entry).
      n += 1.
      log_entry = VALUE #(     %is_draft = if_abap_behv=>mk-off
                               %cid      = |test{ n }|
                               Severity = my_log_entry-Severity
                               DetailLevel = my_log_entry-DetailLevel
                               Text = my_log_entry-Text
                               TimeStamp = time_stamp
                               ).
      APPEND log_entry TO log_entries.
    ENDLOOP.

    create_rapbolog_cba = VALUE #( ( %is_draft = if_abap_behv=>mk-off
                                     %key-rapbouuid = rap_generator_bo-RapboUUID
                                     %target   = log_entries ) ) .

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
             ENTITY project
                   CREATE BY \_Log
                   FIELDS (
                           LogItemNumber
                           DetailLevel
                           Severity
                           Text
                           TimeStamp
                   )
                   WITH create_rapbolog_cba
             MAPPED   DATA(mapped)
             FAILED   DATA(failed)
             REPORTED DATA(reported).


    IF mapped-log IS NOT INITIAL.
      COMMIT ENTITIES.
      COMMIT WORK.
      r_success = abap_true.
    ENDIF.
    IF failed-log IS NOT INITIAL.
      r_success = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD add_text_to_app_log_or_console.

    DATA log_entry TYPE t_log_entry.
    DATA log_entries TYPE t_log_entries.

    log_entry-text = i_text.
    log_entry-detaillevel = 1.
    log_entry-severity = i_severity.
    APPEND log_entry TO log_entries.

    IF boname IS NOT INITIAL.
      add_log_entries_for_rap_bo(
             i_rap_bo_name = CONV #( boname )
             i_log_entries = log_entries
           ).
    ENDIF.

*    DATA(application_log_free_text) = cl_bali_free_text_setter=>create(
*      severity = i_severity " if_bali_constants=>c_severity_status
*      text     = i_text ).
*    application_log_free_text->set_detail_level( detail_level = '1' ).
*    application_log->add_item( item = application_log_free_text ).
*    cl_bali_log_db=>get_instance( )->save_log(
*                                               log = application_log
*                                               assign_to_current_appl_job = abap_true
*                                               ).



*    ELSE.

  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).
    boname = i_boname.
    SELECT SINGLE *  FROM ZDMO_R_RAPG_ProjectTP WHERE BoName = @i_boname
                                                    INTO @bo_data .
    DATA(xco_on_prem_library) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    IF xco_on_prem_library->on_premise_branch_is_used( ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.
  ENDMETHOD.


  METHOD delete_behavior_definitions.
    DATA task_name TYPE bapi_msg VALUE 'delete behavior definitions'.
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

    IF bo_data-isExtensible = abap_true.
      LOOP AT del_repository_objects INTO DATA(del_repository_object).
        delete_release_state(
          EXPORTING
            object_type                = del_repository_object-object_type
            object_name                = del_repository_object-object_name
            request                    = del_repository_object-transport_request
      RECEIVING
         r_release_state_is_deleted = DATA(release_state_is_deleted)
        ).
        add_text_to_app_log_or_console(
          i_text     = |Delete release state { object_type } { object_name } - errors occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
      ENDLOOP.
    ENDIF.

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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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
    DATA task_name TYPE bapi_msg VALUE 'delete cds views'.
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

    IF bo_data-isExtensible = abap_true.
      LOOP AT del_repository_objects INTO DATA(del_repository_object).
        delete_release_state(
          EXPORTING
            object_type                = del_repository_object-object_type
            object_name                = del_repository_object-object_name
            request                    = del_repository_object-transport_request
      RECEIVING
         r_release_state_is_deleted = DATA(release_state_is_deleted)
        ).
        add_text_to_app_log_or_console(
          i_text     = |Delete release state { object_type } { object_name } - errors occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
      ENDLOOP.
    ENDIF.


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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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
    DATA task_name TYPE bapi_msg VALUE 'delete classes'.
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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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
    DATA task_name TYPE bapi_msg VALUE 'delete draft tables'.
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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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

    SELECT SINGLE * FROM ZDMO_R_RAPG_ProjectTP WHERE BoName = @i_rap_bo_name
                                               INTO @DATA(rap_bo_header_data).

    SELECT SINGLE * FROM ZDMO_R_RAPG_NodeTP WHERE rapboUUID = @rap_bo_header_data-RapboUUID
                                                     INTO @DATA(rap_bo_root_node_data).

    DATA(my_bdef) = xco_lib->get_behavior_definition( CONV sxco_cds_object_name( rap_bo_header_data-BoName ) ).
    DATA(my_srvb) = xco_lib->get_service_binding( CONV sxco_srvb_object_name( rap_bo_root_node_data-ServiceBinding ) ).

    "@todo - add more checks
    IF my_srvb->if_xco_ar_object~exists(  ).
      DATA(package) = my_srvb->content(  )->service_binding->if_xco_ar_object~get_package(  )->name.
    ELSEIF my_bdef->if_xco_ar_object~exists( ).
      package = my_bdef->content(  )->behavior_definition->if_xco_ar_object~get_package(  )->name.
    ENDIF.

    package = bo_data-PackageName.

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

*    IF delete_objects_in_package IS NOT INITIAL.
*      package = delete_objects_in_package.
*    ENDIF.
    IF xco_lib->get_package( package )->exists( ) = abap_true.
      DATA(package_records_changes) = xco_lib->get_package( package )->read( )-property-record_object_changes.
    ELSE.
      add_text_to_app_log_or_console( |Package { package } does not exist.| ).
*      EXIT.
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
    DATA task_name TYPE bapi_msg VALUE 'metadata extensions'.
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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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


  ENDMETHOD.


  METHOD delete_release_state.

    DATA release_contract TYPE if_abap_api_state=>ty_release_contract.
    DATA log_entry TYPE t_log_entry.
    DATA log_entries TYPE t_log_entries.

    TRY.

        CASE object_type.

          WHEN 'DDLS'.
            DATA(api_state_handler) = cl_abap_api_state=>create_instance( api_key = VALUE #(
                 object_type     = object_type
                 object_name     = to_upper( object_name ) "'ZRAP630E_Shop_051' )
                 sub_object_type = 'CDS_STOB'
                 sub_object_name     = to_upper( object_name ) "'ZRAP630E_Shop_051' )
                 ) ).

          WHEN 'STRU'.
            "internally we use object_type 'STRU' to be able to choose the correct
            "xco generation api ->for->structure vs. ->for->table

            api_state_handler = cl_abap_api_state=>create_instance( api_key = VALUE #(
                            object_type     = 'TABL'
                            object_name     = to_upper( object_name ) "'zrap630sshop_051' )
                            ) ).

          WHEN OTHERS.

            api_state_handler = cl_abap_api_state=>create_instance( api_key = VALUE #(
                  object_type     = object_type
                  object_name     = to_upper( object_name ) "'zrap630sshop_051' )
                  ) ).

        ENDCASE.

        release_contract = zdmo_cl_rap_node=>release_contract_c1.

        IF api_state_handler->is_released(
                    EXPORTING
                      release_contract         = release_contract
                      use_in_cloud_development = abap_true
                      use_in_key_user_apps     = abap_false
                  ).
          r_release_state_is_deleted = abap_false.
          api_state_handler->delete_release_state(
                 release_contract = zdmo_cl_rap_node=>release_contract_c1
                 request   = request
               ).
          r_release_state_is_deleted = abap_true.
        ELSE.
          r_release_state_is_deleted = abap_true.
        ENDIF.

        release_contract = zdmo_cl_rap_node=>release_contract_c0.

        IF api_state_handler->is_released(
                    EXPORTING
                      release_contract         = release_contract
                      use_in_cloud_development = abap_true
                      use_in_key_user_apps     = abap_false
                  ).
          r_release_state_is_deleted = abap_false.
          api_state_handler->delete_release_state(
                 release_contract = zdmo_cl_rap_node=>release_contract_c0
                 request   = request
               ).
          r_release_state_is_deleted = abap_true.
        ELSE.
          r_release_state_is_deleted = abap_true.
        ENDIF.


      CATCH cx_abap_api_state INTO DATA(bdef_del_rel_state_exception).


        log_entry-text = |Delete release state - { release_contract } of { object_type } { object_name } .|.
        log_entry-severity = 'E'.
        log_entry-detaillevel = 1.
        APPEND log_entry TO log_entries.

        log_entry-text = | { bdef_del_rel_state_exception->get_text( ) }.|.
        log_entry-detaillevel = 2.
        APPEND log_entry TO log_entries.

        add_log_entries_for_rap_bo(
                   i_rap_bo_name = CONV #( boname )
                   i_log_entries = log_entries
                 ).

    ENDTRY.

  ENDMETHOD.


  METHOD delete_service_bindings.
    DATA task_name TYPE bapi_msg VALUE 'service bindings'.
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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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
    DATA task_name TYPE bapi_msg VALUE 'service definitions'.
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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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
    DATA task_name TYPE bapi_msg VALUE 'structures'.
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
    IF bo_data-isExtensible = abap_true.
      LOOP AT del_repository_objects INTO DATA(del_repository_object).
        delete_release_state(
          EXPORTING
            object_type                = del_repository_object-object_type
            object_name                = del_repository_object-object_name
            request                    = del_repository_object-transport_request
      RECEIVING
         r_release_state_is_deleted = DATA(release_state_is_deleted)
        ).
        add_text_to_app_log_or_console(
           i_text     = |Delete release state { object_type } { object_name } - errors occured.|
           i_severity = if_bali_constants=>c_severity_error
         ).
      ENDLOOP.
    ENDIF.

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
          add_findings_to_output(
            i_task_name = task_name
            i_findings  = delete_operation_result->findings
          ).
*          CATCH cx_bali_runtime.( delete_operation_result->findings ).
        ENDIF.
      CATCH cx_xco_gen_delete_exception INTO DATA(xco_delete_exception).
        add_text_to_app_log_or_console(
          i_text     = |Delete operation - Exception occured.|
          i_severity = if_bali_constants=>c_severity_error
        ).
        add_findings_to_output(
          i_task_name = task_name
          i_findings  = xco_delete_exception->findings
        ).
*        CATCH cx_bali_runtime.( xco_delete_exception->findings ).
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

      IF to_upper( repository_object-object_type ) = 'STRU'.
        object_type = 'TABL'.
      ELSE.
        object_type = to_upper( repository_object-object_type ).
      ENDIF.

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

    DATA   object_type TYPE if_xco_gen_o_finding=>tv_object_type  .

    IF i_object_type = 'STRU'.
      object_type = 'TABL'.
    ELSE.
      object_type = i_object_type.
    ENDIF.

    DATA(lo_transport_lock) = xco_cp_abap_repository=>object->for(
      iv_type = object_type
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

    SELECT SINGLE RapboUUID  FROM ZDMO_R_RAPG_ProjectTP WHERE BoName = @i_rap_bo_name
                                                    INTO @DATA(rapnodeuuid) .

    SELECT * FROM ZDMO_R_RAPG_NodeTP WHERE rapboUUID = @RapNodeUUID
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
        IF bo_generated_object-CdsIView IS NOT INITIAL.
          "projection bdef and cds pr-view have the same name
          generated_repository_object-object_name = bo_generated_object-CdsiView.
          generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-behavior_definition_i.
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

      "basic i view

      IF bo_generated_object-CdsIViewBasic IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-CdsIViewBasic.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_i.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.

      " extension include view

      IF bo_generated_object-ExtensionIncludeView IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-ExtensionIncludeView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-extension_include_view.
        generated_repository_object-transport_request = get_locking_transport(
          i_object_type = generated_repository_object-object_type
          i_object_name = generated_repository_object-object_name
        ).
        APPEND generated_repository_object TO r_repository_objects.
      ENDIF.


      IF bo_generated_object-DraftQueryView IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-DraftQueryView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-draft_query_view.
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

      IF bo_generated_object-ExtensionInclude IS NOT INITIAL.
        generated_repository_object-object_name = bo_generated_object-ExtensionInclude.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-extension_include.
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


  METHOD rap_gen_project_objects_exist.

    DATA generated_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    DATA generated_repository_object TYPE zdmo_cl_rap_generator=>t_generated_repository_object.

*    DATA on_prem_xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.
*    DATA xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.
*
*    on_prem_xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
*
*    IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_true.
*      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
*    ELSE.
*      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
*    ENDIF.

    SELECT * FROM ZDMO_R_RAPG_NodeTP WHERE rapboUUID = @i_rap_generator_project-RapboUUID
                                                  INTO TABLE @DATA(rapbo_nodes).

    LOOP AT rapbo_nodes INTO DATA(rapbo_node).
      "get repository object names and types

      CLEAR generated_repository_objects.

      IF rapbo_node-ServiceBinding IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-ServiceBinding.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-service_binding.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-ServiceDefinition IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-ServiceDefinition.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-service_definition.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-CdsRView IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-CdsRView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-behavior_definition_r.
        APPEND generated_repository_object TO generated_repository_objects.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_r.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-CdsPView IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-CdsPView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-behavior_definition_p.
        APPEND generated_repository_object TO generated_repository_objects.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_p.
        APPEND generated_repository_object TO generated_repository_objects.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-meta_data_extension.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-CdsiView IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-CdsiView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_i.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-ControlStructure IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-ControlStructure.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-control_structure.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-BehaviorImplementationClass IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-BehaviorImplementationClass.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-behavior_implementation.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-DraftTableName IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-DraftTableName.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-draft_table.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      LOOP AT generated_repository_objects INTO generated_repository_object.

        CASE generated_repository_object-object_type.

          WHEN zdmo_cl_rap_node=>root_node_object_types-service_binding.
            IF xco_lib->get_service_binding( CONV sxco_srvb_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>root_node_object_types-service_definition.
            IF xco_lib->get_service_definition( CONV sxco_srvd_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>root_node_object_types-behavior_definition_r. "this checks also for behavior projection 'BDEF'
            IF xco_lib->get_behavior_definition( CONV sxco_cds_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-behavior_implementation. "checks also for query implementation 'CLAS'
            IF xco_lib->get_class( CONV  sxco_ao_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-cds_view_r. "this checks also for i- and p-views as well as for custom entities
            IF xco_lib->get_view( CONV  sxco_cds_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-control_structure.
            IF xco_lib->get_structure( CONV  sxco_ad_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-draft_table.
            IF xco_lib->get_database_table( CONV  sxco_dbt_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN  zdmo_cl_rap_node=>node_object_types-meta_data_extension.
            IF xco_lib->get_metadata_extension( CONV  sxco_cds_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN OTHERS.
            "do nothing
        ENDCASE.

      ENDLOOP.

    ENDLOOP.

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


  METHOD start_deletion.

    TRY.
*        IF application_log IS INITIAL.
*          create_application_log(  ).
*        ENDIF.

        add_text_to_app_log_or_console( 'start method start_deletion( )' ).


        add_text_to_app_log_or_console( |checking rap bo { BoName }| ).

        DATA(objects_to_be_deleted_1) = get_objects_from_rap_generator( BoName ).


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
            i_rap_bo_name        = BoName
            i_repository_objects = objects_to_be_deleted
          ).



          IF generated_objects_are_deleted(
*                   i_rap_bo_name        = rap_generator_bo-BoName
                 i_repository_objects = objects_to_be_deleted
               ) = abap_true.

            add_text_to_app_log_or_console(
              i_text     = |All objects of { BoName } have been deleted. |
              i_severity = if_bali_constants=>c_severity_status
            ).

*                  Delete_RAP_Generator_Project( rap_generator_bo-BoName ).

          ELSE.
            add_text_to_app_log_or_console(
              i_text     = |Not all objects of { BoName } have been deleted. |
              i_severity = if_bali_constants=>c_severity_error
            ).
          ENDIF.
        ENDIF.


*      CATCH cx_bali_runtime INTO DATA(application_log_exception).
      CATCH cx_root INTO DATA(application_log_exception).

        DATA(exception_text) = application_log_exception->get_text(  ).
        exception_text = |Exception was raised: { exception_text }|.
        add_text_to_app_log_or_console(
          i_text     = CONV #( exception_text )
          i_severity = if_bali_constants=>c_severity_error
        ).

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
