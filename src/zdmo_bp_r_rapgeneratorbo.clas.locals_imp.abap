CLASS lhc_rapgeneratorbo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR rapgeneratorbo RESULT result,
      createbo FOR MODIFY
        IMPORTING keys FOR ACTION rapgeneratorbo~createbo RESULT result,
      setnamespace FOR DETERMINE ON MODIFY
        IMPORTING keys FOR rapgeneratorbo~setnamespace,
      setobjectnames FOR DETERMINE ON MODIFY
        IMPORTING keys FOR rapgeneratorbo~setobjectnames,
      setfieldnames FOR DETERMINE ON MODIFY
        IMPORTING keys FOR rapgeneratorbo~setfieldnames,
      createboandrootnode FOR MODIFY
        IMPORTING keys FOR ACTION rapgeneratorbo~createboandrootnode RESULT result,
      allowed_combinations FOR VALIDATE ON SAVE
        IMPORTING keys FOR rapgeneratorbo~allowed_combinations,
*     Methods that are not supported for 2020
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR rapgeneratorbo
        RESULT result,
      mandatory_fields_check FOR VALIDATE ON SAVE
        IMPORTING keys FOR rapgeneratorbo~mandatory_fields_check,
      createjsonstring FOR DETERMINE ON SAVE
        IMPORTING keys FOR rapgeneratorbo~createjsonstring.

ENDCLASS.

CLASS lhc_rapgeneratorbo IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD mandatory_fields_check.

    DATA permission_request TYPE STRUCTURE FOR PERMISSIONS REQUEST zdmo_c_rapgeneratorbo.

    DATA reported_rapgeneratorbo_line LIKE LINE OF reported-rapgeneratorbo.

    DATA(description_permission_request) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( permission_request-%field ) ) ).
    DATA(components_permission_request) = description_permission_request->get_components(  ).

    LOOP AT components_permission_request INTO DATA(component_permission_request).
      permission_request-%field-(component_permission_request-name) = if_abap_behv=>mk-on.
    ENDLOOP.

*    " Get Permissions without instance keys, as we are only interested in static / global feature control ( mandatory )
*    GET PERMISSIONS OF  zdmo_c_rapgeneratorbo
*      ENTITY rapgeneratorbo
*      FROM VALUE #(  )
*        REQUEST permission_request
*        RESULT DATA(permission_result)
*        FAILED DATA(failed_permission_result)
*        REPORTED DATA(reported_permission_result).

    " Get current field values
    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(rap_generator_projects).

    "Do check
    LOOP AT rap_generator_projects INTO DATA(rap_generator_project).

      GET PERMISSIONS ONLY INSTANCE ENTITY zdmo_c_rapgeneratorbo
                FROM VALUE #( ( RapNodeUUID = rap_generator_project-RapNodeUUID ) )
                REQUEST permission_request
                RESULT DATA(permission_result)
                FAILED DATA(failed_permission_result)
                REPORTED DATA(reported_permission_result).


      LOOP AT components_permission_request INTO component_permission_request.

        IF permission_result-global-%field-(component_permission_request-name) = if_abap_behv=>fc-f-mandatory
                                AND rap_generator_project-(component_permission_request-name) IS INITIAL.

          APPEND VALUE #( %tky = rap_generator_project-%tky ) TO failed-rapgeneratorbo.

          "since %element-(component_permission_request-name) = if_abap_behv=>mk-on could not be added using a VALUE statement
          "add the value via assigning value to the field of a structure

          CLEAR reported_rapgeneratorbo_line.
          reported_rapgeneratorbo_line-%tky = rap_generator_project-%tky.
          reported_rapgeneratorbo_line-%element-(component_permission_request-name) = if_abap_behv=>mk-on.
          reported_rapgeneratorbo_line-%msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                                           number   = 071
                                                           severity = if_abap_behv_message=>severity-error
                                                           v1       = |{ component_permission_request-name }|
                                                           v2 = |{ rap_generator_project-BoName }| ).
          APPEND reported_rapgeneratorbo_line  TO reported-rapgeneratorbo.

*          APPEND VALUE #( %tky = entity-%tky
**                   %element-(component_permission_request-name) = if_abap_behv=>mk-on
*                    %msg = new_message(
*                            id       = 'ZDMO_CM_RAP_GEN_MSG'
*                            number   = 013
*                            severity = if_abap_behv_message=>severity-error
*                            v1       = |{ component_permission_request-name }| )
*                           )
*          TO reported-rapgeneratorbo.

        ENDIF.
      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.


  METHOD createbo.

    TYPES: BEGIN OF ty_longtext,
             msgv1(50),
             msgv2(50),
             msgv3(50),
             msgv4(50),
           END OF ty_longtext.
    DATA update TYPE TABLE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbo.
    DATA update_line TYPE STRUCTURE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbo .



    "check json string
    "if this is not valid, raise an exception

    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
          ENTITY rapgeneratorbo
*            FIELDS ( jsonstring abaplanguageversion boname )
            ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(rapbos).

    "Do check
    LOOP AT rapbos INTO DATA(rapbo).

      TRY.

          IF rapbo-abaplanguageversion = zdmo_cl_rap_node=>abap_language_version-standard.
            DATA(check_rapbo_on_prem) =  zdmo_cl_rap_generator_on_prem=>create_for_on_prem_development( rapbo-jsonstring ).
          ELSE.
            DATA(check_rapbo_cloud) =  zdmo_cl_rap_generator=>create_for_cloud_development( rapbo-jsonstring ).
          ENDIF.

        CATCH zdmo_cx_rap_generator INTO DATA(rapobo_exception).
          DATA(exception_text) = rapobo_exception->get_text(  ).
          DATA(msg) = rapobo_exception->get_message(  ).

          "Set failed keys
          APPEND VALUE #( %tky = rapbo-%tky )
                 TO failed-rapgeneratorbo.

          "Set message
          APPEND VALUE #( %tky = rapbo-%tky
                          %element-jsonstring = if_abap_behv=>mk-on
                          %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                              number   = msg->value-msgno
                                              severity = if_abap_behv_message=>severity-error
                                              v1       =  msg->value-msgv1
                                              v2       =  msg->value-msgv2
                                              v3       =  msg->value-msgv3
                                              v4       =  msg->value-msgv4 )
                         )
                 TO reported-rapgeneratorbo.
          RETURN.
      ENDTRY.
    ENDLOOP.


    LOOP AT rapbos INTO rapbo.
      "set a flag to check in the save sequence that a job is to be scheduled
      update_line-BoIsGenerated = abap_true.
      update_line-%tky      = rapbo-%tky.
      APPEND update_line TO update.
    ENDLOOP.


    MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      UPDATE FIELDS (
                      BoIsGenerated
                      ) WITH update
    REPORTED reported
    FAILED failed
    MAPPED mapped.

    IF failed IS INITIAL.
      "Read changed data for action result
      READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo
          ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT rapbos.
      result = VALUE #( FOR rapbo2 IN rapbos ( %tky   = rapbo2-%tky
                                               %param = rapbo2 ) ).
    ENDIF.

  ENDMETHOD.

  METHOD setnamespace.


    DATA update TYPE TABLE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbo.
    DATA update_line TYPE STRUCTURE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbo .

    DATA node TYPE REF TO zdmo_cl_rap_node.
    DATA xco_api TYPE REF TO zdmo_cl_rap_xco_lib.


    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
      ENTITY rapgeneratorbo
      FIELDS ( packagename abaplanguageversion )
      WITH CORRESPONDING #( keys )
      RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).

      IF rapbo-abaplanguageversion = zdmo_cl_rap_node=>abap_language_version-standard.
        xco_api = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
      ELSE.
        xco_api = NEW zdmo_cl_rap_xco_cloud_lib(  ).
      ENDIF.

      update_line-packagelanguageversion = xco_api->get_abap_language_version( rapbo-packagename ).

      node = NEW zdmo_cl_rap_node( xco_api ).

      update_line-%tky      = rapbo-%tky.

      CHECK rapbo-packagename IS NOT INITIAL.

      node->set_package( rapbo-packagename ).
      node->set_namespace(  ).

      update_line-namespace = node->namespace.
      APPEND update_line TO update.

    ENDLOOP.


    " Update the namespace of all relevant business objects
    MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      UPDATE FIELDS (
                      namespace
                      packagelanguageversion
                      ) WITH update

    REPORTED DATA(update_reported).

    LOOP AT rapbos INTO rapbo.
      CHECK rapbo-packagename IS NOT INITIAL.
      READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbo BY \_rapgeneratorbonode
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbonode
                EXECUTE setrepoobjectnames
                  FROM VALUE #( ( %tky = rapbo_node-%tky ) ).
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.



  METHOD get_instance_features.

    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(rapbos).

    result = VALUE #( FOR rapbo IN rapbos
                    ( %tky                   = rapbo-%tky

                      %field-packagename    = COND #( WHEN rapbo-packagename IS INITIAL
                                                      THEN if_abap_behv=>fc-f-mandatory
                                                      ELSE if_abap_behv=>fc-f-read_only )
                      %field-namespace      = COND #( WHEN rapbo-packagename IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-mandatory
                                                      ELSE if_abap_behv=>fc-f-read_only )
                      %action-edit          = COND #( WHEN rapbo-jobname IS INITIAL
                                                      THEN if_abap_behv=>fc-o-enabled
                                                      ELSE if_abap_behv=>fc-o-disabled )
                      %action-createbo      = COND #( WHEN rapbo-%is_draft = if_abap_behv=>mk-off AND
                                                           rapbo-jobname IS INITIAL
                                                      THEN if_abap_behv=>fc-o-enabled
                                                      ELSE if_abap_behv=>fc-o-disabled )
                      %field-MultiInlineEdit  = COND #( WHEN rapbo-ImplementationType = zdmo_cl_rap_node=>implementation_type-managed_semantic
                                                         AND rapbo-DataSourceType = zdmo_cl_rap_node=>data_source_types-table
                                                         AND rapbo-DraftEnabled = abap_true
                                                         AND rapbo-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                                                        THEN if_abap_behv=>fc-f-unrestricted
                                                        ELSE if_abap_behv=>fc-f-read_only )
                      %field-CustomizingTable = COND #( WHEN rapbo-ImplementationType = zdmo_cl_rap_node=>implementation_type-managed_semantic
                                                         AND rapbo-DataSourceType = zdmo_cl_rap_node=>data_source_types-table
                                                         AND rapbo-DraftEnabled = abap_true
                                                         AND rapbo-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                                                        THEN if_abap_behv=>fc-f-unrestricted
                                                        ELSE if_abap_behv=>fc-f-read_only )
                      %field-AddToManageBusinessConfig  = COND #( WHEN rapbo-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                                                                  THEN if_abap_behv=>fc-f-unrestricted
                                                                  ELSE if_abap_behv=>fc-f-read_only )


                                                         ) ).

  ENDMETHOD.

  METHOD setobjectnames.

    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
      ENTITY rapgeneratorbo
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).
      CHECK rapbo-packagename IS NOT INITIAL.
      READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbo BY \_rapgeneratorbonode
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbonode
                EXECUTE setrepoobjectnames
                  FROM VALUE #( ( %tky = rapbo_node-%tky ) ).
      ENDLOOP.

    ENDLOOP.



  ENDMETHOD.

  METHOD setfieldnames.

    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
       ENTITY rapgeneratorbo
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).
      CHECK rapbo-packagename IS NOT INITIAL.
      READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbo BY \_rapgeneratorbonode
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbonode
                EXECUTE setrepofieldnames
                  FROM VALUE #( ( %tky = rapbo_node-%tky ) ).
      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD createboandrootnode.

    CONSTANTS mycid_rapbonode TYPE abp_behv_cid VALUE 'My%CID_rapbonode' ##NO_TEXT.

    DATA(xco_on_prem_library) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
      DATA(abap_language_version) = zdmo_cl_rap_node=>abap_language_version-standard.
    ELSE.
      abap_language_version = zdmo_cl_rap_node=>abap_language_version-abap_for_cloud_development.
    ENDIF.

    LOOP AT keys INTO DATA(ls_key).

      MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo
          CREATE
            SET FIELDS WITH VALUE #( ( %is_draft        = if_abap_behv=>mk-on
                                       %cid             = ls_key-%cid
                                       %data-rootentityname   = ls_key-%param-entity_name
                                       %data-packagename = ls_key-%param-package_name
                                       %data-abaplanguageversion = abap_language_version "ls_key-%param-language_version
                                       %data-draftenabled = abap_true
                                       %data-implementationtype = zdmo_cl_rap_node=>implementation_type-managed_uuid
                                       %data-datasourcetype = zdmo_cl_rap_node=>data_source_types-table
                                       %data-bindingtype = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui

                                        ) )
        ENTITY rapgeneratorbo
          CREATE BY \_rapgeneratorbonode
            SET FIELDS WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on
                                       %cid_ref  = ls_key-%cid
                                       %target   = VALUE #( (
                                                              %is_draft = if_abap_behv=>mk-on
                                                              %cid      = mycid_rapbonode
                                                              entityname = ls_key-%param-entity_name
*                                                              parententityname = ls_key-%param-entity_name
                                                              isrootnode = abap_true
                                                              hierarchydistancefromroot = 0


                                                               ) )


                                        ) )
        MAPPED   mapped
        FAILED   failed
        REPORTED reported.

      CHECK mapped-rapgeneratorbo[] IS NOT INITIAL.

      APPEND VALUE #( %cid = ls_key-%cid
                      %param = VALUE #( %is_draft = mapped-rapgeneratorbo[ 1 ]-%is_draft
                                        %key      = mapped-rapgeneratorbo[ 1 ]-%key ) ) TO result.

      MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
               ENTITY rapgeneratorbonode
                 UPDATE FROM VALUE #( (     %is_draft = if_abap_behv=>mk-on
                                            nodeuuid  = mapped-rapgeneratorbonode[ 1 ]-nodeuuid
                                            parentuuid = mapped-rapgeneratorbonode[ 1 ]-nodeuuid
                                            rootuuid = mapped-rapgeneratorbonode[ 1 ]-nodeuuid
                     ) )
                EXECUTE setrepoobjectnames
                  FROM VALUE #( (   %is_draft      =  if_abap_behv=>mk-on
                                    %key-nodeuuid  =  mapped-rapgeneratorbonode[ 1 ]-nodeuuid ) )


     FAILED   failed
     REPORTED reported.





    ENDLOOP.

  ENDMETHOD.

  METHOD allowed_combinations.

    "Get values of fields
    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

      IF entity-DataSourceType = zdmo_cl_rap_node=>data_source_types-abstract_entity AND
         ( entity-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui OR
           entity-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_web_api ) .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-rapgeneratorbo.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 063
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-rapgeneratorbo.
      ENDIF.

      IF entity-DataSourceType = zdmo_cl_rap_node=>data_source_types-abstract_entity AND
         entity-DraftEnabled = abap_true .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-rapgeneratorbo.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 072
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-rapgeneratorbo.
      ENDIF.

      IF ( entity-MultiInlineEdit = abap_true OR entity-CustomizingTable = abap_true ) AND
         entity-DataSourceType <> zdmo_cl_rap_node=>data_source_types-table .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-rapgeneratorbo.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 067
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-DataSourceType }| ) )
               TO reported-rapgeneratorbo.
      ENDIF.

      IF ( entity-MultiInlineEdit = abap_true OR entity-CustomizingTable = abap_true ) AND
         entity-ImplementationType <> zdmo_cl_rap_node=>implementation_type-managed_semantic .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-rapgeneratorbo.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 068
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-ImplementationType }| ) )
               TO reported-rapgeneratorbo.
      ENDIF.

      IF entity-MultiInlineEdit = abap_true AND
         ( entity-BindingType <> zdmo_cl_rap_node=>binding_type_name-odata_v4_ui OR
           entity-DraftEnabled = abap_false ) .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-rapgeneratorbo.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 058
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-rapgeneratorbo.
      ENDIF.

      IF entity-CustomizingTable = abap_true AND
         ( entity-BindingType <> zdmo_cl_rap_node=>binding_type_name-odata_v4_ui OR
           entity-DraftEnabled = abap_false ) .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-rapgeneratorbo.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 059
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-rapgeneratorbo.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD createJsonString.

    DATA json_string_builder TYPE REF TO zdmo_cl_rap_gen_build_json.
    DATA update TYPE TABLE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbo.
    DATA update_line TYPE STRUCTURE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbo .

    READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
       ENTITY rapgeneratorbo
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(rapbos).

    LOOP AT rapbos ASSIGNING FIELD-SYMBOL(<rapbo>).
      READ ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
        ALL FIELDS
        WITH VALUE #( ( %tky = <rapbo>-%tky ) )
        RESULT DATA(rapnodes).
    ENDLOOP.


    DATA it_rapgen_node  TYPE zdmo_cl_rap_gen_build_json=>tt_rapgen_node .
    DATA it_rapgen_bo  TYPE zdmo_cl_rap_gen_build_json=>tt_rapgen_bo .

    MOVE-CORRESPONDING rapbos TO it_rapgen_bo.
    MOVE-CORRESPONDING rapnodes TO it_rapgen_node.

    LOOP AT rapbos INTO DATA(rapbo).

      json_string_builder = NEW zdmo_cl_rap_gen_build_json(
          iv_bo_uuid =  rapbo-%tky-rapnodeuuid
          it_rapgen_bo = it_rapgen_bo
          it_rapgen_node = it_rapgen_node
      ).

      DATA(root_node)      =   it_rapgen_node[ isrootnode = abap_true headeruuid  = rapbo-%tky-rapnodeuuid  ].

      update_line-jsonstring  = json_string_builder->create_json(  ).
      update_line-%tky      = rapbo-%tky.
      APPEND update_line TO update.

    ENDLOOP.

    MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
       ENTITY rapgeneratorbo
       UPDATE FIELDS (
                jsonstring
                ) WITH update
       REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).




  ENDMETHOD.

ENDCLASS.

CLASS lsc_zdmo_i_rapgeneratorbo DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zdmo_i_rapgeneratorbo IMPLEMENTATION.

  METHOD save_modified.


    DATA ls_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA lt_job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA ls_job_parameters TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA ls_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA lv_jobname TYPE cl_apj_rt_api=>ty_jobname.
    DATA lv_jobcount TYPE cl_apj_rt_api=>ty_jobcount.

    LOOP AT update-rapgeneratorbo INTO DATA(update_rapgeneratorbo)
            WHERE BoIsGenerated = abap_true AND
                  %control-BoIsGenerated = if_abap_behv=>mk-on.

      " ls_start_info-start_immediately MUST NOT BE USED
      " since it performs a commit work which would cause a dump
      GET TIME STAMP FIELD DATA(start_time_of_job).
      ls_start_info-timestamp = start_time_of_job.

      ls_job_parameters-name = zdmo_cl_rap_node=>job_selection_name. "'I_VIEW'.
      ls_value-sign = 'I'.
      ls_value-option = 'EQ'.
      ls_value-low = update_rapgeneratorbo-boname.
      APPEND ls_value TO ls_job_parameters-t_value.
      APPEND ls_job_parameters TO lt_job_parameters.

      TRY.
          cl_apj_rt_api=>schedule_job(
              EXPORTING
              iv_job_template_name = zdmo_cl_rap_node=>job_template_name
              iv_job_text = |Generate { update_rapgeneratorbo-boname }|
              is_start_info = ls_start_info
              it_job_parameter_value = lt_job_parameters
              IMPORTING
              ev_jobname  = lv_jobname
              ev_jobcount = lv_jobcount
              ).

          UPDATE zdmo_rapgen_bo SET job_count = @lv_jobcount , job_name = @lv_jobname WHERE rap_node_uuid = @update_rapgeneratorbo-rapnodeuuid.

        CATCH cx_apj_rt INTO DATA(job_scheduling_error).
          "handle exception
          TYPES: BEGIN OF ty_longtext,
                   msgv1(50),
                   msgv2(50),
                   msgv3(50),
                   msgv4(50),
                 END OF ty_longtext.
          DATA: ls_longtext      TYPE ty_longtext.
          ls_longtext = job_scheduling_error->bapimsg-message .

          "reported-rapgeneratorbo
          APPEND VALUE #(  rapnodeuuid = update_rapgeneratorbo-rapnodeuuid
*                   %element-%field-(component_request-name) = if_abap_behv=>mk-on
             %msg = new_message(
                      id       = 'ZDMO_CM_RAP_GEN_MSG'
                      number   = 064
                      severity = if_abap_behv_message=>severity-error
                      v1       = |{ ls_longtext-msgv1 }|
                      v2       = |{ ls_longtext-msgv2 }|
                    )
                     )
           TO reported-rapgeneratorbo.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
