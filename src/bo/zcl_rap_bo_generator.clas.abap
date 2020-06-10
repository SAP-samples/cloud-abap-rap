CLASS zcl_rap_bo_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
            ty_string_table_type TYPE STANDARD TABLE OF string WITH DEFAULT KEY .

    METHODS constructor
      IMPORTING
                VALUE(iv_package)          TYPE sxco_package
                VALUE(io_rap_bo_root_node) TYPE REF TO zcl_rap_node
      RAISING   zcx_rap_generator.


    METHODS generate_bo
      RETURNING
                VALUE(rt_todos) TYPE ty_string_table_type
      RAISING   cx_xco_gen_put_exception.



  PROTECTED SECTION.

    DATA mo_root_node_m_uuid    TYPE REF TO zcl_rap_node_m_uuid_root.

  PRIVATE SECTION.

    DATA mo_package      TYPE sxco_package.

    DATA mo_environment TYPE REF TO if_xco_cp_gen_env_dev_system.
    DATA mo_transport TYPE    sxco_transport .

    METHODS assign_package.

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

    METHODS create_behavior_implementation
      IMPORTING
        io_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put
        VALUE(io_rap_bo_node) TYPE REF TO zcl_rap_node.

ENDCLASS.



CLASS zcl_rap_bo_generator IMPLEMENTATION.

  METHOD constructor.

    CASE TYPE OF io_rap_bo_root_node.
      WHEN TYPE  zcl_rap_node_m_uuid_root .
        mo_root_node_m_uuid =  CAST zcl_rap_node_m_uuid_root( io_rap_bo_root_node ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_rap_generator
          EXPORTING
            textid    = zcx_rap_generator=>root_node_type_not_supported
            mv_entity = io_rap_bo_root_node->entityname.
    ENDCASE.
    IF io_rap_bo_root_node->is_consistent(  ) = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>node_is_not_consistent
          mv_entity = io_rap_bo_root_node->entityname.
    ENDIF.
    IF io_rap_bo_root_node->has_childs(  ).
      LOOP AT io_rap_bo_root_node->all_childnodes INTO DATA(ls_childnode).
        IF ls_childnode->is_consistent(  ) = abap_false.
          RAISE EXCEPTION TYPE zcx_rap_generator
            EXPORTING
              textid    = zcx_rap_generator=>node_is_not_consistent
              mv_entity = io_rap_bo_root_node->entityname.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF xco_cp_abap_repository=>object->devc->for( iv_package )->exists( ).
      mo_package = iv_package .
    ELSE.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>package_does_not_exist
          mv_value = CONV #( iv_package ).
    ENDIF.

    DATA(lo_transport_layer) = xco_cp_abap_repository=>package->for( mo_package )->read( )-property-transport_layer.
    DATA(lo_transport_target) = lo_transport_layer->get_transport_target( ).
    DATA(lv_transport_target) = lo_transport_target->value.
    DATA(lo_transport_request) = xco_cp_cts=>transports->workbench( lo_transport_target->value  )->create_request( |RAP Business object - entity name: { mo_root_node_m_uuid->entityname } | ).
    DATA(lv_transport) = lo_transport_request->value.
    mo_transport = lv_transport.
    mo_environment = xco_cp_generation=>environment->dev_system( lv_transport ).


  ENDMETHOD.

  METHOD generate_bo.

    assign_package( ).
    " Execute the PUT operation for the objects in the package.
    DATA(lo_objects_put_operation) = mo_environment->create_put_operation( ).

*LOOP AT root_bo->all_childnodes INTO DATA(ls_node).
*          out->write( ls_node->entityname  ).
*        ENDLOOP.

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

    create_behavior_implementation(
        EXPORTING
                    io_put_operation = lo_objects_put_operation
                    io_rap_bo_node   = mo_root_node_m_uuid
                ).

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

      create_behavior_implementation(
          EXPORTING
                      io_put_operation = lo_objects_put_operation
                      io_rap_bo_node   = lo_bo_node
                  ).

    ENDLOOP.


    DATA(lo_result) = lo_objects_put_operation->execute( ).

    DATA(lo_findings) = lo_result->findings.
    DATA(lt_findings) = lo_findings->get( ).

    APPEND 'todo:' TO rt_todos.
    APPEND |1. create and activate service definition: { mo_root_node_m_uuid->rap_root_node_objects-service_definition }| TO rt_todos.
    APPEND '2. add the following line(s) to the service definition:' TO rt_todos.
    APPEND |expose { mo_root_node_m_uuid->rap_node_objects-cds_view_p } as { mo_root_node_m_uuid->rap_node_objects-alias };| TO rt_todos.
    LOOP AT mo_root_node_m_uuid->all_childnodes INTO DATA(lo_childnode).
      APPEND |expose { lo_childnode->rap_node_objects-cds_view_p } as { lo_childnode->rap_node_objects-alias };| TO rt_todos.
    ENDLOOP.
    APPEND |3. Create and activate service binding: { mo_root_node_m_uuid->rap_root_node_objects-service_binding }| TO rt_todos.
    APPEND '4. Activate local service endpoint' TO rt_todos.
    APPEND |5. Double-click on { mo_root_node_m_uuid->rap_node_objects-cds_view_p }| TO rt_todos.
    IF lt_findings  IS NOT INITIAL.
      APPEND 'Messages from XCO framework' TO rt_todos.
      LOOP AT lt_findings INTO DATA(ls_findings).
        APPEND ls_findings->message->get_text(  ) TO rt_todos.
      ENDLOOP.
    ENDIF.

    APPEND 'The following repository objects have been created' TO rt_todos.
    APPEND mo_root_node_m_uuid->rap_node_objects TO rt_todos.
    LOOP AT mo_root_node_m_uuid->all_childnodes INTO lo_childnode.
      APPEND lo_childnode->rap_node_objects TO rt_todos.
    ENDLOOP.

  ENDMETHOD.

  METHOD assign_package.
    DATA(lo_package_put_operation) = mo_environment->for-devc->create_put_operation( ).
    DATA(lo_specification) = lo_package_put_operation->add_object( mo_package ).
  ENDMETHOD.

  METHOD create_i_cds_view.
    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .

    DATA(lo_specification) = io_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_i
     )->set_package( mo_package
     )->create_form_specification( ).

    DATA(lo_view) = lo_specification->set_short_description( 'CDS View for ' &&  io_rap_bo_node->rap_node_objects-alias "mo_alias_header
      )->add_view( ).

    " Annotations.
    lo_view->add_annotation( 'AbapCatalog' )->value->build( )->begin_record(
      )->add_member( 'sqlViewName' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-ddic_view_i ) "mo_view_header )
      )->add_member( 'compiler.compareFilter' )->add_boolean( abap_true
      )->add_member( 'preserveKey' )->add_boolean( abap_true
      )->end_record( ).
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'CDS View for ' && io_rap_bo_node->rap_node_objects-alias ). " mo_alias_header ).

    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ELSE.

*      DATA(lo_condition) = CAST if_xco_gen_ddls_ddl_expression(
*    xco_cp_ddl=>expression->for( '$projection.ParentUUID = _' && io_rap_bo_node->parent_node->rap_node_objects-alias && '.UUID'  )
*        ).

      DATA(lo_condition) = xco_cp_ddl=>field( 'ParentUUID' )->of_projection( )->eq(
        xco_cp_ddl=>field( io_rap_bo_node->parent_node->field_name-uuid && '' )->of( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias ) ).


      lo_view->add_association( io_rap_bo_node->parent_node->rap_node_objects-cds_view_i )->set_to_parent(
        )->set_alias( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias
        )->set_condition( lo_condition ).

      "association to Z_I_RAP_TRAVEL_015 as _travel on $projection.RootUuid = _travel.Uuid

      IF io_rap_bo_node->is_grand_child_or_deeper(  ).

*        lo_condition = CAST if_xco_gen_ddls_ddl_expression(
*      xco_cp_ddl=>expression->for( '$projection.RootUuid = _' && io_rap_bo_node->root_node->rap_node_objects-alias && '.UUID'  )
*          ).

        lo_condition = xco_cp_ddl=>field( 'RootUUID' )->of_projection( )->eq(
             xco_cp_ddl=>field( io_rap_bo_node->parent_node->field_name-uuid && '' )->of( '_' && io_rap_bo_node->root_node->rap_node_objects-alias ) ).


        lo_view->add_association( io_rap_bo_node->root_node->rap_node_objects-cds_view_i
          )->set_alias( '_' && io_rap_bo_node->root_node->rap_node_objects-alias
          )->set_cardinality(  xco_cp_cds=>cardinality->one
          )->set_condition( lo_condition ).

      ENDIF.

    ENDIF.

    " Data source.
    lo_view->data_source->set_entity( CONV #( io_rap_bo_node->table_name ) ).

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
        WHEN io_rap_bo_node->field_name-created_at.
          lo_field->add_annotation( 'Semantics.systemDateTime.createdAt' )->value->build( )->add_boolean( abap_true ).
        WHEN io_rap_bo_node->field_name-created_by.
          lo_field->add_annotation( 'Semantics.user.createdBy' )->value->build( )->add_boolean( abap_true ).
        WHEN io_rap_bo_node->field_name-last_changed_at.
          lo_field->add_annotation( 'Semantics.systemDateTime.lastChangedAt' )->value->build( )->add_boolean( abap_true ).
        WHEN io_rap_bo_node->field_name-last_changed_by.
          lo_field->add_annotation( 'Semantics.user.lastChangedBy' )->value->build( )->add_boolean( abap_true ).
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

  ENDMETHOD.

  METHOD create_p_cds_view.
    DATA(lo_specification) = io_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_p
     )->set_package( mo_package
     )->create_form_specification( ).

    DATA(lo_view) = lo_specification->set_short_description( 'Projection View for ' &&  io_rap_bo_node->rap_node_objects-alias
      )->add_projection_view( ).

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Projection View for ' && io_rap_bo_node->rap_node_objects-alias ).



    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ENDIF.

    " Data source.
    lo_view->data_source->set_view_entity( iv_view_entity = io_rap_bo_node->rap_node_objects-cds_view_i ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields) WHERE name  <> io_rap_bo_node->field_name-client.

      IF ls_header_fields-key_indicator = abap_true AND ls_header_fields-not_null = abap_true.

        lo_view->add_field( xco_cp_ddl=>field( to_mixed( ls_header_fields-name ) )
          )->set_key( )->set_alias( to_mixed( ls_header_fields-name ) ).

      ELSE.
        lo_view->add_field( xco_cp_ddl=>field( to_mixed( ls_header_fields-name ) )
          )->set_alias( to_mixed( ls_header_fields-name ) ).
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

  METHOD create_mde_view.
    DATA pos TYPE i VALUE 0.
    DATA lo_field TYPE REF TO if_xco_gen_ddlx_s_fo_field .

    DATA(lo_specification) = io_put_operation->for-ddlx->add_object(  io_rap_bo_node->rap_node_objects-meta_data_extension " cds_view_p " mo_p_cds_header
      )->set_package( mo_package
      )->create_form_specification( ).

    lo_specification->set_short_description( 'MDE for ' && io_rap_bo_node->rap_node_objects-alias
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
              )->add_member( 'value' )->add_string( io_rap_bo_node->semantic_keys[ 1 ]  && '' " mo_header_semantic_key && ''
        )->end_record(
        )->end_record(
      )->end_record(
    ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields) WHERE name <> io_rap_bo_node->field_name-client.

      pos += 10.

      lo_field = lo_specification->add_field( ls_header_fields-cds_view_field ).


      CASE to_upper( ls_header_fields-name ).

        WHEN io_rap_bo_node->field_name-uuid.

          "key field header

          "lo_field = lo_specification->add_field( 'uuid' ).
          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).

          IF io_rap_bo_node IS INSTANCE OF zcl_rap_node_m_uuid_root.

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
          "hide administrative fields and guid-based fields
        WHEN io_rap_bo_node->field_name-last_changed_at OR io_rap_bo_node->field_name-last_changed_by OR
             io_rap_bo_node->field_name-created_at OR io_rap_bo_node->field_name-created_by OR
             io_rap_bo_node->field_name-parent_uuid OR io_rap_bo_node->field_name-root_uuid.

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

  METHOD create_bdef.



    DATA lt_mapping_header TYPE HASHED TABLE OF  if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                               WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_header TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    DATA lt_mapping_item TYPE HASHED TABLE OF if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                           WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_item TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields).
      ls_mapping_header-dbtable_field = ls_header_fields-name.
      ls_mapping_header-cds_view_field = to_mixed( ls_header_fields-name ).
      IF  ls_header_fields-name  <> io_rap_bo_node->field_name-client.
        INSERT ls_mapping_header INTO TABLE lt_mapping_header.
      ENDIF.
    ENDLOOP.

    DATA(lo_specification) = io_put_operation->for-bdef->add_object( io_rap_bo_node->rap_root_node_objects-behavior_definition_i "mo_i_bdef_header
        )->set_package( mo_package
        )->create_form_specification( ).
    lo_specification->set_short_description( 'Behavior for ' && io_rap_bo_node->rap_node_objects-cds_view_i
       )->set_implementation_type( xco_cp_behavior_definition=>implementation_type->managed
       ).

    "define behavior for root entity

    DATA(lo_header_behavior) = lo_specification->add_behavior( io_rap_bo_node->rap_node_objects-cds_view_i ).

    " Characteristics.
    lo_header_behavior->characteristics->set_alias( CONV #( io_rap_bo_node->rap_node_objects-alias )
      )->set_persistent_table( io_rap_bo_node->table_name
      )->set_implementation_class(  io_rap_bo_node->rap_node_objects-behavior_implementation
      )->lock->set_master( ).

    " Standard operations.
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
    lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).


    "determination CalculateSemanticKey on modify { create; }
    lo_header_behavior->add_determination( 'CalculateSemanticKey'
      )->set_time( xco_cp_behavior_definition=>evaluation->time->on_modify
      )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).

    DATA lv_semantic_db_key TYPE sxco_cds_field_name.
    lv_semantic_db_key = io_rap_bo_node->semantic_db_keys[ 1 ].

    LOOP AT lt_mapping_header INTO ls_mapping_header.
      CASE ls_mapping_header-dbtable_field.
        WHEN io_rap_bo_node->field_name-uuid. " co_key.  "  field ( readonly, numbering : managed ) Uuid;
          lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                           )->set_numbering_managed(
                           ")->set_read_only(
                           ).

          "io_rap_bo_node->semantic_keys[ 1 ]

        WHEN  lv_semantic_db_key . "  mo_header_semantic_db_key .

          lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                             )->set_read_only(
                             ).

      ENDCASE.
    ENDLOOP.



    lo_header_behavior->add_mapping_for( io_rap_bo_node->table_name )->set_field_mapping( it_field_mappings =  lt_mapping_header ).


    IF io_rap_bo_node->has_childs(  ).
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).
        lo_header_behavior->add_association( iv_name = '_' && lo_childnode->rap_node_objects-alias )->set_create_enabled( abap_true ).
      ENDLOOP.
    ENDIF.


    "define behavior for child entities

    IF io_rap_bo_node->has_childs(  ).

      LOOP AT io_rap_bo_node->all_childnodes INTO lo_childnode.

        CLEAR lt_mapping_item.

        LOOP AT lo_childnode->lt_fields INTO  DATA(ls_item_fields) .
          ls_mapping_item-dbtable_field = ls_item_fields-name.
          ls_mapping_item-cds_view_field = to_mixed( ls_item_fields-name ).
          IF  ls_item_fields-name  <> lo_childnode->field_name-client.
            INSERT ls_mapping_item INTO TABLE lt_mapping_item.
          ENDIF.
        ENDLOOP.

        DATA(lo_item_behavior) = lo_specification->add_behavior( lo_childnode->rap_node_objects-cds_view_i ).
*
*    " Characteristics.
        IF lo_childnode->is_grand_child_or_deeper(  ).

          lo_item_behavior->characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
            )->set_persistent_table( lo_childnode->table_name
            )->set_implementation_class( lo_childnode->rap_node_objects-behavior_implementation
            )->lock->set_dependent_by( '_' && lo_childnode->root_node->rap_node_objects-alias  ).

          "@todo change code when HFC3 is available
          "lo_item_behavior->add_association( mo_assoc_to_header ).
          lo_item_behavior->add_association( '_' && lo_childnode->root_node->rap_node_objects-alias  ).


        ELSEIF lo_childnode->is_child(  ).

          lo_item_behavior->characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
                   )->set_persistent_table( lo_childnode->table_name
                   )->set_implementation_class( lo_childnode->rap_node_objects-behavior_implementation
                   )->lock->set_dependent_by( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).

          "@todo change code when HFC3 is available
          "lo_item_behavior->add_association( mo_assoc_to_header ).
          lo_item_behavior->add_association( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).

          "lo_header_behavior->add_association( iv_name = '_' && lo_childnode->rap_node_objects-alias )->set_create_enabled( abap_true ).


        ELSE.
          "should not happen

          RAISE EXCEPTION TYPE zcx_rap_generator
            MESSAGE ID 'ZCM_RAP_GENERATOR' TYPE 'E' NUMBER '001'
            WITH lo_childnode->entityname lo_childnode->root_node->entityname.

        ENDIF.


        IF lo_childnode->has_childs(  ).
          LOOP AT lo_childnode->childnodes INTO DATA(lo_grandchildnode).
            lo_item_behavior->add_association( iv_name = '_' && lo_grandchildnode->rap_node_objects-alias )->set_create_enabled( abap_true ).
          ENDLOOP.
        ENDIF.


        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).



        "determination CalculateSemanticKey on modify { create; }
        lo_item_behavior->add_determination( 'CalculateSemanticKey'
          )->set_time( xco_cp_behavior_definition=>evaluation->time->on_modify
          )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).

        lv_semantic_db_key = lo_childnode->semantic_db_keys[ 1 ].

        LOOP AT lt_mapping_item INTO ls_mapping_item.
          CASE ls_mapping_item-dbtable_field.
            WHEN lo_childnode->field_name-uuid.  "  field ( readonly, numbering : managed ) uuid;
              lo_item_behavior->add_field( ls_mapping_item-cds_view_field
                             )->set_numbering_managed(
                             ")->set_read_only(
                             ).
            WHEN lo_childnode->field_name-parent_uuid OR
                 lo_childnode->field_name-root_uuid .  "  field ( readonly ) parentuuid, bookingid;
              lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

            WHEN  lv_semantic_db_key. "  mo_item_semantic_db_key .
              lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

          ENDCASE.
        ENDLOOP.


        lo_item_behavior->add_mapping_for( lo_childnode->table_name )->set_field_mapping( it_field_mappings =  lt_mapping_item ).

      ENDLOOP.

    ENDIF.


  ENDMETHOD.

  METHOD create_bdef_p.
    DATA(lo_specification) = io_put_operation->for-bdef->add_object( io_rap_bo_node->rap_root_node_objects-behavior_definition_p
               )->set_package( mo_package
               )->create_form_specification( ).
    lo_specification->set_short_description( 'Behavior for ' && io_rap_bo_node->rap_node_objects-cds_view_p
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

        "lo_item_behavior->add_association(  mo_assoc_to_header )->set_use(  ).
        " lo_item_behavior->add_association( mo_assoc_to_header && ';' )->set_use(  ).

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

*    IF create_item_objects(  ).
*      lo_header_behavior->add_association( iv_name = mo_assoc_to_item )->set_create_enabled( abap_true )->set_use(  ).
*    ENDIF.
*
*    IF create_item_objects(  ).
*      DATA(lo_item_behavior) = lo_specification->add_behavior( mo_p_cds_item ).
*
*      " Characteristics.
*      lo_item_behavior->characteristics->set_alias( CONV #( mo_alias_item )
*        ).
*      " Standard operations.
*      lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
*      lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).
*
*      "lo_item_behavior->add_association(  mo_assoc_to_header )->set_use(  ).
*      lo_item_behavior->add_association( mo_assoc_to_header && ';' )->set_use(  ).
*    ENDIF.

  ENDMETHOD.

  METHOD create_behavior_implementation.

    "create bdef implemenation for header

    DATA(lo_specification_header) = io_put_operation->for-clas->add_object(  io_rap_bo_node->rap_node_objects-behavior_implementation "  mo_i_bil_header
        )->set_package( mo_package
        )->create_form_specification( ).
    lo_specification_header->set_short_description( 'Behavior implementation for ' && io_rap_bo_node->root_node->rap_node_objects-cds_view_i  ).

    lo_specification_header->definition->set_abstract(
      )->set_final(
      )->set_for_behavior_of( io_rap_bo_node->root_node->rap_node_objects-cds_view_i ).

    DATA(lo_handler_header) = lo_specification_header->add_local_class( 'LHC_' && to_upper( io_rap_bo_node->rap_node_objects-alias ) ).
    lo_handler_header->definition->set_superclass( 'CL_ABAP_BEHAVIOR_HANDLER' ).

    DATA(lo_determination_header) = lo_handler_header->definition->section-private->add_method( 'CALCULATE_SEMANTIC_KEY' ).
    lo_determination_header->behavior_implementation->set_for_determination(
      iv_entity_name        = io_rap_bo_node->rap_node_objects-alias
      iv_determination_name = 'CalculateSemanticKey'
    ).
    lo_determination_header->add_importing_parameter( 'IT_KEYS' )->behavior_implementation->set_for( io_rap_bo_node->rap_node_objects-alias ).

    lo_handler_header->implementation->add_method( 'CALCULATE_SEMANTIC_KEY'
      )->set_source( VALUE #(
        ( |" Determination implementation goes here| ) )
      ).

  ENDMETHOD.


ENDCLASS.
