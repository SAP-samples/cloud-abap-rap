CLASS zrap_cl_bo_generator DEFINITION

  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
        ty_string_table_type TYPE STANDARD TABLE OF string WITH DEFAULT KEY .

    METHODS constructor
      IMPORTING
                VALUE(iv_package)             TYPE sxco_package
                VALUE(iv_namespace)           TYPE string
                VALUE(iv_header_table)        TYPE sxco_dbt_object_name
                VALUE(iv_header_semantic_key) TYPE sxco_dbt_object_name
                VALUE(iv_header_entity_name)  TYPE sxco_ddef_alias_name
                VALUE(iv_item_table)          TYPE sxco_dbt_object_name OPTIONAL
                VALUE(iv_item_semantic_key)   TYPE sxco_dbt_object_name OPTIONAL
                VALUE(iv_item_entity_name)    TYPE sxco_ddef_alias_name OPTIONAL
                VALUE(iv_suffix)              TYPE string OPTIONAL

      RAISING   cx_parameter_invalid
      .

    METHODS generate_managed_bo
      RETURNING
                VALUE(rt_todos) TYPE ty_string_table_type
      RAISING   cx_xco_gen_put_exception.


  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS:
      "co_hotfixcollection TYPE i VALUE 2,
      co_client          TYPE string VALUE 'CLIENT',
      co_key             TYPE string VALUE 'UUID',
      co_parent_key      TYPE string VALUE 'PARENT_UUID',
      co_root_key        TYPE string VALUE 'ROOT_UUID',
      co_created_by      TYPE string VALUE 'CREATED_BY',
      co_created_at      TYPE string VALUE 'CREATED_AT',
      co_last_changed_by TYPE string VALUE 'LAST_CHANGED_BY',
      co_last_changed_at TYPE string VALUE 'LAST_CHANGED_AT'
      .

    TYPES:
      BEGIN OF ts_field,
        name               TYPE sxco_ad_object_name,
        doma               TYPE sxco_ad_object_name,
        key_indicator      TYPE abap_bool,
        not_null           TYPE abap_bool,
        domain_fixed_value TYPE abap_bool,
        cds_view_field     TYPE sxco_cds_field_name,
      END OF ts_field.



    DATA lt_header_fields TYPE STANDARD TABLE OF ts_field.
    DATA lt_item_fields TYPE STANDARD TABLE OF ts_field.
    DATA ls_header_fields TYPE ts_field.
    DATA ls_item_fields TYPE ts_field.

    DATA mo_create_item_objects TYPE abap_bool.

    DATA mo_namespace TYPE string.

    DATA mo_environment TYPE REF TO if_xco_cp_gen_env_dev_system.

    DATA mo_group_id TYPE string.

    DATA mo_transport TYPE    sxco_transport .

    DATA mo_package      TYPE sxco_package.
    DATA mo_tabl_header  TYPE sxco_dbt_object_name.
    DATA mo_tabl_item  TYPE sxco_dbt_object_name.

    DATA mo_header_semantic_key TYPE sxco_dbt_object_name.
    DATA mo_item_semantic_key TYPE sxco_dbt_object_name.
    DATA mo_header_semantic_db_key TYPE sxco_dbt_object_name.
    DATA mo_item_semantic_db_key TYPE sxco_dbt_object_name.

    DATA mo_view_header TYPE sxco_cds_object_name.
    DATA mo_view_item TYPE sxco_cds_object_name.
    DATA mo_i_cds_header TYPE sxco_cds_object_name.
    DATA mo_i_cds_item TYPE sxco_cds_object_name.

    DATA mo_alias_header TYPE sxco_ddef_alias_name  .
    DATA mo_alias_item   TYPE sxco_ddef_alias_name  .

    DATA mo_viewname_header TYPE sxco_cds_object_name.
    DATA mo_viewname_item TYPE sxco_cds_object_name.

    DATA mo_p_cds_header TYPE sxco_cds_object_name.
    DATA mo_p_cds_item TYPE sxco_cds_object_name.

    DATA mo_i_bdef_header TYPE sxco_cds_object_name .
    DATA mo_p_bdef_header TYPE sxco_cds_object_name .
    DATA mo_i_bil_header  TYPE sxco_ao_object_name.
    DATA mo_i_bil_item    TYPE sxco_ao_object_name.

    DATA mo_assoc_to_item TYPE sxco_cds_association_name.
    DATA mo_assoc_to_header TYPE sxco_cds_association_name.

    DATA mo_service_definition    TYPE sxco_ao_object_name.
    DATA mo_service_binding    TYPE sxco_ao_object_name.

    DATA  mo_transport_target  TYPE if_xco_transport_target=>tv_value.





    METHODS assign_package.

    METHODS create_header_i_cds_view
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS create_item_i_cds_view
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS create_header_p_cds_view
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS create_item_p_cds_view
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS create_header_p_mde_view
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS create_item_p_mde_view
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.


    METHODS create_bdef
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS create_bdef_p
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS create_bdef_impl
      IMPORTING
        io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put.

    METHODS are_repository_obj_names_valid RETURNING VALUE(rv_names_are_valid) TYPE abap_bool.

    METHODS create_item_objects RETURNING VALUE(rv_create_item_objects) TYPE abap_bool.

    METHODS get_root_exception
      IMPORTING
        !ix_exception  TYPE REF TO cx_root
      RETURNING
        VALUE(rx_root) TYPE REF TO cx_root .

ENDCLASS.



CLASS zrap_cl_bo_generator IMPLEMENTATION.

  METHOD constructor.

    IF iv_item_table IS NOT INITIAL OR iv_item_semantic_key IS NOT INITIAL OR iv_item_entity_name IS NOT INITIAL.

      IF iv_item_table IS INITIAL.
        RAISE EXCEPTION TYPE cx_parameter_invalid
          EXPORTING
            parameter = 'parameter iv_item_table is missing'.
      ENDIF.

      IF iv_item_semantic_key IS INITIAL.
        RAISE EXCEPTION TYPE cx_parameter_invalid
          EXPORTING
            parameter = 'parameter iv_item_semantic_key is missing'.
      ENDIF.

      IF iv_item_entity_name IS INITIAL.
        RAISE EXCEPTION TYPE cx_parameter_invalid
          EXPORTING
            parameter = 'parameter iv_item_entity_name is missing'.
      ENDIF.

    ENDIF.

    mo_group_id = iv_suffix .
    mo_package = iv_package .
    mo_tabl_header = iv_header_table .
    mo_tabl_item = iv_item_table .
    mo_alias_header = iv_header_entity_name .
    mo_alias_item = iv_item_entity_name .
    mo_namespace = iv_namespace .

    mo_header_semantic_db_key = iv_header_semantic_key.
    mo_item_semantic_db_key =  iv_item_semantic_key .

    mo_header_semantic_key = to_mixed( mo_header_semantic_db_key ).
    mo_item_semantic_key = to_mixed( mo_item_semantic_db_key ).

    mo_viewname_header =  substring( val = to_upper( mo_alias_header ) len = 10 - strlen( mo_group_id ) ).
    mo_view_header = |{ mo_namespace }V{ mo_viewname_header }{ mo_group_id }|.
    mo_i_cds_header = |{ mo_namespace }I_{ mo_alias_header }{ mo_group_id }|.
    mo_p_cds_header = |{ mo_namespace }C_{ mo_alias_header }{ mo_group_id }|.
    mo_i_bdef_header = mo_i_cds_header.
    mo_p_bdef_header = mo_p_cds_header.
    mo_i_bil_header = |{ mo_namespace }CL_BIL_{ mo_alias_header }{ mo_group_id }|.

    mo_service_definition = |{ mo_namespace }UI_{ mo_alias_header }_M{ mo_group_id }|.
    mo_service_binding = mo_service_definition.

    IF create_item_objects(  ).
      mo_viewname_item =  substring( val = to_upper( mo_alias_item ) len = 10 - strlen( mo_group_id ) ).
      mo_view_item = |{ mo_namespace }V{ mo_viewname_item }{ mo_group_id }|.
      mo_i_cds_item = |{ mo_namespace }I_{ mo_alias_item }{ mo_group_id }|.
      mo_p_cds_item = |{ mo_namespace }C_{ mo_alias_item }{ mo_group_id }|.
      mo_i_bil_item = |{ mo_namespace }CL_BIL_{ mo_alias_item }{ mo_group_id }|.
      mo_assoc_to_item =  '_' && mo_alias_item.
      mo_assoc_to_header =  '_' && mo_alias_header.
    ENDIF.

    IF are_repository_obj_names_valid(  ) <> abap_true.
      "raise some exception
    ENDIF.

    "check if group number is already used
    DATA(lo_name_filter) = xco_cp_abap_repository=>object_name->get_filter( xco_cp_abap_sql=>constraint->contains_pattern(  mo_namespace && '%' && mo_group_id )  ).
    DATA(lt_objects) = xco_cp_abap_repository=>objects->where( VALUE #(
                        ( lo_name_filter ) ) )->in( xco_cp_abap=>repository  )->get(  ).

    IF lt_objects IS NOT INITIAL.
      "raise some exception
    ENDIF.



**********************************************************************

    IF xco_cp_abap_repository=>object->ddls->for( mo_i_cds_header )->exists( ).
      RAISE EXCEPTION TYPE cx_abap_invalid_name
        EXPORTING
          name = | CDS view { mo_i_cds_header } exists|.
    ENDIF.
    IF xco_cp_abap_repository=>object->ddls->for( mo_p_cds_header )->exists( ).
      RAISE EXCEPTION TYPE cx_abap_invalid_name
        EXPORTING
          name = | CDS view { mo_p_cds_header } exists|.
    ENDIF.
    IF create_item_objects(  ).
      IF xco_cp_abap_repository=>object->ddls->for( mo_i_cds_item )->exists( ).
        RAISE EXCEPTION TYPE cx_abap_invalid_name
          EXPORTING
            name = | CDS view { mo_i_cds_item } exists|.
      ENDIF.
      IF xco_cp_abap_repository=>object->ddls->for( mo_p_cds_item )->exists( ).
        RAISE EXCEPTION TYPE cx_abap_invalid_name
          EXPORTING
            name = | CDS view { mo_p_cds_item } exists|.
      ENDIF.
    ENDIF.
    "check existence of meta data extension views
    IF xco_cp_abap_repository=>object->ddlx->for( mo_p_cds_header )->exists( ).
      RAISE EXCEPTION TYPE cx_abap_invalid_name
        EXPORTING
          name = | meta data extension view { mo_p_cds_header } exists|.
    ENDIF.
    IF create_item_objects(  ).
      IF xco_cp_abap_repository=>object->ddlx->for( mo_p_cds_item )->exists( ).
        RAISE EXCEPTION TYPE cx_abap_invalid_name
          EXPORTING
            name = | meta data extension view { mo_p_cds_item } exists|.
      ENDIF.
    ENDIF.
    "check existence of BDEF objects
    IF xco_cp_abap_repository=>object->bdef->for( mo_i_bdef_header )->exists( ).
      RAISE EXCEPTION TYPE cx_abap_invalid_name
        EXPORTING
          name = | behavior definition { mo_i_bdef_header } exists|.
    ENDIF.
    IF xco_cp_abap_repository=>object->bdef->for( mo_p_bdef_header )->exists( ).
      RAISE EXCEPTION TYPE cx_abap_invalid_name
        EXPORTING
          name = | behavior definition { mo_p_bdef_header } exists|.
    ENDIF.
    "check existence of BIL objects
    IF xco_cp_abap_repository=>object->clas->for( mo_i_bil_header )->exists( ).
      RAISE EXCEPTION TYPE cx_abap_invalid_name
        EXPORTING
          name = | behavior implementation class { mo_i_bil_header } exists|.
    ENDIF.
    IF create_item_objects(  ).
      IF xco_cp_abap_repository=>object->clas->for( mo_i_bil_item )->exists( ).
        RAISE EXCEPTION TYPE cx_abap_invalid_name
          EXPORTING
            name = | behavior implementation class { mo_i_bil_item } exists|.
      ENDIF.
    ENDIF.
    "check existence of DDIC views of interface views
    IF xco_cp_abap_repository=>object->for( iv_type = 'VIEW' iv_name = CONV #( mo_view_header ) )->exists( ).
      RAISE EXCEPTION TYPE cx_abap_invalid_name
        EXPORTING
          name = | DDIC view { mo_view_header } exists|.
    ENDIF.
    IF create_item_objects(  ).
      IF xco_cp_abap_repository=>object->for( iv_type = 'VIEW' iv_name = CONV #( mo_view_item ) )->exists( ).
        RAISE EXCEPTION TYPE cx_abap_invalid_name
          EXPORTING
            name = | DDIC view { mo_view_item  } exists|.
      ENDIF.
    ENDIF.


**********************************************************************





    DATA  lo_struct_desc           TYPE REF TO cl_abap_structdescr.
    DATA  lo_type_desc             TYPE REF TO cl_abap_typedescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table .
    DATA ls_components LIKE LINE OF lt_components.
    DATA dref_header TYPE REF TO data.
    DATA dref_item TYPE REF TO data.

    CREATE DATA dref_header TYPE (mo_tabl_header).

    lo_type_desc =  cl_abap_typedescr=>describe_by_data_ref( p_data_ref = dref_header ).
    TRY.
        IF lo_type_desc->kind = lo_type_desc->kind_struct.
          lo_struct_desc ?= lo_type_desc.
          lt_components = lo_struct_desc->get_components( ).

          IF sy-subrc <> 0.
          ELSE.
            LOOP AT lt_components INTO ls_components.
              CLEAR ls_header_fields.
              "check if field has domain fixed values
              "Caution: This will dump for complicated tables
              DATA(header_field_type) = CAST cl_abap_elemdescr( lo_struct_desc->get_component_type( ls_components-name ) ).
              IF header_field_type->is_ddic_type(  ) AND
                 header_field_type->get_ddic_fixed_values(  ).
                ls_header_fields-domain_fixed_value = abap_true.
                ls_header_fields-doma = header_field_type->get_relative_name( ).
              ENDIF.
              "check if field is key or not null
              ls_header_fields-name = ls_components-name.
              ls_header_fields-cds_view_field = to_mixed( ls_components-name ).
              IF to_upper( ls_components-name ) = co_key OR
                 to_upper( ls_components-name ) = co_client.
                ls_header_fields-key_indicator = 'X'.
                ls_header_fields-not_null = 'X'.
              ENDIF.
              APPEND ls_header_fields TO lt_header_fields.
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.

    IF create_item_objects( ).

      CREATE DATA dref_item TYPE (mo_tabl_item).

      lo_type_desc =  cl_abap_typedescr=>describe_by_data_ref( p_data_ref = dref_item ).
      TRY.
          IF lo_type_desc->kind = lo_type_desc->kind_struct.
            lo_struct_desc ?= lo_type_desc.
            lt_components = lo_struct_desc->get_components( ).
            IF sy-subrc <> 0.
            ELSE.
              LOOP AT lt_components INTO ls_components.

                CLEAR ls_item_fields.

                "check if field has domain fixed values
                "Caution: This will dump for complicated tables
                DATA(item_field_type) = CAST cl_abap_elemdescr( lo_struct_desc->get_component_type( ls_components-name ) ).
                IF item_field_type->is_ddic_type(  ) AND
                   item_field_type->get_ddic_fixed_values(  ).
                  ls_item_fields-domain_fixed_value = abap_true.
                ENDIF.

                ls_item_fields-name = ls_components-name.
                ls_item_fields-cds_view_field = to_mixed( ls_components-name ).

                IF to_upper( ls_components-name ) = co_key OR
                   to_upper( ls_components-name ) = co_client.
                  ls_item_fields-key_indicator = 'X'.
                  ls_item_fields-not_null = 'X'.
                ENDIF.
                APPEND ls_item_fields TO lt_item_fields.
              ENDLOOP.
            ENDIF.
          ENDIF.
      ENDTRY.

    ENDIF.

    DATA(lo_transport_layer) = xco_cp_abap_repository=>package->for( mo_package )->read( )-property-transport_layer.
    DATA(lo_transport_target) = lo_transport_layer->get_transport_target( ).
    DATA(lv_transport_target) = lo_transport_target->value.
    DATA(lo_transport_request) = xco_cp_cts=>transports->workbench( lo_transport_target->value  )->create_request( 'Short description' && mo_group_id ).
    DATA(lv_transport) = lo_transport_request->value.
    mo_transport = lv_transport.
    mo_environment = xco_cp_generation=>environment->dev_system( lv_transport ).

  ENDMETHOD.

  METHOD get_root_exception.
    rx_root = ix_exception.
    WHILE rx_root->previous IS BOUND.
      rx_root ?= rx_root->previous.
    ENDWHILE.
  ENDMETHOD.

  METHOD are_repository_obj_names_valid.
    rv_names_are_valid = abap_true.
    IF strlen( mo_tabl_header ) > 16.
      rv_names_are_valid = abap_false.
    ENDIF.
    IF strlen( mo_tabl_item ) > 16.
      rv_names_are_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD assign_package.

    DATA(lo_package_put_operation) = mo_environment->for-devc->create_put_operation( ).
    DATA(lo_specification) = lo_package_put_operation->add_object( mo_package ).

  ENDMETHOD.

  METHOD create_header_i_cds_view.

    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .

    DATA(lo_specification) = io_put_operation->for-ddls->add_object( mo_i_cds_header
     )->set_package( mo_package
     )->create_form_specification( ).

    DATA(lo_view) = lo_specification->set_short_description( 'CDS View for ' &&  mo_alias_header
      )->add_view( ).

    " Annotations.
    lo_view->add_annotation( 'AbapCatalog' )->value->build( )->begin_record(
      )->add_member( 'sqlViewName' )->add_string( CONV #( mo_view_header )
      )->add_member( 'compiler.compareFilter' )->add_boolean( abap_true
      )->add_member( 'preserveKey' )->add_boolean( abap_true
      )->end_record( ).
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'CDS View for ' && mo_alias_header ).

    lo_view->set_root( ).

    " Data source.
    lo_view->data_source->set_entity( CONV #( mo_tabl_header ) ).

    IF create_item_objects(  ).
      " Composition.
      lo_view->add_composition( mo_i_cds_item
        )->set_cardinality( xco_cp_cds=>cardinality->zero_to_n
        )->set_alias( '_' && mo_alias_item ).
    ENDIF.

    "Client field does not need to be specified in client-specific CDS view
    LOOP AT lt_header_fields INTO  DATA(ls_header_fields) WHERE  name  <> co_client.

      IF ls_header_fields-key_indicator = abap_true AND ls_header_fields-not_null = abap_true.

        lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-name )
           )->set_key( )->set_alias( to_mixed( ls_header_fields-name ) ).

      ELSE.
        lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-name )
           )->set_alias( to_mixed( ls_header_fields-name ) ).
      ENDIF.

      "add @Semantics annotation once available
*      IF ls_header_fields-name = 'booking_fee'.
*        DATA(lo_booking_fee) = lo_header_specficiation->get_field( ls_header_fields-name ).
*      ENDIF.
      CASE ls_header_fields-name.
        WHEN co_created_at.
          lo_field->add_annotation( 'Semantics.systemDateTime.createdAt' )->value->build( )->add_boolean( abap_true ).
        WHEN co_created_by.
          lo_field->add_annotation( 'Semantics.user.createdBy' )->value->build( )->add_boolean( abap_true ).
        WHEN co_last_changed_at.
          lo_field->add_annotation( 'Semantics.systemDateTime.lastChangedAt' )->value->build( )->add_boolean( abap_true ).
        WHEN co_last_changed_by.
          lo_field->add_annotation( 'Semantics.user.lastChangedBy' )->value->build( )->add_boolean( abap_true ).
      ENDCASE.

    ENDLOOP.

    IF create_item_objects(  ).
      "publish association to item  view
      lo_view->add_field( xco_cp_ddl=>field( '_' && mo_alias_item ) ).
    ENDIF.

  ENDMETHOD.

  METHOD create_item_i_cds_view.
    DATA(lo_specification) = io_put_operation->for-ddls->add_object( mo_i_cds_item
          )->set_package( mo_package
          )->create_form_specification( ).

    DATA(lo_view) = lo_specification->set_short_description( 'CDS View for ' && mo_alias_item
      )->add_view( ).

    " Annotations.
    lo_view->add_annotation( 'AbapCatalog' )->value->build( )->begin_record(
      )->add_member( 'sqlViewName' )->add_string( CONV #( mo_view_item )
      )->add_member( 'compiler.compareFilter' )->add_boolean( abap_true
      )->add_member( 'preserveKey' )->add_boolean( abap_true
      )->end_record( ).
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'CDS View for ' && mo_alias_item ).

    " Data Source.
    lo_view->data_source->set_entity( CONV #( mo_tabl_item ) ).

    DATA(lo_condition) = CAST if_xco_gen_ddls_ddl_expression(
      xco_cp_ddl=>expression->for( '$projection.ParentUUID = _' && mo_alias_header && '.UUID'  )
    ).

    lo_view->add_association( mo_i_cds_header )->set_to_parent(
      )->set_alias( '_' && mo_alias_header
      )->set_condition( lo_condition ).

    "Client field does not need to be specified in client-specific CDS view
    LOOP AT lt_item_fields INTO  DATA(ls_item_fields) WHERE name <> co_client.

      IF ls_item_fields-key_indicator = abap_true AND ls_item_fields-not_null = abap_true.

        lo_view->add_field( xco_cp_ddl=>field( ls_item_fields-name )
              )->set_key( )->set_alias( to_mixed( ls_item_fields-name ) ).

      ELSE.
        lo_view->add_field( xco_cp_ddl=>field( ls_item_fields-name )
          )->set_alias( to_mixed( ls_item_fields-name ) ).
      ENDIF.

    ENDLOOP.

    "publish association to parent
    lo_view->add_field( xco_cp_ddl=>field( '_' && mo_alias_header ) ).

  ENDMETHOD.

  METHOD create_header_p_cds_view.

    DATA(lo_specification) = io_put_operation->for-ddls->add_object( mo_p_cds_header
     )->set_package( mo_package
     )->create_form_specification( ).

    DATA(lo_view) = lo_specification->set_short_description( 'Projection View for ' &&  mo_alias_header
      )->add_projection_view( ).

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Projection View for ' && mo_alias_header ).

    lo_view->set_root( ).

    " Data source.
    lo_view->data_source->set_view_entity( iv_view_entity = mo_i_cds_header ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT lt_header_fields INTO  DATA(ls_header_fields) WHERE name <> co_client.

      IF ls_header_fields-key_indicator = abap_true AND ls_header_fields-not_null = abap_true.

        lo_view->add_field( xco_cp_ddl=>field( to_mixed( ls_header_fields-name ) )
          )->set_key( )->set_alias( to_mixed( ls_header_fields-name ) ).

      ELSE.
        lo_view->add_field( xco_cp_ddl=>field( to_mixed( ls_header_fields-name ) )
          )->set_alias( to_mixed( ls_header_fields-name ) ).
      ENDIF.

    ENDLOOP.

    IF create_item_objects(  ).
      "publish association to item  view
      lo_view->add_field( xco_cp_ddl=>field( '_' && mo_alias_item ) )->set_redirected_to_compos_child( mo_p_cds_item ).
    ENDIF.

  ENDMETHOD.

  METHOD create_item_p_cds_view.
    DATA(lo_specification) = io_put_operation->for-ddls->add_object( mo_p_cds_item
          )->set_package( mo_package
          )->create_form_specification( ).

    DATA(lo_view) = lo_specification->set_short_description( 'CDS View for ' && mo_alias_item
      )->add_projection_view( ).

    " Annotations.

    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'CDS View for ' && mo_alias_item ).

    " Data Source.
    lo_view->data_source->set_view_entity( iv_view_entity =  mo_i_cds_item ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT lt_item_fields INTO  DATA(ls_item_fields) WHERE name <> co_client.

      IF ls_item_fields-key_indicator = abap_true AND ls_item_fields-not_null = abap_true.

        lo_view->add_field( xco_cp_ddl=>field( to_mixed( ls_item_fields-name ) )
              )->set_key( )->set_alias( to_mixed( ls_item_fields-name ) ).

      ELSE.
        lo_view->add_field( xco_cp_ddl=>field( to_mixed( ls_item_fields-name ) )
          )->set_alias( to_mixed( ls_item_fields-name ) ).
      ENDIF.

    ENDLOOP.


    "publish association to parent
    lo_view->add_field( xco_cp_ddl=>field( '_' && mo_alias_header ) )->set_redirected_to_parent( mo_p_cds_header ).

  ENDMETHOD.

  METHOD create_header_p_mde_view.

    DATA pos TYPE i VALUE 0.
    DATA lo_field TYPE REF TO if_xco_gen_ddlx_s_fo_field .

    DATA(lo_specification) = io_put_operation->for-ddlx->add_object( mo_p_cds_header
      )->set_package( mo_package
      )->create_form_specification( ).

    lo_specification->set_short_description( 'MDE for ' && mo_alias_header
      )->set_layer( xco_cp_metadata_extension=>layer->customer
      )->set_view( mo_p_cds_header ).

*begin_array --> square bracket open
*Begin_record-> curly bracket open

    lo_specification->add_annotation( 'UI' )->value->build(
    )->begin_record(
        )->add_member( 'headerInfo'
         )->begin_record(
          )->add_member( 'typeName' )->add_string( mo_alias_header && ''
          )->add_member( 'typeNamePlural' )->add_string( mo_alias_header && 's'
          )->add_member( 'title'
            )->begin_record(
              )->add_member( 'type' )->add_enum( 'STANDARD'
              )->add_member( 'label' )->add_string( mo_alias_header && ''
              )->add_member( 'value' )->add_string( mo_header_semantic_key && ''
        )->end_record(
        )->end_record(
      )->end_record(
    ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT lt_header_fields INTO  DATA(ls_header_fields) WHERE name <> co_client.

      pos += 10.

      lo_field = lo_specification->add_field( ls_header_fields-cds_view_field ).


      CASE to_upper( ls_header_fields-name ).

        WHEN co_key.

          "key field header

          "lo_field = lo_specification->add_field( 'uuid' ).
          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).

          IF create_item_objects(  ).

            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'COLLECTION'
                  )->add_member( 'label' )->add_string( mo_alias_header && ''
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idIdentification'
                  )->add_member( 'parentId' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( 'General Information'
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idLineitem'
                  )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
                  )->add_member( 'label' )->add_string( mo_alias_item && ''
                  )->add_member( 'position' )->add_number( 20
                  )->add_member( 'targetElement' )->add_string( '_' && mo_alias_item
                )->end_record(
              )->end_array( ).
          ELSE.

            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'COLLECTION'
                  )->add_member( 'label' )->add_string( mo_alias_header && ''
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idIdentification'
                  )->add_member( 'parentId' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( 'General Information'
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
              )->end_array( ).

          ENDIF.

        WHEN co_last_changed_at OR co_last_changed_by OR co_created_at OR co_created_by.


          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).


        WHEN OTHERS.

          lo_field->add_annotation( 'UI.lineItem' )->value->build(
          )->begin_array(
          )->begin_record(
              )->add_member( 'position' )->add_number( pos
              )->add_member( 'importance' )->add_enum( 'HIGH'
              )->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field )
            )->end_record(
          )->end_array( ).

          lo_field->add_annotation( 'UI.identification' )->value->build(
          )->begin_array(
          )->begin_record(
              )->add_member( 'position' )->add_number( pos
              )->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field )
            )->end_record(
          )->end_array( ).

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD create_item_p_mde_view.

    DATA pos TYPE i VALUE 0.
    DATA lo_field TYPE REF TO if_xco_gen_ddlx_s_fo_field .

    DATA(lo_specification) = io_put_operation->for-ddlx->add_object( mo_p_cds_item
      )->set_package( mo_package
      )->create_form_specification( ).

    lo_specification->set_short_description( 'DDLX for ' && mo_alias_item
      )->set_layer( xco_cp_metadata_extension=>layer->customer
      )->set_view( mo_p_cds_item ).

    lo_specification->add_annotation( 'UI' )->value->build(
    )->begin_record(
        )->add_member( 'headerInfo'
         )->begin_record(
          )->add_member( 'typeName' )->add_string( CONV #( mo_alias_item )
          )->add_member( 'typeNamePlural' )->add_string( CONV #( mo_alias_item && 's' )
          )->add_member( 'title'
            )->begin_record(
              )->add_member( 'type' )->add_enum( 'STANDARD'
              )->add_member( 'label' )->add_string( CONV #( mo_alias_item )
              )->add_member( 'value' )->add_string( mo_item_semantic_key && ''
        )->end_record(
        )->end_record(
      )->end_record(
    ).

    "Client field does not need to be specified in client-specific CDS view
    LOOP AT lt_item_fields INTO  DATA(ls_item_fields) WHERE name <> co_client.

      pos += 10.
      lo_field = lo_specification->add_field( ls_item_fields-cds_view_field  ).

      CASE to_upper( ls_item_fields-name ).

        WHEN co_key. "key field header

          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).

          lo_field->add_annotation( 'UI.facet' )->value->build(
            )->begin_array(
              )->begin_record(
                )->add_member( 'id' )->add_string( CONV #( 'id' && mo_alias_item )
                )->add_member( 'purpose' )->add_enum( 'STANDARD'
                )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                )->add_member( 'label' )->add_string( CONV #( mo_alias_item )
                )->add_member( 'position' )->add_number( 10
              )->end_record(
            )->end_array( ).

        WHEN co_parent_key.

          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).

        WHEN OTHERS.

          lo_field->add_annotation( 'UI' )->value->build(
          )->begin_record(
            )->add_member( 'lineItem'
                )->begin_array(
                  )->begin_record(
                      )->add_member( 'position' )->add_number( pos
                      )->add_member( 'importance' )->add_enum( 'HIGH'
                      )->add_member( 'label' )->add_string( CONV #( ls_item_fields-cds_view_field )
                    )->end_record(
                )->end_array(
            )->add_member( 'identification'
                )->begin_array(
                  )->begin_record(
                      )->add_member( 'position' )->add_number( pos
                      )->add_member( 'label' )->add_string( CONV #( ls_item_fields-cds_view_field )
                  )->end_record(
                )->end_array(
         )->end_record(  ).

      ENDCASE.

    ENDLOOP.


  ENDMETHOD.

  METHOD create_bdef_p.

    DATA(lo_specification) = io_put_operation->for-bdef->add_object( mo_p_bdef_header
            )->set_package( mo_package
            )->create_form_specification( ).
    lo_specification->set_short_description( 'Behavior for ' && mo_p_bdef_header
       )->set_implementation_type( xco_cp_behavior_definition=>implementation_type->projection
       ).

    DATA(lo_header_behavior) = lo_specification->add_behavior( mo_p_cds_header ).

    " Characteristics.
    lo_header_behavior->characteristics->set_alias( CONV #( mo_alias_header )
      ).
    " Standard operations.
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create )->set_use( ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).
*
    IF create_item_objects(  ).
      lo_header_behavior->add_association( iv_name = mo_assoc_to_item )->set_create_enabled( abap_true )->set_use(  ).
    ENDIF.

    IF create_item_objects(  ).
      DATA(lo_item_behavior) = lo_specification->add_behavior( mo_p_cds_item ).

      " Characteristics.
      lo_item_behavior->characteristics->set_alias( CONV #( mo_alias_item )
        ).
      " Standard operations.
      lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
      lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).

      "lo_item_behavior->add_association(  mo_assoc_to_header )->set_use(  ).
      lo_item_behavior->add_association( mo_assoc_to_header && ';' )->set_use(  ).
    ENDIF.

  ENDMETHOD.

  METHOD create_bdef.

    DATA lt_mapping_header TYPE HASHED TABLE OF  if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                           WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_header TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    DATA lt_mapping_item TYPE HASHED TABLE OF if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                           WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_item TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    LOOP AT lt_header_fields INTO  DATA(ls_header_fields).
      ls_mapping_header-dbtable_field = ls_header_fields-name.
      ls_mapping_header-cds_view_field = to_mixed( ls_header_fields-name ).
      IF  ls_header_fields-name  <> co_client.
        INSERT ls_mapping_header INTO TABLE lt_mapping_header.
      ENDIF.
    ENDLOOP.

    DATA(lo_specification) = io_put_operation->for-bdef->add_object( mo_i_bdef_header
        )->set_package( mo_package
        )->create_form_specification( ).
    lo_specification->set_short_description( 'Behavior for ' && mo_i_bdef_header
       )->set_implementation_type( xco_cp_behavior_definition=>implementation_type->managed
       ).

    "define behavior for root entity

    DATA(lo_header_behavior) = lo_specification->add_behavior( mo_i_cds_header ).

    " Characteristics.
    lo_header_behavior->characteristics->set_alias( CONV #( mo_alias_header )
      )->set_persistent_table( mo_tabl_header
      )->set_implementation_class( mo_i_bil_header
      )->lock->set_master( ).

    " Standard operations.
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).


    "determination CalculateSemanticKey on modify { create; }
    lo_header_behavior->add_determination( 'CalculateSemanticKey'
      )->set_time( xco_cp_behavior_definition=>evaluation->time->on_modify
      )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).

    LOOP AT lt_mapping_header INTO ls_mapping_header.
      CASE ls_mapping_header-dbtable_field.
        WHEN co_key.  "  field ( readonly, numbering : managed ) Uuid;
          lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                           )->set_numbering_managed(
                           ")->set_read_only(
                           ).

        WHEN  mo_header_semantic_db_key .

          lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                             )->set_read_only(
                             ).

      ENDCASE.
    ENDLOOP.



    lo_header_behavior->add_mapping_for( mo_tabl_header )->set_field_mapping( it_field_mappings =  lt_mapping_header ).

    IF create_item_objects(  ).
      lo_header_behavior->add_association( iv_name = mo_assoc_to_item )->set_create_enabled( abap_true ).
    ENDIF.


    "define behavior for child entity

    IF create_item_objects(  ).

      LOOP AT lt_item_fields INTO  DATA(ls_item_fields) .
        ls_mapping_item-dbtable_field = ls_item_fields-name.
        ls_mapping_item-cds_view_field = to_mixed( ls_item_fields-name ).
        IF  ls_item_fields-name  <> co_client.
          INSERT ls_mapping_item INTO TABLE lt_mapping_item.
        ENDIF.
      ENDLOOP.

      DATA(lo_item_behavior) = lo_specification->add_behavior( mo_i_cds_item ).
*
*    " Characteristics.
      lo_item_behavior->characteristics->set_alias( CONV #( mo_alias_item )
        )->set_persistent_table( mo_tabl_item
        )->set_implementation_class( mo_i_bil_item
        )->lock->set_dependent_by( mo_assoc_to_header ).

      lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
      lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).

      "@todo change code when HFC3 is available
      "lo_item_behavior->add_association( mo_assoc_to_header ).
      lo_item_behavior->add_association( mo_assoc_to_header && ';' ).


      "determination CalculateSemanticKey on modify { create; }
      lo_item_behavior->add_determination( 'CalculateSemanticKey'
        )->set_time( xco_cp_behavior_definition=>evaluation->time->on_modify
        )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).


      LOOP AT lt_mapping_item INTO ls_mapping_item.
        CASE ls_mapping_item-dbtable_field.
          WHEN co_key.  "  field ( readonly, numbering : managed ) uuid;
            lo_item_behavior->add_field( ls_mapping_item-cds_view_field
                           )->set_numbering_managed(
                           ")->set_read_only(
                           ).
          WHEN co_parent_key.  "  field ( readonly ) parentuuid, bookingid;
            lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

          WHEN  mo_item_semantic_db_key .
            lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

        ENDCASE.
      ENDLOOP.


      lo_item_behavior->add_mapping_for( mo_tabl_item )->set_field_mapping( it_field_mappings =  lt_mapping_item ).

    ENDIF.

  ENDMETHOD.

  METHOD create_bdef_impl.

    "create bdef implemenation for header

    DATA(lo_specification_header) = io_put_operation->for-clas->add_object( mo_i_bil_header
        )->set_package( mo_package
        )->create_form_specification( ).
    lo_specification_header->set_short_description( 'Behavior implementation for ' && mo_i_bdef_header  ).

    lo_specification_header->definition->set_abstract(
      )->set_final(
      )->set_for_behavior_of( mo_i_bdef_header ).

    DATA(lo_handler_header) = lo_specification_header->add_local_class( 'LHC_' && to_upper( mo_alias_header ) ).
    lo_handler_header->definition->set_superclass( 'CL_ABAP_BEHAVIOR_HANDLER' ).

    DATA(lo_determination_header) = lo_handler_header->definition->section-private->add_method( 'CALCULATE_SEMANTIC_KEY' ).
    lo_determination_header->behavior_implementation->set_for_determination(
      iv_entity_name        = mo_alias_header
      iv_determination_name = 'CalculateSemanticKey'
    ).
    lo_determination_header->add_importing_parameter( 'IT_KEYS' )->behavior_implementation->set_for( mo_alias_header ).

    lo_handler_header->implementation->add_method( 'CALCULATE_SEMANTIC_KEY'
      )->set_source( VALUE #(
        ( |" Determination implementation goes here| ) )
      ).

    "create bdef implementation for item
    IF create_item_objects(  ).

      DATA(lo_specification_item) = io_put_operation->for-clas->add_object( mo_i_bil_item
           )->set_package( mo_package
           )->create_form_specification( ).
      lo_specification_item->set_short_description( 'Behavior implementation for ' && mo_i_bdef_header ).

      lo_specification_item->definition->set_abstract(
        )->set_final(
        )->set_for_behavior_of( mo_i_bdef_header ).

      DATA(lo_handler_item) = lo_specification_item->add_local_class( 'LHC_' && to_upper( mo_alias_item ) ).
      lo_handler_item->definition->set_superclass( 'CL_ABAP_BEHAVIOR_HANDLER' ).

      DATA(lo_determination_item) = lo_handler_item->definition->section-private->add_method( 'CALCULATE_SEMANTIC_KEY' ).
      lo_determination_item->behavior_implementation->set_for_determination(
        iv_entity_name        = mo_alias_item
        iv_determination_name = 'CalculateSemanticKey'
      ).
      lo_determination_item->add_importing_parameter( 'IT_KEYS' )->behavior_implementation->set_for( mo_alias_item ).

      lo_handler_item->implementation->add_method( 'CALCULATE_SEMANTIC_KEY'
        )->set_source( VALUE #(
          ( |" Determination implementation goes here| ) )
        ).

    ENDIF.

  ENDMETHOD.

  METHOD generate_managed_bo.

    assign_package( ).
    " Execute the PUT operation for the objects in the package.
    DATA(lo_objects_put_operation) = mo_environment->create_put_operation( ).

    create_header_i_cds_view( lo_objects_put_operation ).
    create_header_p_cds_view( lo_objects_put_operation ).
    create_header_p_mde_view( lo_objects_put_operation ).

    IF create_item_objects( ).
      create_item_i_cds_view( lo_objects_put_operation ).
      create_item_p_cds_view( lo_objects_put_operation ).
      create_item_p_mde_view( lo_objects_put_operation ).
    ENDIF.

    create_bdef( lo_objects_put_operation ).
    create_bdef_p( lo_objects_put_operation ).
    create_bdef_impl( lo_objects_put_operation ).

    DATA(lo_result) = lo_objects_put_operation->execute( ).

    DATA(lo_findings) = lo_result->findings.
    DATA(lt_findings) = lo_findings->get( ).

    APPEND 'todo:' TO rt_todos.
    APPEND |1. create and activate service definition: { mo_service_definition }| TO rt_todos.
    APPEND '2. add the following line(s) to the service definition:' TO rt_todos.
    APPEND |expose { mo_p_cds_header } as { mo_alias_header };| TO rt_todos.
    IF create_item_objects(  ).
      APPEND |expose { mo_p_cds_item } as { mo_alias_item };| TO rt_todos.
    ENDIF.
    APPEND |3. Create and activate service binding: { mo_service_binding }| TO rt_todos.
    APPEND '4. Activate local service endpoint' TO rt_todos.
    APPEND |5. Double-click on { mo_alias_header }| TO rt_todos.
    IF lt_findings  IS NOT INITIAL.
      APPEND 'Messages from XCO framework' TO rt_todos.
      LOOP AT lt_findings INTO DATA(ls_findings).
        APPEND ls_findings->message->get_text(  ) TO rt_todos.
      ENDLOOP.
    ENDIF.

    APPEND 'The following repository objects have been created' TO rt_todos.
    APPEND mo_i_cds_header TO rt_todos.
    APPEND mo_p_cds_header TO rt_todos.
    APPEND mo_i_bdef_header TO rt_todos.
    APPEND mo_p_bdef_header TO rt_todos.
    APPEND mo_i_bil_header  TO rt_todos.
    "items can not yet be generated
    "append mo_service_definition to rt_todos.
    "APPEND mo_service_binding TO rt_todos.

    IF create_item_objects(  ).
      APPEND mo_i_cds_item TO rt_todos.
      APPEND mo_p_cds_item  TO rt_todos.
      APPEND mo_i_bil_item    TO rt_todos.
    ENDIF.

  ENDMETHOD.



  METHOD create_item_objects.
    IF mo_tabl_item IS INITIAL.
      rv_create_item_objects = abap_false.
    ELSE.
      rv_create_item_objects = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

