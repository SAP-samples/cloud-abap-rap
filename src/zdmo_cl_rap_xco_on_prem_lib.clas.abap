CLASS zdmo_cl_rap_xco_on_prem_lib DEFINITION INHERITING FROM ZDMO_cl_rap_xco_lib
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS get_aggregated_annotations REDEFINITION.
    METHODS get_behavior_definition REDEFINITION.
    METHODS get_class REDEFINITION.
    METHODS get_database_table REDEFINITION.
    METHODS get_data_definition REDEFINITION.
    METHODS get_metadata_extension REDEFINITION.
    METHODS get_package REDEFINITION.
    METHODS get_service_binding REDEFINITION.
    METHODS get_service_definition REDEFINITION.
    METHODS get_structure REDEFINITION.
    METHODS get_view_entity REDEFINITION.
    METHODS get_view REDEFINITION.
    METHODS get_entity REDEFINITION.
    METHODS get_abstract_entity REDEFINITION.
    METHODS add_draft_include REDEFINITION.
    METHODS get_structures REDEFINITION.
    METHODS get_tables REDEFINITION.
    METHODS get_views REDEFINITION.
    METHODS get_packages REDEFINITION.
    METHODS on_premise_branch_is_used REDEFINITION.
    METHODS get_abap_language_version REDEFINITION.
    METHODS publish_service_binding REDEFINITION.
    METHODS un_publish_service_binding REDEFINITION.
    METHODS service_binding_is_published REDEFINITION.
    METHODS get_abap_obj_directory_entry REDEFINITION.
    METHODS get_objects_in_package REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_XCO_ON_PREM_LIB IMPLEMENTATION.


  METHOD add_draft_include.
    DATA:
      draft_template_table_name TYPE ddobjname,
      draft_table_name          TYPE ddobjname,
      lv_return                 TYPE syst_subrc,
      lt_dd03p                  TYPE TABLE OF dd03p,
      lt_dd03p_draft            TYPE TABLE OF dd03p,
      lt_dd12v                  TYPE TABLE OF dd12v,
      lt_dd17v                  TYPE TABLE OF dd17v,
      ls_dd02v                  TYPE dd02v,
      ls_dd09l                  TYPE dd09l,
      state                     TYPE ddgotstate,
      position                  TYPE i.

    FIELD-SYMBOLS:
      <ls_dd03p>           TYPE dd03p.

    draft_template_table_name  = 'ZDMO_DRAFT_INCL'.
    draft_table_name  = table_name.

    "get information about draft include from template table

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = draft_template_table_name
        state         = 'A'
      IMPORTING
        gotstate      = state
        dd02v_wa      = ls_dd02v
        dd09l_wa      = ls_dd09l
      TABLES
        dd03p_tab     = lt_dd03p_draft
        dd12v_tab     = lt_dd12v
        dd17v_tab     = lt_dd17v
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      "RAISE EXCEPTION TYPE cx_cnv_indx_iuuc.
      ASSERT 1 = 0.

    ENDIF.

    "get draft table information.
    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = draft_table_name
        state         = 'A'
      IMPORTING
        gotstate      = state
        dd02v_wa      = ls_dd02v
        dd09l_wa      = ls_dd09l
      TABLES
        dd03p_tab     = lt_dd03p
        dd12v_tab     = lt_dd12v
        dd17v_tab     = lt_dd17v
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    "add draft include structure to draft table
    IF lt_dd03p IS NOT INITIAL.


      position = lines( lt_dd03p ).


      LOOP AT lt_dd03p_draft INTO DATA(ls_dd03p_draft)  .
        ls_dd03p_draft-tabname = draft_table_name.

        CASE ls_dd03p_draft-fieldname.
          WHEN '.INCLUDE'.
            position += 1.
            ls_dd03p_draft-position = position.
            APPEND ls_dd03p_draft TO lt_dd03p.
          WHEN 'DRAFTENTITYCREATIONDATETIME' .
            position += 1.
            ls_dd03p_draft-position = position.
            APPEND ls_dd03p_draft TO lt_dd03p.
          WHEN 'DRAFTENTITYLASTCHANGEDATETIME'.
            position += 1.
            ls_dd03p_draft-position = position.
            APPEND ls_dd03p_draft TO lt_dd03p.
          WHEN 'DRAFTADMINISTRATIVEDATAUUID' .
            position += 1.
            ls_dd03p_draft-position = position.
            APPEND ls_dd03p_draft TO lt_dd03p.
          WHEN 'DRAFTENTITYOPERATIONCODE' .
            position += 1.
            ls_dd03p_draft-position = position.
            APPEND ls_dd03p_draft TO lt_dd03p.
          WHEN 'HASACTIVEENTITY' .
            position += 1.
            ls_dd03p_draft-position = position.
            APPEND ls_dd03p_draft TO lt_dd03p.
          WHEN'DRAFTFIELDCHANGES'.
            position += 1.
            ls_dd03p_draft-position = position.
            APPEND ls_dd03p_draft TO lt_dd03p.
        ENDCASE.
      ENDLOOP.
    ELSE.
      ASSERT 1 = 0.
    ENDIF.

    "change draft table
    CALL FUNCTION 'DDIF_TABL_PUT'
      EXPORTING
        name              = draft_table_name
        dd02v_wa          = ls_dd02v
        dd09l_wa          = ls_dd09l
      TABLES
        dd03p_tab         = lt_dd03p
      EXCEPTIONS
        tabl_not_found    = 1
        name_inconsistent = 2
        tabl_inconsistent = 3
        put_failure       = 4
        put_refused       = 5
        OTHERS            = 6.

    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ELSE.

      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
        EXPORTING
          name        = draft_table_name
          auth_chk    = ' '
        IMPORTING
          rc          = lv_return
        EXCEPTIONS
          not_found   = 1
          put_failure = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_abap_language_version.
    r_abap_language_version = xco_abap_language_version=>object_type->devc->get_object_language_version( CONV #( iv_name ) )->get_value(  ).
  ENDMETHOD.


  METHOD get_abap_obj_directory_entry.
    SELECT SINGLE * FROM
     I_ABAPObjectDirectoryEntry "ObjDirectoryEntry
     WHERE ABAPObjectType = @i_abap_object_type
       AND ABAPObjectCategory = @i_abap_object_category
       AND ABAPObject = @i_abap_object
       INTO CORRESPONDING FIELDS OF @r_abap_object_directory_entry.
  ENDMETHOD.


  METHOD get_abstract_entity.
    IF method_exists_in_class(
         class_name  = 'xco_cds'
         method_name = 'abstract_entity'
       ).
      CALL METHOD xco_cds=>('abstract_entity')
        EXPORTING
          iv_name            = iv_name
        RECEIVING
          ro_abstract_entity = ro_abstract_entity.
    ENDIF.
  ENDMETHOD.


  METHOD  get_aggregated_annotations.
    ro_aggregated_annotations = xco_cds=>annotations->aggregated->of( io_field ).
  ENDMETHOD.


  METHOD  get_behavior_definition.
    ro_behavior_definition = xco_abap_repository=>object->bdef->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_class.
    ro_class = xco_abap_repository=>object->clas->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_database_table.
    ro_table = xco_abap_repository=>object->tabl->database_table->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_data_definition.
    ro_data_definition = xco_abap_repository=>object->ddls->for( iv_name  ).
  ENDMETHOD.


  METHOD get_entity.
    ro_entity = xco_cds=>view_entity( iv_name ).
  ENDMETHOD.


  METHOD  get_metadata_extension.
    ro_metadata_extension  = xco_abap_repository=>object->ddlx->for( iv_name  ).
  ENDMETHOD.


  METHOD get_objects_in_package.
    SELECT * FROM I_ABAPObjectDirectoryEntry WHERE ABAPPackage = @i_package
                                              INTO CORRESPONDING FIELDS OF TABLE @r_objects_in_package .
  ENDMETHOD.


  METHOD  get_package.
    ro_package = xco_abap_repository=>object->devc->for( iv_name  ).
  ENDMETHOD.


  METHOD get_packages.
    IF it_filters IS NOT INITIAL.
      rt_packages =  xco_abap_repository=>objects->devc->where( it_filters )->in( xco_cp_abap=>repository )->get( ).
    ELSE.
      rt_packages = xco_abap_repository=>objects->devc->all->in( xco_cp_abap=>repository )->get( ).
    ENDIF.
  ENDMETHOD.


  METHOD  get_service_binding.
    ro_service_binding = xco_abap_repository=>object->srvb->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_service_definition.
    ro_service_definition = xco_abap_repository=>object->srvd->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_structure.
    ro_structure = xco_abap_repository=>object->tabl->structure->for( iv_name  ).
  ENDMETHOD.


  METHOD get_structures.
*    IF io_filter IS NOT INITIAL.
*      rt_structures =  xco_abap_repository=>objects->tabl->structures->where( VALUE #(
*                                              ( io_filter )
*                                              ) )->in( xco_abap=>repository )->get( ).
*    ELSE.
*      rt_structures = xco_abap_repository=>objects->tabl->structures->all->in( xco_abap=>repository )->get( ).
*    ENDIF.
  ENDMETHOD.


  METHOD get_tables.
    IF it_filters IS NOT INITIAL.
      rt_tables = xco_abap_repository=>objects->tabl->database_tables->where( it_filters )->in( xco_abap=>repository )->get( ).

    ELSE.
      rt_tables = xco_abap_repository=>objects->tabl->database_tables->all->in( xco_abap=>repository )->get( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_view.
    ro_view = xco_cds=>view( iv_name ).
  ENDMETHOD.


  METHOD get_views.
    IF it_filters IS NOT INITIAL.
      rt_data_definitions =  xco_abap_repository=>objects->ddls->where( it_filters )->in( xco_abap=>repository )->get( ).
    ELSE.
      rt_data_definitions = xco_abap_repository=>objects->ddls->all->in( xco_abap=>repository )->get( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_view_entity.
    ro_view_entity = xco_cds=>view_entity( iv_name ).
  ENDMETHOD.


  METHOD on_premise_branch_is_used.
    "get default value abap_false
    super->on_premise_branch_is_used(  ).
    r_value = abap_true.
  ENDMETHOD.


  METHOD publish_service_binding.
    CHECK get_service_binding( i_service_binding )->if_xco_ar_object~exists(  ).
    DATA(service_binding_name_to_upper) = to_upper( i_service_binding ).
    DATA(service_binding) = get_service_binding( CONV #( service_binding_name_to_upper ) ).
    DATA(package) =  service_binding->if_xco_ar_object~get_package(  ).
    DATA(transport_target) = package->read( )-property-transport_layer->get_transport_target( ).
    DATA(transport_target_name) = transport_target->value.
    DATA(new_transport_object) = xco_cts=>transports->customizing( iv_target = transport_target_name )->create_request( |Publish: { i_service_binding } | ).
    DATA(transport_request) = new_transport_object->value.
    DATA(service_binding_name) = to_upper( i_service_binding ).
    IF service_binding_is_published( i_service_binding ) = abap_false.
      DATA(service_binding_type) = service_binding->content( )->get_binding_type( )->value.
      IF service_binding_type-bind_type = 'ODATA'.

        CASE service_binding_type-bind_type_version .
          WHEN 'V4'.
            TRY.

                /iwfnd/cl_v4_cof_facade=>publish_group(
                  EXPORTING
                    iv_group_id        = CONV /iwfnd/v4_med_group_id( service_binding_name )
                    iv_system_alias    = 'LOCAL'
*               iv_do_not_transport = ABAP_true
                    iv_suppress_dialog = abap_true
                  CHANGING
                    cv_transport       = transport_request
                ).
              CATCH /iwfnd/cx_gateway INTO DATA(publish_locally_exception).
                DATA(root_exception_text) = get_root_exception( publish_locally_exception )->get_text( ).
                RAISE EXCEPTION TYPE zdmo_cx_rap_generator
                  EXPORTING
                    textid   = zdmo_cx_rap_generator=>service_binding_publish_err
                    mv_value = root_exception_text.
            ENDTRY.

          WHEN  'V2'.

            DATA: lo_config_facade  TYPE REF TO /iwfnd/cl_cof_facade.
            DATA: lx_cof     TYPE REF TO /iwfnd/cx_cof.
            DATA: lx_previous  TYPE REF TO cx_root  .
            DATA: lx_root_cause  TYPE REF TO /iwfnd/cx_base  .
            DATA: lv_service_id TYPE /iwfnd/med_mdl_srg_identifier.
            DATA: lv_service_name_tech TYPE /iwfnd/med_mdl_srg_name ##NEEDED.

            " activate service

            DATA(a) = 2.

            TRY.
                lo_config_facade = /iwfnd/cl_cof_facade=>get_instance( ).

                lo_config_facade->activate_service(
                  EXPORTING
                    iv_service_name_bep    = CONV #( service_binding_name )
                    iv_service_version_bep = '0001'
                    iv_prefix              = 'Z'
                    iv_system_alias        = 'LOCAL'
                    iv_package             = '$TMP'
*                    iv_process_mode        = /iwfnd/if_mgw_core_types=>gcs_process_mode-co_deployed_only
                    iv_shorten_long_names  = abap_true
                    iv_suppress_dialog     = abap_true
                  IMPORTING
                    ev_srg_identifier      = lv_service_id
                    ev_tech_service_name   = lv_service_name_tech
                    ).


                DATA(result) = lv_service_id.

              CATCH cx_root INTO lx_previous.

                WHILE lx_previous->previous IS NOT INITIAL ."BOUND.
                  lx_previous = lx_previous->previous.    " Get the exception that caused this exception
                  TRY.
                      lx_root_cause ?= lx_previous.
                    CATCH cx_sy_move_cast_error.
                  ENDTRY.
                ENDWHILE.

                DATA(root_cause) = lx_root_cause->get_text( ).

                RAISE EXCEPTION TYPE zdmo_cx_rap_generator
                  EXPORTING
                    textid   = zdmo_cx_rap_generator=>service_binding_publish_err
                    mv_value = root_cause.

            ENDTRY.


          WHEN OTHERS.
            DATA(b) = service_binding_type-bind_type.
            DATA(c) = service_binding_type-bind_type_version.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD service_binding_is_published.
    r_is_published = abap_false.
    CHECK get_service_binding( i_service_binding )->if_xco_ar_object~exists(  ).
    DATA(service_binding_name_to_upper) = to_upper( i_service_binding ).
    DATA(service_binding) = get_service_binding( CONV #( service_binding_name_to_upper ) ).
    DATA(service_binding_type) = service_binding->content( )->get_binding_type( )->value.

    IF service_binding_type-bind_type = 'ODATA' AND service_binding_type-bind_type_version = 'V4'.
      TRY.
          /iwfnd/cl_v4_cof_facade=>get_published_groups(
            IMPORTING
              et_publish_group_info = DATA(published_service_groups) ).
        CATCH /iwfnd/cx_gateway INTO DATA(get_service_groups_exception).
          DATA(root_exception_text) = get_root_exception( get_service_groups_exception )->get_text( ).
          RAISE EXCEPTION TYPE zdmo_cx_rap_generator
            EXPORTING
              textid     = zdmo_cx_rap_generator=>root_cause_exception
              mv_value   = 'Error getting service groups'
              mv_value_2 = root_exception_text.
          EXIT.
      ENDTRY.

      IF line_exists( published_service_groups[ group_id = service_binding_name_to_upper ] ).  " Service group is already published
        r_is_published = abap_true.
      ELSE.
        r_is_published = abap_false.
      ENDIF.

    ELSEIF service_binding_type-bind_type = 'ODATA' AND service_binding_type-bind_type_version = 'V2'.

      DATA: lo_config_facade  TYPE REF TO /iwfnd/cl_cof_facade.
      DATA: lx_cof     TYPE REF TO /iwfnd/cx_cof.
      DATA:   lx_previous  TYPE REF TO cx_root  .
      DATA: lx_root_cause  TYPE REF TO /iwfnd/cx_base  .
      DATA: lv_service_id TYPE /iwfnd/med_mdl_srg_identifier.
      DATA: lv_service_name_tech TYPE /iwfnd/med_mdl_srg_name ##NEEDED.



      TRY.

          " activate service
          lo_config_facade = /iwfnd/cl_cof_facade=>get_instance( ).
          lo_config_facade->is_service_active(
            EXPORTING
              iv_service_name_bep    = CONV #( service_binding_name_to_upper )
              iv_service_version_bep = '0001'
*       iv_prefix              =
*       iv_shorten_long_names  =
     IMPORTING
       ev_active              = r_is_published
          ).
*   CATCH /iwfnd/cx_cof.
        CATCH cx_root INTO DATA(v2_check_activation_exc).

          DATA(root_exception_text2) = get_root_exception( v2_check_activation_exc )->get_text( ).

          RAISE EXCEPTION TYPE zdmo_cx_rap_generator
            EXPORTING
              textid     = zdmo_cx_rap_generator=>root_cause_exception
              mv_value   = 'Error checking if service binding is active'
              mv_value_2 = root_exception_text2.


      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD un_publish_service_binding.
    CHECK get_service_binding( i_service_binding )->if_xco_ar_object~exists(  ).
    DATA(service_binding_name_to_upper) = to_upper( i_service_binding ).
    DATA(service_binding) = get_service_binding( CONV #( service_binding_name_to_upper ) ).
    DATA(package) =  service_binding->if_xco_ar_object~get_package(  ).
    DATA(transport_target) = package->read( )-property-transport_layer->get_transport_target( ).
    DATA(transport_target_name) = transport_target->value.
    DATA(new_transport_object) = xco_cts=>transports->customizing( iv_target = transport_target_name )->create_request( |Unpublish: { i_service_binding } | ).
    DATA(transport_request) = new_transport_object->value.

    IF service_binding_is_published( i_service_binding ) = abap_true.

      DATA(service_binding_type) = service_binding->content( )->get_binding_type( )->value.

      IF service_binding_type-bind_type = 'ODATA' .

        CASE service_binding_type-bind_type_version.

          WHEN 'V4'.

            TRY.
                DATA(service_binding_name) = to_upper( i_service_binding ).
                /iwfnd/cl_v4_cof_facade=>unpublish_group(
                  EXPORTING
                    iv_group_id        = CONV /iwfnd/v4_med_group_id( service_binding_name )
                    iv_suppress_dialog = abap_true
                  CHANGING
                    cv_transport       = transport_request
                ).
              CATCH /iwfnd/cx_gateway INTO DATA(un_publish_locally_exception).
                "handle exception
                DATA(root_exception_text) = get_root_exception( un_publish_locally_exception )->get_text( ).
                RAISE EXCEPTION TYPE zdmo_cx_rap_generator
                  EXPORTING
                    textid   = zdmo_cx_rap_generator=>service_binding_un_publish_err
                    mv_value = root_exception_text.
            ENDTRY.

          WHEN 'V2'.

            " do nothing right now yet

            DATA: lo_config_facade  TYPE REF TO /iwfnd/cl_cof_facade.
            DATA: lx_cof     TYPE REF TO /iwfnd/cx_cof.
            DATA:   lx_previous  TYPE REF TO cx_root  .
            DATA: lx_root_cause  TYPE REF TO /iwfnd/cx_base  .
            DATA: lv_service_id TYPE /iwfnd/med_mdl_srg_identifier.
            DATA: lv_service_name_tech TYPE /iwfnd/med_mdl_srg_name ##NEEDED.

            TRY.

                DATA object_name TYPE /iwfnd/med_mdl_srg_name .
                object_name = service_binding_name_to_upper.
*-check whether service group already exists
                SELECT SINGLE srv_identifier FROM /iwfnd/i_med_srh
                  INTO @DATA(lv_srg_identifier)
                    WHERE object_name     = @object_name
                    AND   service_version = '0001'.

                IF sy-subrc EQ 0.

                  " deactivate service
                  lo_config_facade = /iwfnd/cl_cof_facade=>get_instance( ).
                  lo_config_facade->deactivate_service(
                    iv_service_identifier = lv_srg_identifier
*            iv_transport_cust     = space
*            iv_transport_dev      = space
*            iv_suppress_dialog    =
                  ).
*          CATCH /iwfnd/cx_cof.

                ENDIF.

              CATCH cx_root INTO DATA(v2_check_activation_exc).

                DATA(root_exception_text2) = get_root_exception( v2_check_activation_exc )->get_text( ).

                RAISE EXCEPTION TYPE zdmo_cx_rap_generator
                  EXPORTING
                    textid     = zdmo_cx_rap_generator=>root_cause_exception
                    mv_value   = 'Error checking if service binding is active'
                    mv_value_2 = root_exception_text2.


            ENDTRY.

      ENDCASE.

    ENDIF.

  ENDIF.

  ENDMETHOD.
ENDCLASS.
