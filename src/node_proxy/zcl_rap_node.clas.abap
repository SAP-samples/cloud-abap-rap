CLASS zcl_rap_node DEFINITION
  PUBLIC
  "FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "the RAP generator only supports certain combinations of implementation type and key type
      BEGIN OF implementation_type,
        managed_uuid      TYPE string VALUE 'managed_uuid',
        unmanged_semantic TYPE string VALUE 'unmanaged_semantic',
      END OF implementation_type.

    TYPES:
      BEGIN OF root_cause_textid,
        msgid TYPE symsgid,
        msgno TYPE symsgno,
        attr1 TYPE scx_attrname,
        attr2 TYPE scx_attrname,
        attr3 TYPE scx_attrname,
        attr4 TYPE scx_attrname,
      END OF root_cause_textid.


    TYPES:
      BEGIN OF ts_field_name,
        client          TYPE string,
        uuid            TYPE string,
        parent_uuid     TYPE string,
        root_uuid       TYPE string,
        created_by      TYPE string,
        created_at      TYPE string,
        last_changed_by TYPE string,
        last_changed_at TYPE string,
      END OF ts_field_name.

    TYPES :  tt_childnodes TYPE STANDARD TABLE OF REF TO zcl_rap_node WITH EMPTY KEY.
    TYPES :  ty_childnode TYPE REF TO zcl_rap_node.
    TYPES :  tt_semantic_keys TYPE TABLE OF sxco_dbt_object_name.
    TYPES :  tt_semantic_db_keys TYPE TABLE OF sxco_dbt_object_name.

    TYPES:
      BEGIN OF ts_field,
        name               TYPE sxco_ad_object_name,
        doma               TYPE sxco_ad_object_name,
        key_indicator      TYPE abap_bool,
        not_null           TYPE abap_bool,
        domain_fixed_value TYPE abap_bool,
        cds_view_field     TYPE sxco_cds_field_name,
      END OF ts_field.

    TYPES : tt_fields TYPE STANDARD TABLE OF ts_field WITH EMPTY KEY.

    TYPES:
      BEGIN OF ts_node_objects,
        cds_view_i              TYPE sxco_cds_object_name,
        ddic_view_i             TYPE sxco_dbt_object_name,
        cds_view_p              TYPE sxco_cds_object_name,
        meta_data_extension     TYPE sxco_cds_object_name,
        alias                   TYPE sxco_ddef_alias_name,
        behavior_implementation TYPE sxco_ao_object_name,
      END OF ts_node_objects.

    TYPES:
      BEGIN OF ts_root_node_objects,
        behavior_definition_i TYPE sxco_cds_object_name,
        behavior_definition_p TYPE sxco_cds_object_name,
        service_definition    TYPE sxco_ao_object_name,
        service_binding       TYPE sxco_ao_object_name,
      END OF ts_root_node_objects.

    DATA lt_messages TYPE TABLE OF string.

    DATA field_name TYPE ts_field_name READ-ONLY.

    DATA rap_node_objects TYPE ts_node_objects READ-ONLY.
    DATA rap_root_node_objects TYPE ts_root_node_objects READ-ONLY.
    DATA lt_fields TYPE STANDARD TABLE OF ts_field WITH DEFAULT KEY READ-ONLY.
    DATA table_name          TYPE sxco_dbt_object_name READ-ONLY.
    DATA semantic_keys       TYPE tt_semantic_keys READ-ONLY.
    DATA semantic_db_keys    TYPE tt_semantic_db_keys READ-ONLY.
    DATA suffix              TYPE string READ-ONLY.
    DATA prefix              TYPE string READ-ONLY.
    DATA namespace           TYPE string READ-ONLY.
    DATA entityname          TYPE sxco_ddef_alias_name READ-ONLY.
    DATA node_number         TYPE i.

    DATA all_childnodes TYPE STANDARD TABLE OF REF TO zcl_rap_node READ-ONLY.
    DATA childnodes TYPE STANDARD TABLE OF REF TO zcl_rap_node READ-ONLY.

    DATA root_node TYPE REF TO zcl_rap_node READ-ONLY.
    DATA parent_node TYPE REF TO zcl_rap_node READ-ONLY.




    METHODS constructor
      IMPORTING
                VALUE(iv_entity_name) TYPE sxco_ddef_alias_name
      RAISING   zcx_rap_generator.

    METHODS get_root_exception
      IMPORTING
        !ix_exception  TYPE REF TO cx_root
      RETURNING
        VALUE(rx_root) TYPE REF TO cx_root .

    METHODS get_root_cause_textid
      IMPORTING
                ix_previous                 TYPE REF TO cx_root
      RETURNING VALUE(rs_root_cause_textid) TYPE root_cause_textid.

    METHODS add_child
      IMPORTING
                VALUE(iv_entity_name) TYPE sxco_ddef_alias_name
      RETURNING VALUE(ro_child_node)
                  TYPE REF TO zcl_rap_node
      RAISING   zcx_rap_generator.

    METHODS check_repository_object_name
      IMPORTING
                iv_type TYPE sxco_ar_object_type
                iv_name TYPE string
      RAISING   zcx_rap_generator.

    METHODS check_parameter
      IMPORTING
                iv_parameter_name TYPE string
                iv_value          TYPE string
      RAISING   zcx_rap_generator.

    METHODS finalize
      RAISING zcx_rap_generator.

    METHODS get_fields
      RAISING zcx_rap_generator.

    METHODS set_namespace
      IMPORTING
                iv_namespace TYPE sxco_ar_object_name
      RAISING   zcx_rap_generator.

    METHODS set_prefix
      IMPORTING
                iv_prefix TYPE    sxco_ar_object_name
      RAISING   zcx_rap_generator.

    METHODS set_suffix
      IMPORTING
                iv_suffix TYPE    sxco_ar_object_name
      RAISING   zcx_rap_generator.

    METHODS set_parent
      IMPORTING
                io_parent_node TYPE REF TO zcl_rap_node
      RAISING   zcx_rap_generator.

    METHODS set_root
      IMPORTING
                io_root_node TYPE REF TO zcl_rap_node
      RAISING   zcx_rap_generator.

    METHODS is_root RETURNING VALUE(rv_is_root) TYPE abap_bool.

    METHODS is_child RETURNING VALUE(rv_is_child) TYPE abap_bool.

    METHODS is_grand_child_or_deeper RETURNING VALUE(rv_is_grand_child) TYPE abap_bool.

    METHODS set_table
      IMPORTING
                iv_table TYPE sxco_ar_object_name
      RAISING   zcx_rap_generator.

    METHODS has_childs
      RETURNING VALUE(rv_has_childs) TYPE abap_bool.

    METHODS set_semantic_key_fields
      IMPORTING it_semantic_key TYPE tt_semantic_keys
      RAISING   zcx_rap_generator.

    METHODS set_cds_view_i_name
      RETURNING VALUE(rv_cds_i_view_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS set_cds_view_p_name
      RETURNING VALUE(rv_cds_p_view_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS set_mde_name
      RETURNING VALUE(rv_mde_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS set_ddic_view_i_name
      RETURNING VALUE(rv_ddic_i_view_name) TYPE sxco_dbt_object_name
      RAISING   zcx_rap_generator.

    METHODS set_behavior_impl_name
      RETURNING VALUE(rv_behavior_imp_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS set_behavior_def_i_name
      RETURNING VALUE(rv_behavior_dev_i_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS set_behavior_def_p_name
      RETURNING VALUE(rv_behavior_dev_p_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS set_service_definition_name
      RETURNING VALUE(rv_service_definition_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS set_service_binding_name
      RETURNING VALUE(rv_service_binding_name) TYPE sxco_cds_object_name
      RAISING   zcx_rap_generator.

    METHODS is_alpha_numeric
      IMPORTING iv_string                  TYPE string
      RETURNING VALUE(rv_is_alpha_numeric) TYPE abap_bool.

    METHODS contains_no_blanks
      IMPORTING iv_string                    TYPE string
      RETURNING VALUE(rv_contains_no_blanks) TYPE abap_bool.

    METHODS is_consistent
      RETURNING VALUE(rv_is_consistent) TYPE abap_bool.

  PROTECTED SECTION.


    DATA is_test_run TYPE abap_bool.

    DATA package             TYPE sxco_package.
    DATA is_root_node        TYPE abap_bool.
    DATA is_child_node       TYPE abap_bool.
    DATA is_grand_child_node TYPE abap_bool.
    DATA is_finalized           TYPE abap_bool.
    DATA bo_node_is_consistent  TYPE abap_bool.
    DATA implementationtype  TYPE string.
    DATA keytype             TYPE string.
    DATA data_source_type    TYPE string.

    METHODS set_number
      IMPORTING
                iv_number TYPE i
      RAISING   cx_parameter_invalid.


  PRIVATE SECTION.






ENDCLASS.



CLASS zcl_rap_node IMPLEMENTATION.

  METHOD constructor.

    bo_node_is_consistent = abap_true.
    is_finalized = abap_false.

*    "search for non alpha numeric characters
*    IF is_alpha_numeric( CONV #( iv_entity_name ) ) = abap_false.
*      bo_node_is_consistent = abap_false.
*      RAISE EXCEPTION TYPE zcx_rap_generator
*        EXPORTING
*          textid   = zcx_rap_generator=>non_alpha_numeric_characters
*          mv_value = CONV #( iv_entity_name ).
*    ENDIF.
*
*    "search for spaces
*    IF contains_no_blanks( CONV #( iv_entity_name ) ) = abap_false.
*      bo_node_is_consistent = abap_false.
*      RAISE EXCEPTION TYPE zcx_rap_generator
*        EXPORTING
*          textid   = zcx_rap_generator=>contains_spaces
*          mv_value = CONV #( iv_entity_name ).
*    ENDIF.

    check_parameter(
      EXPORTING
        iv_parameter_name = 'Entity'
        iv_value          = CONV #( iv_entity_name )
    ).
*CATCH zcx_rap_generator.

*    check_repository_object_name(
*         EXPORTING
*           iv_type = 'devc'
*           iv_name = lv_name
*       ).

    entityname = iv_entity_name .
    rap_node_objects-alias = entityname.

    field_name-client          = 'CLIENT'.
    field_name-uuid            = 'UUID'.
    field_name-parent_uuid     = 'PARENT_UUID'.
    field_name-root_uuid       = 'ROOT_UUID'.
    field_name-created_by      = 'CREATED_BY'.
    field_name-created_at      = 'CREATED_AT'.
    field_name-last_changed_by = 'LAST_CHANGED_BY'.
    field_name-last_changed_at = 'LAST_CHANGED_AT'.

    TEST-SEAM test_run_base_class.
      is_test_run = abap_false.
    end-test-SEAM.

  ENDMETHOD.


  METHOD add_child.

    DATA lt_all_childnodes  TYPE STANDARD TABLE OF REF TO zcl_rap_node .

    IF me->is_finalized = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>node_is_not_finalized
          mv_entity = me->entityname.
    ENDIF.

    ro_child_node = NEW zcl_rap_node(
      iv_entity_name         = iv_entity_name
    ).

    "get settings from parent node
    ro_child_node->set_parent( me ).
    ro_child_node->set_root( me->root_node ).
    ro_child_node->set_namespace( CONV #( me->namespace ) ).
    ro_child_node->set_prefix( CONV #( me->prefix ) ).
    ro_child_node->set_suffix( CONV #( me->suffix ) ).

    IF me->root_node IS INSTANCE OF zcl_rap_node_m_uuid_root .
      ro_child_node->set_number( lines( me->root_node->all_childnodes ) + 1 ).
    ENDIF.

    ro_child_node->finalize( ).

    APPEND ro_child_node TO childnodes.

    CASE TYPE OF me->root_node.

      WHEN TYPE zcl_rap_node_m_uuid_root INTO DATA(rap_node_m_uuid_root).

        lt_all_childnodes = rap_node_m_uuid_root->all_childnodes.

        LOOP AT lt_all_childnodes INTO DATA(ls_childnode).
          IF ls_childnode->entityname = iv_entity_name.
            RAISE EXCEPTION TYPE zcx_rap_generator
              EXPORTING
                textid    = zcx_rap_generator=>entity_name_is_not_unique
                mv_entity = ls_childnode->entityname.
          ENDIF.
        ENDLOOP.

        rap_node_m_uuid_root->add_to_all_childnodes( ro_child_node ).

      WHEN OTHERS.

        RAISE EXCEPTION TYPE zcx_rap_generator
          EXPORTING
            textid    = zcx_rap_generator=>root_node_type_not_supported
            mv_entity = ls_childnode->entityname.

    ENDCASE.



  ENDMETHOD.

  METHOD is_root.
    rv_is_root = is_root_node.
  ENDMETHOD.

  METHOD set_parent.
    IF io_parent_node IS NOT INITIAL.
      parent_node = io_parent_node.
    ELSE.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid            = zcx_rap_generator=>parameter_is_initial
          mv_parameter_name = 'Parent node'.
    ENDIF.
  ENDMETHOD.

  METHOD set_root.
    IF  io_root_node IS INITIAL.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid            = zcx_rap_generator=>parameter_is_initial
          mv_parameter_name = 'Parent node'.
    ENDIF.
    IF me <> io_root_node.
      " IF me IS INSTANCE OF zcl_rap_node_m_uuid_root.
      root_node = io_root_node.
    ELSE.
      IF me IS INSTANCE OF zcl_rap_node_m_uuid_root.
        root_node = io_root_node.
      ELSE.
        RAISE EXCEPTION TYPE zcx_rap_generator
          EXPORTING
            textid    = zcx_rap_generator=>is_not_a_root_node
            mv_entity = io_root_node->entityname.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD get_fields.

    DATA lo_struct_desc           TYPE REF TO cl_abap_structdescr.
    DATA lo_type_desc             TYPE REF TO cl_abap_typedescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table .
    DATA ls_components LIKE LINE OF lt_components.
    DATA dref_table TYPE REF TO data.
    DATA ls_fields TYPE ts_field.

    CREATE DATA dref_table TYPE (me->table_name).

    lo_type_desc =  cl_abap_typedescr=>describe_by_data_ref( p_data_ref = dref_table ).
    TRY.
        IF lo_type_desc->kind = lo_type_desc->kind_struct.
          lo_struct_desc ?= lo_type_desc.
          lt_components = lo_struct_desc->get_components( ).

          IF sy-subrc <> 0.
          ELSE.
            LOOP AT lt_components INTO ls_components.
              CLEAR ls_fields.
              "check if field has domain fixed values
              "Caution: This will dump for complicated tables
              DATA(header_field_type) = CAST cl_abap_elemdescr( lo_struct_desc->get_component_type( ls_components-name ) ).
              IF header_field_type->is_ddic_type(  ) AND
                 header_field_type->get_ddic_fixed_values(  ).
                ls_fields-domain_fixed_value = abap_true.
                ls_fields-doma = header_field_type->get_relative_name( ).
              ENDIF.
              "check if field is key or not null
              ls_fields-name = ls_components-name.
              ls_fields-cds_view_field = to_mixed( ls_components-name ).
              IF to_upper( ls_components-name ) = field_name-uuid OR
                 to_upper( ls_components-name ) = field_name-client.
                ls_fields-key_indicator = 'X'.
                ls_fields-not_null = 'X'.
              ENDIF.
              APPEND ls_fields TO lt_fields.
            ENDLOOP.
          ENDIF.
        ENDIF.

      CATCH cx_root INTO DATA(lx_root).

        RAISE EXCEPTION TYPE zcx_rap_generator
          EXPORTING
            textid = get_root_cause_textid( lx_root ).

    ENDTRY.

  ENDMETHOD.

  METHOD set_table.

    DATA(lv_table) = to_upper( iv_table ) .

    "check if table exists
    IF xco_cp_abap_repository=>object->for( iv_type = CONV #( 'TABL' ) iv_name = CONV #( lv_table ) )->exists( ) = abap_false.
      APPEND | Table { lv_table } does not exist| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>table_does_not_exist
          mv_value = CONV #( lv_table ).
    ENDIF.

    table_name = iv_table.
    get_fields(  ).

  ENDMETHOD.

  METHOD set_namespace.

    check_parameter(
      EXPORTING
         iv_parameter_name = 'Namespace'
         iv_value          = CONV #( iv_namespace )
      ).

    namespace = iv_namespace.

  ENDMETHOD.

  METHOD set_prefix.

    check_parameter(
      EXPORTING
         iv_parameter_name = 'Prefix'
         iv_value          = CONV #( iv_prefix )
      ).

    prefix = iv_prefix.

  ENDMETHOD.

  METHOD set_suffix.

    check_parameter(
      EXPORTING
         iv_parameter_name = 'Prefix'
         iv_value          = CONV #( iv_suffix )
      ).

    suffix = iv_suffix.

  ENDMETHOD.

  METHOD has_childs.
    IF childnodes IS NOT INITIAL.
      rv_has_childs = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD set_semantic_key_fields.

    IF it_semantic_key IS INITIAL.

      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid            = zcx_rap_generator=>parameter_is_initial
          mv_parameter_name = 'Semantic key field(s)'.

    ELSE.

      LOOP AT it_semantic_key INTO DATA(ls_semantic_key).

        SELECT SINGLE * FROM @lt_fields AS SemanticKeyAlias WHERE name  = @ls_semantic_key INTO @DATA(result).

        IF result IS INITIAL.
          APPEND |The specified semantic key field { ls_semantic_key } is not a field of table { table_name }| TO lt_messages.
          bo_node_is_consistent = abap_false.



        ELSE.
          APPEND result-name TO semantic_db_keys.
          APPEND result-cds_view_field TO semantic_keys.
        ENDIF.

      ENDLOOP.
    ENDIF.
    "  semantic_keys = it_semantic_key.

  ENDMETHOD.



  METHOD set_behavior_def_i_name.

    DATA(lv_name) = |{ namespace }I_{ prefix }{ entityname }{ suffix }|.

*    IF lv_name IS INITIAL.
*      APPEND |Behavior definition name must be identical as cds view name, but cds interface view name of { me->entityname } is still initial| TO lt_messages.
*      bo_node_is_consistent = abap_false.
*    ENDIF.
*    IF xco_cp_abap_repository=>object->bdef->for( lv_name )->exists( ).
*      APPEND | behavior definition { lv_name } already exists| TO lt_messages.
*      bo_node_is_consistent = abap_false.
*    ENDIF.

    check_repository_object_name(
          EXPORTING
            iv_type = 'BDEF'
            iv_name = lv_name
        ).


    IF is_root( ).
      rap_root_node_objects-behavior_definition_i = lv_name.
      rv_behavior_dev_i_name = lv_name.
    ELSEIF is_test_run = abap_true.
      rap_root_node_objects-behavior_definition_i = lv_name.
      rv_behavior_dev_i_name = lv_name.
    ELSE.
      APPEND | { me->entityname } is not a root node. BDEF for an interface view is only generated for the root node| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>is_not_a_root_node
          mv_entity = me->entityname.
    ENDIF.



  ENDMETHOD.

  METHOD set_behavior_def_p_name.

    DATA(lv_name) = |{ namespace }C_{ prefix }{ entityname }{ suffix }|.

*    IF lv_name IS INITIAL.
*      APPEND |Behavior definition name must be identical as cds view name, but cds projection view name of { me->entityname } is still initial| TO lt_messages.
*      bo_node_is_consistent = abap_false.
*    ENDIF.
*    IF xco_cp_abap_repository=>object->bdef->for( lv_name )->exists( ).
*      APPEND | behavior definition { lv_name } already exists| TO lt_messages.
*      bo_node_is_consistent = abap_false.
*    ENDIF.

    check_repository_object_name(
          EXPORTING
            iv_type = 'BDEF'
            iv_name = lv_name
        ).

    IF is_root( ).
      rap_root_node_objects-behavior_definition_p = lv_name.
      rv_behavior_dev_p_name = lv_name.
    ELSEIF is_test_run = abap_true.
      rap_root_node_objects-behavior_definition_p = lv_name.
      rv_behavior_dev_p_name = lv_name.
    ELSE.
      APPEND | { me->entityname } is not a root node. BDEF for a projection view is only generated for the root node| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>is_not_a_root_node
          mv_entity = me->entityname.
    ENDIF.

  ENDMETHOD.

  METHOD set_behavior_impl_name.

    DATA(lv_name) = |{ namespace }BP_{ prefix }{ entityname }{ suffix }|.

    check_repository_object_name(
       EXPORTING
          iv_type = 'CLAS'
          iv_name = lv_name
         ).

    rap_node_objects-behavior_implementation = lv_name.
    rv_behavior_imp_name = lv_name.


  ENDMETHOD.

  METHOD set_cds_view_i_name.

    DATA(lv_name) = |{ namespace }I_{ prefix }{ entityname }{ suffix }|.

    check_repository_object_name(
      EXPORTING
        iv_type = 'DDLS'
        iv_name = lv_name
    ).

    rap_node_objects-cds_view_i = lv_name.

    rv_cds_i_view_name = lv_name.

  ENDMETHOD.

  METHOD set_cds_view_p_name.

    DATA(lv_name) = |{ namespace }C_{ prefix }{ entityname }{ suffix }|.

    check_repository_object_name(
         EXPORTING
           iv_type = 'DDLS'
           iv_name = lv_name
       ).

    rap_node_objects-cds_view_p = lv_name.

    rv_cds_p_view_name = lv_name.

  ENDMETHOD.

  METHOD set_mde_name.

    DATA(lv_name) = |{ namespace }C_{ prefix }{ entityname }{ suffix }|.

    IF lv_name IS INITIAL.
      APPEND | Projection view name is still initial | TO lt_messages.
      bo_node_is_consistent = abap_false.
    ENDIF.

    check_repository_object_name(
       EXPORTING
         iv_type = 'DDLX'
         iv_name = lv_name
     ).

    rap_node_objects-meta_data_extension = lv_name.

    rv_mde_name  = lv_name.

  ENDMETHOD.


  METHOD set_ddic_view_i_name.

    "lv_name will be shortened to 16 characters
    DATA lv_name TYPE string.
    DATA lv_entityname TYPE sxco_ddef_alias_name.

    DATA(lv_mandatory_name_components) =  to_upper( namespace ) &&  to_upper( prefix )  && to_upper( suffix  ).
    DATA(max_length_mandatory_name_comp) = 10.
    DATA(length_mandatory_name_comp) = strlen( lv_mandatory_name_components ).
    DATA(remaining_num_characters) = 16 - length_mandatory_name_comp.

    IF length_mandatory_name_comp > max_length_mandatory_name_comp.
      APPEND |{ lv_mandatory_name_components } mandatory components are too long more than { max_length_mandatory_name_comp } characters| TO lt_messages.
      bo_node_is_consistent = abap_false.
    ENDIF.

    DATA(lv_node_number_as_hex) = CONV xstring( node_number ).

    IF strlen( entityname ) > remaining_num_characters - 2.
      lv_entityname = substring( val = entityname len = remaining_num_characters - 2 ).
    ELSE.
      lv_entityname = entityname.
    ENDIF.

    lv_name =  to_upper( namespace ) &&  to_upper( prefix )  && to_upper( lv_entityname ) && lv_node_number_as_hex && to_upper( suffix  ).

    "check if name already exists within the BO
    TEST-SEAM is_not_a_root_node.
      LOOP AT me->root_node->all_childnodes INTO DATA(lo_bo_node).
        IF lo_bo_node->rap_node_objects-ddic_view_i = lv_name.
          APPEND |Name of DDIC view { lv_name } for CDS interface view is not unique in this BO. Check { lo_bo_node->entityname }  and { me->entityname } | TO lt_messages.
          bo_node_is_consistent = abap_false.
        ENDIF.
      ENDLOOP.
    END-TEST-SEAM.

    check_repository_object_name(
     EXPORTING
       iv_type = 'TABL'
       iv_name = lv_name
   ).

    rap_node_objects-ddic_view_i = lv_name.

    rv_ddic_i_view_name = lv_name.

  ENDMETHOD.

  METHOD set_service_binding_name.

    DATA(lv_name) =  |{ namespace }UI_{ prefix }{ entityname }_M{ suffix }|.

    IF rap_root_node_objects-service_definition IS INITIAL.
      APPEND | service binding name is still initial | TO lt_messages.
      bo_node_is_consistent = abap_false.
    ENDIF.

    "check only for spaces and non alpha numeric characters
    "since XCO framework does not support generation of service definition yet
    check_parameter(
      EXPORTING
        iv_parameter_name = 'Service Binding'
        iv_value          = lv_name
    ).

    IF is_root( ).
      rap_root_node_objects-service_binding = lv_name.
      rv_service_binding_name = lv_name.
    ELSEIF is_test_run = abap_true.
      rap_root_node_objects-service_binding = lv_name.
      rv_service_binding_name = lv_name.
    ELSE.
      APPEND | { me->entityname } is not a root node. Service binding can only be created for the root node| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>is_not_a_root_node
          mv_entity = me->entityname.
    ENDIF.

  ENDMETHOD.






  METHOD set_service_definition_name.

    DATA(lv_name) =  |{ namespace }UI_{ prefix }{ entityname }_M{ suffix }|.

    "check only for spaces and non alpha numeric characters
    "since XCO framework does not support generation of service definition yet
    check_parameter(
      EXPORTING
        iv_parameter_name = 'Service Definition'
        iv_value          = lv_name
    ).


    IF is_root( ).
      rap_root_node_objects-service_definition = lv_name.
      rv_service_definition_name = lv_name.
    ELSEIF is_test_run = abap_true.
      rap_root_node_objects-service_definition = lv_name.
      rv_service_definition_name = lv_name.
    ELSE.
      APPEND | { me->entityname } is not a root node. Service defintion can only be created for the root node| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid    = zcx_rap_generator=>is_not_a_root_node
          mv_entity = me->entityname.
    ENDIF.



  ENDMETHOD.

  METHOD contains_no_blanks.
    rv_contains_no_blanks = abap_true.
    FIND ALL OCCURRENCES OF REGEX  '[[:space:]]' IN iv_string RESULTS DATA(blanks).
    IF blanks IS NOT INITIAL.
      rv_contains_no_blanks = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_alpha_numeric.
    rv_is_alpha_numeric = abap_true.
    FIND ALL OCCURRENCES OF REGEX '[^[:word:]]' IN iv_string RESULTS DATA(non_alpha_numeric_characters).
    IF non_alpha_numeric_characters IS NOT INITIAL.
      rv_is_alpha_numeric = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD set_number.
    node_number = iv_number.
  ENDMETHOD.

  METHOD is_child.
    rv_is_child = abap_false.
    IF me->root_node = me->parent_node AND
    me->is_root(  ) = abap_false.
      rv_is_child = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_grand_child_or_deeper.
    rv_is_grand_child = abap_false.
    IF me->root_node <> me->parent_node.
      rv_is_grand_child = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_consistent.
    rv_is_consistent = bo_node_is_consistent.
  ENDMETHOD.


  METHOD finalize.

    "namespace must be set for root node
    "namespace for child objects will be set in method add_child( )
    IF namespace IS INITIAL.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid = zcx_rap_generator=>no_namespace_set.
    ENDIF.

    set_cds_view_i_name(  ).
    set_ddic_view_i_name(  ).
    set_cds_view_p_name(  ).
    set_mde_name(  ).
    set_behavior_impl_name(  ).

    IF is_root(  ).
      set_behavior_def_i_name(  ).
      set_behavior_def_p_name(  ).
      set_service_definition_name(  ).
      set_service_binding_name(  ).
    ENDIF.

    IF lt_messages IS NOT INITIAL AND is_root(  ) = abap_false.
      APPEND | Messages from { entityname } | TO me->root_node->lt_messages.
      APPEND LINES OF lt_messages TO me->root_node->lt_messages.
    ENDIF.

    IF bo_node_is_consistent = abap_true.
      is_finalized = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD check_parameter.

    "search for spaces
    IF contains_no_blanks( CONV #( iv_value ) ) = abap_false.
      APPEND |Name of { iv_parameter_name } { iv_value } contains spaces| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>contains_spaces
          mv_value = |Object:{ iv_parameter_name } Name:{ iv_value }|.
    ENDIF.

    "search for non alpha numeric characters
    IF is_alpha_numeric( CONV #( iv_value ) ) = abap_false.
      APPEND |Name of { iv_parameter_name } { iv_value } contains non alpha numeric characters| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>non_alpha_numeric_characters
          mv_value = |Object:{ iv_parameter_name } Name:{ iv_value }|.
    ENDIF.

    "check length
    DATA(lv_max_length) = 30.

    IF strlen( iv_value ) > lv_max_length.
      APPEND |Name of { iv_value } is too long ( { lv_max_length } chararcters max)| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid        = zcx_rap_generator=>is_too_long
          mv_value      = iv_value
          mv_max_length = lv_max_length.
    ENDIF.


  ENDMETHOD.

  METHOD check_repository_object_name.

    "parameters have to be set to upper case
    "this will not be necessary in an upcomming release

    DATA lv_max_length TYPE i.
    DATA(lv_type) = to_upper( iv_type ).
    DATA(lv_name) = to_upper( iv_name ).

    CASE lv_type.
      WHEN 'BDEF' OR 'DDLS' OR 'DDLX'.
        lv_max_length = 30.
      WHEN 'CLAS'.
        lv_max_length = 30.
      WHEN 'DEVC'.
        lv_max_length = 20.
      WHEN 'TABL'.
        lv_max_length = 16.
      WHEN OTHERS.
    ENDCASE.


    "search for non alpha numeric characters
    IF is_alpha_numeric( CONV #( lv_name ) ) = abap_false.
      APPEND |Name of { lv_type } { lv_name } contains non alpha numeric characters| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>non_alpha_numeric_characters
          mv_value = |Object Type: { lv_type } Object Name:{ lv_name }|.
    ENDIF.

    "search for spaces
    IF contains_no_blanks( CONV #( lv_name ) ) = abap_false.
      APPEND |Name of { lv_type } { lv_name } contains spaces| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>contains_spaces
          mv_value = |Object Type: { lv_type } Object Name:{ lv_name }|.
    ENDIF.

    "check length
    IF strlen( lv_name ) > lv_max_length.
      APPEND |Name of { lv_type } is too long ( { lv_max_length } chararcters max)| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid        = zcx_rap_generator=>is_too_long
          mv_value      = lv_name
          mv_max_length = lv_max_length.
    ENDIF.

    "check if repository already exists
    IF xco_cp_abap_repository=>object->for( iv_type = CONV #( lv_type ) iv_name = CONV #( lv_name ) )->exists( ).
      APPEND | meta data extension view { lv_name } already exists| TO lt_messages.
      bo_node_is_consistent = abap_false.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>repository_already_exists
          mv_value = lv_name.
    ENDIF.

  ENDMETHOD.

  METHOD get_root_exception.
    rx_root = ix_exception.
    WHILE rx_root->previous IS BOUND.
      rx_root ?= rx_root->previous.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_root_cause_textid.
    "error and success messages
    TYPES: BEGIN OF ty_exception_text,
             msgv1(50),
             msgv2(50),
             msgv3(50),
             msgv4(50),
           END OF ty_exception_text.

    DATA : lx_root_cause     TYPE REF TO cx_root,
           ls_exception_text TYPE ty_exception_text.

    "the caller of this method should retrieve the error message of the root cause
    "that has been originally raised by the config facade

    lx_root_cause = ix_previous.

    WHILE lx_root_cause->previous IS BOUND.
      lx_root_cause = lx_root_cause->previous.    " Get the exception that caused this exception
    ENDWHILE.

    "move the (long) text to a structure with 4 fields of length 50 characters each
    "error messages longer than 200 characters are truncated.
    "no exception is thrown opposed to using substring
    ls_exception_text = lx_root_cause->get_longtext( ).

    IF ls_exception_text IS INITIAL.
      ls_exception_text = lx_root_cause->get_text( ).
    ENDIF.

    rs_root_cause_textid-attr1 = CONV #( ls_exception_text-msgv1 ).
    rs_root_cause_textid-attr2 = CONV #( ls_exception_text-msgv2 ).
    rs_root_cause_textid-attr3 = CONV #( ls_exception_text-msgv3 ).
    rs_root_cause_textid-attr4 = CONV #( ls_exception_text-msgv4 ).
    rs_root_cause_textid-msgid = 'ZCM_RAP_GENERATOR'.
    rs_root_cause_textid-msgno = 016.

  ENDMETHOD.

ENDCLASS.
