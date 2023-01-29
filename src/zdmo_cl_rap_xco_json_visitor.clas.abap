CLASS zdmo_cl_rap_xco_json_visitor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_xco_json_tree_visitor.
    DATA root_node  TYPE REF TO ZDMO_cl_rap_node READ-ONLY.

    METHODS constructor
      IMPORTING io_root_node TYPE REF TO ZDMO_cl_rap_node
      RAISING   ZDMO_cx_rap_generator.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF t_valuehelp,
             alias              TYPE sxco_ddef_alias_name,
             name               TYPE sxco_cds_object_name,
             local_element      TYPE sxco_cds_field_name,
             element            TYPE sxco_cds_field_name,
             additional_binding TYPE ZDMO_cl_rap_node=>tt_addtionalbinding,
           END OF t_valuehelp.

    TYPES: BEGIN OF t_association,
             name             TYPE sxco_ddef_alias_name,
             target           TYPE sxco_cds_object_name,
             cardinality      TYPE string,
             condition_fields TYPE ZDMO_cl_rap_node=>tt_condition_fields,
           END OF t_association.

*    TYPES : BEGIN OF t_objects_with_add_fields,
*              object            TYPE string,
*              additional_fields TYPE ZDMO_cl_rap_node=>tt_additional_fields_old,
*              "localized         TYPE abap_bool,
*            END OF t_objects_with_add_fields.


    DATA:

      json_schema                TYPE string,
      parent_node                TYPE REF TO ZDMO_cl_rap_node,
      last_visited_member        TYPE string,
      current_node               TYPE REF TO ZDMO_cl_rap_node,
      object_number              TYPE i,
      array_level                TYPE i,
      array_level_valuehelps     TYPE i,
      array_level_associations   TYPE i,
      array_level_obj_with_add_f TYPE i,
      in_value_helps             TYPE abap_bool,
      in_additional_binding      TYPE abap_bool,
      in_associations            TYPE abap_bool,
      in_conditions              TYPE abap_bool,
      in_mapping                 TYPE abap_bool,
      in_fields                  TYPE abap_bool,
      "in_objects_with_add_fields TYPE abap_bool,
      in_additional_fields       TYPE abap_bool,
      in_keys                    TYPE abap_bool,
      additional_binding         TYPE ZDMO_cl_rap_node=>ts_additionalbinding,
      value_help                 TYPE t_valuehelp,
      condition_fields           TYPE ZDMO_cl_rap_node=>ts_condition_fields,
      association                TYPE t_association,
      additional_field           TYPE ZDMO_cl_rap_node=>ts_additional_fields,
      additional_fields          TYPE ZDMO_cl_rap_node=>tt_additional_fields,
*      objects_with_add_fields    TYPE t_objects_with_add_fields,
      field_mappings             TYPE HASHED TABLE OF  if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                                    WITH UNIQUE KEY cds_view_field dbtable_field,
      field_mapping              TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping,
      key_fields                 TYPE TABLE OF sxco_ad_field_name,
      field                      TYPE ZDMO_cl_rap_node=>ts_field,
      fields                     TYPE ZDMO_cl_rap_node=>tt_fields.
ENDCLASS.



CLASS ZDMO_CL_RAP_XCO_JSON_VISITOR IMPLEMENTATION.


  METHOD constructor.
    root_node = io_root_node.
  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~enter_array.
    array_level += 1.
    CASE last_visited_member.
      WHEN 'keys'.
        CLEAR key_fields.
        in_keys = abap_true.
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
*      WHEN 'objectswithadditionalfields'.
*        in_objects_with_add_fields = abap_true.
*        array_level_obj_with_add_f = array_level.
      WHEN 'additionalfields'.
        in_additional_fields = abap_true.
      WHEN 'mapping'.
        in_mapping = abap_true.
      WHEN 'fields'.
        in_fields = abap_true.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
          EXPORTING
            textid   = ZDMO_cx_rap_generator=>invalid_json_array_name
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

    IF in_additional_fields = abap_true.
      CLEAR additional_field.
    ENDIF.

    IF in_mapping  = abap_true.
      CLEAR field_mapping.
    ENDIF.

    IF in_fields = abap_true.
      CLEAR fields.
    ENDIF.

    IF in_additional_binding = abap_false AND
       in_associations = abap_false AND
       in_value_helps = abap_false AND
       in_conditions = abap_false AND
       in_mapping  = abap_false AND
       in_fields = abap_false AND
       "in_objects_with_add_fields = abap_false AND
       in_additional_fields = abap_false.

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
    ELSEIF in_additional_fields = abap_true.
      in_additional_fields = abap_false.

      IF object_number = 1.
        root_node->add_additional_fields(
          EXPORTING
            "iv_object            = objects_with_add_fields-object
            it_additional_fields = additional_fields
        ).
        CLEAR additional_fields.

      ELSE.
        current_node->add_additional_fields(
          EXPORTING
            "iv_object            = objects_with_add_fields-object
            it_additional_fields = additional_fields
        ).
        CLEAR additional_fields.
      ENDIF.

*    ELSEIF in_objects_with_add_fields = abap_true.
*      in_objects_with_add_fields = abap_false.

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

    ELSEIF in_fields = abap_true.
      in_fields = abap_false.

      IF object_number = 1.
        root_node->set_fields(
            it_fields = fields
        ).
        CLEAR field_mappings.
      ELSE.
        current_node->set_fields(
            it_fields = fields
        ).
        CLEAR fields.
      ENDIF.
    ELSEIF in_keys = abap_true.
      in_keys = abap_false.
      current_node->set_semantic_key_fields( key_fields  ).
      CLEAR key_fields.
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
*CATCH ZDMO_cx_rap_generator.
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
*        CATCH ZDMO_cx_rap_generator.
        CLEAR association.
*CATCH ZDMO_cx_rap_generator.
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

    "add additonal fields

    IF in_additional_fields = abap_true.
      APPEND additional_field TO additional_fields.
    ENDIF.



    "add mapping

    IF in_mapping = abap_true.
      INSERT field_mapping INTO TABLE field_mappings.
    ENDIF.

    "add a field to the field list
    IF in_fields = abap_true.
      INSERT field INTO TABLE fields.
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
    "root_node = NEW ZDMO_cl_rap_node(  ).
    "root_node->set_is_root_node( ).

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~visit_boolean.
    DATA error_message TYPE string.
    CHECK iv_value IS NOT INITIAL.
    IF object_number = 1.
      CASE last_visited_member.

        WHEN 'transactionalbehavior'.
          root_node->set_has_transactional_behavior( iv_value ).
        WHEN 'publishservice'.
          root_node->set_publish_service( iv_value ).
        WHEN 'draftenabled'.
          root_node->set_draft_enabled( iv_value ).
        WHEN 'addbusinessconfigurationregistration' .
          root_node->add_to_manage_business_config( iv_value ).
        WHEN 'skipactivation'.
          root_node->set_skip_activation( iv_value ).
        WHEN 'addmetadataextensions'.
          root_node->set_add_meta_data_extensions( iv_value ).
        WHEN 'iscustomizingtable'.
          root_node->set_is_customizing_table( iv_value ).
        WHEN 'multiinlineedit'.
          root_node->add_multi_edit( iv_value ).
        WHEN 'generateonlynodehierachy'.
          root_node->set_generate_only_node_hierach( iv_value ).
        WHEN 'createtable'.
          root_node->set_create_table( iv_value ).
        when 'mimicadtwizard'.
          root_node->set_mimic_adt_wizard( iv_value ).
        WHEN OTHERS.

          error_message = |{ last_visited_member } in entity { root_node->entityname }| ##NO_TEXT.

          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            EXPORTING
              textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
              mv_value = error_message.

      ENDCASE.
    ENDIF.


    IF object_number > 1.

      IF in_additional_fields = abap_true.

        CASE last_visited_member .
          WHEN 'localized'.
            additional_field-localized = iv_value.
          WHEN 'cdsinterfaceview'.
            additional_field-cds_interface_view = iv_value .
          whEN 'cdsRestrictedReuseView'.
            additional_field-cds_restricted_reuse_view = iv_value .
          WHEN 'cdsprojectionview'.
            additional_field-cds_projection_view  = iv_value .
          WHEN 'drafttable'.
            additional_field-draft_table   = iv_value .
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in objects with add. fields| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSEIF in_fields = abap_true.

        CASE last_visited_member .
          WHEN 'iskey'.
            field-key_indicator =  iv_value .
          WHEN 'notnull'.
            field-not_null =  iv_value .
          WHEN 'isdomainfixedvalue'.
            field-domain_fixed_value =  iv_value .
          WHEN 'ishidden'.
            field-is_hidden =  iv_value .
          WHEN 'hasassociation'.
            field-has_association =  iv_value .
          WHEN 'hasvaluehelp'.
            field-has_valuehelp =  iv_value .
          WHEN 'isdataelement'.
            field-is_data_element =  iv_value .
          WHEN 'isbuiltintype'.
            field-is_built_in_type =  iv_value .
          WHEN 'iscurrencycode'.
            field-is_currencycode =  iv_value .
          WHEN 'isunitofmeasure'.
            field-is_unitofmeasure =  iv_value .
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in fields| ##NO_TEXT.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~visit_member.

    "we want to use camelCase in the json file
    "but we do not want to enforce it here

    last_visited_member = to_lower( iv_name ).

    IF in_keys = abap_true.
      DATA(key_field) = iv_name.
    ENDIF.

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~visit_number.
    DATA error_message TYPE string.
    CHECK iv_value IS NOT INITIAL.
    IF object_number = 1.
      CASE last_visited_member.

*        WHEN 'transactionalbehavior'.
*          root_node->add_transactional_behavior( iv_value ).

        WHEN OTHERS.

          error_message = |{ last_visited_member } in entity { root_node->entityname }| ##NO_TEXT.

          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            EXPORTING
              textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
              mv_value = error_message.

      ENDCASE.
    ENDIF.


    IF object_number > 1.

      IF in_additional_fields = abap_true.

        CASE last_visited_member .
          WHEN 'builtintypelength'.
            additional_field-built_in_type_length = iv_value.
          WHEN 'builtintypedecimals'.
            additional_field-built_in_type_decimals = iv_value .
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in objects with add. fields| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSEIF in_fields = abap_true.

        CASE last_visited_member .
          WHEN 'builtintypelength'.
            field-built_in_type_length =  iv_value .
          WHEN 'builtintypedecimals'.
            field-built_in_type_decimals =  iv_value .
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in fields| ##NO_TEXT.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.


      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD if_xco_json_tree_visitor~visit_string.

    DATA error_message TYPE string.

    IF iv_value IS INITIAL.
      EXIT.
    ENDIF.

    IF in_keys = abap_true.
      APPEND iv_value TO key_fields.
    ENDIF.

    IF object_number = 1.
      CASE last_visited_member.


        WHEN '$schema'.
          json_schema = iv_value.
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
          root_node->set_data_source_type( iv_value  ).
        WHEN 'bindingtype'.
          root_node->set_binding_type(  iv_value  ).
        WHEN 'transportrequest'.
          root_node->set_transport_request( CONV #( iv_value ) ).
        WHEN 'businessconfigurationname'.
          root_node->set_mbc_name( iv_value  ).
        WHEN 'businessconfigurationidentifier'  .
          root_node->set_mbc_identifier( iv_value ).
        WHEN 'businessconfigurationdescription'.
          root_node->set_mbc_description( iv_value ).
        WHEN OTHERS.

          error_message = |{ last_visited_member } in entity { root_node->entityname }| ##NO_TEXT.

          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            EXPORTING
              textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
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

            error_message = |{ last_visited_member } in entity { current_node->entityname } in additionalBinding| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
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
            error_message = |{ last_visited_member } in entity { current_node->entityname } in valueHelps| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.


      ELSEIF in_conditions = abap_true.

        CASE last_visited_member .
          WHEN 'projectionfield'.
            condition_fields-projection_field = iv_value.
          WHEN 'associationfield'.
            condition_fields-association_field = iv_value.
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in conditions| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
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
            error_message = |{ last_visited_member } in entity { current_node->entityname } in associations| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSEIF in_additional_fields = abap_true.

        CASE last_visited_member .
          WHEN 'name'.
            additional_field-name = iv_value.
          WHEN 'cdsviewfield'.
            additional_field-cds_view_field = iv_value.
          WHEN 'dataelement' .
            additional_field-data_element  = iv_value.
          WHEN 'builtintype'  .
            additional_field-built_in_type = iv_value.
          WHEN 'builtintypelength'.
            additional_field-built_in_type_length = iv_value.
          WHEN 'builtintypedecimals'.
            additional_field-built_in_type_decimals = iv_value.
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in additional fields| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

*      ELSEIF in_objects_with_add_fields = abap_true.
*
*        CASE last_visited_member .
*          WHEN 'object'.
*            objects_with_add_fields-object =  iv_value .
*
*          WHEN OTHERS.
*            error_message = |{ last_visited_member } in entity { current_node->entityname } in objects with add. fields|.
*
*            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
*              EXPORTING
*                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
*                mv_value = error_message.
*        ENDCASE.

      ELSEIF in_mapping = abap_true.
        CASE last_visited_member .
          WHEN 'dbtable_field'.
            field_mapping-dbtable_field = CONV sxco_cds_field_name( iv_value ).
          WHEN 'cds_view_field' .
            field_mapping-cds_view_field = CONV sxco_cds_field_name( iv_value ).
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in mapping| ##NO_TEXT.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.

      ELSEIF in_fields = abap_true.

        CASE last_visited_member .
          WHEN 'abapfieldname'.
            field-name = CONV sxco_cds_field_name( iv_value ).
          WHEN 'domain' .
            field-doma = CONV sxco_cds_field_name( iv_value ).
          WHEN 'dataelement'.
            field-data_element = CONV sxco_cds_field_name( iv_value ).
          WHEN 'cdsviewfieldname'.
            field-cds_view_field = CONV sxco_cds_field_name( iv_value ).
          WHEN 'builtintype'.
            field-built_in_type = CONV sxco_cds_field_name( iv_value ).
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname } in fields| ##NO_TEXT.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.
        ENDCASE.


      ELSEIF in_keys = abap_true.
        DATA(test) = iv_value.
      ELSE.

        CASE last_visited_member .
          WHEN 'keys'.
            "do nothing

          WHEN 'entityname'.
            current_node->set_entity_name( CONV #( iv_value ) ).
          WHEN 'datasource'.
            current_node->set_data_source( iv_value  ).
          WHEN 'persistenttable' .
            current_node->set_persistent_table(  iv_value  ).
          WHEN 'objectid'.
            "current_node->set_semantic_key_fields( it_semantic_key = VALUE #( ( CONV #( iv_value ) ) ) ).
            current_node->set_object_id( CONV sxco_ad_field_name( iv_value ) ).
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
            current_node->set_field_name_loc_last_chg_at( iv_value ).
          WHEN 'localinstancelastchangedby'.
            current_node->set_field_name_loc_last_chg_by( iv_value ).
          WHEN 'etagmaster'.
            current_node->set_field_name_etag_master( iv_value ).
          WHEN 'totaletag'.
            current_node->set_field_name_total_etag( iv_value ).
          WHEN 'client'.
            current_node->set_field_name_client( iv_value ).
          WHEN 'language'.
            current_node->set_field_name_language( iv_value ).
          WHEN 'drafttable'.
            current_node->set_name_draft_table( iv_value ).
          WHEN 'cdsinterfaceview' .
            current_node->set_name_cds_i_view( CONV #( iv_value ) ).
          WHEN 'cdsrestrictedreuseview'  .
            current_node->set_name_cds_r_view( CONV #( iv_value ) ).
          WHEN 'cdsprojectionview'.
            current_node->set_name_cds_p_view( CONV #( iv_value ) ).
          WHEN 'metadataextensionview'.
            current_node->set_name_mde( CONV #( iv_value ) ).
          WHEN 'behaviorimplementationclass'.
            current_node->set_name_behavior_impl( CONV #( iv_value )  ).
          WHEN 'servicedefinition'.
            current_node->set_name_service_definition( CONV #( iv_value )  ).
          WHEN 'servicebinding'.
            current_node->set_name_service_binding( CONV #( iv_value )  ).
          WHEN 'controlstructure'.
            current_node->set_name_control_structure( CONV #( iv_value )  ).
          WHEN 'customqueryimplementationclass'.
            current_node->set_name_custom_query_impl( CONV #( iv_value )  ).
          WHEN 'textelement' .
            error_message = |{ last_visited_member } in entity { current_node->entityname }| ##NO_TEXT.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>not_implemented
                mv_value = error_message.
          WHEN 'description'.
            error_message = |{ last_visited_member } in entity { current_node->entityname }| ##NO_TEXT.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>not_implemented
                mv_value = error_message.
          WHEN OTHERS.
            error_message = |{ last_visited_member } in entity { current_node->entityname }| ##NO_TEXT.

            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>invalid_json_property_name
                mv_value = error_message.


        ENDCASE.

      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
