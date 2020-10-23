CLASS zcl_rap_bo_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
            ty_string_table_type TYPE STANDARD TABLE OF string WITH DEFAULT KEY .


    TYPES:
      BEGIN OF ts_condition_components,
        projection_field  TYPE sxco_cds_field_name,
        association_name  TYPE sxco_cds_association_name,
        association_field TYPE sxco_cds_field_name,
      END OF ts_condition_components,

      tt_condition_components TYPE STANDARD TABLE OF ts_condition_components WITH EMPTY KEY.


    METHODS constructor
      IMPORTING
                "     VALUE(iv_package)          TYPE sxco_package
                VALUE(io_rap_bo_root_node) TYPE REF TO zcl_rap_node
      RAISING   zcx_rap_generator.


    METHODS generate_bo
      RETURNING
                VALUE(rt_todos) TYPE ty_string_table_type
      RAISING   cx_xco_gen_put_exception
                zcx_rap_generator.



  PROTECTED SECTION.

    DATA mo_root_node_m_uuid    TYPE REF TO zcl_rap_node.
    "data mo_root_node_u_semkey  type ref to zcl_rap_node_u_semkey_root.

  PRIVATE SECTION.

    DATA mo_package      TYPE sxco_package.

    DATA mo_environment TYPE REF TO if_xco_cp_gen_env_dev_system.
    DATA mo_transport TYPE    sxco_transport .

    METHODS assign_package.

    METHODS create_control_structure
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.

    METHODS create_i_cds_view
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.

    METHODS create_p_cds_view
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.

    METHODS create_mde_view
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.


    METHODS create_bdef
      IMPORTING
                io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
                VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node
      RAISING   zcx_rap_generator.

    METHODS create_bdef_p
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.

    METHODS create_condition
      IMPORTING
        VALUE(it_condition_components) TYPE tt_condition_components
      RETURNING
        VALUE(ro_expression)           TYPE REF TO if_xco_ddl_expr_condition.

    METHODS create_service_definition
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.

    "service binding needs a separate put operation
    METHODS create_service_binding
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_srvb_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.

ENDCLASS.



CLASS zcl_rap_bo_generator IMPLEMENTATION.


  METHOD assign_package.
    DATA(lo_package_put_operation) = mo_environment->for-devc->create_put_operation( ).
    DATA(lo_specification) = lo_package_put_operation->add_object( mo_package ).
  ENDMETHOD.


  METHOD constructor.

    IF io_rap_bo_root_node->get_implementation_type( ) =
       zcl_rap_node=>implementation_type-managed_uuid OR
       io_rap_bo_root_node->get_implementation_type( ) =
       zcl_rap_node=>implementation_type-managed_semantic
       OR io_rap_bo_root_node->get_implementation_type( ) =
       zcl_rap_node=>implementation_type-unmanged_semantic.
      mo_root_node_m_uuid =  io_rap_bo_root_node .
    ELSE.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>implementation_type_not_valid
          mv_value = io_rap_bo_root_node->get_implementation_type( ).
    ENDIF.

    IF io_rap_bo_root_node->is_consistent(  ) = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>node_is_not_consistent
          mv_entity = io_rap_bo_root_node->entityname.
    ENDIF.
    IF io_rap_bo_root_node->is_finalized = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>node_is_not_finalized
          mv_entity = io_rap_bo_root_node->entityname.
    ENDIF.
    IF io_rap_bo_root_node->has_childs(  ).
      LOOP AT io_rap_bo_root_node->all_childnodes INTO DATA(ls_childnode).
        IF ls_childnode->is_consistent(  ) = abap_false.
          RAISE EXCEPTION TYPE zcx_rap_generator
            EXPORTING
              textid    = zcx_rap_generator=>node_is_not_consistent
              mv_entity = ls_childnode->entityname.
        ENDIF.
        IF ls_childnode->is_finalized = abap_false.
          RAISE EXCEPTION TYPE zcx_rap_generator
            EXPORTING
              textid    = zcx_rap_generator=>node_is_not_finalized
              mv_entity = ls_childnode->entityname.
        ENDIF.
      ENDLOOP.
    ENDIF.

    mo_package = io_rap_bo_root_node->package.

    DATA(lo_package) = mo_root_node_m_uuid->xco_lib->get_package( mo_package ).

    IF NOT lo_package->exists( ).

      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>package_does_not_exist
          mv_value = CONV #( mo_package ).

    ENDIF.

    "check if tables or CDS views that shall be used
    "and the package that has been provided
    "reside in the same software component

    " Get software component for package

    "DATA(lo_package) = xco_cp_abap_repository=>object->devc->for( iv_package ).
    DATA(lv_package_software_component) = lo_package->read( )-property-software_component->name.


*    "Compare with software components of data sources
*    "check data source of root node
*    CASE io_rap_bo_root_node->data_source_type.
*      WHEN io_rap_bo_root_node->data_source_types-table.
*        "create object for table
*        DATA(lo_database_table) = xco_cp_abap_dictionary=>database_table( io_rap_bo_root_node->table_name ).
*        " Get package.
*        DATA(lo_dbt_package) = lo_database_table->if_xco_ar_object~get_package( ).
*
*        " Read package.
*        DATA(ls_dbt_package) = lo_dbt_package->read( ).
*        " Software component.
*        DATA(lv_dbt_software_component) = ls_dbt_package-property-software_component->name.
*
*        IF lv_package_software_component <> lv_dbt_software_component.
*          IF NOT lv_dbt_software_component = '/DMO/SAP'  AND  lv_dbt_software_component = 'ZLOCAL'.
*            RAISE EXCEPTION TYPE zcx_rap_generator
*              EXPORTING
*                textid          = zcx_rap_generator=>software_comp_do_not_match
*                mv_table_name   = CONV #( io_rap_bo_root_node->table_name )
*                mv_package_name = CONV #( iv_package ).
*          ENDIF.
*        ENDIF.
*
*      WHEN io_rap_bo_root_node->data_source_types-cds_view.
*
*        "@todo: add a check here
*
*    ENDCASE.


    "check tables of child nodes

*    IF io_rap_bo_root_node->has_childs(  ).
*      LOOP AT io_rap_bo_root_node->all_childnodes INTO ls_childnode.
*        CASE io_rap_bo_root_node->data_source_type.
*          WHEN  io_rap_bo_root_node->data_source_types-table.
*            lo_database_table = xco_cp_abap_dictionary=>database_table( ls_childnode->table_name ).
*            lo_dbt_package = lo_database_table->if_xco_ar_object~get_package( ).
*
*            ls_dbt_package = lo_dbt_package->read( ).
*            lv_dbt_software_component = ls_dbt_package-property-software_component->name.
*            IF lv_package_software_component <> lv_dbt_software_component.
*              IF NOT lv_dbt_software_component = '/DMO/SAP'  AND  lv_dbt_software_component = 'ZLOCAL'.
*                RAISE EXCEPTION TYPE zcx_rap_generator
*                  EXPORTING
*                    textid          = zcx_rap_generator=>software_comp_do_not_match
*                    mv_table_name   = CONV #( io_rap_bo_root_node->table_name )
*                    mv_package_name = CONV #( iv_package ).
*              ENDIF.
*            ENDIF.
*          WHEN io_rap_bo_root_node->data_source_types-cds_view.
*            "@todo: add a check here
*        ENDCASE.
*      ENDLOOP.
*    ENDIF.

    "DATA(lo_transport_layer) = xco_cp_abap_repository=>package->for( mo_package )->read( )-property-transport_layer.
    DATA(lo_transport_layer) = lo_package->read(  )-property-transport_layer.
    DATA(lo_transport_target) = lo_transport_layer->get_transport_target( ).
    DATA(lv_transport_target) = lo_transport_target->value.
    DATA(lo_transport_request) = xco_cp_cts=>transports->workbench( lo_transport_target->value  )->create_request( |RAP Business object - entity name: { mo_root_node_m_uuid->entityname } | ).
    DATA(lv_transport) = lo_transport_request->value.
    mo_transport = lv_transport.
    mo_environment = xco_cp_generation=>environment->dev_system( lv_transport ).


  ENDMETHOD.


  METHOD create_bdef.

    DATA lv_determination_name TYPE string.

    DATA lt_mapping_header TYPE HASHED TABLE OF  if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                               WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_header TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    DATA lt_mapping_item TYPE HASHED TABLE OF if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                           WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_item TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    lt_mapping_header = io_rap_bo_node->lt_mapping.

    DATA(lo_specification) = io_put_operation->for-bdef->add_object( io_rap_bo_node->rap_root_node_objects-behavior_definition_i "mo_i_bdef_header
        )->set_package( mo_package
        )->create_form_specification( ).
    lo_specification->set_short_description( |Behavior for { io_rap_bo_node->rap_node_objects-cds_view_i }| ).
    "set implementation type
    CASE io_rap_bo_node->get_implementation_type(  ).
      WHEN zcl_rap_node=>implementation_type-managed_uuid.
        lo_specification->set_implementation_type( xco_cp_behavior_definition=>implementation_type->managed ).
      WHEN zcl_rap_node=>implementation_type-managed_semantic.
        lo_specification->set_implementation_type( xco_cp_behavior_definition=>implementation_type->managed ).
      WHEN zcl_rap_node=>implementation_type-unmanged_semantic.
        lo_specification->set_implementation_type( xco_cp_behavior_definition=>implementation_type->unmanaged ).
    ENDCASE.


    "define behavior for root entity

    DATA(lo_header_behavior) = lo_specification->add_behavior( io_rap_bo_node->rap_node_objects-cds_view_i ).

    " Characteristics.
    lo_header_behavior->characteristics->set_alias( CONV #( io_rap_bo_node->rap_node_objects-alias )
      ")->set_persistent_table( io_rap_bo_node->table_name
      )->set_implementation_class(  io_rap_bo_node->rap_node_objects-behavior_implementation
      )->lock->set_master( ).
    LOOP AT io_rap_bo_node->lt_fields INTO DATA(ls_etag_field).
      IF ls_etag_field-name = io_rap_bo_node->field_name-last_changed_at.
        lo_header_behavior->characteristics->etag->set_master( ls_etag_field-cds_view_field ).
      ENDIF.
    ENDLOOP.
    CASE io_rap_bo_node->get_implementation_type(  ).
      WHEN zcl_rap_node=>implementation_type-managed_uuid.
        lo_header_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) ).
      WHEN zcl_rap_node=>implementation_type-managed_semantic.
        lo_header_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) ).
      WHEN zcl_rap_node=>implementation_type-unmanged_semantic.
        "set not persistent table
    ENDCASE.

    " Standard operations for root node
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).

    CASE io_rap_bo_node->get_implementation_type(  ).
      WHEN zcl_rap_node=>implementation_type-managed_uuid.

        lv_determination_name = |Calculate{ io_rap_bo_node->object_id_cds_field_name }| .

        lo_header_behavior->add_determination( CONV #( lv_determination_name ) "'CalculateSemanticKey'
          )->set_time( xco_cp_behavior_definition=>evaluation->time->on_modify
          )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).

        LOOP AT lt_mapping_header INTO ls_mapping_header.
          CASE ls_mapping_header-dbtable_field.
            WHEN io_rap_bo_node->field_name-uuid.
              lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                               )->set_numbering_managed( )->set_read_only(  ).
            WHEN io_rap_bo_node->field_name-parent_uuid OR
                 io_rap_bo_node->field_name-root_uuid.
              lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                               )->set_read_only( ).
            WHEN  io_rap_bo_node->object_id .
              lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                                 )->set_read_only( ).
            WHEN io_rap_bo_node->field_name-created_at OR
                 io_rap_bo_node->field_name-created_by OR
                 io_rap_bo_node->field_name-last_changed_at OR
                 io_rap_bo_node->field_name-last_changed_by OR
                 io_rap_bo_node->field_name-local_instance_last_changed_at.
              lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                              )->set_read_only( ).
          ENDCASE.
        ENDLOOP.

      WHEN zcl_rap_node=>implementation_type-managed_semantic.

        "no specific settings needed for managed_semantic until draft would be supported

      WHEN zcl_rap_node=>implementation_type-unmanged_semantic.

        LOOP AT io_rap_bo_node->lt_fields INTO DATA(ls_field) WHERE name <> io_rap_bo_node->field_name-client.
          IF ls_field-key_indicator = abap_true.
            lo_header_behavior->add_field( ls_field-cds_view_field
                               )->set_read_only(
                               ).
          ENDIF.
        ENDLOOP.
    ENDCASE.

    IF lt_mapping_header IS NOT INITIAL.
      CASE io_rap_bo_node->get_implementation_type(  ).
        WHEN zcl_rap_node=>implementation_type-managed_uuid.
          lo_header_behavior->add_mapping_for( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) )->set_field_mapping( it_field_mappings =  lt_mapping_header ).
        WHEN zcl_rap_node=>implementation_type-managed_semantic.
          lo_header_behavior->add_mapping_for( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) )->set_field_mapping( it_field_mappings =  lt_mapping_header ).
        WHEN zcl_rap_node=>implementation_type-unmanged_semantic.
          "add control structure
          lo_header_behavior->add_mapping_for( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) )->set_field_mapping( it_field_mappings =  lt_mapping_header )->set_control( io_rap_bo_node->rap_node_objects-control_structure ).
      ENDCASE.
    ENDIF.

    IF io_rap_bo_node->has_childs(  ).
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).
        DATA lv_alias TYPE sxco_cds_association_name  .
        lv_alias = CONV #( '_' && lo_childnode->rap_node_objects-alias ).
        lo_header_behavior->add_association( lv_alias )->set_create_enabled(  ).
      ENDLOOP.
    ENDIF.



    "define behavior for child entities

    IF io_rap_bo_node->has_childs(  ).

      LOOP AT io_rap_bo_node->all_childnodes INTO lo_childnode.

        CLEAR lt_mapping_item.

        lt_mapping_item = lo_childnode->lt_mapping.

        DATA(lo_item_behavior) = lo_specification->add_behavior( lo_childnode->rap_node_objects-cds_view_i ).

*    " Characteristics.
        IF lo_childnode->is_grand_child_or_deeper(  ).

          lo_item_behavior->characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
            )->set_implementation_class( lo_childnode->rap_node_objects-behavior_implementation
            )->lock->set_dependent_by( '_' && lo_childnode->root_node->rap_node_objects-alias  ).

          CASE lo_childnode->get_implementation_type(  ).
            WHEN zcl_rap_node=>implementation_type-managed_uuid.
              lo_item_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) ).
            WHEN   zcl_rap_node=>implementation_type-managed_semantic.
              lo_item_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) ).
            WHEN zcl_rap_node=>implementation_type-unmanged_semantic.
              "nothing to do
          ENDCASE.

          lo_item_behavior->add_association( '_' && lo_childnode->root_node->rap_node_objects-alias  ).

        ELSEIF lo_childnode->is_child(  ).

          lo_item_behavior->characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
                   )->set_implementation_class( lo_childnode->rap_node_objects-behavior_implementation
                   )->lock->set_dependent_by( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).

          CASE lo_childnode->get_implementation_type(  ).
            WHEN zcl_rap_node=>implementation_type-managed_uuid.
              lo_item_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) ).
            WHEN   zcl_rap_node=>implementation_type-managed_semantic.
              lo_item_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name  ) ).
            WHEN zcl_rap_node=>implementation_type-unmanged_semantic.
              "set no persistent table
          ENDCASE.


          lo_item_behavior->add_association( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).

        ELSE.
          "should not happen

          RAISE EXCEPTION TYPE zcx_rap_generator
            MESSAGE ID 'ZCM_RAP_GENERATOR' TYPE 'E' NUMBER '001'
            WITH lo_childnode->entityname lo_childnode->root_node->entityname.

        ENDIF.


        IF lo_childnode->has_childs(  ).
          LOOP AT lo_childnode->childnodes INTO DATA(lo_grandchildnode).
            lo_item_behavior->add_association( iv_name = '_' && lo_grandchildnode->rap_node_objects-alias )->set_create_enabled(  ).
          ENDLOOP.
        ENDIF.

        "child nodes only offer update and delete and create by assocation
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).

        CASE lo_childnode->get_implementation_type(  ).
          WHEN zcl_rap_node=>implementation_type-managed_uuid.
            "determination CalculateSemanticKey on modify { create; }
            lv_determination_name = 'Calculate' && lo_childnode->object_id_cds_field_name.

            lo_item_behavior->add_determination( CONV #( lv_determination_name )
              )->set_time( xco_cp_behavior_definition=>evaluation->time->on_modify
              )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).

            LOOP AT lt_mapping_item INTO ls_mapping_item.
              CASE ls_mapping_item-dbtable_field.
                WHEN lo_childnode->field_name-uuid.
                  lo_item_behavior->add_field( ls_mapping_item-cds_view_field
                                 )->set_numbering_managed( )->set_read_only(  ).
                WHEN lo_childnode->field_name-parent_uuid OR
                     lo_childnode->field_name-root_uuid .
                  lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

                WHEN lo_childnode->field_name-created_at OR
                     lo_childnode->field_name-created_by OR
                     lo_childnode->field_name-last_changed_at OR
                     lo_childnode->field_name-last_changed_by OR
                     lo_childnode->field_name-local_instance_last_changed_at.
                  lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

                WHEN  lo_childnode->object_id.
                  lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

              ENDCASE.
            ENDLOOP.

          WHEN zcl_rap_node=>implementation_type-managed_semantic.

            "key field is not set as read only since at this point we assume
            "that the key is set externally

          WHEN zcl_rap_node=>implementation_type-unmanged_semantic.
            "make the key fields read only in the child entities
            "Otherwise you get the warning
            "The field "<semantic key of root node>" is used for "lock" dependency (in the ON clause of
            "the association "_Travel"). This means it should be flagged as
            "readonly / readonly:update".

            "LOOP AT lo_childnode->root_node->lt_fields INTO DATA(ls_fields)
            LOOP AT lo_childnode->lt_fields INTO DATA(ls_fields)
              WHERE key_indicator = abap_true AND name <> lo_childnode->field_name-client.
              lo_item_behavior->add_field( ls_fields-cds_view_field )->set_read_only( ).
            ENDLOOP.



        ENDCASE.

        IF lt_mapping_item IS NOT INITIAL.
          CASE io_rap_bo_node->get_implementation_type(  ).
            WHEN zcl_rap_node=>implementation_type-managed_uuid.
              lo_item_behavior->add_mapping_for( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) )->set_field_mapping( it_field_mappings =  lt_mapping_item ).
            WHEN zcl_rap_node=>implementation_type-managed_semantic.
              lo_item_behavior->add_mapping_for( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) )->set_field_mapping( it_field_mappings =  lt_mapping_item ).
            WHEN zcl_rap_node=>implementation_type-unmanged_semantic.
              "add control structure
              lo_item_behavior->add_mapping_for( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) )->set_field_mapping( it_field_mappings =  lt_mapping_item )->set_control( lo_childnode->rap_node_objects-control_structure ).
          ENDCASE.
        ENDIF.



      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD create_bdef_p.
    DATA(lo_specification) = io_put_operation->for-bdef->add_object( io_rap_bo_node->rap_root_node_objects-behavior_definition_p
               )->set_package( mo_package
               )->create_form_specification( ).
    lo_specification->set_short_description( |Behavior for { io_rap_bo_node->rap_node_objects-cds_view_p }|
       )->set_implementation_type( xco_cp_behavior_definition=>implementation_type->projection
       ).

    DATA(lo_header_behavior) = lo_specification->add_behavior( io_rap_bo_node->rap_node_objects-cds_view_p ).

    " Characteristics.
    lo_header_behavior->characteristics->set_alias( CONV #( io_rap_bo_node->rap_node_objects-alias )
      ).
    " Standard operations.
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create )->set_use( ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).
*

    IF io_rap_bo_node->has_childs(  ).

      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).
        lo_header_behavior->add_association( iv_name = '_' && lo_childnode->rap_node_objects-alias )->set_create_enabled( abap_true )->set_use(  ).
      ENDLOOP.

      LOOP AT io_rap_bo_node->all_childnodes INTO lo_childnode.

        DATA(lo_item_behavior) = lo_specification->add_behavior( lo_childnode->rap_node_objects-cds_view_p ).

        " Characteristics.
        lo_item_behavior->characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
          ).
        " Standard operations.
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).

        IF lo_childnode->is_grand_child_or_deeper(  ).
          "lo_item_behavior->add_association(  mo_assoc_to_root )->set_use(  ).
          "'_' && lo_childnode->root_node->rap_node_objects-alias
          lo_item_behavior->add_association(  '_' && lo_childnode->root_node->rap_node_objects-alias )->set_use(  ).
        ELSEIF lo_childnode->is_child( ).
          "lo_item_behavior->add_association(  mo_assoc_to_header )->set_use(  ).
          "'_' && lo_childnode->parent_node->rap_node_objects-alias
          lo_item_behavior->add_association(  '_' && lo_childnode->parent_node->rap_node_objects-alias )->set_use(  ).
        ELSE.


        ENDIF.
        IF lo_childnode->has_childs(  ).
          LOOP AT lo_childnode->childnodes INTO DATA(lo_grandchildnode).
            lo_item_behavior->add_association( iv_name = '_' && lo_grandchildnode->rap_node_objects-alias )->set_create_enabled( abap_true )->set_use(  ).
          ENDLOOP.
        ENDIF.

      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD create_condition.

    DATA lo_expression TYPE REF TO if_xco_ddl_expr_condition.

    LOOP AT it_condition_components INTO DATA(ls_condition_components).
      DATA(lo_projection_field) = xco_cp_ddl=>field( ls_condition_components-projection_field )->of_projection( ).
      DATA(lo_association_field) = xco_cp_ddl=>field( ls_condition_components-association_field )->of( CONV #( ls_condition_components-association_name ) ).

      DATA(lo_condition) = lo_projection_field->eq( lo_association_field ).

      IF lo_expression IS INITIAL.
        lo_expression = lo_condition.
      ELSE.
        lo_expression = lo_expression->and( lo_condition ).
      ENDIF.

      ro_expression = lo_expression.

    ENDLOOP.

  ENDMETHOD.


  METHOD create_control_structure.

    DATA lv_control_structure_name TYPE sxco_ad_object_name .
    lv_control_structure_name = to_upper( io_rap_bo_node->rap_node_objects-control_structure ).

    DATA(lo_specification) = io_put_operation->for-tabl-for-structure->add_object(  lv_control_structure_name
     )->set_package( mo_package
     )->create_form_specification( ).

    "create a view entity
    lo_specification->set_short_description( |Control structure for { io_rap_bo_node->rap_node_objects-alias }| ).

    LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_header_fields) WHERE  key_indicator  <> abap_true .
      lo_specification->add_component( ls_header_fields-name
         )->set_type( xco_cp_abap_dictionary=>data_element( 'xsdboolean' ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD create_i_cds_view.

    DATA ls_condition_components TYPE ts_condition_components.
    DATA lt_condition_components TYPE tt_condition_components.
    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .

    DATA(lo_specification) = io_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_i
     )->set_package( mo_package
     )->create_form_specification( ).

    "create a view entity
    DATA(lo_view) = lo_specification->set_short_description( |CDS View for { io_rap_bo_node->rap_node_objects-alias  }|
      )->add_view_entity( ).

    "create a normal CDS view with DDIC view
*    DATA(lo_view) = lo_specification->set_short_description( 'CDS View for ' &&  io_rap_bo_node->rap_node_objects-alias "mo_alias_header
*      )->add_view( ).
*
*    " Annotations.
*    lo_view->add_annotation( 'AbapCatalog' )->value->build( )->begin_record(
*      )->add_member( 'sqlViewName' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-ddic_view_i ) "mo_view_header )
*      )->add_member( 'compiler.compareFilter' )->add_boolean( abap_true
*      )->add_member( 'preserveKey' )->add_boolean( abap_true
*      )->end_record( ).

    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'CDS View for ' && io_rap_bo_node->rap_node_objects-alias ). " mo_alias_header ).

    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ELSE.

      CASE io_rap_bo_node->get_implementation_type(  ) .
        WHEN zcl_rap_node=>implementation_type-managed_uuid.

          DATA(parent_uuid_cds_field_name) = io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-parent_uuid ]-cds_view_field.
          DATA(uuid_cds_field_name_in_parent) = io_rap_bo_node->parent_node->lt_fields[ name = io_rap_bo_node->parent_node->field_name-uuid ]-cds_view_field.

          DATA(lo_condition) = xco_cp_ddl=>field( parent_uuid_cds_field_name )->of_projection( )->eq(
            xco_cp_ddl=>field( uuid_cds_field_name_in_parent )->of( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias ) ).




        WHEN  zcl_rap_node=>implementation_type-unmanged_semantic OR zcl_rap_node=>implementation_type-managed_semantic.

          CLEAR ls_condition_components.
          CLEAR lt_condition_components.

          LOOP AT io_rap_bo_node->parent_node->semantic_key INTO DATA(ls_semantic_key).
            ls_condition_components-association_name = '_' && io_rap_bo_node->parent_node->rap_node_objects-alias.
            ls_condition_components-association_field = ls_semantic_key-cds_view_field.
            ls_condition_components-projection_field = ls_semantic_key-cds_view_field.
            APPEND ls_condition_components TO lt_condition_components.
          ENDLOOP.

          lo_condition = create_condition( lt_condition_components ).

      ENDCASE.

      lo_view->add_association( io_rap_bo_node->parent_node->rap_node_objects-cds_view_i )->set_to_parent(
  )->set_alias( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias
  )->set_condition( lo_condition ).



      IF io_rap_bo_node->is_grand_child_or_deeper(  ).

        CASE io_rap_bo_node->get_implementation_type(  ) .
          WHEN zcl_rap_node=>implementation_type-managed_uuid.

            DATA(root_uuid_cds_field_name) = io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-root_uuid ]-cds_view_field.
            DATA(uuid_cds_field_name_in_root) = io_rap_bo_node->root_node->lt_fields[ name = io_rap_bo_node->root_node->field_name-uuid ]-cds_view_field.

            lo_condition = xco_cp_ddl=>field( root_uuid_cds_field_name )->of_projection( )->eq(
              xco_cp_ddl=>field( uuid_cds_field_name_in_root )->of( '_' && io_rap_bo_node->root_node->rap_node_objects-alias ) ).



          WHEN  zcl_rap_node=>implementation_type-unmanged_semantic OR zcl_rap_node=>implementation_type-managed_semantic.

            CLEAR ls_condition_components.
            CLEAR lt_condition_components.

            LOOP AT io_rap_bo_node->ROOT_node->semantic_key INTO DATA(ls_root_semantic_key).
              ls_condition_components-association_name = '_' && io_rap_bo_node->root_node->rap_node_objects-alias.
              ls_condition_components-association_field = ls_root_semantic_key-cds_view_field.
              ls_condition_components-projection_field = ls_root_semantic_key-cds_view_field.
              APPEND ls_condition_components TO lt_condition_components.
            ENDLOOP.

            lo_condition = create_condition( lt_condition_components ).

        ENDCASE.

        lo_view->add_association( io_rap_bo_node->root_node->rap_node_objects-cds_view_i
          )->set_alias( '_' && io_rap_bo_node->root_node->rap_node_objects-alias
          )->set_cardinality(  xco_cp_cds=>cardinality->one
          )->set_condition( lo_condition ).

      ENDIF.

    ENDIF.

    " Data source.
    CASE io_rap_bo_node->data_source_type.
      WHEN io_rap_bo_node->data_source_types-table.
        lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->table_name ) ).
      WHEN io_rap_bo_node->data_source_types-cds_view.
        lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->cds_view_name ) ).
    ENDCASE.

    IF io_rap_bo_node->has_childs(  ).   " create_item_objects(  ).
      " Composition.

      "change to a new property "childnodes" which only contains the direct childs
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).

        lo_view->add_composition( lo_childnode->rap_node_objects-cds_view_i "  mo_i_cds_item
          )->set_cardinality( xco_cp_cds=>cardinality->zero_to_n
          )->set_alias( '_' && lo_childnode->rap_node_objects-alias ). " mo_alias_item ).

      ENDLOOP.

    ENDIF.

    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_header_fields) WHERE  name  <> io_rap_bo_node->field_name-client . "   co_client.

      IF ls_header_fields-key_indicator = abap_true.
        lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-name )
           )->set_key( )->set_alias(  ls_header_fields-cds_view_field  ).
      ELSE.
        lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-name )
           )->set_alias( ls_header_fields-cds_view_field ).
      ENDIF.

      "add @Semantics annotation for currency code
      IF ls_header_fields-currencycode IS NOT INITIAL.
        READ TABLE io_rap_bo_node->lt_fields INTO DATA(ls_field) WITH KEY name = to_upper( ls_header_fields-currencycode ).
        IF sy-subrc = 0.
          "for example @Semantics.amount.currencyCode: 'CurrencyCode'
          lo_field->add_annotation( 'Semantics.amount.currencyCode' )->value->build( )->add_string( CONV #( ls_field-cds_view_field ) ).
        ENDIF.
      ENDIF.

      "add @Semantics annotation for unit of measure
      IF ls_header_fields-unitofmeasure IS NOT INITIAL.
        CLEAR ls_field.
        READ TABLE io_rap_bo_node->lt_fields INTO ls_field WITH KEY name = to_upper( ls_header_fields-unitofmeasure ).
        IF sy-subrc = 0.
          "for example @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
          lo_field->add_annotation( 'Semantics.quantity.unitOfMeasure' )->value->build( )->add_string( CONV #( ls_field-cds_view_field ) ).
        ENDIF.
      ENDIF.

      CASE ls_header_fields-name.
        WHEN io_rap_bo_node->field_name-created_at.
          lo_field->add_annotation( 'Semantics.systemDateTime.createdAt' )->value->build( )->add_boolean( abap_true ).
        WHEN io_rap_bo_node->field_name-created_by.
          lo_field->add_annotation( 'Semantics.user.createdBy' )->value->build( )->add_boolean( abap_true ).
        WHEN io_rap_bo_node->field_name-last_changed_at.
          lo_field->add_annotation( 'Semantics.systemDateTime.lastChangedAt' )->value->build( )->add_boolean( abap_true ).
        WHEN io_rap_bo_node->field_name-last_changed_by.
          lo_field->add_annotation( 'Semantics.user.lastChangedBy' )->value->build( )->add_boolean( abap_true ).
        WHEN io_rap_bo_node->field_name-local_instance_last_changed_at.
          lo_field->add_annotation( 'Semantics.systemDateTime.localInstanceLastChangedAt' )->value->build( )->add_boolean( abap_true ).
      ENDCASE.

    ENDLOOP.

    "IF create_item_objects(  ).
    IF io_rap_bo_node->has_childs(  ).

      "change to a new property "childnodes" which only contains the direct childs
      LOOP AT io_rap_bo_node->childnodes INTO lo_childnode.

        "publish association to item  view
        lo_view->add_field( xco_cp_ddl=>field( '_' && lo_childnode->rap_node_objects-alias ) ).

      ENDLOOP.

    ENDIF.

    IF io_rap_bo_node->is_root(  ) = abap_false.
      "publish association to parent
      lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias ) ).
    ENDIF.

    IF io_rap_bo_node->is_grand_child_or_deeper(  ).
      "add assocation to root node
      lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->root_node->rap_node_objects-alias ) ).
    ENDIF.

    "add associations

    LOOP AT io_rap_bo_node->lt_association INTO DATA(ls_assocation).

      CLEAR ls_condition_components.
      CLEAR lt_condition_components.
      LOOP AT ls_assocation-condition_components INTO DATA(ls_components).
        ls_condition_components-association_field =  ls_components-association_field.
        ls_condition_components-projection_field = ls_components-projection_field.
        ls_condition_components-association_name = ls_assocation-name.
        APPEND ls_condition_components TO lt_condition_components.
      ENDLOOP.

      lo_condition = create_condition( lt_condition_components ).

      DATA(lo_association) = lo_view->add_association( ls_assocation-target )->set_alias(
           ls_assocation-name
          )->set_condition( lo_condition ).

      CASE ls_assocation-cardinality .
        WHEN zcl_rap_node=>cardinality-one.
          lo_association->set_cardinality(  xco_cp_cds=>cardinality->one ).
        WHEN zcl_rap_node=>cardinality-one_to_n.
          lo_association->set_cardinality(  xco_cp_cds=>cardinality->one_to_n ).
        WHEN zcl_rap_node=>cardinality-zero_to_n.
          lo_association->set_cardinality(  xco_cp_cds=>cardinality->zero_to_n ).
        WHEN zcl_rap_node=>cardinality-zero_to_one.
          lo_association->set_cardinality(  xco_cp_cds=>cardinality->zero_to_one ).
        WHEN zcl_rap_node=>cardinality-one_to_one.
          "@todo: currently association[1] will be generated
          "fix available with 2008 HFC2
          lo_association->set_cardinality(  xco_cp_cds=>cardinality->range( iv_min = 1 iv_max = 1 ) ).
      ENDCASE.

      "publish association
      lo_view->add_field( xco_cp_ddl=>field( ls_assocation-name ) ).

    ENDLOOP.


  ENDMETHOD.


  METHOD create_mde_view.
    DATA pos TYPE i VALUE 0.
    DATA lo_field TYPE REF TO if_xco_gen_ddlx_s_fo_field .

    DATA(lo_specification) = io_put_operation->for-ddlx->add_object(  io_rap_bo_node->rap_node_objects-meta_data_extension " cds_view_p " mo_p_cds_header
      )->set_package( mo_package
      )->create_form_specification( ).

    lo_specification->set_short_description( |MDE for { io_rap_bo_node->rap_node_objects-alias }|
      )->set_layer( xco_cp_metadata_extension=>layer->customer
      )->set_view( io_rap_bo_node->rap_node_objects-cds_view_p ). " cds_view_p ).

*begin_array --> square bracket open
*Begin_record-> curly bracket open


    lo_specification->add_annotation( 'UI' )->value->build(
    )->begin_record(
        )->add_member( 'headerInfo'
         )->begin_record(
          )->add_member( 'typeName' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
          )->add_member( 'typeNamePlural' )->add_string( io_rap_bo_node->rap_node_objects-alias && 's'
          )->add_member( 'title'
            )->begin_record(
              )->add_member( 'type' )->add_enum( 'STANDARD'
              )->add_member( 'label' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
              "@todo: Check what happens if several key fields are present
              "for a first test we just take the first one.
              "also check what happens if no semantic key has been specified
              )->add_member( 'value' )->add_string( io_rap_bo_node->object_id_cds_field_name && '' "semantic_keys[ 1 ]  && '' " mo_header_semantic_key && ''
        )->end_record(
        )->end_record(
      )->end_record(
    ).



    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields) WHERE name <> io_rap_bo_node->field_name-client.

      pos += 10.

      lo_field = lo_specification->add_field( ls_header_fields-cds_view_field ).

      "put facet annotation in front of the first
      IF pos = 10.
        IF io_rap_bo_node->is_root(  ) = abap_true.

          IF io_rap_bo_node->has_childs(  ).

            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'COLLECTION'
                  )->add_member( 'label' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idIdentification'
                  )->add_member( 'parentId' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( 'General Information'
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                "@todo check what happens if an entity has several child entities
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idLineitem'
                  )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
                  )->add_member( 'label' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''
                  )->add_member( 'position' )->add_number( 20
                  )->add_member( 'targetElement' )->add_string( '_' && io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias
                )->end_record(
              )->end_array( ).
          ELSE.

            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'COLLECTION'
                  )->add_member( 'label' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
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

        ELSE.

          IF io_rap_bo_node->has_childs(  ).

            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( CONV #( 'id' && io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'purpose' )->add_enum( 'STANDARD'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                    )->add_member( 'id' )->add_string( 'idLineitem'
                    )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
                    )->add_member( 'label' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''
                    )->add_member( 'position' )->add_number( 20
                    )->add_member( 'targetElement' )->add_string( '_' && io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias
                  )->end_record(
              )->end_array( ).

          ELSE.

            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( CONV #( 'id' && io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'purpose' )->add_enum( 'STANDARD'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
              )->end_array( ).

          ENDIF.
        ENDIF.
      ENDIF.



      CASE to_upper( ls_header_fields-name ).

        WHEN io_rap_bo_node->field_name-uuid.

          "key field header

          "lo_field = lo_specification->add_field( 'uuid' ).
          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).


          "hide administrative fields and guid-based fields
        WHEN io_rap_bo_node->field_name-last_changed_at OR io_rap_bo_node->field_name-last_changed_by OR
             io_rap_bo_node->field_name-created_at OR io_rap_bo_node->field_name-created_by OR
             io_rap_bo_node->field_name-parent_uuid OR io_rap_bo_node->field_name-root_uuid.

          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).

        WHEN OTHERS.

*DATA(lo_valuebuilder) = lo_field->add_annotation( 'Consumption.valueHelpDefinition' )->value->build( ).
*
*          lo_valuebuilder

          DATA(lo_valuebuilder) = lo_field->add_annotation( 'UI.lineItem' )->value->build( ).

          DATA(lo_record) = lo_valuebuilder->begin_array(
          )->begin_record(
              )->add_member( 'position' )->add_number( pos
              )->add_member( 'importance' )->add_enum( 'HIGH').
          "if field is based on a data element label will be set from its field description
          "if its a built in type we will set a label whith a meaningful default vaule that
          "can be changed by the developer afterwards
          IF ls_header_fields-is_data_element = abap_false.
            lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
          ENDIF.
          lo_valuebuilder->end_record( )->end_array( ).

          lo_valuebuilder = lo_field->add_annotation( 'UI.identification' )->value->build( ).
          lo_record = lo_valuebuilder->begin_array(
          )->begin_record(
              )->add_member( 'position' )->add_number( pos ).
          IF ls_header_fields-is_data_element = abap_false.
            lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
          ENDIF.
          lo_valuebuilder->end_record( )->end_array( ).

          "add selection fields for semantic key fields or for the fields that are marked as object id

          IF io_rap_bo_node->is_root(  ) = abap_true AND
             ( io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-unmanged_semantic OR
                io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-managed_semantic ) AND
                ls_header_fields-key_indicator = abap_true.

            lo_field->add_annotation( 'UI.selectionField' )->value->build(
            )->begin_array(
            )->begin_record(
                )->add_member( 'position' )->add_number( pos
              )->end_record(
            )->end_array( ).

          ENDIF.

          IF io_rap_bo_node->is_root(  ) = abap_true AND
             io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-managed_uuid  AND
             ls_header_fields-name = io_rap_bo_node->object_id.

            lo_field->add_annotation( 'UI.selectionField' )->value->build(
            )->begin_array(
            )->begin_record(
                )->add_member( 'position' )->add_number( pos
              )->end_record(
            )->end_array( ).

          ENDIF.



      ENDCASE.

    ENDLOOP.
  ENDMETHOD.


  METHOD create_p_cds_view.
    DATA(lo_specification) = io_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_p
     )->set_package( mo_package
     )->create_form_specification( ).

    DATA(lo_view) = lo_specification->set_short_description( |Projection View for { io_rap_bo_node->rap_node_objects-alias }|
      )->add_projection_view( ).

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Projection View for ' && io_rap_bo_node->rap_node_objects-alias ).


    lo_view->add_annotation( 'Search.searchable' )->value->build( )->add_boolean( abap_true ).


    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ENDIF.

    " Data source.
    lo_view->data_source->set_view_entity( iv_view_entity = io_rap_bo_node->rap_node_objects-cds_view_i ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields) WHERE name  <> io_rap_bo_node->field_name-client.

      DATA(lo_field) = lo_view->add_field( xco_cp_ddl=>field(  ls_header_fields-cds_view_field   )
         ). "->set_alias(  ls_header_fields-cds_view_field   ).

      IF ls_header_fields-key_indicator = abap_true  .
        lo_field->set_key(  ).
        lo_field->add_annotation( 'Search.defaultSearchElement' )->value->build( )->add_boolean( abap_true ).
      ENDIF.

      CASE ls_header_fields-name.
        WHEN io_rap_bo_node->object_id.
          IF ls_header_fields-key_indicator = abap_false.
            lo_field->add_annotation( 'Search.defaultSearchElement' )->value->build( )->add_boolean( abap_true ).
          ENDIF.
      ENDCASE.

      "add @Semantics annotation once available
      IF ls_header_fields-currencycode IS NOT INITIAL.
        READ TABLE io_rap_bo_node->lt_fields INTO DATA(ls_field) WITH KEY name = ls_header_fields-currencycode.
        IF sy-subrc = 0.
          lo_field->add_annotation( 'Semantics.amount.currencyCode' )->value->build( )->add_string( CONV #( ls_field-cds_view_field ) ).
        ENDIF.
      ENDIF.

      IF ls_header_fields-has_valuehelp = abap_true.

        READ TABLE io_rap_bo_node->lt_valuehelp INTO DATA(ls_valuehelp) WITH KEY localelement = ls_header_fields-cds_view_field.

        IF sy-subrc = 0.

          DATA(lo_valuebuilder) = lo_field->add_annotation( 'Consumption.valueHelpDefinition' )->value->build( ).

          lo_valuebuilder->begin_array(
                     )->begin_record(
                       )->add_member( 'entity'
                          )->begin_record(
                             )->add_member( 'name' )->add_string( CONV #( ls_valuehelp-name )
                             )->add_member( 'element' )->add_string( CONV #( ls_valuehelp-element )
                          )->end_record( ).

          IF ls_valuehelp-additionalbinding IS NOT INITIAL.

            lo_valuebuilder->add_member( 'additionalBinding'
            )->begin_array( ).

            LOOP AT ls_valuehelp-additionalbinding INTO DATA(ls_additionalbinding).

              DATA(lo_record) = lo_valuebuilder->begin_record(
                )->add_member( 'localElement' )->add_string( CONV #( ls_additionalbinding-localelement )
                )->add_member( 'element' )->add_string( CONV #( ls_additionalbinding-element )
                ).
              IF ls_additionalbinding-usage IS NOT INITIAL.
                lo_record->add_member( 'usage' )->add_enum( CONV #( ls_additionalbinding-usage ) ).
              ENDIF.

              lo_valuebuilder->end_record(  ).

            ENDLOOP.

            lo_valuebuilder->end_array( ).

          ENDIF.

          lo_valuebuilder->end_record(
      )->end_array(
).

        ENDIF.

      ENDIF.



    ENDLOOP.

    IF io_rap_bo_node->has_childs(  ).   " create_item_objects(  ).
      " Composition.

      "change to a new property "childnodes" which only contains the direct childs
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).

        lo_view->add_field( xco_cp_ddl=>field( '_' && lo_childnode->rap_node_objects-alias ) )->set_redirected_to_compos_child( lo_childnode->rap_node_objects-cds_view_p ).


      ENDLOOP.

    ENDIF.

    IF io_rap_bo_node->is_root(  ) = abap_false.
      " "publish association to parent
      lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias ) )->set_redirected_to_parent( io_rap_bo_node->parent_node->rap_node_objects-cds_view_p ).
    ENDIF.

    "for grand-child nodes we have to add an association to the root node
    IF io_rap_bo_node->is_grand_child_or_deeper(  ).
      lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->root_node->rap_node_objects-alias ) )->set_redirected_to( io_rap_bo_node->root_node->rap_node_objects-cds_view_p ).
    ENDIF.

  ENDMETHOD.


  METHOD create_service_binding.

    DATA lv_service_binding_name TYPE sxco_srvb_object_name.
    lv_service_binding_name = to_upper( io_rap_bo_node->root_node->rap_root_node_objects-service_binding ).

    DATA lv_service_definition_name TYPE sxco_srvd_object_name.
    lv_service_definition_name = to_upper( io_rap_bo_node->root_node->rap_root_node_objects-service_definition ).

    DATA(lo_specification_header) = io_put_operation->add_object(   lv_service_binding_name
                                    )->set_package( mo_package
                                    )->create_form_specification( ).

    lo_specification_header->set_short_description( |Service binding for { io_rap_bo_node->root_node->entityname }| ).



    lo_specification_header->set_binding_type( xco_cp_service_binding=>binding_type->odata_v2_ui ).
*
    lo_specification_header->add_service( )->add_version( '0001' )->set_service_definition( lv_service_definition_name ).




  ENDMETHOD.


  METHOD create_service_definition.


    TYPES: BEGIN OF ty_cds_views_used_by_assoc,
             name   TYPE zcl_rap_node=>ts_assocation-name,    "    sxco_ddef_alias_name,
             target TYPE zcl_rap_node=>ts_assocation-target,
           END OF ty_cds_views_used_by_assoc.
    DATA  lt_cds_views_used_by_assoc  TYPE STANDARD TABLE OF ty_cds_views_used_by_assoc.
    DATA  ls_cds_views_used_by_assoc  TYPE ty_cds_views_used_by_assoc.

    DATA(lo_specification_header) = io_put_operation->for-srvd->add_object(  io_rap_bo_node->rap_root_node_objects-service_definition
                                    )->set_package( mo_package
                                    )->create_form_specification( ).

    lo_specification_header->set_short_description( |Service definition for { io_rap_bo_node->root_node->entityname }|  ).

    "add exposure for root node
    lo_specification_header->add_exposure( mo_root_node_m_uuid->rap_node_objects-cds_view_p )->set_alias( mo_root_node_m_uuid->rap_node_objects-alias ).

    "create a list of all CDS views used in associations of childnodes to the service definition
    LOOP AT mo_root_node_m_uuid->lt_association INTO DATA(ls_assocation).
      "remove the first character which is an underscore
      ls_cds_views_used_by_assoc-name = substring( val = ls_assocation-name off = 1 ).
      ls_cds_views_used_by_assoc-target =  ls_assocation-target.
      COLLECT ls_cds_views_used_by_assoc INTO lt_cds_views_used_by_assoc.
    ENDLOOP.
    LOOP AT mo_root_node_m_uuid->lt_valuehelp INTO DATA(ls_valuehelp).
      ls_cds_views_used_by_assoc-name = ls_valuehelp-alias.
      ls_cds_views_used_by_assoc-target = ls_valuehelp-name.
      COLLECT ls_cds_views_used_by_assoc INTO lt_cds_views_used_by_assoc.
    ENDLOOP.



    "add exposure for all child nodes
    LOOP AT mo_root_node_m_uuid->all_childnodes INTO DATA(lo_childnode).
      "add all nodes to the service definition
      lo_specification_header->add_exposure( lo_childnode->rap_node_objects-cds_view_p )->set_alias( lo_childnode->rap_node_objects-alias ).
      "create a list of all CDS views used in associations of childnodes to the service definition
      LOOP AT lo_childnode->lt_association INTO ls_assocation.
        "remove the first character which is an underscore
        ls_cds_views_used_by_assoc-name = substring( val = ls_assocation-name off = 1 ).
        ls_cds_views_used_by_assoc-target =  ls_assocation-target.
        COLLECT ls_cds_views_used_by_assoc INTO lt_cds_views_used_by_assoc.
      ENDLOOP.
      LOOP AT lo_childnode->lt_valuehelp INTO ls_valuehelp.
        ls_cds_views_used_by_assoc-name = ls_valuehelp-alias.
        ls_cds_views_used_by_assoc-target = ls_valuehelp-name.
        COLLECT ls_cds_views_used_by_assoc INTO lt_cds_views_used_by_assoc.
      ENDLOOP.
    ENDLOOP.

    "add exposure for all associations and value helps that have been collected (and condensed) in the step before
    LOOP AT lt_cds_views_used_by_assoc INTO ls_cds_views_used_by_assoc.
      lo_specification_header->add_exposure( ls_cds_views_used_by_assoc-target )->set_alias( ls_cds_views_used_by_assoc-name ).
    ENDLOOP.


  ENDMETHOD.


  METHOD generate_bo.

    assign_package( ).
    " Execute the PUT operation for the objects in the package.
    DATA(lo_objects_put_operation) = mo_environment->create_put_operation( ).

    create_i_cds_view(
      EXPORTING
        io_put_operation = lo_objects_put_operation
        io_rap_bo_node   = mo_root_node_m_uuid
    ). " lo_objects_put_operation ).


    create_p_cds_view(
      EXPORTING
        io_put_operation = lo_objects_put_operation
        io_rap_bo_node   = mo_root_node_m_uuid
    ). " lo_objects_put_operation ).

    create_mde_view(
          EXPORTING
            io_put_operation = lo_objects_put_operation
            io_rap_bo_node   = mo_root_node_m_uuid
        ). " lo_objects_put

    IF mo_root_node_m_uuid->transactional_behavior = abap_true.
      create_bdef(
      EXPORTING
                  io_put_operation = lo_objects_put_operation
                  io_rap_bo_node   = mo_root_node_m_uuid
              ). "

      create_bdef_p(
      EXPORTING
                      io_put_operation = lo_objects_put_operation
                      io_rap_bo_node   = mo_root_node_m_uuid
                  ).
    ENDIF.


    LOOP AT mo_root_node_m_uuid->all_childnodes INTO DATA(lo_bo_node).

      create_i_cds_view(
        EXPORTING
          io_put_operation = lo_objects_put_operation
          io_rap_bo_node   = lo_bo_node
      ). " lo_objects_put_operation ).

      create_p_cds_view(
           EXPORTING
             io_put_operation = lo_objects_put_operation
             io_rap_bo_node   = lo_bo_node
         ).

      create_mde_view(
      EXPORTING
        io_put_operation = lo_objects_put_operation
        io_rap_bo_node   = lo_bo_node
    ). " lo_objects_put


      IF lo_bo_node->get_implementation_type( ) = lo_bo_node->implementation_type-unmanged_semantic.
        create_control_structure(
            EXPORTING
                        io_put_operation = lo_objects_put_operation
                        io_rap_bo_node   = lo_bo_node
                    ).
      ENDIF.

    ENDLOOP.

    IF mo_root_node_m_uuid->get_implementation_type( ) = mo_root_node_m_uuid->implementation_type-unmanged_semantic.
      create_control_structure(
     EXPORTING
       io_put_operation = lo_objects_put_operation
       io_rap_bo_node   = mo_root_node_m_uuid
   ).
    ENDIF.

    IF mo_root_node_m_uuid->publish_service = abap_true.
      create_service_definition(
        EXPORTING
          io_put_operation = lo_objects_put_operation
          io_rap_bo_node   = mo_root_node_m_uuid
      ).
    ENDIF.
    "start generation of all objects beside service binding
    DATA(lo_result) = lo_objects_put_operation->execute( ).

    DATA(lo_findings) = lo_result->findings.
    DATA(lt_findings) = lo_findings->get( ).
    IF mo_root_node_m_uuid->publish_service = abap_true.
      "service binding needs a separate put operation
      DATA(lo_srvb_put_operation) = mo_environment->for-srvb->create_put_operation( ).

      create_service_binding(
        EXPORTING
          io_put_operation = lo_srvb_put_operation
          io_rap_bo_node   = mo_root_node_m_uuid
      ).

      lo_result = lo_srvb_put_operation->execute( ).

      lo_findings = lo_result->findings.
      DATA(lt_srvb_findings) = lo_findings->get( ).

      IF lt_srvb_findings IS NOT INITIAL.
        APPEND 'Messages from XCO framework (Service Binding)' TO rt_todos.
        LOOP AT lt_srvb_findings INTO DATA(ls_findings).
          APPEND | Type: { ls_findings->object_type } Object name: { ls_findings->object_name } Message: { ls_findings->message->get_text(  ) }  | TO rt_todos.
        ENDLOOP.
      ENDIF.


    ENDIF.

    IF lt_findings IS NOT INITIAL.
      APPEND 'Messages from XCO framework' TO rt_todos.
      LOOP AT lt_findings INTO ls_findings.
        APPEND | Type: { ls_findings->object_type } Object name: { ls_findings->object_name } Message: { ls_findings->message->get_text(  ) }  | TO rt_todos.
      ENDLOOP.
    ENDIF.


    APPEND 'The following repository objects have been created' TO rt_todos.
    "root node
    APPEND mo_root_node_m_uuid->rap_root_node_objects TO rt_todos.
    APPEND mo_root_node_m_uuid->rap_node_objects TO rt_todos.
    "child nodes
    LOOP AT mo_root_node_m_uuid->all_childnodes INTO DATA(lo_childnode).
      APPEND lo_childnode->rap_node_objects TO rt_todos.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
