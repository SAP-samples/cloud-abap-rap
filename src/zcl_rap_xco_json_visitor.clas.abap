CLASS zcl_rap_xco_json_visitor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_xco_json_tree_visitor.
    DATA root_node  TYPE REF TO zcl_rap_node READ-ONLY.

    METHODS constructor
      IMPORTING io_root_node TYPE REF TO zcl_rap_node
      RAISING   zcx_rap_generator.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF t_valuehelp,
             alias              TYPE sxco_ddef_alias_name,
             name               TYPE sxco_cds_object_name,
             local_element      TYPE sxco_cds_field_name,
             element            TYPE sxco_cds_field_name,
             additional_binding TYPE zcl_rap_node=>tt_addtionalbinding,
           END OF t_valuehelp.

    TYPES: BEGIN OF t_association,
             name             TYPE sxco_ddef_alias_name,
             target           TYPE sxco_cds_object_name,
             cardinality      TYPE string,
             condition_fields TYPE zcl_rap_node=>tt_condition_fields,
           END OF t_association.


    DATA:

      parent_node              TYPE REF TO zcl_rap_node,
      last_visited_member      TYPE string,
      current_node             TYPE REF TO zcl_rap_node,
      object_number            TYPE i,
      array_level              TYPE i,
      array_level_valuehelps   TYPE i,
      array_level_associations TYPE i,
      in_value_helps           TYPE abap_bool,
      in_additional_binding    TYPE abap_bool,
      in_associations          TYPE abap_bool,
      in_conditions            TYPE abap_bool,
      in_mapping               TYPE abap_bool,
      additional_binding       TYPE zcl_rap_node=>ts_additionalbinding,
      value_help               TYPE t_valuehelp,
      condition_fields         TYPE zcl_rap_node=>ts_condition_fields,
      association              TYPE t_association,
      field_mappings           TYPE HASHED TABLE OF  if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                                    WITH UNIQUE KEY cds_view_field dbtable_field,
      field_mapping            TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping.



ENDCLASS.



CLASS zcl_rap_xco_json_visitor IMPLEMENTATION.



  METHOD if_xco_json_tree_visitor~enter_array.
    array_level += 1.
    CASE last_visited_member.
      WHEN 'children'.
        IF current_node->is_child(  ) OR current_node->is_grand_child_or_deeper(  ).
          parent_node = current_node.
        ENDIF.
*        in_children = abap_true.
*        array_level_children = array_level.
      WHEN 'valuehelps'.
        in_value_helps = abap_true.
        array_level_valuehelps = array_level.
      WHEN 'additionalbinding'.
        in_additional_binding = abap_true.
      WHEN 'associations'.
        in_associations = abap_true.
        array_level_associations = array_level.
      WHEN 'conditions'.
        in_conditions = abap_true.
      WHEN 'mapping'.
        in_mapping = abap_true.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_rap_generator
          EXPORTING
            textid   = zcx_rap_generator=>invalid_json_array_name
            mv_value = last_visited_member.
    ENDCASE.

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~enter_object.

    object_number += 1.

    IF in_additional_binding = abap_true.
      CLEAR additional_binding.
    ENDIF.

    IF in_conditions = abap_true.
      CLEAR condition_fields.
    ENDIF.

    IF in_mapping  = abap_true.
      CLEAR field_mapping.
    ENDIF.

    IF in_additional_binding = abap_false AND
       in_associations = abap_false AND
       in_value_helps = abap_false AND
       in_conditions = abap_false AND
       in_mapping  = abap_false.

      IF object_number > 1.

        IF current_node IS INITIAL.
          parent_node = root_node.
          current_node = root_node.
        ELSE.
          current_node = parent_node->add_child( ).
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~leave_array.

    array_level -= 1.

    IF in_additional_binding = abap_true .
      in_additional_binding = abap_false.
    ELSEIF in_value_helps = abap_true .
      in_value_helps = abap_false.
    ELSEIF in_conditions = abap_true.
      in_conditions = abap_false.
    ELSEIF in_associations = abap_true.
      in_associations = abap_false.
    ELSEIF in_mapping = abap_true.
      in_mapping = abap_false.

      IF object_number = 1.
        root_node->set_mapping(
            it_field_mappings = field_mappings
        ).
        CLEAR field_mappings.
      ELSE.
        current_node->set_mapping(
            it_field_mappings = field_mappings
        ).
        CLEAR field_mappings.
      ENDIF.

    ELSE.

      IF current_node->is_grand_child_or_deeper( ).
        parent_node = current_node->parent_node->parent_node.
        current_node = current_node->parent_node.
      ENDIF.

      IF current_node->is_child(  ).
        parent_node = root_node.
        current_node = current_node->parent_node.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~leave_object.

    object_number -= 1.

    "add valuehelp

    IF in_additional_binding = abap_true.
      APPEND additional_binding TO value_help-additional_binding.
    ENDIF.

    IF in_additional_binding = abap_false AND
     in_value_helps = abap_true.
      IF object_number = 1.
        root_node->add_valuehelp(
          EXPORTING
            iv_alias              = value_help-alias
            iv_name               = value_help-name
            iv_localelement       = value_help-local_element
            iv_element            = value_help-element
            it_additional_binding = value_help-additional_binding
        ).
        CLEAR value_help.
*CATCH zcx_rap_generator.
      ELSE.
        current_node->add_valuehelp(
                 EXPORTING
                   iv_alias              = value_help-alias
                   iv_name               = value_help-name
                   iv_localelement       = value_help-local_element
                   iv_element            = value_help-element
                   it_additional_binding = value_help-additional_binding
               ).
        CLEAR value_help.
      ENDIF.
    ENDIF.

    " add association

    IF in_conditions = abap_true.
      APPEND condition_fields TO association-condition_fields.
    ENDIF.

    IF in_conditions = abap_false AND
     in_associations = abap_true.
      IF object_number = 1.
        root_node->add_association(
          EXPORTING
            iv_name             = association-name
            iv_target           = association-target
            it_condition_fields = association-condition_fields
            iv_cardinality      = association-cardinality
        ).
*        CATCH zcx_rap_generator.
        CLEAR association.
*CATCH zcx_rap_generator.
      ELSE.
        current_node->add_association(
          EXPORTING
            iv_name             = association-name
            iv_target           = association-target
            it_condition_fields = association-condition_fields
            iv_cardinality      = association-cardinality
        ).
        CLEAR association.
      ENDIF.
    ENDIF.

    "add mapping

    IF in_mapping = abap_true.
      INSERT field_mapping INTO TABLE field_mappings.
    ENDIF.




    "current_node->finalize( ).

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~on_end.

    LOOP AT root_node->all_childnodes INTO DATA(childnode).
      childnode->finalize(  ).
    ENDLOOP.

    root_node->finalize(  ).

*    DATA(my_bo_generator) = NEW zcl_rap_bo_generator(
*  iv_package          = root_node->package
*  io_rap_bo_root_node = root_node
*  ).
*
*    DATA(lt_todos) = my_bo_generator->generate_bo(  ).

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~on_start.

    CLEAR object_number.
    "root_node = NEW zcl_rap_node(  ).
    "root_node->set_is_root_node( ).

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~visit_boolean.

    IF object_number = 1.
      CASE last_visited_member.

        WHEN 'transactionalbehavior'.
          root_node->add_transactional_behavior( iv_value ).
        WHEN 'publishservice'.
          root_node->set_publish_service( iv_value ).
        WHEN OTHERS.

          DATA(error_message) = |{ last_visited_member } in entity { root_node->entityname }|.

          RAISE EXCEPTION TYPE zcx_rap_generator
            EXPORTING
              textid   = zcx_rap_generator=>invalid_json_property_name
              mv_value = error_message.

      ENDCASE.
    ENDIF.


  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~visit_member.

    "we want to use camelCase in the json file
    "but we do not want to enforce it here

    last_visited_member = to_lower( iv_name ).

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~visit_string.

    DATA error_message TYPE string.

    IF object_number = 1.
      CASE last_visited_member.
        WHEN 'implementationtype'.
          root_node->set_implementation_type( iv_value ).
        WHEN 'namespace'.
          root_node->set_namespace( CONV sxco_ar_object_name( iv_value ) ).
        WHEN 'suffix'.
          root_node->set_suffix( CONV sxco_ar_object_name( iv_value ) ).
        WHEN 'prefix'.
          root_node->set_prefix( CONV sxco_ar_object_name( iv_value ) ).
        WHEN 'package'.
          root_node->set_package( CONV sxco_package( iv_value ) ).
        WHEN 'datasourcetype'.
          root_node->set_data_source_type( CONV #( iv_value ) ).
        WHEN OTHERS.

          error_message = |{ last_visited_member } in entity { root_node->entityname }|.

          RAISE EXCEPTION TYPE zcx_rap_generator
            EXPORTING
              textid   = zcx_rap_generator=>invalid_json_property_name
              mv_value = error_message.

      ENDCASE.
    ENDIF.

    IF object_number > 1.

      IF in_additional_binding = abap_true.

        CASE last_visited_member .

          WHEN 'localelement'.
            additional_binding-localelement = iv_value.
          WHEN 'element'.
            additional_binding-element = iv_value.
          WHEN OTHERS.

            error_message = |{ last_visited_member } in entity { current_node->entityname } in additionalBinding|.

            RAISE EXCEPTION TYPE zcx_rap_generator
              EXPORTING
                textid   = zcx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSEIF in_value_helps = abap_true.

        CASE last_visited_member .
          WHEN 'alias' .
            value_help-alias = CONV sxco_cds_object_name( iv_value ).
          WHEN 'name' .
            value_help-name = CONV sxco_cds_object_name( iv_value ).
          WHEN 'localelement'.
            value_help-local_element = CONV sxco_cds_field_name( iv_value ).
          WHEN 'element'.
            value_help-element = CONV sxco_cds_field_name( iv_value ).
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in valueHelps|.

            RAISE EXCEPTION TYPE zcx_rap_generator
              EXPORTING
                textid   = zcx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.


      ELSEIF in_conditions = abap_true.

        CASE last_visited_member .
          WHEN 'projectionfield'.
            condition_fields-projection_field = iv_value.
          WHEN 'associationfield'.
            condition_fields-association_field = iv_value.
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in conditions|.

            RAISE EXCEPTION TYPE zcx_rap_generator
              EXPORTING
                textid   = zcx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSEIF in_associations = abap_true.

        CASE last_visited_member .
          WHEN 'name'.
            association-name = CONV sxco_ddef_alias_name( iv_value ).
          WHEN 'target' .
            association-target = CONV sxco_cds_object_name( iv_value ).
          WHEN 'cardinality'.
            association-cardinality = iv_value.
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in associations|.

            RAISE EXCEPTION TYPE zcx_rap_generator
              EXPORTING
                textid   = zcx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSEIF in_mapping = abap_true.
        CASE last_visited_member .
          WHEN 'dbtable_field'.
            field_mapping-dbtable_field = CONV sxco_cds_field_name( iv_value ).
          WHEN 'cds_view_field' .
            field_mapping-cds_view_field = CONV sxco_cds_field_name( iv_value ).
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in mapping|.
            RAISE EXCEPTION TYPE zcx_rap_generator
              EXPORTING
                textid   = zcx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSE.

        CASE last_visited_member .
          WHEN 'entityname'.
            current_node->set_entity_name( CONV #( iv_value ) ).
          WHEN 'datasource'.
            current_node->set_data_source( CONV #( iv_value ) ).
          WHEN 'persistenttable' .
            current_node->set_persistent_table( CONV #( iv_value ) ).
          WHEN 'objectid'.
            "current_node->set_semantic_key_fields( it_semantic_key = VALUE #( ( CONV #( iv_value ) ) ) ).
            current_node->set_object_id( CONV sxco_ad_field_name( iv_value ) ).
          WHEN 'client'.
            "current_node->set_field_name_( CONV #( iv_value ) ).
          WHEN 'uuid'.
            current_node->set_field_name_uuid( iv_value ).
          WHEN 'parentuuid'.
            current_node->set_field_name_parent_uuid( iv_value ).
          WHEN 'rootuuid'.
            current_node->set_field_name_root_uuid( iv_value ).
          WHEN 'createdby'.
            current_node->set_field_name_created_by( iv_value ).
          WHEN 'createdat'.
            current_node->set_field_name_created_at( iv_value ).
          WHEN 'lastchangedby'.
            current_node->set_field_name_last_changed_by( iv_value ).
          WHEN 'lastchangedat'.
            current_node->set_field_name_last_changed_at( iv_value ).
          WHEN 'localinstancelastchangedat'.

          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname }|.

            RAISE EXCEPTION TYPE zcx_rap_generator
              EXPORTING
                textid   = zcx_rap_generator=>invalid_json_property_name
                mv_value = error_message.


        ENDCASE.

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.
    root_node = io_root_node.
  ENDMETHOD.

ENDCLASS.
