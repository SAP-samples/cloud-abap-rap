CLASS lhc_rapgeneratorbo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR rapgeneratorbo RESULT result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR rapgeneratorbo
        RESULT result,
*      addChild1 FOR MODIFY
*        IMPORTING keys FOR ACTION rapgeneratorbo~addchild1 RESULT result ,
*      addchild FOR MODIFY
*        IMPORTING keys FOR ACTION rapgeneratorbo~addchild ,
      createbo FOR MODIFY
        IMPORTING keys FOR ACTION rapgeneratorbo~createbo RESULT result,
      setnamespace FOR DETERMINE ON MODIFY
        IMPORTING keys FOR rapgeneratorbo~setnamespace,
      mandatory_fields_check FOR VALIDATE ON SAVE
        IMPORTING keys FOR rapgeneratorbo~mandatory_fields_check,
      check_json_string FOR VALIDATE ON SAVE
        IMPORTING keys FOR rapgeneratorbo~check_json_string,
      createjsonstring FOR DETERMINE ON SAVE
        IMPORTING keys FOR rapgeneratorbo~createjsonstring,
      setobjectnames FOR DETERMINE ON MODIFY
        IMPORTING keys FOR rapgeneratorbo~setobjectnames,
      setfieldnames FOR DETERMINE ON MODIFY
        IMPORTING keys FOR rapgeneratorbo~setfieldnames,
      createboandrootnode FOR MODIFY
        IMPORTING keys FOR ACTION rapgeneratorbo~createboandrootnode RESULT result.

ENDCLASS.

CLASS lhc_rapgeneratorbo IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.




  METHOD createbo.

    TYPES: BEGIN OF ty_longtext,
             msgv1(50),
             msgv2(50),
             msgv3(50),
             msgv4(50),
           END OF ty_longtext.
    DATA: ls_longtext      TYPE ty_longtext.

    DATA update TYPE TABLE FOR UPDATE zdmo_i_rapgeneratorbo\\rapgeneratorbo.
    DATA update_line TYPE STRUCTURE FOR UPDATE zdmo_i_rapgeneratorbo\\rapgeneratorbo .

    DATA ls_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA lt_job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA ls_job_parameters TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA ls_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA lv_jobname TYPE cl_apj_rt_api=>ty_jobname.
    DATA lv_jobcount TYPE cl_apj_rt_api=>ty_jobcount.

    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

    TRY.


        LOOP AT rapbos INTO DATA(rapbo).

          "background job API does not provide an existing check for the job template
          "job api has to try to create a new job catalog entry and
          "a new job template.

*          DATA(background_job) = NEW ZDMO_cl_rap_gen_in_background(  ).
*          background_job->create_job_template( rapbo-PackageName ).

          ls_start_info-start_immediately = 'X'.
          ls_job_parameters-name = 'I_VIEW'.
          ls_value-sign = 'I'.
          ls_value-option = 'EQ'.
          ls_value-low = rapbo-boname.
          APPEND ls_value TO ls_job_parameters-t_value.
          APPEND ls_job_parameters TO lt_job_parameters.


          cl_apj_rt_api=>schedule_job(
              EXPORTING
              iv_job_template_name = zdmo_cl_rap_node=>job_template_name
              iv_job_text = |Generate { rapbo-boname }|
              is_start_info = ls_start_info
*        is_scheduling_info = ls_scheduling_info
*        is_end_info = ls_end_info
              it_job_parameter_value = lt_job_parameters
              IMPORTING
              ev_jobname  = lv_jobname
              ev_jobcount = lv_jobcount
              ).

          update_line-jobname = lv_jobname.
          update_line-jobcount  = lv_jobcount.

          update_line-%tky      = rapbo-%tky.
          APPEND update_line TO update.


        ENDLOOP.


        MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo
          UPDATE FIELDS (
                          jobname
                          jobcount
                          ) WITH update

        REPORTED reported
        FAILED failed
        MAPPED mapped.

        IF failed IS INITIAL.

          "Read changed data for action result
          READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
            ENTITY rapgeneratorbo
              ALL FIELDS WITH
              CORRESPONDING #( keys )
            RESULT rapbos.

          result = VALUE #( FOR rapbo2 IN rapbos ( %tky   = rapbo2-%tky
                                                   %param = rapbo2 ) ).

        ENDIF.

      CATCH cx_apj_rt  INTO DATA(job_scheduling_error).


*        IF job_scheduling_error->if_t100_message~t100key-msgno = cx_apj_rt=>cx_job_doesnt_exist-msgno AND
*           job_scheduling_error->if_t100_message~t100key-msgid = cx_apj_rt=>cx_job_doesnt_exist-msgid.
        IF job_scheduling_error->bapimsg-id = cx_apj_rt=>cx_job_doesnt_exist-msgid AND
           job_scheduling_error->bapimsg-number = '015' .

*          DATA(rap_generator_setup) = NEW zdmo_cl_rap_generator_setup(  ).
*          DATA(application_log_object_name) = rap_generator_setup->create_application_log_entry(  ).
*          DATA(job_catalog_name) = rap_generator_setup->create_job_catalog_entry(  ).
*          DATA(job_template_name) = rap_generator_setup->create_job_template_entry(  ).

          ls_longtext = CONV #( |Job template { zdmo_cl_rap_node=>job_template_name } does not exist. Run setup class.| ).
        ELSE.
          ls_longtext = job_scheduling_error->bapimsg-message .
        ENDIF.

        APPEND VALUE #( %tky = keys[ 1 ]-%tky )
                         TO failed-rapgeneratorbo.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
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




  ENDMETHOD.

  METHOD setnamespace.


    DATA update TYPE TABLE FOR UPDATE zdmo_i_rapgeneratorbo\\rapgeneratorbo.
    DATA update_line TYPE STRUCTURE FOR UPDATE zdmo_i_rapgeneratorbo\\rapgeneratorbo .

    DATA node TYPE REF TO zdmo_cl_rap_node.
    DATA xco_api TYPE REF TO zdmo_cl_rap_xco_lib.


    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
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

*      IF rapbo-PackageName IS NOT INITIAL.
      node->set_package( rapbo-packagename ).
      node->set_namespace(  ).
      update_line-namespace = node->namespace.
*      ENDIF.


      APPEND update_line TO update.

    ENDLOOP.


    " Update the namespace of all relevant business objects
    MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      UPDATE FIELDS (
                      namespace
                      packagelanguageversion
                      ) WITH update

    REPORTED DATA(update_reported).

    LOOP AT rapbos INTO rapbo.
      CHECK rapbo-packagename IS NOT INITIAL.
      READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbo BY \_rapgeneratorbonode
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbonode
                EXECUTE setrepoobjectnames
                  FROM VALUE #( ( %tky = rapbo_node-%tky ) ).
      ENDLOOP.

    ENDLOOP.

*    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*          ENTITY rapgeneratorbo
*            EXECUTE createjsonstring
*              FROM CORRESPONDING  #( keys ).





  ENDMETHOD.

  METHOD mandatory_fields_check.

    DATA permission_request TYPE STRUCTURE FOR PERMISSIONS REQUEST zdmo_c_rapgeneratorbo.

    DATA instance_feature_keys TYPE TABLE FOR INSTANCE FEATURES KEY zdmo_i_rapgeneratorbo\\rapgeneratorbo.
    DATA requested_features  TYPE STRUCTURE FOR INSTANCE FEATURES REQUEST zdmo_i_rapgeneratorbo\\rapgeneratorbo .

    DATA result_instance_features TYPE TABLE FOR INSTANCE FEATURES RESULT zdmo_i_rapgeneratorbo\\rapgeneratorbo.
    DATA failed_instance_features TYPE RESPONSE FOR FAILED EARLY zdmo_i_rapgeneratorbo  .
    DATA reported_instance_features TYPE RESPONSE FOR REPORTED EARLY zdmo_i_rapgeneratorbo .

    DATA(description_permission_request) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( permission_request-%field ) ) ).
    DATA(components_permission_request) = description_permission_request->get_components(  ).

    DATA(description_requested_features) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( requested_features-%field ) ) ).
    DATA(components_requested_features) = description_requested_features->get_components(  ).

    LOOP AT components_permission_request INTO DATA(component_permission_request).
      permission_request-%field-(component_permission_request-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    LOOP AT components_requested_features INTO DATA(component_requested_features).
      requested_features-%field-(component_requested_features-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    " Get Permissions without instance keys, as we are only interested in static / global feature control ( mandatory )
    GET PERMISSIONS OF  zdmo_c_rapgeneratorbo
      ENTITY rapgeneratorbo
      FROM VALUE #(  )
    REQUEST permission_request
    RESULT DATA(permission_result)
    FAILED DATA(f_p)
    REPORTED DATA(r_p).



    instance_feature_keys = VALUE #( FOR key IN keys
       (
         %is_draft  = key-%is_draft
         rapnodeuuid  = key-rapnodeuuid
        "Component Groups
        %key  = key-%key
        %tky  = key-%tky
        %pky  = key-%pky
        ) ) .


    get_instance_features(
      EXPORTING
        keys               = instance_feature_keys
        requested_features = requested_features
      CHANGING
        result             = result_instance_features
        failed             = failed_instance_features
        reported           = reported_instance_features
    ).

    "Get Mandatory Fields
    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    "Do check
    LOOP AT entities INTO DATA(entity).

      LOOP AT components_permission_request INTO component_permission_request.

        IF permission_result-global-%field-(component_permission_request-name) = if_abap_behv=>fc-f-mandatory
           AND entity-(component_permission_request-name) IS INITIAL.

          APPEND VALUE #( %tky = entity-%tky )
                 TO failed-rapgeneratorbo.
          APPEND VALUE #( %tky = entity-%tky
*                   %element-%field-(component_request-name) = if_abap_behv=>mk-on
                   %msg = new_message(
                            id       = 'ZDMO_CM_RAP_GEN_MSG'
                            number   = 013
                            severity = if_abap_behv_message=>severity-error
                            v1       = |{ component_permission_request-name }|
                          )
                           )
          TO reported-rapgeneratorbo.
        ENDIF.
      ENDLOOP.

      LOOP AT components_requested_features INTO component_requested_features.

        IF entity-(component_requested_features-name) IS INITIAL.
          APPEND VALUE #( %tky = entity-%tky )
                 TO failed-rapgeneratorbo.
          APPEND VALUE #( %tky = entity-%tky
*                   %element-%field-(component_request-name) = if_abap_behv=>mk-on
                   %msg = new_message(
                            id       = 'ZDMO_CM_RAP_GEN_MSG'
                            number   = 013
                            severity = if_abap_behv_message=>severity-error
                            v1       = |{ component_requested_features-name }|
                          )
                           )
          TO reported-rapgeneratorbo.
        ENDIF.

      ENDLOOP.


    ENDLOOP.




*    DATA instance_feature_keys  TYPE TABLE FOR INSTANCE FEATURES KEY ZDMO_i_rapgeneratorbo\\rapgeneratorbo ." [ derived type... ]
*    DATA requested_features  TYPE STRUCTURE FOR INSTANCE FEATURES REQUEST ZDMO_i_rapgeneratorbo\\rapgeneratorbo ." [ derived type... ]
*
*    DATA  result_instance_features  TYPE TABLE FOR INSTANCE FEATURES RESULT ZDMO_i_rapgeneratorbo\\rapgeneratorbo  ." optional  [ derived type... ]
*    DATA  failed_instance_features  TYPE RESPONSE FOR FAILED EARLY ZDMO_i_rapgeneratorbo ." [ derived type... ]
*    DATA  reported_instance_features  TYPE RESPONSE FOR REPORTED EARLY ZDMO_i_rapgeneratorbo ." [ derived type... ]
*
*    instance_feature_keys = VALUE #( FOR instance_feature_key IN keys
*    (
*      %is_draft  = instance_feature_key-%is_draft
*     RapNodeUUID = instance_feature_key-rapnodeuuid
*     "Component Groups
*     %key  = instance_feature_key-%key
*     %tky  = instance_feature_key-%tky
*     %pky  = instance_feature_key-%pky
*     ) ) .
*
*    requested_features-%field-BindingType = if_abap_behv=>mk-on.
*    requested_features-%field-DataSourceType = if_abap_behv=>mk-on.
*    requested_features-%field-ImplementationType = if_abap_behv=>mk-on.
*    requested_features-%field-PackageName = if_abap_behv=>mk-on.
*
*    get_instance_features(
*      EXPORTING
*        keys               = instance_feature_keys
*        requested_features = requested_features
*      CHANGING
*        result             = result_instance_features
*        failed             = failed_instance_features
*        reported           = reported_instance_features
*    ).
*
*
*
*    "Get Mandatory Fields
*    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*    ENTITY rapgeneratorbo
*      FIELDS ( packagename bindingtype implementationtype datasourcetype )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(rapbos).
*
*    "Do check
*    LOOP AT rapbos INTO DATA(rapbo).
**        APPEND VALUE #( %tky = rapbo-%tky
**                        %state_area = 'MANDATORY_FIELDS_CHECK')
**               TO reported-rapgeneratorbo.
*
*      IF rapbo-packagename IS INITIAL
**      or
**         rapbo-BindingType is initial or
**         rapbo-ImplementationType is initial or
**         rapbo-DataSourceType IS INITIAL
*         .
*
**
**      APPEND VALUE #( %tky = rapbo-%tky
**                        %state_area = 'mandatory_fields_check')
**               TO reported-rapgeneratorbo.
*
*        "Set failed keys
*        APPEND VALUE #( %tky = rapbo-%tky )
*               TO failed-rapgeneratorbo.
*
*        "Set message
*        APPEND VALUE #( %tky = rapbo-%tky
*                        %element-packagename = if_abap_behv=>mk-on
**                        %state_area = 'MANDATORY_FIELDS_CHECK'
*                        %msg = new_message(
*                                 id       = 'ZDMO_CM_RAP_GEN_MSG'
*                                 number   = 013
*                                 severity = if_abap_behv_message=>severity-error
*                                 v1       = 'Packagename'
*                               )
**                          %msg   = NEW ZDMO_cm_flight_messages(
**                                                                textid   = ZDMO_cm_rap_gen_msg=>parameter_is_initial
**                                                                severity = if_abap_behv_message=>severity-error )
*
*
*                                )
*               TO reported-rapgeneratorbo.
*      ENDIF.
*    ENDLOOP.
*
*
  ENDMETHOD.
*
  METHOD check_json_string.

    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo
          FIELDS ( jsonstring abaplanguageversion )
          WITH CORRESPONDING #( keys )
          RESULT DATA(rapbos).



    "Do check
    LOOP AT rapbos INTO DATA(rapbo).

      IF rapbo-jsonstring IS NOT INITIAL.
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
                            %msg = new_message(
                                     id       = 'ZDMO_CM_RAP_GEN_MSG'
                                     number   = 016 "msg->value-msgno
                                     severity = if_abap_behv_message=>severity-error
                                     v1       = exception_text "msg->value-msgv1
*                                     v2       = msg->value-msgv2
*                                     v3       = msg->value-msgv3
*                                     v4      =  msg->value-msgv4

                                   )

                                    )
                   TO reported-rapgeneratorbo.


        ENDTRY.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD createjsonstring.
    DATA json_string_builder TYPE REF TO zdmo_cl_rap_gen_build_json.

    DATA update TYPE TABLE FOR UPDATE zdmo_i_rapgeneratorbo\\rapgeneratorbo.
    DATA update_line TYPE STRUCTURE FOR UPDATE zdmo_i_rapgeneratorbo\\rapgeneratorbo .

*    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*      ENTITY RAPGeneratorBO
*      FIELDS ( BoName )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(rapbos).

    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

    LOOP AT rapbos ASSIGNING FIELD-SYMBOL(<rapbo>).
      READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
     ENTITY rapgeneratorbo BY \_rapgeneratorbonode
      ALL FIELDS "( FlightPrice CurrencyCode )
     WITH VALUE #( ( %tky = <rapbo>-%tky ) )
     RESULT DATA(rapnodes).

    ENDLOOP.


*    ENTITY RAPGeneratorBONode
*    by \_RAPGeneratorBO
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(rapbo_nodes).

    DATA it_rapgen_node  TYPE zdmo_cl_rap_gen_build_json=>tt_rapgen_node .
    DATA it_rapgen_bo  TYPE zdmo_cl_rap_gen_build_json=>tt_rapgen_bo .
    DATA iv_rapgen_node  TYPE zdmo_cl_rap_gen_build_json=>ty_rapgen_node .
    DATA iv_rapgen_bo  TYPE zdmo_cl_rap_gen_build_json=>ty_rapgen_bo  .


    CLEAR it_rapgen_bo.

    MOVE-CORRESPONDING rapbos TO it_rapgen_bo.
    MOVE-CORRESPONDING rapnodes TO it_rapgen_node.

    LOOP AT rapbos INTO DATA(rapbo).

      json_string_builder = NEW zdmo_cl_rap_gen_build_json(
          iv_bo_uuid =  rapbo-%tky-rapnodeuuid
          it_rapgen_bo = it_rapgen_bo
          it_rapgen_node = it_rapgen_node
      ).

      DATA(root_node)      =   it_rapgen_node[ isrootnode = abap_true headeruuid  = rapbo-%tky-rapnodeuuid  ].

      update_line-boname = root_node-cdsiview.
*      update_line-ADTLink   = |javascript:window.open( adt://{ sy-sysid }/sap/bc/adt/ddic/ddl/sources/{ root_node-cdsiview } )|.
      update_line-adtlink   = | adt://{ sy-sysid }/sap/bc/adt/ddic/ddl/sources/{ root_node-cdsiview } |.
      update_line-jsonstring  = json_string_builder->create_json(  ).
      update_line-%tky      = rapbo-%tky.
      APPEND update_line TO update.

    ENDLOOP.


    " Update the Booking ID of all relevant bookings
    MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      UPDATE FIELDS (
                      jsonstring
                      boname
                      adtlink
                      ) WITH update

    REPORTED DATA(update_reported).

*    "Read changed data for action result
*    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*      ENTITY rapgeneratorbo
*        ALL FIELDS WITH
*        CORRESPONDING #( keys )
*      RESULT DATA(rapbos2).
*
*    result = VALUE #( FOR rapbo2 IN rapbos2 ( %tky   = rapbo2-%tky
*                                              %param = rapbo2 ) ).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.



  METHOD get_instance_features.

    DATA update TYPE TABLE FOR UPDATE zdmo_i_rapgeneratorbo.
    DATA update_line TYPE STRUCTURE FOR UPDATE zdmo_i_rapgeneratorbo .

    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
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
                                                         ) ).

  ENDMETHOD.

  METHOD setobjectnames.

    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
      ENTITY rapgeneratorbo
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).
      CHECK rapbo-packagename IS NOT INITIAL.
      READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbo BY \_rapgeneratorbonode
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbonode
                EXECUTE setrepoobjectnames
                  FROM VALUE #( ( %tky = rapbo_node-%tky ) ).
      ENDLOOP.

    ENDLOOP.



  ENDMETHOD.

  METHOD setfieldnames.

    READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
       ENTITY rapgeneratorbo
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).
      CHECK rapbo-packagename IS NOT INITIAL.
      READ ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbo BY \_rapgeneratorbonode
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
              ENTITY rapgeneratorbonode
                EXECUTE setrepofieldnames
                  FROM VALUE #( ( %tky = rapbo_node-%tky ) ).
      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD createboandrootnode.

    CONSTANTS mycid_rapbo    TYPE abp_behv_cid VALUE 'My%CID_rapbo' ##NO_TEXT.
    CONSTANTS mycid_rapbonode TYPE abp_behv_cid VALUE 'My%CID_rapbonode' ##NO_TEXT.

    DATA(xco_on_prem_library) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
      DATA(abap_language_version) = zdmo_cl_rap_node=>abap_language_version-standard.
    ELSE.
      abap_language_version = zdmo_cl_rap_node=>abap_language_version-abap_for_cloud_development.
    ENDIF.

    LOOP AT keys INTO DATA(ls_key).

      MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
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

      MODIFY ENTITIES OF zdmo_i_rapgeneratorbo IN LOCAL MODE
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





ENDCLASS.
