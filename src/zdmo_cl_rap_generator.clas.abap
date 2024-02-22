CLASS zdmo_cl_rap_generator DEFINITION
INHERITING FROM zdmo_cl_rap_generator_base
 PUBLIC
  CREATE PUBLIC.
  PUBLIC SECTION.

    TYPES:
            ty_string_table_type TYPE STANDARD TABLE OF string WITH DEFAULT KEY .

*    TYPES: BEGIN OF t_framework_message_fields,
*             severity    TYPE symsgty,
*             object_TYPE TYPE if_xco_gen_o_finding=>tv_object_type,
*             object_name TYPE if_xco_gen_o_finding=>tv_object_name,
*             message     TYPE string,
*           END OF t_framework_message_fields.
*
*    TYPES: tt_framework_message_fields TYPE STANDARD TABLE OF t_framework_message_fields WITH EMPTY KEY.

    TYPES: BEGIN OF t_generated_repository_object,
             object_TYPE                  TYPE if_xco_gen_o_finding=>tv_object_type,
             object_name                  TYPE if_xco_gen_o_finding=>tv_object_name,
             hierarchy_distance_from_root TYPE int4,
             transport_request            TYPE sxco_transport,
           END OF t_generated_repository_object.

    TYPES: t_generated_repository_objects TYPE STANDARD TABLE OF t_generated_repository_object WITH EMPTY KEY.

    TYPES: BEGIN OF t_method_exists_in_interface,
             interface_name TYPE c LENGTH 30,
             method_name    TYPE c LENGTH 61,
             method_exists  TYPE abap_bool,
           END OF t_method_exists_in_interface.

    TYPES : t_method_exists_in_interfaces TYPE STANDARD TABLE OF t_method_exists_in_interface.

    TYPES: BEGIN OF t_method_exists_in_class,
             class_name    TYPE c LENGTH 30,
             method_name   TYPE c LENGTH 61,
             method_exists TYPE abap_bool,
           END OF t_method_exists_in_class.

    TYPES : t_method_exists_in_classes TYPE STANDARD TABLE OF t_method_exists_in_class.


    TYPES:
      BEGIN OF ts_condition_components,
        projection_field  TYPE sxco_cds_field_name,
        association_name  TYPE sxco_cds_association_name,
        association_field TYPE sxco_cds_field_name,
      END OF ts_condition_components,


      tt_condition_components TYPE STANDARD TABLE OF ts_condition_components WITH EMPTY KEY.

    TYPES: BEGIN OF t_table_fields,
             field         TYPE sxco_ad_field_name,
             data_element  TYPE sxco_ad_object_name,
             is_key        TYPE abap_bool,
             not_null      TYPE abap_bool,
             currencyCode  TYPE sxco_cds_field_name,
             unitOfMeasure TYPE sxco_cds_field_name,
           END OF t_table_fields.

    TYPES: tt_table_fields TYPE STANDARD TABLE OF t_table_fields WITH KEY field.

    DATA root_node    TYPE REF TO ZDMO_cl_rap_node.

    METHODS get_rap_bo_name RETURNING VALUE(rap_bo_name) TYPE sxco_cds_object_name.

    METHODS get_generated_repo_objects RETURNING VALUE(r_generated_repository_objects) TYPE t_generated_repository_objects.

    METHODS exception_occured RETURNING VALUE(rv_exception_occured) TYPE abap_bool.

    METHODS generate_bo RETURNING VALUE(framework_messages) TYPE zdmo_cl_rap_node=>tt_framework_message_fields
                        RAISING   cx_xco_gen_put_exception
                                  ZDMO_cx_rap_generator.

    METHODS store_bo RAISING zdmo_cx_rap_generator.

    METHODS constructor
      IMPORTING
                json_string  TYPE clike OPTIONAL
                io_root_node TYPE REF TO ZDMO_cl_rap_node OPTIONAL
                xco_lib      TYPE REF TO ZDMO_cl_rap_xco_lib OPTIONAL
      RAISING   ZDMO_cx_rap_generator.

    CLASS-METHODS create_for_cloud_development
      IMPORTING
        json_string   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO zdmo_cl_rap_generator.

    CLASS-METHODS create_for_on_prem_development
      IMPORTING
        json_string   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO zdmo_cl_rap_generator.

    CLASS-METHODS create_with_rap_node_object
      IMPORTING
        rap_node      TYPE REF TO ZDMO_cl_rap_node OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO zdmo_cl_rap_generator.

  PROTECTED SECTION.

    METHODS cds_i_view_set_provider_cntrct REDEFINITION.
    METHODS cds_p_view_set_provider_cntrct REDEFINITION.
    METHODS put_operation_execute REDEFINITION.

  PRIVATE SECTION.

    CONSTANTS method_get_glbl_authorizations TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'GET_GLOBAL_AUTHORIZATIONS'.
    CONSTANTS method_get_instance_features TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'GET_INSTANCE_FEATURES'.
    CONSTANTS method_save_modified TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'SAVE_MODIFIED'.
    CONSTANTS cleanup_finalize TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name VALUE 'CLEANUP_FINALIZE' .

    CONSTANTS method_create TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'CREATE'.
    CONSTANTS method_update TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'UPDATE'.
    CONSTANTS method_delete TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'DELETE'.
    CONSTANTS method_read TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'READ'.
    CONSTANTS method_lock TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'LOCK'.
    CONSTANTS method_rba TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'rba'.
    CONSTANTS method_cba TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'cba'.

    CONSTANTS method_finalize TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'finalize'.
    CONSTANTS method_check_before_save TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'check_before_save'.
    CONSTANTS method_save TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'save'.
    CONSTANTS method_cleanup TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'cleanup'.
    CONSTANTS method_cleanup_finalize TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  VALUE 'cleanup_finalize'.



    TYPES : aliases TYPE STANDARD TABLE OF sxco_ddef_alias_name.

    TYPES : BEGIN OF t_log_entry,
              DetailLevel TYPE ballevel,
              Severity    TYPE symsgty,
              Text        TYPE  bapi_msg,
              TimeStamp   TYPE timestamp,
            END OF t_log_entry.
    TYPES : t_log_entries TYPE STANDARD TABLE OF t_log_entry.

    DATA xco_api  TYPE REF TO ZDMO_cl_rap_xco_lib  .

    DATA mo_package      TYPE sxco_package.

    DATA put_exception_occured  TYPE abap_bool.

    DATA generated_repository_objects TYPE t_generated_repository_objects.
    DATA generated_repository_object TYPE t_generated_repository_object.

    DATA method_exists_in_interface TYPE t_method_exists_in_interface.
    DATA method_exists_in_classe TYPE t_method_exists_in_class.
    DATA method_exists_in_interfaces TYPE t_method_exists_in_interfaces.
    DATA method_exists_in_classes TYPE t_method_exists_in_classes.

********************************************************************************
*    "cloud
*    DATA mo_environment TYPE REF TO if_xco_cp_gen_env_dev_system.
*    DATA mo_put_operation  TYPE REF TO if_xco_cp_gen_d_o_put .
*    DATA mo_draft_tabl_put_opertion TYPE REF TO if_xco_cp_gen_d_o_put .
*    DATA mo_srvb_put_operation    TYPE REF TO if_xco_cp_gen_d_o_put .
********************************************************************************
*    "onpremise
*    DATA mo_environment           TYPE REF TO if_xco_gen_environment .
*    DATA mo_put_operation         TYPE REF TO if_xco_gen_o_mass_put.
*    DATA mo_draft_tabl_put_opertion TYPE REF TO if_xco_gen_o_mass_put.
*    DATA mo_srvb_put_operation    TYPE REF TO if_xco_gen_o_mass_put.
********************************************************************************

    DATA mo_transport TYPE    sxco_transport .

    DATA exc_method_does_not_exist TYPE REF TO cx_sy_dyn_call_illegal_method.
    DATA call_method_succeeded_list TYPE TABLE OF string.
    DATA call_method_not_succeeded_list TYPE TABLE OF string.
*    METHODS constructor
*      IMPORTING
*                json_string  TYPE clike OPTIONAL
*                io_root_node TYPE REF TO ZDMO_cl_rap_node OPTIONAL
*                xco_lib      TYPE REF TO ZDMO_cl_rap_xco_lib OPTIONAL
*      RAISING   ZDMO_cx_rap_generator.




    METHODS add_log_entries_for_rap_bo IMPORTING i_rap_bo_name    TYPE sxco_cds_object_name
                                                 i_log_entries    TYPE t_log_entries
                                       RETURNING VALUE(r_success) TYPE abap_boolean.

    METHODS assign_package.

    METHODS get_transport_layer
      IMPORTING
        io_package                TYPE REF TO if_xco_package
      RETURNING
        VALUE(ro_transport_layer) TYPE REF TO if_xco_transport_layer.

    METHODS create_control_structure
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_extension_include
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO zdmo_cl_rap_node.

    METHODS create_extension_include_view
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_draft_query_view
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO zdmo_cl_rap_node.

    METHODS create_r_cds_view
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_p_cds_view
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_i_cds_view
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_i_cds_view_basic
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_mde_view
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_table
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node
        is_draft_table        TYPE abap_bool.

    METHODS create_bdef
      IMPORTING
                VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node
      RAISING   ZDMO_cx_rap_generator.

    METHODS create_bil
      IMPORTING
                VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node
      RAISING   ZDMO_cx_rap_generator.

    METHODS create_bdef_p
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_bdef_i
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_condition
      IMPORTING
        VALUE(it_condition_components) TYPE tt_condition_components
      RETURNING
        VALUE(ro_expression)           TYPE REF TO if_xco_ddl_expr_condition.

    METHODS create_service_definition
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_sap_object_type
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO zdmo_cl_rap_node.

    METHODS create_sap_object_node_type
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO zdmo_cl_rap_node.

    "service binding needs a separate put operation
    METHODS create_service_binding
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_custom_entity
      IMPORTING
        VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node.

    METHODS create_custom_query
      IMPORTING
                VALUE(io_rap_bo_node) TYPE REF TO ZDMO_cl_rap_node
      RAISING   ZDMO_cx_rap_generator.

    METHODS add_anno_ABAP_Catalog_Ext
      IMPORTING
        io_view                TYPE REF TO if_xco_gen_cds_s_fo_ann_target
        i_allowNewDataSources  TYPE abap_bool
        i_elementSuffix        TYPE string
        i_dataSources          TYPE sxco_cds_association_name
        i_maximumFields        TYPE i
        i_allowNewCompositions TYPE abap_bool.

    METHODS add_anno_ui_hidden
      IMPORTING
        io_field         TYPE REF TO if_xco_gen_cds_s_fo_ann_target
        ls_header_fields TYPE ZDMO_cl_rap_node=>ts_field.

    METHODS add_anno_ui_lineitem
      IMPORTING
        io_field         TYPE REF TO if_xco_gen_cds_s_fo_ann_target
        ls_header_fields TYPE ZDMO_cl_rap_node=>ts_field
        position         TYPE i
        label            TYPE string OPTIONAL.

    METHODS add_anno_ui_identification
      IMPORTING
        io_field                 TYPE REF TO if_xco_gen_cds_s_fo_ann_target
        io_rap_bo_node           TYPE REF TO ZDMO_cl_rap_node
        ls_header_fields         TYPE ZDMO_cl_rap_node=>ts_field
        position                 TYPE i
        label                    TYPE string OPTIONAL
        add_action_for_transport TYPE abap_bool OPTIONAL.

    METHODS add_annotation_ui_selectionfld
      IMPORTING
        io_field         TYPE REF TO if_xco_gen_cds_s_fo_ann_target
        io_rap_bo_node   TYPE REF TO ZDMO_cl_rap_node
        ls_header_fields TYPE ZDMO_cl_rap_node=>ts_field
        position         TYPE i.

    METHODS add_annotation_ui_header
      IMPORTING
        io_specification TYPE REF TO if_xco_gen_cds_s_fo_ann_target
        io_rap_bo_node   TYPE REF TO ZDMO_cl_rap_node .

    METHODS add_annotation_ui_facets
      IMPORTING
        io_field       TYPE REF TO if_xco_gen_cds_s_fo_ann_target
        io_rap_bo_node TYPE REF TO ZDMO_cl_rap_node  .

    METHODS zz_add_business_configuration
      CHANGING
        c_framework_messages TYPE zdmo_cl_rap_node=>tt_framework_message_fields
      RAISING
        cx_mbc_api_exception.

    METHODS add_findings_to_output
      IMPORTING i_task_name      TYPE bapi_msg
                i_findings       TYPE REF TO if_xco_gen_o_findings
      RETURNING VALUE(r_success) TYPE abap_bool.

    METHODS check_and_add_ext_incl_struc
      IMPORTING
        i_node TYPE REF TO zdmo_cl_rap_node.

ENDCLASS.



CLASS zdmo_cl_rap_generator IMPLEMENTATION.


  METHOD add_annotation_ui_facets.

    DATA position TYPE i.

    IF io_rap_bo_node->is_virtual_root(  ) = abap_true.

      io_field->add_annotation( 'UI.facet' )->value->build(
        )->begin_array(
          )->begin_record(
            )->add_member( 'id' )->add_string( 'idIdentification'
            )->add_member( 'parentId' )->add_string( 'idCollection'
            )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
            )->add_member( 'label' )->add_string( 'General Information'
            )->add_member( 'position' )->add_number( 10
            )->add_member( 'hidden' )->add_boolean( abap_true
          )->end_record(
          "@todo check what happens if an entity has several child entities
          )->begin_record(
            )->add_member( 'purpose' )->add_enum( 'STANDARD'
            )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
            )->add_member( 'label' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''
            )->add_member( 'position' )->add_number( 20
            )->add_member( 'targetElement' )->add_string( '_' && io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias
          )->end_record(
        )->end_array( ) ##no_text.

    ELSE.

      IF io_rap_bo_node->is_root(  ) = abap_true.

        IF io_rap_bo_node->has_childs(  ).

*          io_field->add_annotation( 'UI.facet' )->value->build(
*            )->begin_array(
*              )->begin_record(
*                )->add_member( 'id' )->add_string( 'idCollection'
*                )->add_member( 'type' )->add_enum( 'COLLECTION'
*                )->add_member( 'label' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
*                )->add_member( 'position' )->add_number( 10
*              )->end_record(
*              )->begin_record(
*                )->add_member( 'id' )->add_string( 'idIdentification'
*                )->add_member( 'parentId' )->add_string( 'idCollection'
*                )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
*                )->add_member( 'label' )->add_string( 'General Information'
*                )->add_member( 'position' )->add_number( 10
*              )->end_record(
*              "@todo check what happens if an entity has several child entities
*              )->begin_record(
*                )->add_member( 'id' )->add_string( 'idLineitem'
*                )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
*                )->add_member( 'label' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''
*                )->add_member( 'position' )->add_number( 20
*                )->add_member( 'targetElement' )->add_string( '_' && io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias
*              )->end_record(
*            )->end_array( ).

          DATA(ui_facet_array) = io_field->add_annotation( 'UI.facet' )->value->build(
            )->begin_array( ).
          ui_facet_array->begin_record(
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
                )->add_member( 'position' )->add_number( 20
              )->end_record( ).

          position = 20.

          LOOP AT io_rap_bo_node->childnodes INTO DATA(childnode).

            position += 10.
            "@todo check what happens if an entity has several child entities
            ui_facet_array->begin_record(
              )->add_member( 'id' )->add_string( |id{ childnode->rap_node_objects-alias }|
              )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
              )->add_member( 'label' )->add_string( childnode->rap_node_objects-alias && ''
              )->add_member( 'position' )->add_number( position
              )->add_member( 'targetElement' )->add_string( '_' && childnode->rap_node_objects-alias
            )->end_record( ).
          ENDLOOP.
          ui_facet_array->end_array( ).


        ELSE.

          io_field->add_annotation( 'UI.facet' )->value->build(
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
            )->end_array( ) ##no_text.

        ENDIF.

      ELSE.

        IF io_rap_bo_node->has_childs(  ).

*          io_field->add_annotation( 'UI.facet' )->value->build(
*            )->begin_array(
*              )->begin_record(
*                )->add_member( 'id' )->add_string( CONV #( 'id' && io_rap_bo_node->rap_node_objects-alias )
*                )->add_member( 'purpose' )->add_enum( 'STANDARD'
*                )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
*                )->add_member( 'label' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-alias )
*                )->add_member( 'position' )->add_number( 10
*              )->end_record(
*              )->begin_record(
*                  )->add_member( 'id' )->add_string( 'idLineitem'
*                  )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
*                  )->add_member( 'label' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''
*                  )->add_member( 'position' )->add_number( 20
*                  )->add_member( 'targetElement' )->add_string( '_' && io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias
*                )->end_record(
*            )->end_array( ).


          DATA(ui_facet_array_child) =  io_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array( ).

          ui_facet_array_child->begin_record(
            )->add_member( 'id' )->add_string( CONV #( 'id' && io_rap_bo_node->rap_node_objects-alias )
            )->add_member( 'purpose' )->add_enum( 'STANDARD'
            )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
            )->add_member( 'label' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-alias )
            )->add_member( 'position' )->add_number( 10
          )->end_record( ).

          position = 10.

          LOOP AT io_rap_bo_node->childnodes INTO DATA(childnode_child).
            position += 10.
            ui_facet_array_child->begin_record(
                )->add_member( 'id' )->add_string( |id{ childnode_child->rap_node_objects-alias }|
                )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
                )->add_member( 'label' )->add_string( childnode_child->rap_node_objects-alias && ''
                )->add_member( 'position' )->add_number( position
                )->add_member( 'targetElement' )->add_string( '_' && childnode_child->rap_node_objects-alias
              )->end_record( ).
          ENDLOOP.

          ui_facet_array_child->end_array( ).

        ELSE.

          io_field->add_annotation( 'UI.facet' )->value->build(
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
  ENDMETHOD.


  METHOD add_annotation_ui_header.
    "show the name of the "real" entity, not the virtual one
    IF io_rap_bo_node->is_virtual_root(  ).
      io_specification->add_annotation( 'UI' )->value->build(
            )->begin_record(
                )->add_member( 'headerInfo'
                 )->begin_record(
                  )->add_member( 'typeName' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''

              )->end_record(
            ).
    ELSE.
      io_specification->add_annotation( 'UI' )->value->build(
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
                )->add_member( 'value' )->add_string(  io_rap_bo_node->object_id_cds_field_name && ''
          )->end_record(
          )->end_record(

                  "presentationVariant: [ { sortOrder: [{ by: 'TravelID', direction:  #DESC }], visualizations: [{type: #AS_LINEITEM}] }] }
      )->add_member( 'presentationVariant'
        )->begin_array(
          )->begin_record(
          )->add_member( 'sortOrder'
            )->begin_array(
             )->begin_record(
               )->add_member( 'by' )->add_string( io_rap_bo_node->object_id_cds_field_name && ''
               )->add_member( 'direction' )->add_enum( 'DESC'
             )->end_record(
            )->end_array(
          )->add_member( 'visualizations'
          )->begin_array(
             )->begin_record(
               )->add_member( 'type' )->add_enum( 'AS_LINEITEM'
             )->end_record(
            )->end_array(
          )->end_record(
          )->end_array(
          )->end_record(
         ).
    ENDIF.
  ENDMETHOD.


  METHOD add_annotation_ui_selectionfld.

    "add selection fields for semantic key fields or for the fields that are marked as object id

    DATA add_annotation_UI_selectionFld TYPE abap_bool VALUE abap_false .

    IF io_rap_bo_node->is_root(  ) = abap_true AND
       ( io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-unmanaged_semantic OR
          io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-managed_semantic ) AND
          ls_header_fields-key_indicator = abap_true.

      add_annotation_UI_selectionFld = abap_true.

    ENDIF.

    IF io_rap_bo_node->is_root(  ) = abap_true AND
       io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-managed_uuid  AND
       ls_header_fields-name = io_rap_bo_node->object_id.

      add_annotation_UI_selectionFld = abap_true.

    ENDIF.

    IF io_rap_bo_node->is_root(  ) = abap_true AND
       ls_header_fields-has_valuehelp = abap_true.

      add_annotation_UI_selectionFld = abap_true.

    ENDIF.

    IF add_annotation_UI_selectionFld = abap_true.
      io_field->add_annotation( 'UI.selectionField' )->value->build(
      )->begin_array(
      )->begin_record(
          )->add_member( 'position' )->add_number( position
        )->end_record(
      )->end_array( ).
    ENDIF.

  ENDMETHOD.


  METHOD add_anno_abap_catalog_ext.
    DATA(lo_valuebuilder) = io_view->add_annotation( 'AbapCatalog.extensibility' )->value->build( ).

    DATA(lo_record) = lo_valuebuilder->begin_record(
        )->add_member( 'extensible' )->add_boolean( abap_true
        )->add_member( 'elementSuffix' )->add_string( i_elementsuffix
        )->add_member( 'allowNewDatasources' )->add_boolean( i_allownewdatasources
        )->add_member( 'allowNewCompositions' )->add_boolean( i_allownewcompositions
        ).

    lo_record->add_member( 'dataSources' )->begin_array(  )->add_string( CONV #( i_datasources ) )->end_array( ).
    DATA(quota) = lo_record->add_member( 'quota' )->begin_record( ).
    quota->add_member( 'maximumFields' )->add_number( i_maximumfields ).
    "recommended formula to calculate maximumBytes
    quota->add_member( 'maximumBytes' )->add_number( i_maximumfields * 100 ).
    quota->end_record(  ).

    lo_valuebuilder->end_record( ).
  ENDMETHOD.


  METHOD add_anno_ui_hidden.

    IF ls_header_fields-is_hidden = abap_true.
      io_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).
    ENDIF.

  ENDMETHOD.


  METHOD add_anno_ui_identification.

    IF ls_header_fields-is_currencycode = abap_true OR ls_header_fields-is_unitofmeasure = abap_true.
      EXIT.
    ENDIF.

    DATA(lo_valuebuilder) = io_field->add_annotation( 'UI.identification' )->value->build( ).
    DATA(lo_record) = lo_valuebuilder->begin_array(
    )->begin_record(
        )->add_member( 'position' )->add_number( position ).

    "@UI.identification: [{position: 2, importance: #HIGH },{ type: #FOR_ACTION, dataAction: 'selectTransport', label: 'Select Transport' }]

    IF io_rap_bo_node->is_root(  ) = abap_true AND
       io_rap_bo_node->is_customizing_table = abap_true AND
       ls_header_fields-cds_view_field = 'Request'.
      lo_record->add_member( 'type' )->add_enum( 'FOR_ACTION' ).
      lo_record->add_member( 'dataAction' )->add_string( 'selectTransport' ).
      lo_record->add_member( 'label' )->add_string( CONV #( 'Select Transport' ) ) ##no_text.
    ELSE.
      IF ls_header_fields-is_data_element = abap_false.
        lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
      ENDIF.
    ENDIF.
    lo_valuebuilder->end_record( )->end_array( ).



  ENDMETHOD.


  METHOD add_anno_ui_lineitem.

    IF ls_header_fields-is_currencycode = abap_true OR ls_header_fields-is_unitofmeasure = abap_true.
      EXIT.
    ENDIF.

    DATA(lo_valuebuilder) = io_field->add_annotation( 'UI.lineItem' )->value->build( ).

    DATA(lo_record) = lo_valuebuilder->begin_array(
    )->begin_record(
        )->add_member( 'position' )->add_number( position
        )->add_member( 'importance' )->add_enum( 'HIGH').
    "if field is based on a data element label will be set from its field description
    "if its a built in type we will set a label whith a meaningful default vaule that
    "can be changed by the developer afterwards
    IF ls_header_fields-is_data_element = abap_false.
      lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
    ENDIF.
    lo_valuebuilder->end_record( )->end_array( ).
  ENDMETHOD.


  METHOD add_findings_to_output.

    DATA text TYPE c LENGTH 200 .
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

    DATA(finding_texts) = i_findings->get( ).

    IF finding_texts IS NOT INITIAL.
      LOOP AT finding_texts INTO DATA(finding_text).
        log_entry-text = |{ finding_text->object_type } { finding_text->object_name } { finding_text->message->get_text(  ) }|.
        log_entry-severity = finding_text->message->value-msgty.
        log_entry-detaillevel = 2.
        APPEND log_entry TO log_entries.
      ENDLOOP.
    ENDIF.

    r_success = add_log_entries_for_rap_bo(
           i_rap_bo_name = root_node->rap_root_node_objects-behavior_definition_r
           i_log_entries = log_entries
         ).

  ENDMETHOD.


  METHOD add_log_entries_for_rap_bo.

*    DATA create_rapbolog_cba TYPE TABLE FOR CREATE ZDMO_R_RapGeneratorBO\_RAPGeneratorBOLog.
*    DATA log_entries TYPE TABLE FOR CREATE zdmo_r_rapgeneratorbo\\rapgeneratorbolog   .
*    DATA log_entry TYPE STRUCTURE FOR CREATE zdmo_r_rapgeneratorbo\\rapgeneratorbolog   .
*    DATA n TYPE i.
*    DATA time_stamp TYPE timestampl.
*
*    GET TIME STAMP FIELD time_stamp.
*
*    SELECT SINGLE * FROM zdmo_r_rapgeneratorbo  WHERE boname = @i_rap_bo_name
*          INTO @DATA(rap_generator_bo).
*
*    LOOP AT i_log_entries INTO DATA(my_log_entry) where Severity GE 1.
*      n += 1.
*      log_entry = VALUE #(     %is_draft = if_abap_behv=>mk-off
*                               %cid      = |test{ n }|
*                               Severity = my_log_entry-Severity
*                               DetailLevel = my_log_entry-DetailLevel
*                               Text = my_log_entry-Text
*                               TimeStamp = time_stamp
*                               ).
*      APPEND log_entry TO log_entries.
*    ENDLOOP.
*
*    create_rapbolog_cba = VALUE #( ( %is_draft = if_abap_behv=>mk-off
*                                     %key-rapnodeuuid = rap_generator_bo-RapNodeUUID
*                                     %target   = log_entries ) ) .
*
*    MODIFY ENTITIES OF zdmo_r_rapgeneratorbo
*             ENTITY RAPGeneratorBO
*                   CREATE BY \_RAPGeneratorBOLog
*                   FIELDS (
*                           LogItemNumber
*                           DetailLevel
*                           Severity
*                           Text
*                           TimeStamp
*                   )
*                   WITH create_rapbolog_cba
*             MAPPED   DATA(mapped)
*             FAILED   DATA(failed)
*             REPORTED DATA(reported).
*
*
*    IF mapped-rapgeneratorbolog IS NOT INITIAL.
*      COMMIT ENTITIES.
*      COMMIT WORK.
*      r_success = abap_true.
*    ENDIF.
*    IF failed-rapgeneratorbolog IS NOT INITIAL.
*      r_success = abap_false.
*    ENDIF.

    DATA create_rapbolog_cba TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Log.
*    DATA log_entries TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\\Log   .
*    DATA log_entry TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_ProjectTP\\Log   .
    DATA create_raplog_cba_line TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Log.
    DATA log_entries LIKE create_raplog_cba_line-%target.
    DATA log_entry LIKE LINE OF log_entries.

    DATA n TYPE i.
    DATA time_stamp TYPE timestampl.

    GET TIME STAMP FIELD time_stamp.

    SELECT SINGLE * FROM ZDMO_R_RAPG_ProjectTP   WHERE boname = @i_rap_bo_name
          INTO @DATA(rap_generator_bo).


    LOOP AT i_log_entries INTO DATA(my_log_entry) .
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
             ENTITY Project
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


    IF mapped-log  IS NOT INITIAL.
      COMMIT ENTITIES.
      COMMIT WORK.
      r_success = abap_true.
    ENDIF.
    IF failed-log IS NOT INITIAL.
      r_success = abap_false.
    ENDIF.


  ENDMETHOD.


  METHOD assign_package.
    DATA(lo_package_put_operation) = mo_environment->for-devc->create_put_operation( ).
    DATA(lo_specification) = lo_package_put_operation->add_object( mo_package ).
  ENDMETHOD.


  METHOD cds_i_view_set_provider_cntrct.
    super->cds_i_view_set_provider_cntrct( i_interface_view_spcification ).
  ENDMETHOD.


  METHOD cds_p_view_set_provider_cntrct.
    super->cds_p_view_set_provider_cntrct( i_projection_view_spcification  ).
  ENDMETHOD.


  METHOD constructor.

    super->constructor( ).

    IF json_string IS INITIAL AND io_root_node IS INITIAL.
      RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
        EXPORTING
          textid   = ZDMO_cx_rap_generator=>parameter_is_initial
          mv_value = |json_string and io_root_node|.
    ENDIF.

    "in on premise systems one can provide the on premise version
    "of the xco libraries as a parameter

    IF xco_lib IS NOT INITIAL.
      xco_api = xco_lib.
    ELSE.
      xco_api = NEW ZDMO_cl_rap_xco_cloud_lib( ).
    ENDIF.

    IF io_root_node IS INITIAL.

      root_node = NEW ZDMO_cl_rap_node(  ).

      root_node->set_is_root_node( io_is_root_node = abap_true ).
      root_node->set_xco_lib( xco_api ).

      DATA(rap_bo_visitor) = NEW ZDMO_cl_rap_xco_json_visitor( root_node ).
      DATA(json_data) = xco_cp_json=>data->from_string( json_string ).
      json_data->traverse( rap_bo_visitor ).
      DATA(a) = 1.
    ELSE.

      root_node = io_root_node.
      xco_api = io_root_node->xco_lib.

    ENDIF.

    CASE root_node->get_implementation_type( ).
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid .
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic.
      WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
          EXPORTING
            textid   = ZDMO_cx_rap_generator=>implementation_type_not_valid
            mv_value = root_node->get_implementation_type( ).
    ENDCASE.

    IF root_node->is_consistent(  ) = abap_false.
      RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
        EXPORTING
          textid    = ZDMO_cx_rap_generator=>node_is_not_consistent
          mv_entity = root_node->entityname.
    ENDIF.
    IF root_node->is_finalized = abap_false.
      RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
        EXPORTING
          textid    = ZDMO_cx_rap_generator=>node_is_not_finalized
          mv_entity = root_node->entityname.
    ENDIF.
    IF root_node->has_childs(  ).
      LOOP AT root_node->all_childnodes INTO DATA(ls_childnode).
        IF ls_childnode->is_consistent(  ) = abap_false.
          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            EXPORTING
              textid    = ZDMO_cx_rap_generator=>node_is_not_consistent
              mv_entity = ls_childnode->entityname.
        ENDIF.
        IF ls_childnode->is_finalized = abap_false.
          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            EXPORTING
              textid    = ZDMO_cx_rap_generator=>node_is_not_finalized
              mv_entity = ls_childnode->entityname.
        ENDIF.
      ENDLOOP.
    ENDIF.

    mo_package = root_node->package.

    IF root_node->transport_request IS INITIAL.
      root_node->set_transport_request(  ).
    ENDIF.
    mo_transport = root_node->transport_request.


**********************************************************************
    "cloud
*    mo_environment = xco_cp_generation=>environment->dev_system( mo_transport )  .
*    mo_put_operation = mo_environment->create_put_operation( ).
*    mo_draft_tabl_put_opertion = mo_environment->create_put_operation( ).
*    mo_srvb_put_operation = mo_environment->create_put_operation( ).
**********************************************************************
    "on premise
*    IF xco_api->get_package( root_node->package  )->read( )-property-record_object_changes = abap_true.
*      mo_environment = xco_generation=>environment->transported( mo_transport ).
*    ELSE.
*      mo_environment = xco_generation=>environment->local.
*    ENDIF.
*    mo_draft_tabl_put_opertion = mo_environment->create_mass_put_operation( ).
*    mo_put_operation = mo_environment->create_mass_put_operation( ).
*    mo_srvb_put_operation = mo_environment->create_mass_put_operation( ).


    mo_environment = get_environment( mo_transport ) .
    mo_draft_tabl_put_operation = get_put_operation( mo_environment ).
    mo_put_operation = get_put_operation( mo_environment ).
    mo_srvb_put_operation = get_put_operation( mo_environment ).
    mo_patch_operation = get_patch_operation( mo_environment ).

**********************************************************************
  ENDMETHOD.


  METHOD create_bdef.

    DATA lv_determination_name TYPE string.
    DATA lv_validation_name TYPE string.
    DATA lv_action_name TYPE string.


    DATA lt_mapping_header TYPE HASHED TABLE OF  if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                               WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_header TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    DATA lt_mapping_item TYPE HASHED TABLE OF if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping
                           WITH UNIQUE KEY cds_view_field dbtable_field.
    DATA ls_mapping_item TYPE if_xco_gen_bdef_s_fo_b_mapping=>ts_field_mapping  .

    FIELD-SYMBOLS: <fs_create> TYPE REF TO  cl_xco_bdef_eval_trigger_oprtn,
                   <fs_update> TYPE REF TO  cl_xco_bdef_eval_trigger_oprtn,
                   <fs_delete> TYPE REF TO  cl_xco_bdef_eval_trigger_oprtn.

    lt_mapping_header = io_rap_bo_node->lt_mapping.

    DATA(lo_specification) = mo_put_operation->for-bdef->add_object( io_rap_bo_node->rap_root_node_objects-behavior_definition_r "mo_i_bdef_header
        )->set_package( mo_package
        )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_root_node_objects-behavior_definition_r.
    generated_repository_object-object_type = 'BDEF'.
    APPEND generated_repository_object TO generated_repository_objects.

    lo_specification->set_short_description( |Behavior for { io_rap_bo_node->rap_node_objects-cds_view_r }| ) ##no_text.

    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      lo_specification->set_extensible(  ).
      set_bdef_extensible_options( lo_specification  ).
    ENDIF.

    "set implementation type
    CASE io_rap_bo_node->get_implementation_type(  ).
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.
        lo_specification->set_implementation_type( xco_cp_behavior_definition=>implementation_type->managed ).
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic.
        lo_specification->set_implementation_type( xco_cp_behavior_definition=>implementation_type->managed ).
      WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
        lo_specification->set_implementation_type( xco_cp_behavior_definition=>implementation_type->unmanaged ).

        "add the code :
        "implementation in class ZBP_R_Holiday_U02 unique;
        lo_specification->set_implementation_class( io_rap_bo_node->rap_node_objects-behavior_implementation ).
    ENDCASE.


    "set is draft enabled
    lo_specification->set_draft_enabled( io_rap_bo_node->draft_enabled ).

    "use the highest recommended strict mode
    IF io_rap_bo_node->is_abstract_or_custom_entity(  ) = abap_false.
*      lo_specification->set_strict_n( zdmo_cl_rap_node=>strict_mode_2 ).
      IF xco_api->on_premise_branch_is_used(  ).
        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
      ELSE.
        method_exists_in_interface-interface_name = 'if_xco_cp_gen_bdef_s_form'.
      ENDIF.
      method_exists_in_interface-method_name    = 'SET_STRICT_N'.
      IF xco_api->method_exists_in_interface(
           interface_name = method_exists_in_interface-interface_name
           method_name    = method_exists_in_interface-method_name
         ).
        CALL METHOD lo_specification->(method_exists_in_interface-method_name)
          EXPORTING
            iv_n = zdmo_cl_rap_node=>strict_mode_2.
        APPEND 'SET_STRICT_N' TO call_method_succeeded_list.
        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.
      "set_strict_n not found
      "try to set strict
      IF method_exists_in_interface-method_exists = abap_false.
*        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
        method_exists_in_interface-method_name    = 'SET_STRICT'.
        IF xco_api->method_exists_in_interface(
             interface_name = method_exists_in_interface-interface_name
             method_name    = method_exists_in_interface-method_name
           ).
          CALL METHOD lo_specification->(method_exists_in_interface-method_name).
          APPEND 'SET_STRICT' TO call_method_succeeded_list.
          method_exists_in_interface-method_exists = abap_true.
        ELSE.
          method_exists_in_interface-method_exists = abap_false.
        ENDIF.
        APPEND method_exists_in_interface TO method_exists_in_interfaces.
      ENDIF.
    ENDIF.

    "define behavior for root entity
    DATA(lo_header_behavior) = lo_specification->add_behavior( io_rap_bo_node->rap_node_objects-cds_view_r ).

    " Characteristics.
    DATA(characteristics) = lo_header_behavior->characteristics.
    characteristics->set_alias( CONV #( io_rap_bo_node->rap_node_objects-alias ) ).
    characteristics->set_implementation_class( io_rap_bo_node->rap_node_objects-behavior_implementation ).

**********************************************************************
** @todo check when to set unmanaged_save and addtionial_save
**********************************************************************

    IF io_rap_bo_node->is_customizing_table = abap_true AND
      io_rap_bo_node->is_virtual_root(  ) = abap_false.
      characteristics->set_with_additional_save( ).
    ENDIF.

    IF io_rap_bo_node->is_virtual_root(  ) .
      method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_chara'.
      method_exists_in_interface-method_name    = 'SET_WITH_UNMANAGED_SAVE'.
      IF xco_api->method_exists_in_interface(
           interface_name = method_exists_in_interface-interface_name
           method_name    = method_exists_in_interface-method_name
         ).
        CALL METHOD characteristics->(method_exists_in_interface-method_name).
        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.
    ENDIF.

    method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_auth'.
    method_exists_in_interface-method_name    = 'SET_MASTER_GLOBAL'.
    IF xco_api->method_exists_in_interface(
         interface_name = method_exists_in_interface-interface_name
         method_name    = method_exists_in_interface-method_name
       ).
      DATA(authorization) = characteristics->authorization.
      CALL METHOD authorization->(method_exists_in_interface-method_name).
      method_exists_in_interface-method_exists = abap_true.
    ELSE.
      method_exists_in_interface-method_exists = abap_false.
    ENDIF.
    APPEND method_exists_in_interface TO method_exists_in_interfaces.

    IF method_exists_in_interface-method_exists = abap_false.
      method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_auth'.
      method_exists_in_interface-method_name    = 'SET_MASTER_INSTANCE'.
      IF xco_api->method_exists_in_interface(
           interface_name = method_exists_in_interface-interface_name
           method_name    = method_exists_in_interface-method_name
         ).
        authorization = characteristics->authorization.
        CALL METHOD authorization->(method_exists_in_interface-method_name).
        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.

    ENDIF.

    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      characteristics->set_extensible(  ).
    ENDIF.

    IF io_rap_bo_node->draft_enabled = abap_false.
      characteristics->lock->set_master( ).
    ENDIF.

    "add the draft table
    IF io_rap_bo_node->draft_enabled = abap_true.
      IF io_rap_bo_node->is_extensible(  ) = abap_true.
        characteristics->set_draft_table(
                         io_rap_bo_node->draft_table_name )->set_query(
                         io_rap_bo_node->rap_node_objects-draft_query_view ).
      ELSE.
        characteristics->set_draft_table( io_rap_bo_node->draft_table_name ).
      ENDIF.
    ENDIF.




    IF line_exists( io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-last_changed_at ] ).
      DATA(last_changed_at) = io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-last_changed_at ]-cds_view_field.
    ELSEIF line_exists( io_rap_bo_node->lt_additional_fields[ name = io_rap_bo_node->field_name-last_changed_at ] ).
      last_changed_at = io_rap_bo_node->lt_additional_fields[ name = io_rap_bo_node->field_name-last_changed_at ]-cds_view_field.
    ENDIF.

    IF line_exists( io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-local_instance_last_changed_at ] ).
      DATA(local_instance_last_changed_at) = io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-local_instance_last_changed_at ]-cds_view_field.
    ELSEIF line_exists( io_rap_bo_node->lt_additional_fields[ name = io_rap_bo_node->field_name-local_instance_last_changed_at ] ).
      local_instance_last_changed_at = io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-local_instance_last_changed_at ].
    ENDIF.

    IF line_exists( io_rap_bo_node->lt_all_fields[ name = io_rap_bo_node->field_name-etag_master ] ).
      DATA(etag_master) = io_rap_bo_node->lt_all_fields[ name = io_rap_bo_node->field_name-etag_master ]-cds_view_field.
    ENDIF.

    IF line_exists( io_rap_bo_node->lt_all_fields[ name = io_rap_bo_node->field_name-total_etag ] ).
      DATA(total_etag) = io_rap_bo_node->lt_all_fields[ name = io_rap_bo_node->field_name-total_etag ]-cds_view_field.
    ENDIF.

    IF io_rap_bo_node->draft_enabled = abap_true.
      characteristics->etag->set_master( etag_master ).

      " lock type ref to if_xco_gen_bdef_s_fo_b_lock
      DATA(lock) = characteristics->lock.

      method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_lock'.
      method_exists_in_interface-method_name    = 'SET_MASTER_TOTAL_ETAG'.
      IF xco_api->method_exists_in_interface(
           interface_name = method_exists_in_interface-interface_name
           method_name    = method_exists_in_interface-method_name
         ).
        CALL METHOD lock->(method_exists_in_interface-method_name)
          EXPORTING
            iv_master_total_etag = total_etag.
        APPEND 'SET_MASTER_TOTAL_ETAG' TO call_method_succeeded_list.
        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.

    ELSE.
      characteristics->etag->set_master( etag_master ).
      characteristics->lock->set_master( ).
    ENDIF.

    CASE io_rap_bo_node->get_implementation_type(  ).
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.
        lo_header_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) ).
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic.
        lo_header_behavior->characteristics->set_persistent_table( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) ).
      WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
        "do not set a persistent table
    ENDCASE.

    IF io_rap_bo_node->draft_enabled = abap_true.

      "  if this is set, no BIL is needed in a plain vanilla managed draft enabled BO
      "  add the following operations in case draft is used
      "  draft action Edit;
      "  draft action Activate;
      "  draft action Discard;
      "  draft action Resume;
      "  draft determine action Prepare;

**********************************************************************
** Begin of deletion 2020
**********************************************************************

*      lo_header_behavior->add_action( 'Edit'  )->set_draft( ) ##no_text.
*      lo_header_behavior->add_action( 'Activate'  )->set_draft( ) ##no_text.
*      lo_header_behavior->add_action( 'Discard'  )->set_draft( ) ##no_text.
*      lo_header_behavior->add_action( 'Resume'  )->set_draft( ) ##no_text.
*      lo_header_behavior->add_action( 'Prepare'  )->set_draft( )->set_determine( ) ##no_text.

      "lo_action_edit type ref to if_xco_gen_bdef_s_fo_b_action

      " add standard operations
      DATA(lo_action_edit) =   lo_header_behavior->add_action( 'Edit' )." ##no_text.
      DATA(lo_action_activate) = lo_header_behavior->add_action( 'Activate' ) ##no_text.
      DATA(lo_action_discard) = lo_header_behavior->add_action( 'Discard' ) ##no_text.
      DATA(lo_action_resume) = lo_header_behavior->add_action( 'Resume' ) ##no_text.
      DATA(lo_action_prepare) = lo_header_behavior->add_action( 'Prepare' ) ##no_text.

      IF io_rap_bo_node->is_extensible(  ) = abap_true.
        lo_action_prepare->set_extensible( abap_true ).
      ENDIF.


      "add the key word draft, if possible. for example: draft action Activate;

      method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_action'.
      method_exists_in_interface-method_name    = 'SET_DRAFT'.

      IF xco_api->method_exists_in_interface(
                     interface_name = method_exists_in_interface-interface_name
                     method_name    = method_exists_in_interface-method_name
                  ).
        CALL METHOD lo_action_edit->(method_exists_in_interface-method_name).
        CALL METHOD lo_action_activate->(method_exists_in_interface-method_name).
        CALL METHOD lo_action_discard->(method_exists_in_interface-method_name).
        CALL METHOD lo_action_resume->(method_exists_in_interface-method_name).
        CALL METHOD lo_action_prepare->(method_exists_in_interface-method_name).
        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.


      method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_action'.
      method_exists_in_interface-method_name    = 'SET_DETERMINE'.

      IF xco_api->method_exists_in_interface(
                     interface_name = method_exists_in_interface-interface_name
                     method_name    = method_exists_in_interface-method_name
                   ).
        CALL METHOD lo_action_prepare->(method_exists_in_interface-method_name).
        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.

    ENDIF.

    " add standard operations for root node

    IF io_rap_bo_node->is_virtual_root(  ) .
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
    ELSE.
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create ).
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).
    ENDIF.


**********************************************************************
** Begin of deletion 2020
**********************************************************************
    xco_api->todo( 'in create bdef. make sure is_customizing_table is false on premise' ).

    IF io_rap_bo_node->is_customizing_table = abap_true AND io_rap_bo_node->is_virtual_root( ) = abap_false.
      " if_xco_gen_bdef_s_fo_b_validtn
      lv_validation_name = |validateChanges| .

      DATA(validation) = lo_header_behavior->add_validation( CONV #( lv_validation_name ) ).
      validation->set_time( xco_cp_behavior_definition=>evaluation->time->on_save ).

      method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_validtn'.
      method_exists_in_interface-method_name    = 'SET_TRIGGER_OPERATIONS'.
      IF xco_api->method_exists_in_interface(
                  interface_name = method_exists_in_interface-interface_name
                  method_name    = method_exists_in_interface-method_name
                ).
        DATA  trigger_operations  TYPE sxco_t_bdef_trigger_operations  .
        " DATA  trigger_operations_class TYPE REF TO cl_xco_bdef_eval_trigger_op_f.

        ASSIGN xco_cp_behavior_definition=>evaluation->trigger_operation->('CREATE') TO <fs_create>.
        ASSIGN xco_cp_behavior_definition=>evaluation->trigger_operation->('UPDATE') TO <fs_update>.
        ASSIGN xco_cp_behavior_definition=>evaluation->trigger_operation->('DELETE') TO <fs_delete>.

        IF <fs_create> IS ASSIGNED.
          APPEND <fs_create> TO trigger_operations.
        ENDIF.
        IF <fs_update> IS ASSIGNED.
          APPEND <fs_update> TO trigger_operations.
        ENDIF.
        IF <fs_delete> IS ASSIGNED.
          APPEND <fs_delete> TO trigger_operations.
        ENDIF.

* @todo: dynamic call currently fails
*        CALL METHOD validation->('SET_TRIGGER_OPERATIONS')
*          IMPORTING
*            it_trigger_operations = trigger_operations.

        validation->set_trigger_operations( trigger_operations ).

        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.

    ENDIF.

    IF io_rap_bo_node->is_virtual_root(  ) = abap_true.
      "action ( features : instance ) selectTransport parameter D_SelectCustomizingTransptReqP result [1] $self;
      lv_action_name = 'selectTransport'.
      DATA(action) = lo_header_behavior->add_action( CONV #( lv_action_name ) ).
      action->set_features_instance( ).
      action->parameter->set_entity( 'D_SelectCustomizingTransptReqP' ).
      action->result->set_cardinality( xco_cp_cds=>cardinality->one )->set_self( ).
    ENDIF.






**********************************************************************
** End of deletion 2020
**********************************************************************



    CASE io_rap_bo_node->get_implementation_type(  ).
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.

        lv_determination_name = |Calculate{ io_rap_bo_node->object_id_cds_field_name }|  ##no_text.

        lo_header_behavior->add_determination( CONV #( lv_determination_name ) "'CalculateSemanticKey'
          )->set_time( xco_cp_behavior_definition=>evaluation->time->on_save
          )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).




        LOOP AT lt_mapping_header INTO ls_mapping_header.
          CASE ls_mapping_header-dbtable_field.
            WHEN io_rap_bo_node->field_name-uuid.
              lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                               )->set_numbering_managed( ).
              "to do
              "add a working dummy implementation to calculate the object id
            WHEN  io_rap_bo_node->object_id .
              lo_header_behavior->add_field( ls_mapping_header-cds_view_field
                                 )->set_read_only( ).
          ENDCASE.
        ENDLOOP.

      WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic .

        LOOP AT io_rap_bo_node->lt_fields INTO DATA(key_field_root_node)
               WHERE key_indicator = abap_true AND name <> io_rap_bo_node->field_name-client.

          DATA(key_field_root_behavior) = lo_header_behavior->add_field( key_field_root_node-cds_view_field ).


          method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_field'.
          method_exists_in_interface-method_name    = 'SET_READONLY_UPDATE'.

          IF xco_api->method_exists_in_interface( interface_name = method_exists_in_interface-interface_name
                                                  method_name    = method_exists_in_interface-method_name ).
            CALL METHOD key_field_root_behavior->(method_exists_in_interface-method_name).
          ENDIF.


          "lo_item_behavior->add_field( ls_fields-cds_view_field )->set_readonly_update(  ).
        ENDLOOP.


      WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.

        LOOP AT io_rap_bo_node->lt_fields INTO DATA(ls_field) WHERE name <> io_rap_bo_node->field_name-client.
          IF ls_field-key_indicator = abap_true.
            lo_header_behavior->add_field( ls_field-cds_view_field
                               )->set_read_only(
                               ).
          ENDIF.
        ENDLOOP.
    ENDCASE.


*  make administrative fields read-only
*  field ( readonly )
*   CreatedAt,
*   CreatedBy,
*   LocalLastChangedAt,
*   LastChangedAt,
*   LastChangedBy;

    LOOP AT io_rap_bo_node->lt_fields INTO ls_field
      WHERE name <> io_rap_bo_node->field_name-client.
      CASE ls_field-name .
        WHEN io_rap_bo_node->field_name-created_at OR
             io_rap_bo_node->field_name-created_by OR
             io_rap_bo_node->field_name-local_instance_last_changed_at OR
             io_rap_bo_node->field_name-local_instance_last_changed_by OR
             io_rap_bo_node->field_name-last_changed_at OR
             io_rap_bo_node->field_name-last_changed_by OR
             io_rap_bo_node->field_name-uuid.
          lo_header_behavior->add_field( ls_field-cds_view_field )->set_read_only( ).
      ENDCASE.
    ENDLOOP.



    IF lt_mapping_header IS NOT INITIAL.
      CASE io_rap_bo_node->get_implementation_type(  ).
        WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.

          "use conv #( ) since importing parameter iv_database_table
          "was of type sxco_dbt_object_name and has been changed to clike
          "to support structure names longer than 16 characters as of 2111

          DATA(header_mapping) = lo_header_behavior->add_mapping_for( CONV #( io_rap_bo_node->persistent_table_name ) ).
          header_mapping->set_field_mapping( it_field_mappings =  lt_mapping_header ).
          IF io_rap_bo_node->is_extensible(  ) = abap_true.
            "header_mapping->set_extensible(  )->set_corresponding(  ).
            set_extensible_for_mapping( header_mapping ).
          ENDIF.
        WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic.
          header_mapping = lo_header_behavior->add_mapping_for( CONV #( io_rap_bo_node->persistent_table_name ) ).
          header_mapping->set_field_mapping( it_field_mappings =  lt_mapping_header ).
          IF io_rap_bo_node->is_extensible(  ) = abap_true.
            "header_mapping->set_extensible(  )->set_corresponding(  ).
            set_extensible_for_mapping( header_mapping ).
          ENDIF.
        WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
          "add control structure
*          lo_header_behavior->add_mapping_for( CONV sxco_dbt_object_name( io_rap_bo_node->persistent_table_name ) )->set_field_mapping( it_field_mappings =  lt_mapping_header )->set_control( io_rap_bo_node->rap_node_objects-control_structure ).

          "add control structure
          IF io_rap_bo_node->data_source_type = io_rap_bo_node->data_source_types-table.
            header_mapping = lo_header_behavior->add_mapping_for( CONV #( io_rap_bo_node->persistent_table_name ) ).
            header_mapping->set_field_mapping( it_field_mappings = lt_mapping_header )->set_control( io_rap_bo_node->rap_node_objects-control_structure ).
          ELSEIF io_rap_bo_node->data_source_type = io_rap_bo_node->data_source_types-structure.
            header_mapping = lo_header_behavior->add_mapping_for( CONV #( io_rap_bo_node->structure_name ) ).
            header_mapping->set_field_mapping( it_field_mappings = lt_mapping_header )->set_control( io_rap_bo_node->rap_node_objects-control_structure ).
          ELSEIF io_rap_bo_node->data_source_type = io_rap_bo_node->data_source_types-abap_type.
            "structure name is added here since we only support abap types that are based on structures
            header_mapping = lo_header_behavior->add_mapping_for( CONV #( io_rap_bo_node->structure_name ) ).
            header_mapping->set_field_mapping( it_field_mappings = lt_mapping_header )->set_control( io_rap_bo_node->rap_node_objects-control_structure ).
          ENDIF.
          IF io_rap_bo_node->is_extensible(  ) = abap_true.
            " header_mapping->set_extensible(  )->set_corresponding(  ).
            set_extensible_for_mapping( header_mapping ).
          ENDIF.
      ENDCASE.
    ENDIF.

    IF io_rap_bo_node->has_childs(  ).
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).
        DATA(assoc) = lo_header_behavior->add_association( '_' && lo_childnode->rap_node_objects-alias  ).
        assoc->set_create_enabled(  ).
        assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
      ENDLOOP.
    ENDIF.



    "define behavior for child entities

    IF io_rap_bo_node->has_childs(  ).

      LOOP AT io_rap_bo_node->all_childnodes INTO lo_childnode.

        CLEAR lt_mapping_item.

        lt_mapping_item = lo_childnode->lt_mapping.

        DATA(lo_item_behavior) = lo_specification->add_behavior( lo_childnode->rap_node_objects-cds_view_r ).

        " Characteristics.
        DATA(item_characteristics) = lo_item_behavior->characteristics.

        "add the draft table
        IF io_rap_bo_node->draft_enabled = abap_true.
          item_characteristics->set_draft_table( lo_childnode->draft_table_name ).
        ENDIF.

        IF lo_childnode->is_extensible(  ) = abap_true.
          item_characteristics->set_extensible(  ).
        ENDIF.

        "@todo: Compare with code for root entity

        CLEAR local_instance_last_changed_at.

        IF line_exists( lo_childnode->lt_fields[ name = lo_childnode->field_name-local_instance_last_changed_at ] ).
          local_instance_last_changed_at = lo_childnode->lt_fields[ name = lo_childnode->field_name-local_instance_last_changed_at ]-cds_view_field.
        ELSEIF line_exists( lo_childnode->lt_additional_fields[ name = lo_childnode->field_name-local_instance_last_changed_at ] ).
          local_instance_last_changed_at = lo_childnode->lt_additional_fields[ name = lo_childnode->field_name-local_instance_last_changed_at ]-cds_view_field.
        ENDIF.


        IF line_exists( lo_childnode->lt_fields[ name = lo_childnode->field_name-last_changed_at ] ).
          last_changed_at = lo_childnode->lt_fields[ name = lo_childnode->field_name-last_changed_at ]-cds_view_field.
        ELSEIF line_exists( lo_childnode->lt_additional_fields[ name = lo_childnode->field_name-last_changed_at ] ).
          last_changed_at = lo_childnode->lt_additional_fields[ name = lo_childnode->field_name-last_changed_at ]-cds_view_field.
        ENDIF.

        CLEAR etag_master.
        IF line_exists( lo_childnode->lt_fields[ name = lo_childnode->field_name-etag_master ] ).
          etag_master = lo_childnode->lt_fields[ name = lo_childnode->field_name-etag_master ]-cds_view_field.
        ELSEIF line_exists( lo_childnode->lt_additional_fields[ name = lo_childnode->field_name-etag_master ] ).
          etag_master = lo_childnode->lt_additional_fields[ name = lo_childnode->field_name-etag_master ]-cds_view_field.
        ENDIF.

        IF etag_master IS NOT INITIAL.
          item_characteristics->etag->set_master( etag_master ).
        ELSE.
          item_characteristics->etag->set_dependent_by( '_' && lo_childnode->root_node->rap_node_objects-alias ).
        ENDIF.

        " Characteristics.
        IF lo_childnode->is_grand_child_or_deeper(  ).

          item_characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
            )->set_implementation_class( lo_childnode->rap_node_objects-behavior_implementation
            )->lock->set_dependent_by( '_' && lo_childnode->root_node->rap_node_objects-alias  ).

          "@todo add again once setting of
          "authorization master(global)
          "is allowed
          "IF lo_childnode->root_node->is_virtual_root( ).
**********************************************************************
** Begin of deletion 2108
**********************************************************************
          "check if set authorization master(global) root node has been set to
          "MASTER(global) or master(instance)
          "only in this case child nodes can't be set as dependent_by
          method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_auth'.
          method_exists_in_interface-method_name    = 'SET_MASTER_GLOBAL'.


          IF xco_api->method_exists_in_interface(
                     interface_name = method_exists_in_interface-interface_name
                     method_name    = method_exists_in_interface-method_name
                   ).
            DATA(item_authorization) = item_characteristics->authorization.
            DATA(authorization_association) =  |_{ lo_childnode->root_node->rap_node_objects-alias }|.
            item_authorization->set_dependent_by( CONV sxco_cds_association_name( authorization_association ) ).
            method_exists_in_interface-method_exists = abap_true.
          ELSE.
            method_exists_in_interface-method_exists = abap_false.
          ENDIF.
          APPEND method_exists_in_interface TO method_exists_in_interfaces.

          "if setting authorization master(global) fails
          "try authorization master(instance)

          IF method_exists_in_interface-method_exists = abap_false.
            method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_auth'.
            method_exists_in_interface-method_name    = 'SET_MASTER_INSTANCE'.
            IF xco_api->method_exists_in_interface(
                 interface_name = method_exists_in_interface-interface_name
                 method_name    = method_exists_in_interface-method_name
               ).

              item_authorization = item_characteristics->authorization.
              authorization_association =  |_{ lo_childnode->root_node->rap_node_objects-alias }|.
              item_authorization->set_dependent_by( CONV sxco_cds_association_name( authorization_association ) ).

              method_exists_in_interface-method_exists = abap_true.
            ELSE.
              method_exists_in_interface-method_exists = abap_false.
            ENDIF.
            APPEND method_exists_in_interface TO method_exists_in_interfaces.

          ENDIF.



*          item_characteristics->authorization->set_dependent_by( '_' && lo_childnode->root_node->rap_node_objects-alias  ).
*          "ENDIF.
*
**********************************************************************
** end of deletion 2108
**********************************************************************


          CASE lo_childnode->get_implementation_type(  ).
            WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.
              item_characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) ).
            WHEN   ZDMO_cl_rap_node=>implementation_type-managed_semantic.
              item_characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) ).
            WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
              "nothing to do
          ENDCASE.



          "add association to parent node
          assoc = lo_item_behavior->add_association( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).

          "add association to root node
          assoc = lo_item_behavior->add_association( '_' && lo_childnode->root_node->rap_node_objects-alias  ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).

          IF lo_childnode->root_node->is_customizing_table = abap_true.
            item_characteristics->set_with_additional_save( ).
          ENDIF.

        ELSEIF lo_childnode->is_child(  ).

          item_characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
                   )->set_implementation_class( lo_childnode->rap_node_objects-behavior_implementation
                   )->lock->set_dependent_by( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).


          "@todo add again once setting of
          "authorization master(global)
          "is allowed
**********************************************************************
** Begin of deletion 2108
**********************************************************************

          "check if set authorization master(global) root node has been set to
          "MASTER(global) or master(instance)
          "only in this case child nodes can't be set as dependent_by

          method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_auth'.
          method_exists_in_interface-method_name    = 'SET_MASTER_GLOBAL'.
          "if root node can't be set as MASTER GLOBAL child nodes can't be set as dependent_by
          IF xco_api->method_exists_in_interface(
                     interface_name = method_exists_in_interface-interface_name
                     method_name    = method_exists_in_interface-method_name
                   ).
            item_authorization = item_characteristics->authorization.
            authorization_association =  |_{ lo_childnode->root_node->rap_node_objects-alias }|.
            item_authorization->set_dependent_by( CONV sxco_cds_association_name( authorization_association ) ).
            method_exists_in_interface-method_exists = abap_true.
          ELSE.
            method_exists_in_interface-method_exists = abap_false.
          ENDIF.
          APPEND method_exists_in_interface TO method_exists_in_interfaces.


          IF method_exists_in_interface-method_exists = abap_false.
            method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_fo_b_auth'.
            method_exists_in_interface-method_name    = 'SET_MASTER_INSTANCE'.
            IF xco_api->method_exists_in_interface(
                 interface_name = method_exists_in_interface-interface_name
                 method_name    = method_exists_in_interface-method_name
               ).

              item_authorization = item_characteristics->authorization.
              authorization_association =  |_{ lo_childnode->root_node->rap_node_objects-alias }|.
              item_authorization->set_dependent_by( CONV sxco_cds_association_name( authorization_association ) ).

              method_exists_in_interface-method_exists = abap_true.
            ELSE.
              method_exists_in_interface-method_exists = abap_false.
            ENDIF.
            APPEND method_exists_in_interface TO method_exists_in_interfaces.

          ENDIF.


*          item_characteristics->authorization->set_dependent_by( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).

**********************************************************************
** end of deletion 2108
**********************************************************************

          IF lo_childnode->root_node->is_customizing_table = abap_true.
            item_characteristics->set_with_additional_save( ).
          ENDIF.


          CASE lo_childnode->get_implementation_type(  ).
            WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.
              item_characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name ) ).
            WHEN   ZDMO_cl_rap_node=>implementation_type-managed_semantic.
              item_characteristics->set_persistent_table( CONV sxco_dbt_object_name( lo_childnode->persistent_table_name  ) ).
            WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
              "set no persistent table
          ENDCASE.


          "add association to parent node
          assoc = lo_item_behavior->add_association( '_' && lo_childnode->parent_node->rap_node_objects-alias  ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).

        ELSE.
          "should not happen

          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            MESSAGE ID 'ZDMO_CM_RAP_GEN_MSG' TYPE 'E' NUMBER '001'
            WITH lo_childnode->entityname lo_childnode->root_node->entityname.

        ENDIF.


        IF lo_childnode->has_childs(  ).
          LOOP AT lo_childnode->childnodes INTO DATA(lo_grandchildnode).
            assoc = lo_item_behavior->add_association( '_' && lo_grandchildnode->rap_node_objects-alias  ).
            assoc->set_create_enabled(  ).
            assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
          ENDLOOP.
        ENDIF.

        "child nodes only offer update and delete and create by assocation
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update ).
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete ).



**********************************************************************
** Begin of deletion 2020
**********************************************************************
        IF io_rap_bo_node->is_customizing_table = abap_true.

          lv_validation_name = |val_transport| .

          DATA(item_validation) = lo_item_behavior->add_validation( CONV #( lv_validation_name ) ).
          "'val_transport'
          item_validation->set_time( xco_cp_behavior_definition=>evaluation->time->on_save ).

*          trigger_operations = VALUE #(
*                                        ( xco_cp_behavior_definition=>evaluation->trigger_operation->create )
*                                        ( xco_cp_behavior_definition=>evaluation->trigger_operation->update )
*                                        "( xco_cp_behavior_definition=>evaluation->trigger_operation->delete )
*                                       ).

          CLEAR trigger_operations.
          ASSIGN xco_cp_behavior_definition=>evaluation->trigger_operation->('CREATE') TO <fs_create>.
          ASSIGN xco_cp_behavior_definition=>evaluation->trigger_operation->('UPDATE') TO <fs_update>.


          IF <fs_create> IS ASSIGNED.
            APPEND <fs_create> TO trigger_operations.
          ENDIF.
          IF <fs_update> IS ASSIGNED.
            APPEND <fs_update> TO trigger_operations.
          ENDIF.

          IF xco_api->method_exists_in_interface(
            interface_name = 'if_xco_gen_bdef_s_fo_b_validtn'
            method_name    = 'SET_TRIGGER_OPERATIONS'
          ).

* todo: dynamic call currently fails
*              CALL METHOD item_validation->('SET_TRIGGER_OPERATIONS')
*                IMPORTING
*                  it_trigger_operations = trigger_operations.

            item_validation->set_trigger_operations( trigger_operations ).

          ENDIF.
        ENDIF.
**********************************************************************
** End of deletion 2020
**********************************************************************


        CASE lo_childnode->get_implementation_type(  ).
          WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.
            "determination CalculateSemanticKey on modify { create; }
            lv_determination_name = 'Calculate' && lo_childnode->object_id_cds_field_name.

            lo_item_behavior->add_determination( CONV #( lv_determination_name )
              )->set_time( xco_cp_behavior_definition=>evaluation->time->on_save
              )->set_trigger_operations( VALUE #( ( xco_cp_behavior_definition=>evaluation->trigger_operation->create ) )  ).

            LOOP AT lt_mapping_item INTO ls_mapping_item.
              CASE ls_mapping_item-dbtable_field.
                WHEN lo_childnode->field_name-uuid.
                  lo_item_behavior->add_field( ls_mapping_item-cds_view_field
                                 )->set_numbering_managed( )->set_read_only( ).
                WHEN lo_childnode->field_name-parent_uuid OR
                     lo_childnode->field_name-root_uuid.
                  lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

                WHEN  lo_childnode->object_id.
                  lo_item_behavior->add_field( ls_mapping_item-cds_view_field )->set_read_only( ).

              ENDCASE.
            ENDLOOP.

          WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic.

            "key field is not set as read only since at this point we assume
            "that the key is set externally

            IF lo_childnode->root_node->is_virtual_root(  ).
              lo_item_behavior->add_field( lo_childnode->singleton_field_name )->set_read_only( ).
            ENDIF.



            LOOP AT lo_childnode->lt_fields INTO DATA(ls_fields)
                   WHERE key_indicator = abap_true AND name <> lo_childnode->field_name-client.

              DATA(key_field_behavior) = lo_item_behavior->add_field( ls_fields-cds_view_field ).

              "sematic key fields that are set via cba have to be read only.
              "This are these key fields that are not part of the semantic key
              "of the parent entity
              "the remaining key fields have to be set as readonly:update

              IF line_exists( lo_childnode->parent_node->semantic_key[ name = ls_fields-name ] ).

                key_field_behavior->set_read_only( ).

              ELSE.

                IF xco_api->method_exists_in_interface( interface_name = 'if_xco_gen_bdef_s_fo_b_field'
                                                        method_name    = 'SET_READONLY_UPDATE' ).
                  CALL METHOD key_field_behavior->('SET_READONLY_UPDATE').
                ENDIF.

              ENDIF.

              "lo_item_behavior->add_field( ls_fields-cds_view_field )->set_readonly_update(  ).
            ENDLOOP.

          WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
            "make the key fields read only in the child entities
            "Otherwise you get the warning
            "The field "<semantic key of root node>" is used for "lock" dependency (in the ON clause of
            "the association "_Travel"). This means it should be flagged as
            "readonly / readonly:update".

            "LOOP AT lo_childnode->root_node->lt_fields INTO DATA(ls_fields)
            LOOP AT lo_childnode->lt_fields INTO ls_fields
              WHERE key_indicator = abap_true AND name <> lo_childnode->field_name-client.
              lo_item_behavior->add_field( ls_fields-cds_view_field )->set_read_only( ).
            ENDLOOP.



        ENDCASE.


*  make administrative fields read-only
*  field ( readonly )
*   CreatedAt,
*   CreatedBy,
*   LocalLastChangedAt,
*   LastChangedAt,
*   LastChangedBy;

        LOOP AT lo_childnode->lt_fields INTO ls_fields
          WHERE name <> lo_childnode->field_name-client.
          CASE ls_fields-name .
            WHEN lo_childnode->field_name-created_at OR
                 lo_childnode->field_name-created_by OR
                 lo_childnode->field_name-local_instance_last_changed_at OR
                 lo_childnode->field_name-local_instance_last_changed_by OR
                 lo_childnode->field_name-last_changed_at OR
                 lo_childnode->field_name-last_changed_by.
              lo_item_behavior->add_field( ls_fields-cds_view_field )->set_read_only( ).
          ENDCASE.
        ENDLOOP.

        IF lt_mapping_item IS NOT INITIAL.
          CASE io_rap_bo_node->get_implementation_type(  ).
            WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.
              "use conv #( ) since importing parameter iv_database_table
              "was of type sxco_dbt_object_name and has been changed to clike
              "to support structure names longer than 16 characters as of 2111
              DATA(item_mapping) = lo_item_behavior->add_mapping_for( CONV #( lo_childnode->persistent_table_name ) ).
              item_mapping->set_field_mapping( it_field_mappings =  lt_mapping_item ).
              IF io_rap_bo_node->is_extensible(  ) = abap_true.
                "item_mapping->set_extensible(  )->set_corresponding(  ).
                set_extensible_for_mapping( item_mapping ).
              ENDIF.
            WHEN ZDMO_cl_rap_node=>implementation_type-managed_semantic.
              item_mapping = lo_item_behavior->add_mapping_for( CONV #( lo_childnode->persistent_table_name ) ).
              item_mapping->set_field_mapping( it_field_mappings =  lt_mapping_item ).
              IF io_rap_bo_node->is_extensible(  ) = abap_true.
                "item_mapping->set_extensible(  )->set_corresponding(  ).
                set_extensible_for_mapping( item_mapping ).
              ENDIF.
            WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
              "add control structure
              IF io_rap_bo_node->data_source_type = io_rap_bo_node->data_source_types-table.
                item_mapping = lo_item_behavior->add_mapping_for( CONV #( lo_childnode->persistent_table_name ) ).
                item_mapping->set_field_mapping( it_field_mappings = lt_mapping_item )->set_control( lo_childnode->rap_node_objects-control_structure ).
              ELSEIF io_rap_bo_node->data_source_type = io_rap_bo_node->data_source_types-structure.
                item_mapping = lo_item_behavior->add_mapping_for( CONV #( lo_childnode->structure_name ) ).
                item_mapping->set_field_mapping( it_field_mappings = lt_mapping_item )->set_control( lo_childnode->rap_node_objects-control_structure ).
              ELSEIF io_rap_bo_node->data_source_type = io_rap_bo_node->data_source_types-abap_type.
                "structure name is added here since we only support abap types that are based on structures
                item_mapping = lo_item_behavior->add_mapping_for( CONV #( lo_childnode->structure_name ) ).
                item_mapping->set_field_mapping( it_field_mappings = lt_mapping_item )->set_control( lo_childnode->rap_node_objects-control_structure ).
              ENDIF.

              IF io_rap_bo_node->is_extensible(  ) = abap_true.
                "item_mapping->set_extensible(  )->set_corresponding(  ).
                set_extensible_for_mapping( item_mapping ).
              ENDIF.

          ENDCASE.
        ENDIF.



      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD create_bdef_i.

    "todo: add
    "  rap_root_node_objects-behavior_definition_i
    "


    DATA(lo_specification) = mo_put_operation->for-bdef->add_object( io_rap_bo_node->rap_root_node_objects-behavior_definition_i
                  )->set_package( mo_package
                  )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_root_node_objects-behavior_definition_i.
    generated_repository_object-object_type = 'BDEF'.
    APPEND generated_repository_object TO generated_repository_objects.

    lo_specification->set_short_description( |Behavior for { io_rap_bo_node->rap_node_objects-cds_view_i }|
       )->set_implementation_type( xco_cp_behavior_definition=>implementation_type->interface
       )  ##no_text.

    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      lo_specification->set_extensible(  ).
*      IF xco_api->method_exists_in_interface(
*        interface_name = 'if_xco_cp_gen_bdef_s_form'
*        method_name    = 'SET_USE_SIDE_EFFECTS'
*      ).
*        CALL METHOD lo_specification->('SET_USE_SIDE_EFFECTS').
*      ENDIF.
      IF xco_api->on_premise_branch_is_used(  ).
        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
      ELSE.
        method_exists_in_interface-interface_name = 'if_xco_cp_gen_bdef_s_form'.
      ENDIF.
      method_exists_in_interface-method_name    = 'SET_USE_SIDE_EFFECTS'.
      IF xco_api->method_exists_in_interface(
              interface_name = method_exists_in_interface-interface_name
              method_name    = method_exists_in_interface-method_name
            ).
        CALL METHOD lo_specification->(method_exists_in_interface-method_name).
      ENDIF.
    ENDIF.
**********************************************************************
** Begin of deletion 2020
**********************************************************************

    IF io_rap_bo_node->draft_enabled = abap_true.
      "if_xco_cp_gen_bdef_s_form
      IF xco_api->on_premise_branch_is_used(  ).
        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
      ELSE.
        method_exists_in_interface-interface_name = 'if_xco_cp_gen_bdef_s_form'.
      ENDIF.
      method_exists_in_interface-method_name    = 'SET_USE_DRAFT'.
      IF xco_api->method_exists_in_interface(
              interface_name = method_exists_in_interface-interface_name
              method_name    = method_exists_in_interface-method_name
            ).
        CALL METHOD lo_specification->(method_exists_in_interface-method_name).
      ENDIF.
*      IF xco_api->method_exists_in_interface(
*              interface_name = 'if_xco_cp_gen_bdef_s_form'
*              method_name    = 'SET_USE_DRAFT'
*            ).
*        CALL METHOD lo_specification->('SET_USE_DRAFT').
*      ENDIF.
    ENDIF.
**********************************************************************
** End of deletion 2020
**********************************************************************

    "strict statement is not used in bdef of interface view
*    IF io_rap_bo_node->is_abstract_or_custom_entity(  ) = abap_false.
*      lo_specification->set_strict_n( zdmo_cl_rap_node=>strict_mode_2 ).
*      IF xco_api->on_premise_branch_is_used(  ).
*        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
*      ELSE.
*        method_exists_in_interface-interface_name = 'if_xco_cp_gen_bdef_s_form'.
*      ENDIF.
*
*      method_exists_in_interface-method_name    = 'SET_STRICT_N'.
*      IF xco_api->method_exists_in_interface(
*           interface_name = method_exists_in_interface-interface_name
*           method_name    = method_exists_in_interface-method_name
*         ).
*        CALL METHOD lo_specification->(method_exists_in_interface-method_name)
*          EXPORTING
*            iv_n = zdmo_cl_rap_node=>strict_mode_2.
*        APPEND 'SET_STRICT_N' TO call_method_succeeded_list.
*        method_exists_in_interface-method_exists = abap_true.
*      ELSE.
*        method_exists_in_interface-method_exists = abap_false.
*      ENDIF.
*      APPEND method_exists_in_interface TO method_exists_in_interfaces.
*      "set_strict_n not found
*      "try to set strict
*      IF method_exists_in_interface-method_exists = abap_false.
*        method_exists_in_interface-method_name    = 'SET_STRICT'.
*        IF xco_api->method_exists_in_interface(
*             interface_name = method_exists_in_interface-interface_name
*             method_name    = method_exists_in_interface-method_name
*           ).
*          CALL METHOD lo_specification->(method_exists_in_interface-method_name).
*          APPEND 'SET_STRICT' TO call_method_succeeded_list.
*          method_exists_in_interface-method_exists = abap_true.
*        ELSE.
*          method_exists_in_interface-method_exists = abap_false.
*        ENDIF.
*        APPEND method_exists_in_interface TO method_exists_in_interfaces.
*      ENDIF.
*    ENDIF.

    DATA(lo_header_behavior) = lo_specification->add_behavior( io_rap_bo_node->rap_node_objects-cds_view_i ).

    " Characteristics.

    " Characteristics.
    DATA(header_characteristics) = lo_header_behavior->characteristics.

    " extensibility on entity level is inherited from the R-layer
*    IF io_rap_bo_node->is_extensible(  ) = abap_true.
*      header_characteristics->set_extensible(  ).
*    ENDIF.

    lo_header_behavior->characteristics->set_alias( CONV #( io_rap_bo_node->rap_node_objects-alias )
      ).

    lo_header_behavior->characteristics->etag->set_use(  ) .

    IF io_rap_bo_node->draft_enabled = abap_true.

      "add the following actions in case draft is used
      "follows the strict implementation principle
      "use action Activate;
      "use action Discard;
      "use action Edit;
      "use action Prepare;
      "use action Resume;

      xco_api->todo( 'check if the following statements shall be executed or only if the following method exists' ).
*      IF xco_api->method_exists_in_interface(
*                     interface_name = 'if_xco_gen_bdef_s_fo_b_action '
*                     method_name    = 'set_draft'
*                   ).

      lo_header_behavior->add_action( 'Edit' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Activate' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Discard' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Resume' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Prepare' )->set_use( ) ##no_text.


    ENDIF.

    " Standard operations.
    IF io_rap_bo_node->is_virtual_root(  ) .
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
    ELSE.
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create )->set_use( ).
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).
    ENDIF.

    IF io_rap_bo_node->is_virtual_root(  ) = abap_true AND io_rap_bo_node->is_customizing_table = abap_true.
      "use action selectTransport;
      lo_header_behavior->add_action( iv_name = 'selectTransport' )->set_use( ).
    ENDIF.


    "use action Edit;
    "if the Edit function is defined there is no need to implement a BIL
    "IF io_rap_bo_node->draft_enabled = abap_true.
    "  lo_header_behavior->add_action( iv_name = 'Edit' )->set_use( ).
    "ENDIF.

    IF io_rap_bo_node->has_childs(  ).

      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).
        DATA(assoc) =  lo_header_behavior->add_association( '_' && lo_childnode->rap_node_objects-alias ).
        assoc->set_create_enabled( abap_true ).
        assoc->set_use(  ).
        assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
      ENDLOOP.

      LOOP AT io_rap_bo_node->all_childnodes INTO lo_childnode.

        DATA(lo_item_behavior) = lo_specification->add_behavior( lo_childnode->rap_node_objects-cds_view_i ).

        " Characteristics.
        lo_item_behavior->characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
          ).

        " Characteristics.
        DATA(item_characteristics) = lo_item_behavior->characteristics.

        "extensibility on entity level is inherited from the r-layer
*        IF io_rap_bo_node->is_extensible(  ) = abap_true.
*          item_characteristics->set_extensible(  ).
*        ENDIF.

        lo_item_behavior->characteristics->etag->set_use(  ) .

        " Standard operations.
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).

        "add association to parent and root views
        "e.g. use association _Travel { with draft; }

        IF lo_childnode->is_grand_child_or_deeper(  ).

          "publish association to root
          assoc = lo_item_behavior->add_association(  '_' && lo_childnode->root_node->rap_node_objects-alias ).
          assoc->set_use( ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).

          "publish association to parent
          assoc = lo_item_behavior->add_association(  '_' && lo_childnode->parent_node->rap_node_objects-alias ).
          assoc->set_use( ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).

        ELSEIF lo_childnode->is_child( ).
          "lo_item_behavior->add_association(  mo_assoc_to_header )->set_use(  ).
          "'_' && lo_childnode->parent_node->rap_node_objects-alias

          "publish association to parent
          assoc = lo_item_behavior->add_association(  '_' && lo_childnode->parent_node->rap_node_objects-alias ).
          assoc->set_use(  ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
        ELSE.

          "for a root node nothing has to be added here

        ENDIF.

        "publish draft enabled associations to all child nodes of node
        "e.g. use association _Booking { create; with draft; }

        IF lo_childnode->has_childs(  ).
          LOOP AT lo_childnode->childnodes INTO DATA(lo_grandchildnode).
            assoc = lo_item_behavior->add_association( iv_name = '_' && lo_grandchildnode->rap_node_objects-alias ).
            assoc->set_create_enabled(  ).
            assoc->set_use(  ).
            assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
          ENDLOOP.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD create_bdef_p.
    DATA(lo_specification) = mo_put_operation->for-bdef->add_object( io_rap_bo_node->rap_root_node_objects-behavior_definition_p
               )->set_package( mo_package
               )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_root_node_objects-behavior_definition_p.
    generated_repository_object-object_type = 'BDEF'.
    APPEND generated_repository_object TO generated_repository_objects.

    lo_specification->set_short_description( |Behavior for { io_rap_bo_node->rap_node_objects-cds_view_p }|
       )->set_implementation_type( xco_cp_behavior_definition=>implementation_type->projection
       )  ##no_text.

    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      lo_specification->set_extensible(  ).
      IF xco_api->on_premise_branch_is_used(  ).
        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
      ELSE.
        method_exists_in_interface-interface_name = 'if_xco_cp_gen_bdef_s_form'.
      ENDIF.
      method_exists_in_interface-method_name    = 'SET_USE_SIDE_EFFECTS'.
      IF xco_api->method_exists_in_interface(
              interface_name = method_exists_in_interface-interface_name
              method_name    = method_exists_in_interface-method_name
            ).
        CALL METHOD lo_specification->(method_exists_in_interface-method_name).
      ENDIF.
    ENDIF.
**********************************************************************
** Begin of deletion 2020
**********************************************************************

    IF io_rap_bo_node->draft_enabled = abap_true.
      "if_xco_cp_gen_bdef_s_form
      IF xco_api->on_premise_branch_is_used(  ).
        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
      ELSE.
        method_exists_in_interface-interface_name = 'if_xco_cp_gen_bdef_s_form'.
      ENDIF.
      method_exists_in_interface-method_name    = 'SET_USE_DRAFT'.
      IF xco_api->method_exists_in_interface(
              interface_name = method_exists_in_interface-interface_name
              method_name    = method_exists_in_interface-method_name
            ).
        CALL METHOD lo_specification->(method_exists_in_interface-method_name).
      ENDIF.
*      IF xco_api->method_exists_in_interface(
*              interface_name = 'if_xco_cp_gen_bdef_s_form'
*              method_name    = 'SET_USE_DRAFT'
*            ).
*        CALL METHOD lo_specification->('SET_USE_DRAFT').
*      ENDIF.
    ENDIF.
**********************************************************************
** End of deletion 2020
**********************************************************************

    "use the highest recommended strict mode
    IF io_rap_bo_node->is_abstract_or_custom_entity(  ) = abap_false.
*      lo_specification->set_strict_n( zdmo_cl_rap_node=>strict_mode_2 ).
      IF xco_api->on_premise_branch_is_used(  ).
        method_exists_in_interface-interface_name = 'if_xco_gen_bdef_s_form'.
      ELSE.
        method_exists_in_interface-interface_name = 'if_xco_cp_gen_bdef_s_form'.
      ENDIF.

      method_exists_in_interface-method_name    = 'SET_STRICT_N'.
      IF xco_api->method_exists_in_interface(
           interface_name = method_exists_in_interface-interface_name
           method_name    = method_exists_in_interface-method_name
         ).
        CALL METHOD lo_specification->(method_exists_in_interface-method_name)
          EXPORTING
            iv_n = zdmo_cl_rap_node=>strict_mode_2.
        APPEND 'SET_STRICT_N' TO call_method_succeeded_list.
        method_exists_in_interface-method_exists = abap_true.
      ELSE.
        method_exists_in_interface-method_exists = abap_false.
      ENDIF.
      APPEND method_exists_in_interface TO method_exists_in_interfaces.
      "set_strict_n not found
      "try to set strict
      IF method_exists_in_interface-method_exists = abap_false.
        method_exists_in_interface-method_name    = 'SET_STRICT'.
        IF xco_api->method_exists_in_interface(
             interface_name = method_exists_in_interface-interface_name
             method_name    = method_exists_in_interface-method_name
           ).
          CALL METHOD lo_specification->(method_exists_in_interface-method_name).
          APPEND 'SET_STRICT' TO call_method_succeeded_list.
          method_exists_in_interface-method_exists = abap_true.
        ELSE.
          method_exists_in_interface-method_exists = abap_false.
        ENDIF.
        APPEND method_exists_in_interface TO method_exists_in_interfaces.
      ENDIF.
    ENDIF.

    DATA(lo_header_behavior) = lo_specification->add_behavior( io_rap_bo_node->rap_node_objects-cds_view_p ).

    " Characteristics.

    " Characteristics.
    DATA(header_characteristics) = lo_header_behavior->characteristics.

    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      header_characteristics->set_extensible(  ).
    ENDIF.

    lo_header_behavior->characteristics->set_alias( CONV #( io_rap_bo_node->rap_node_objects-alias )
      ).

    lo_header_behavior->characteristics->etag->set_use(  ) .

    IF io_rap_bo_node->draft_enabled = abap_true.

      "add the following actions in case draft is used
      "follows the strict implementation principle
      "use action Activate;
      "use action Discard;
      "use action Edit;
      "use action Prepare;
      "use action Resume;

      xco_api->todo( 'check if the following statements shall be executed or only if the following method exists' ).
*      IF xco_api->method_exists_in_interface(
*                     interface_name = 'if_xco_gen_bdef_s_fo_b_action '
*                     method_name    = 'set_draft'
*                   ).

      lo_header_behavior->add_action( 'Edit' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Activate' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Discard' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Resume' )->set_use( ) ##no_text.
      lo_header_behavior->add_action( 'Prepare' )->set_use( ) ##no_text.


    ENDIF.

    " Standard operations.
    IF io_rap_bo_node->is_virtual_root(  ) .
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
    ELSE.
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->create )->set_use( ).
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
      lo_header_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).
    ENDIF.

    IF io_rap_bo_node->is_virtual_root(  ) = abap_true AND io_rap_bo_node->is_customizing_table = abap_true.
      "use action selectTransport;
      lo_header_behavior->add_action( iv_name = 'selectTransport' )->set_use( ).
    ENDIF.


    "use action Edit;
    "if the Edit function is defined there is no need to implement a BIL
    "IF io_rap_bo_node->draft_enabled = abap_true.
    "  lo_header_behavior->add_action( iv_name = 'Edit' )->set_use( ).
    "ENDIF.

    IF io_rap_bo_node->has_childs(  ).

      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).
        DATA(assoc) =  lo_header_behavior->add_association( '_' && lo_childnode->rap_node_objects-alias ).
        assoc->set_create_enabled( abap_true ).
        assoc->set_use(  ).
        assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
      ENDLOOP.

      LOOP AT io_rap_bo_node->all_childnodes INTO lo_childnode.

        DATA(lo_item_behavior) = lo_specification->add_behavior( lo_childnode->rap_node_objects-cds_view_p ).

        " Characteristics.
        lo_item_behavior->characteristics->set_alias( CONV #( lo_childnode->rap_node_objects-alias )
          ).

        " Characteristics.
        DATA(item_characteristics) = lo_item_behavior->characteristics.

        IF io_rap_bo_node->is_extensible(  ) = abap_true.
          item_characteristics->set_extensible(  ).
        ENDIF.

        lo_item_behavior->characteristics->etag->set_use(  ) .

        " Standard operations.
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->update )->set_use( ).
        lo_item_behavior->add_standard_operation( xco_cp_behavior_definition=>standard_operation->delete )->set_use( ).

        "add association to parent and root views
        "e.g. use association _Travel { with draft; }

        IF lo_childnode->is_grand_child_or_deeper(  ).

          "publish association to root
          assoc = lo_item_behavior->add_association(  '_' && lo_childnode->root_node->rap_node_objects-alias ).
          assoc->set_use( ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).

          "publish association to parent
          assoc = lo_item_behavior->add_association(  '_' && lo_childnode->parent_node->rap_node_objects-alias ).
          assoc->set_use( ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).

        ELSEIF lo_childnode->is_child( ).
          "lo_item_behavior->add_association(  mo_assoc_to_header )->set_use(  ).
          "'_' && lo_childnode->parent_node->rap_node_objects-alias

          "publish association to parent
          assoc = lo_item_behavior->add_association(  '_' && lo_childnode->parent_node->rap_node_objects-alias ).
          assoc->set_use(  ).
          assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
        ELSE.

          "for a root node nothing has to be added here

        ENDIF.

        "publish draft enabled associations to all child nodes of node
        "e.g. use association _Booking { create; with draft; }

        IF lo_childnode->has_childs(  ).
          LOOP AT lo_childnode->childnodes INTO DATA(lo_grandchildnode).
            assoc = lo_item_behavior->add_association( iv_name = '_' && lo_grandchildnode->rap_node_objects-alias ).
            assoc->set_create_enabled(  ).
            assoc->set_use(  ).
            assoc->set_draft_enabled( io_rap_bo_node->draft_enabled ).
          ENDLOOP.
        ENDIF.

      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD create_bil.
**********************************************************************
** Begin of deletion 2020
**********************************************************************

    DATA  source_method_save_modified  TYPE if_xco_gen_clas_s_fo_i_method=>tt_source  .
    DATA  source_method_validation  TYPE if_xco_gen_clas_s_fo_i_method=>tt_source  .
    DATA  source_method_get_inst_feat TYPE if_xco_gen_clas_s_fo_i_method=>tt_source  .
    DATA  source_action_set_transport TYPE if_xco_gen_clas_s_fo_i_method=>tt_source  .
    DATA  source_method_determ_object_id TYPE if_xco_gen_clas_s_fo_i_method=>tt_source  .
    DATA  source_code_line LIKE LINE OF source_method_save_modified.

    DATA handler_has_method TYPE abap_bool.
    DATA saver_has_method TYPE abap_bool.

    DATA  local_handler_class_name TYPE sxco_ao_object_name.
    DATA local_saver_class_name   TYPE sxco_ao_object_name.

    handler_has_method = abap_false.
    saver_has_method = abap_false.

    local_handler_class_name = |lhc_{ io_rap_bo_node->entityname }| .
    local_saver_class_name = 'LCL_SAVER' .

    DATA(lo_specification) = mo_put_operation->for-clas->add_object(  io_rap_bo_node->rap_node_objects-behavior_implementation
                                    )->set_package( mo_package
                                    )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-behavior_implementation.
    generated_repository_object-object_type = 'CLAS'.
    APPEND generated_repository_object TO generated_repository_objects.


    lo_specification->set_short_description( 'Behavior implementation' ) ##no_text.

    "behavior has to be defined for the root node in all BIL classes
    "to_upper( ) as workaround for 2011 and 2020, fix will be available with 2102
    lo_specification->definition->set_abstract(
      )->set_for_behavior_of( to_upper( io_rap_bo_node->root_node->rap_node_objects-cds_view_r ) ).

*    DATA(lo_handler) = lo_specification->add_local_class( 'LCL_HANDLER' ).
*    lo_handler->definition->set_superclass( 'CL_ABAP_BEHAVIOR_HANDLER' ).

    "a local class will only be created if there are methods
    "that are generated as well
    "otherwise we get the error
    "The BEHAVIOR class "LCL_HANDLER" does not contain the BEHAVIOR method "MODIFY | READ".


    DATA(lo_handler) = lo_specification->add_local_class( local_handler_class_name ).
    lo_handler->definition->set_superclass( 'CL_ABAP_BEHAVIOR_HANDLER' ).

**********************************************************************
** Begin of deletion 2108
**********************************************************************
    IF xco_api->method_exists_in_interface(
             interface_name = 'if_xco_gen_clas_s_fo_d_c_m_bi'
             method_name    = 'SET_FOR_GLOBAL_AUTHORIZATION'
           ).
      IF io_rap_bo_node->is_root(  ). " method get_global_authorizations

        DATA(lo_get_global_auth) = lo_handler->definition->section-private->add_method( method_get_glbl_authorizations ).
        DATA(behavior_implementation) = lo_get_global_auth->behavior_implementation.
        behavior_implementation->set_result( iv_result = 'result' ).
        CALL METHOD behavior_implementation->('SET_FOR_GLOBAL_AUTHORIZATION').
        DATA(lo_request) = lo_get_global_auth->add_importing_parameter( ' ' ).
        DATA(behavior_implementation_2) = lo_request->behavior_implementation.
        behavior_implementation_2->set_for( iv_for = io_rap_bo_node->entityname ).
        CALL METHOD behavior_implementation_2->('SET_REQUEST')
          EXPORTING
            iv_request = 'requested_authorizations'.

        lo_handler->implementation->add_method( method_get_glbl_authorizations ).
        handler_has_method = abap_true.
      ENDIF.
    ENDIF.

**********************************************************************
** End of deletion 2108
**********************************************************************

    IF io_rap_bo_node->is_virtual_root(  ).

      " method get_instance_features.
      DATA(lo_get_features) = lo_handler->definition->section-private->add_method( method_get_instance_features ).
      DATA(behavior_implementation_3) =  lo_get_features->behavior_implementation.
      behavior_implementation_3->set_result( iv_result = 'result' ).

      CALL METHOD behavior_implementation_3->('SET_FOR_INSTANCE_FEATURES').

      DATA(lo_keys) = lo_get_features->add_importing_parameter( iv_name = 'keys' ).

      DATA(behavior_implementation_4) = lo_keys->behavior_implementation.
      behavior_implementation_4->set_for( iv_for = io_rap_bo_node->entityname ).
      CALL METHOD behavior_implementation_4->('SET_REQUEST')
        EXPORTING
          iv_request = 'requested_features'.

      lo_handler->implementation->add_method( method_get_instance_features ).
      handler_has_method = abap_true.

      CLEAR  source_method_get_inst_feat.
      APPEND |READ ENTITIES OF { io_rap_bo_node->rap_root_node_objects-behavior_definition_r } IN LOCAL MODE| TO  source_method_get_inst_feat ##no_text.
      APPEND |ENTITY { io_rap_bo_node->entityname }| TO  source_method_get_inst_feat ##no_text.
      APPEND |ALL FIELDS WITH CORRESPONDING #( keys )| TO  source_method_get_inst_feat  ##no_text.
      APPEND |RESULT DATA(all).| TO  source_method_get_inst_feat  ##no_text.

      APPEND |result = VALUE #( ( %tky = all[ 1 ]-%tky| TO  source_method_get_inst_feat  ##no_text.
      APPEND |                    %action-selecttransport = COND #( WHEN all[ 1 ]-%is_draft = if_abap_behv=>mk-on THEN if_abap_behv=>mk-off| TO  source_method_get_inst_feat  ##no_text.
      APPEND |                                                      ELSE if_abap_behv=>mk-on  )   ) ).| TO  source_method_get_inst_feat  ##no_text.

      lo_handler->implementation->add_method( method_get_instance_features )->set_source( source_method_get_inst_feat ).

      DATA lv_action_name   TYPE sxco_bdef_action_name    .
      lv_action_name = 'selectTransport'  ##no_text.

      DATA(lo_transport) = lo_handler->definition->section-private->add_method( CONV #( lv_action_name ) ).
      lo_transport->behavior_implementation->set_for_modify( ).

      DATA(lo_keys_transport)  = lo_transport->add_importing_parameter( iv_name = 'keys' ).
      lo_keys_transport->behavior_implementation->set_for_action(
        EXPORTING
          iv_entity_name = io_rap_bo_node->entityname
          iv_action_name = lv_action_name
*  RECEIVING
*         ro_me          =
      ).
      lo_transport->behavior_implementation->set_result( iv_result = 'result' ).


      APPEND    |MODIFY ENTITIES OF { io_rap_bo_node->rap_root_node_objects-behavior_definition_r } IN LOCAL MODE| TO source_action_set_transport  ##no_text.
      APPEND    |ENTITY { io_rap_bo_node->entityname }| TO source_action_set_transport ##no_text.
      APPEND    |UPDATE FIELDS ( request hidetransport )| TO source_action_set_transport ##no_text.
      APPEND    |WITH VALUE #( FOR key IN keys| TO source_action_set_transport ##no_text.
      APPEND    |               ( %tky         = key-%tky| TO source_action_set_transport ##no_text.
      APPEND    |                 request = key-%param-transportrequestid| TO source_action_set_transport ##no_text.
      APPEND    |                 hidetransport = abap_false ) )| TO source_action_set_transport ##no_text.
      APPEND    |    FAILED failed| TO source_action_set_transport ##no_text.
      APPEND    |    REPORTED reported.| TO source_action_set_transport ##no_text.
      APPEND    | | TO source_action_set_transport ##no_text.
      APPEND    | | TO source_action_set_transport ##no_text.
      APPEND    |    READ ENTITIES OF { io_rap_bo_node->rap_root_node_objects-behavior_definition_r }  IN LOCAL MODE| TO source_action_set_transport ##no_text.
      APPEND    |      ENTITY { io_rap_bo_node->entityname }| TO source_action_set_transport ##no_text.
      APPEND    |        ALL FIELDS WITH CORRESPONDING #( keys )| TO source_action_set_transport ##no_text.
      APPEND    |      RESULT DATA(singletons).| TO source_action_set_transport ##no_text.
      APPEND    |    result = VALUE #( FOR singleton IN singletons| TO source_action_set_transport ##no_text.
      APPEND    |                        ( %tky   = singleton-%tky| TO source_action_set_transport ##no_text.
      APPEND    |                          %param = singleton ) ).| TO source_action_set_transport ##no_text.

      lo_handler->implementation->add_method( CONV #( lv_action_name ) )->set_source( source_action_set_transport ).
      handler_has_method = abap_true.
    ENDIF.



    "add validations of transports
    IF io_rap_bo_node->is_customizing_table = abap_true AND
       io_rap_bo_node->is_virtual_root(  ) = abap_false.

      "SELECT * FROM @io_rap_bo_node->lt_fields AS fields WHERE name  = @io_rap_bo_node->field_name-uuid INTO TABLE @DATA(result_uuid).

      SELECT * FROM @io_rap_bo_node->lt_fields AS fields WHERE key_indicator  = @abap_true
                                                           AND name <> @io_rap_bo_node->field_name-client INTO TABLE @DATA(key_fields).

      DATA(lv_validation_name) = |val_transport| .

      DATA(lo_val) = lo_handler->definition->section-private->add_method( CONV #( lv_validation_name ) ).
      DATA(behavior_implementation_val) = lo_val->behavior_implementation.
      CALL METHOD behavior_implementation_val->('SET_FOR_VALIDATE_ON_SAVE').
      DATA(lo_keys_validation) = lo_val->add_importing_parameter( iv_name = 'keys' ).
      lo_keys_validation->behavior_implementation->set_for( iv_for = | { io_rap_bo_node->entityname }~{ lv_validation_name } | ).

      CLEAR source_method_validation.
      "      APPEND |CHECK lines( keys ) > 0.| TO source_method_validation.

      APPEND |DATA change TYPE REQUEST FOR CHANGE { io_rap_bo_node->root_node->rap_root_node_objects-behavior_definition_r }.| TO source_method_validation ##no_text.
      APPEND |SELECT SINGLE request FROM { io_rap_bo_node->root_node->draft_table_name } INTO @DATA(request).| TO source_method_validation ##no_text.
      APPEND |DATA(rap_transport_api) = mbc_cp_api=>rap_table_cts( table_entity_relations = VALUE #(| TO source_method_validation ##no_text.
      LOOP AT io_rap_bo_node->root_node->all_childnodes INTO DATA(childnode).
        APPEND |                                             ( entity = '{ childnode->entityname }' table = '{ to_upper( childnode->table_name ) }' )| TO source_method_validation ##no_text.
      ENDLOOP.
      APPEND |                                                                       ) ).| TO source_method_validation ##no_text.

      APPEND |rap_transport_api->validate_changes(| TO source_method_validation ##no_text.
      APPEND |    transport_request = request| TO source_method_validation ##no_text.
      APPEND |    table             = '{ to_upper( io_rap_bo_node->table_name ) }'| TO source_method_validation ##no_text.
      APPEND |    keys              = REF #( keys )| TO source_method_validation ##no_text.
      APPEND |    reported          = REF #( reported )| TO source_method_validation ##no_text.
      APPEND |    failed            = REF #( failed )| TO source_method_validation ##no_text.
      APPEND |    change            = REF #( change-{ io_rap_bo_node->entityname } ) ).| TO source_method_validation ##no_text.


      lo_handler->implementation->add_method( CONV #( lv_validation_name ) )->set_source( source_method_validation ).
      handler_has_method = abap_true.
    ENDIF.

    "add local saver class to record customizing data
    IF io_rap_bo_node->is_customizing_table = abap_true AND
       io_rap_bo_node->is_root(  ) = abap_true.

      DATA(lo_saver) = lo_specification->add_local_class( local_saver_class_name ).
      lo_saver->definition->set_superclass( 'CL_ABAP_BEHAVIOR_SAVER' ).

      lo_saver->definition->section-protected->add_method( cleanup_finalize )->set_redefinition( ).
      lo_saver->implementation->add_method( cleanup_finalize ).


      lo_saver->definition->section-protected->add_method( method_save_modified )->set_redefinition( ).

      CLEAR source_method_save_modified.
      " APPEND |   | TO source_method_save_modified.


      APPEND |READ TABLE update-{ io_rap_bo_node->entityname } INDEX 1 INTO DATA(all).| TO source_method_save_modified  ##no_text.
      APPEND |SELECT SINGLE request FROM { io_rap_bo_node->root_node->draft_table_name } INTO @DATA(request).| TO source_method_save_modified ##no_text.
      APPEND |DATA(result) = mbc_cp_api=>rap_table_cts( table_entity_relations = VALUE #(| TO source_method_save_modified ##no_text.
      LOOP AT io_rap_bo_node->all_childnodes INTO DATA(child_node).
        APPEND |                                                                        ( entity = '{ child_node->entityname }' table = '{ child_node->table_name }' )| TO source_method_save_modified  ##no_text.
      ENDLOOP.
      APPEND |                                                                          ) ).| TO source_method_save_modified  ##no_text.


      APPEND |IF all-request IS NOT INITIAL.| TO source_method_save_modified ##no_text.
      APPEND |  result->record_changes(| TO source_method_save_modified ##no_text.
      APPEND |    EXPORTING| TO source_method_save_modified ##no_text.
      APPEND |      transport_request = request| TO source_method_save_modified  ##no_text.
      APPEND |      create            = REF #( create )| TO source_method_save_modified ##no_text.
      APPEND |      update            = REF #( update )| TO source_method_save_modified ##no_text.
      APPEND |      delete            = REF #( delete )| TO source_method_save_modified ##no_text.
      APPEND |  ).| TO source_method_save_modified ##no_text.
      APPEND |ENDIF.| TO source_method_save_modified ##no_text.

      lo_saver->implementation->add_method( method_save_modified )->set_source( source_method_save_modified ).

    ENDIF.

**********************************************************************
** End of deletion 2020
**********************************************************************

    "in case of a semantic key scenario the keys are set externally


    CASE io_rap_bo_node->get_implementation_type(  ).
      WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.

        DATA cba_method_name  TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  .
        DATA rba_method_name  TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name  .

        "method determination
        DATA(lv_determination_name) = |Calculate{ io_rap_bo_node->object_id_cds_field_name }|  ##no_text.

        DATA(lo_det) = lo_handler->definition->section-private->add_method( CONV #( lv_determination_name ) ).
        DATA(Behavior_implementation_det) = lo_det->behavior_implementation.
        CALL METHOD Behavior_implementation_det->('SET_FOR_DETERMINE_ON_SAVE').

        DATA(lo_keys_determination) = lo_det->add_importing_parameter( iv_name = 'keys' ).
        lo_keys_determination->behavior_implementation->set_for( iv_for = | { io_rap_bo_node->entityname }~{ lv_determination_name } | ).


        " add dummy implementation to calculate object_id
        CLEAR  source_method_determ_object_id.
        DATA cm TYPE c LENGTH 1.
        cm = | |.
        IF io_rap_bo_node->is_root(  ) = abap_true.

          APPEND cm && |READ ENTITIES OF { io_rap_bo_node->rap_root_node_objects-behavior_definition_r } IN LOCAL MODE| TO  source_method_determ_object_id ##no_text.
          APPEND cm && |  ENTITY { io_rap_bo_node->entityname }| TO  source_method_determ_object_id ##no_text.
          APPEND cm && |    ALL FIELDS WITH CORRESPONDING #( keys )| TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |  RESULT DATA(entities).| TO  source_method_determ_object_id  ##no_text.
*
          APPEND cm && |DELETE entities WHERE { io_rap_bo_node->object_id_cds_field_name } IS NOT INITIAL.| TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |Check entities is not initial.                 | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |"Dummy logic to determine object_id                | TO  source_method_determ_object_id  ##no_text.

          "active table
          APPEND cm && |SELECT MAX( { io_rap_bo_node->object_id } ) FROM { io_rap_bo_node->table_name } INTO @DATA(max_object_id). | TO  source_method_determ_object_id  ##no_text.

          APPEND cm && |"Add support for draft if used in modify                | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |"SELECT SINGLE FROM FROM { io_rap_bo_node->draft_table_name } FIELDS MAX( { io_rap_bo_node->object_id_cds_field_name } ) INTO @DATA(max_orderid_draft). "draft table | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |"if max_orderid_draft > max_object_id | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |" max_object_id = max_orderid_draft. | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |"ENDIF. | TO  source_method_determ_object_id  ##no_text.

          APPEND cm && |MODIFY ENTITIES OF { io_rap_bo_node->rap_root_node_objects-behavior_definition_r } IN LOCAL MODE| TO  source_method_determ_object_id ##no_text.
          APPEND cm && |  ENTITY { io_rap_bo_node->entityname }| TO  source_method_determ_object_id ##no_text.
          APPEND cm && |    UPDATE FIELDS ( { io_rap_bo_node->object_id_cds_field_name } )| TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |      WITH VALUE #( FOR entity IN entities INDEX INTO i ( | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |      %tky          = entity-%tky | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |      { io_rap_bo_node->object_id_cds_field_name }     = max_object_id + i | TO  source_method_determ_object_id  ##no_text.
          APPEND cm && |) ). | TO  source_method_determ_object_id  ##no_text.

        ENDIF.

        lo_handler->implementation->add_method( CONV #( lv_determination_name ) )->set_source( source_method_determ_object_id ).
        handler_has_method = abap_true.


      WHEN ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.

        IF io_rap_bo_node->is_root(  ).
          DATA(lo_method) = lo_handler->definition->section-private->add_method( method_create ).
          lo_method->behavior_implementation->set_for_modify(  ).
          DATA(lo_import_parameter) = lo_method->add_importing_parameter( iv_name = 'entities' ).
          lo_import_parameter->behavior_implementation->set_for_create( iv_entity_name = | { io_rap_bo_node->entityname } | ).
          lo_handler->implementation->add_method( method_create ).
          handler_has_method = abap_true.
        ENDIF.

        lo_method = lo_handler->definition->section-private->add_method( method_update ).
        lo_method->behavior_implementation->set_for_modify(  ).
        lo_import_parameter = lo_method->add_importing_parameter( iv_name = 'entities' ).
        lo_import_parameter->behavior_implementation->set_for_update( iv_entity_name = | { io_rap_bo_node->entityname } | ).
        lo_handler->implementation->add_method( method_update ).
        handler_has_method = abap_true.

        lo_method = lo_handler->definition->section-private->add_method( method_delete ).
        lo_method->behavior_implementation->set_for_modify(  ).
        lo_import_parameter = lo_method->add_importing_parameter( iv_name = 'keys' ).
        lo_import_parameter->behavior_implementation->set_for_delete( iv_entity_name = | { io_rap_bo_node->entityname } | ).
        lo_handler->implementation->add_method( method_delete ).
        handler_has_method = abap_true.

        IF io_rap_bo_node->is_root(  ).
          lo_method = lo_handler->definition->section-private->add_method( method_lock ).
          lo_method->behavior_implementation->set_for_lock(  ).
          lo_import_parameter = lo_method->add_importing_parameter( iv_name = 'keys' ).
          lo_import_parameter->behavior_implementation->set_for_lock( iv_entity_name = | { io_rap_bo_node->entityname } | ).
          lo_handler->implementation->add_method( method_lock ).
          handler_has_method = abap_true.
        ENDIF.

        lo_method = lo_handler->definition->section-private->add_method( method_read ).
        lo_method->behavior_implementation->set_for_read( )->set_result( 'result' ).
        lo_import_parameter = lo_method->add_importing_parameter( iv_name = 'keys' ).
        lo_import_parameter->behavior_implementation->set_for_read( iv_entity_name = | { io_rap_bo_node->entityname } | ).
        lo_handler->implementation->add_method( method_read ).
        handler_has_method = abap_true.

        IF io_rap_bo_node->is_child(  ) = abap_true OR
           io_rap_bo_node->is_grand_child_or_deeper(  ) = abap_true.

          rba_method_name = |{ method_rba }_{ io_rap_bo_node->parent_node->entityname }|.
          lo_method = lo_handler->definition->section-private->add_method( rba_method_name ).
          lo_method->behavior_implementation->set_for_read(  )->set_result( 'result' )->set_link( 'association_links'  )->set_full( 'result_requested' ).
          lo_import_parameter = lo_method->add_importing_parameter( iv_name = |keys_{ method_rba } | ).
          lo_import_parameter->behavior_implementation->set_for_read( iv_entity_name = | { io_rap_bo_node->entityname }\\_{ io_rap_bo_node->parent_node->entityname } | ).
          lo_handler->implementation->add_method( rba_method_name ).
          handler_has_method = abap_true.

        ENDIF.

        LOOP AT io_rap_bo_node->childnodes INTO childnode.

          lo_method = lo_handler->definition->section-private->add_method( |{ method_cba }_{ childnode->entityname }| ).
          lo_method->behavior_implementation->set_for_modify(  ).
          lo_import_parameter = lo_method->add_importing_parameter( iv_name = |entities_{ method_cba } | ).
          lo_import_parameter->behavior_implementation->set_for_create( iv_entity_name = | { io_rap_bo_node->entityname }\\_{ childnode->entityname } | ).
          lo_handler->implementation->add_method( |{ method_cba }_{ childnode->entityname }| ).
          handler_has_method = abap_true.

          rba_method_name = |{ method_rba }_{ childnode->entityname }|.
          lo_method = lo_handler->definition->section-private->add_method( rba_method_name ).
          lo_method->behavior_implementation->set_for_read(  )->set_result( 'result' )->set_link( 'association_links'  )->set_full( 'result_requested' ).
          lo_import_parameter = lo_method->add_importing_parameter( iv_name = |keys_{ method_rba } | ).
          lo_import_parameter->behavior_implementation->set_for_read( iv_entity_name = | { io_rap_bo_node->entityname }\\_{ childnode->entityname } | ).
          lo_handler->implementation->add_method( rba_method_name ).
          handler_has_method = abap_true.

        ENDLOOP.

        IF io_rap_bo_node->is_root(  ).
          lo_saver = lo_specification->add_local_class( |LCL_{ io_rap_bo_node->rap_root_node_objects-behavior_definition_r }| ).
          lo_saver->definition->set_superclass( 'CL_ABAP_BEHAVIOR_SAVER' ).
          saver_has_method = abap_true.

          lo_saver->definition->section-protected->add_method( method_finalize )->set_redefinition( ).
          lo_saver->implementation->add_method( method_finalize ).

          lo_saver->definition->section-protected->add_method( method_check_before_save )->set_redefinition( ).
          lo_saver->implementation->add_method( method_check_before_save ).

          lo_saver->definition->section-protected->add_method( method_save )->set_redefinition( ).
          lo_saver->implementation->add_method( method_save ).

          lo_saver->definition->section-protected->add_method( method_cleanup )->set_redefinition( ).
          lo_saver->implementation->add_method( method_cleanup ).

          lo_saver->definition->section-protected->add_method( method_cleanup_finalize )->set_redefinition( ).
          lo_saver->implementation->add_method( method_cleanup_finalize ).
        ENDIF.
    ENDCASE.


    DATA(implementation) = lo_handler->implementation.

    DATA(definition) = lo_handler->definition.

    "remove implementation if no method is there
    IF handler_has_method = abap_false AND lo_handler IS NOT INITIAL.
      lo_specification->remove_local_class( local_handler_class_name ).
    ENDIF.
    IF saver_has_method = abap_false AND lo_saver IS NOT INITIAL.
      lo_specification->remove_local_class( local_saver_class_name ).
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

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = lv_control_structure_name.
    generated_repository_object-object_type = 'TABL'.
    APPEND generated_repository_object TO generated_repository_objects.

    DATA(lo_specification) = mo_put_operation->for-tabl-for-structure->add_object(  lv_control_structure_name
     )->set_package( mo_package
     )->create_form_specification( ).

    "create a view entity
    lo_specification->set_short_description( |Control structure for { io_rap_bo_node->rap_node_objects-alias }| ) ##no_text.

    LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_header_fields) WHERE  key_indicator  <> abap_true AND name IS NOT INITIAL.
      lo_specification->add_component( ls_header_fields-name
         )->set_type( xco_cp_abap_dictionary=>data_element( 'xsdboolean' ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD create_custom_entity.
**********************************************************************
** Begin of deletion 2020
**********************************************************************
    DATA ls_condition_components TYPE ts_condition_components.
    DATA lt_condition_components TYPE tt_condition_components.
    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .
    DATA pos TYPE i.

    DATA(lo_specification) = mo_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-custom_entity
     )->set_package( mo_package
     )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-custom_entity.
    generated_repository_object-object_type = 'DDLS'.
    APPEND generated_repository_object TO generated_repository_objects.

    "create a custom entity
    DATA(lo_view) = lo_specification->set_short_description( |CDS View for { io_rap_bo_node->rap_node_objects-alias  }|
      )->add_custom_entity( ) ##no_text.

    " Annotations can be added to custom entities.
    lo_view->add_annotation( 'ObjectModel.query.implementedBy' )->value->build( )->add_string( |ABAP:{ to_upper( io_rap_bo_node->rap_node_objects-custom_query_impl_class ) }| ).

    "@ObjectModel.query.implementedBy:'ABAP:ZDMO_CL_TRAVEL_UQ'

    "in contrast to MDE the annotations are not added to the specification but to the view
    add_annotation_ui_header(
      EXPORTING
        io_specification = lo_view
        io_rap_bo_node   = io_rap_bo_node
    ).



    "Client field does not need to be specified in client-specific CDS view

    CLEAR pos.

    LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_header_fields) WHERE  name  <> io_rap_bo_node->field_name-client . "   co_client.

      pos += 10.

      IF ls_header_fields-key_indicator = abap_true.
        lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-cds_view_field )
           )->set_key( ). "->set_alias(  ls_header_fields-cds_view_field  ).
      ELSE.
        lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-cds_view_field )
           ). "->set_alias( ls_header_fields-cds_view_field ).
      ENDIF.

      IF ls_header_fields-is_data_element = abap_true.
        lo_field->set_type( xco_cp_abap_dictionary=>data_element( ls_header_fields-data_element ) ).
      ENDIF.
      IF ls_header_fields-is_built_in_type = abAP_TRUE.
        lo_field->set_type( xco_cp_abap_dictionary=>built_in_type->for(
                                        iv_type     =  CONV #( ls_header_fields-built_in_type )
                                        iv_length   = ls_header_fields-built_in_type_length
                                        iv_decimals = ls_header_fields-built_in_type_decimals
                                        ) ).
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
        WHEN io_rap_bo_node->field_name-local_instance_last_changed_by.
          lo_field->add_annotation( 'Semantics.user.localInstanceLastChangedBy' )->value->build( )->add_boolean( abap_true ).
      ENDCASE.

      "add UI annotations

      "put facet annotation in front of the first field
      IF pos = 10.
        add_annotation_ui_facets(
          EXPORTING
            io_field       = lo_field
            io_rap_bo_node = io_rap_bo_node
        ).
      ENDIF.
      IF ls_header_fields-is_hidden = abap_true.
        add_anno_ui_hidden(
          EXPORTING
            io_field         = lo_field
            ls_header_fields = ls_header_fields
        ).
      ELSE.
        add_anno_ui_lineitem(
          EXPORTING
            io_field         = lo_field
            ls_header_fields = ls_header_fields
            position         = pos
        ).

        add_anno_ui_identification(
          EXPORTING
            io_field         = lo_field
            io_rap_bo_node   = io_rap_bo_node
            ls_header_fields = ls_header_fields
            position         = pos
        ).

        "add selection fields for semantic key fields or for the fields that are marked as object id
        add_annotation_ui_selectionfld(
          EXPORTING
            io_field         = lo_field
            io_rap_bo_node   = io_rap_bo_node
            ls_header_fields = ls_header_fields
            position         = pos
        ).

      ENDIF.

    ENDLOOP.

    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ELSE.

      CASE io_rap_bo_node->get_implementation_type(  ) .

        WHEN  ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic .

          CLEAR ls_condition_components.
          CLEAR lt_condition_components.

          LOOP AT io_rap_bo_node->parent_node->semantic_key INTO DATA(ls_semantic_key).
            ls_condition_components-association_name = '_' && io_rap_bo_node->parent_node->rap_node_objects-alias.
            ls_condition_components-association_field = ls_semantic_key-cds_view_field.
            ls_condition_components-projection_field = ls_semantic_key-cds_view_field.
            APPEND ls_condition_components TO lt_condition_components.
          ENDLOOP.

          DATA(lo_condition) = create_condition( lt_condition_components ).

      ENDCASE.

      lo_field = lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias ) ).
      lo_field->create_association( io_rap_bo_node->parent_node->rap_node_objects-custom_entity
       " )->set_cardinality( xco_cp_cds=>cardinality->one_to_n
        )->set_condition( lo_condition )->set_to_parent( ).

      IF io_rap_bo_node->is_grand_child_or_deeper(  ).

        CASE io_rap_bo_node->get_implementation_type(  ) .

          WHEN  ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic .

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

        lo_field = lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->root_node->rap_node_objects-alias ) ).
        lo_field->create_association( io_rap_bo_node->root_node->rap_node_objects-custom_entity
          )->set_cardinality( xco_cp_cds=>cardinality->one
          )->set_condition( lo_condition ).

      ENDIF.

    ENDIF.

    " Data source.

    IF io_rap_bo_node->has_childs(  ).   " create_item_objects(  ).
      " Composition.

      "change to a new property "childnodes" which only contains the direct childs
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).

        " Sample field with composition:
        lo_field = lo_view->add_field( xco_cp_ddl=>field( '_' && lo_childnode->rap_node_objects-alias ) ).
        lo_field->create_composition( lo_childnode->rap_node_objects-custom_entity
       )->set_cardinality( xco_cp_cds=>cardinality->zero_to_n ).



      ENDLOOP.

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

      lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_assocation-name ) ).

      DATA(lo_association) = lo_field->create_association( io_rap_bo_node->parent_node->rap_node_objects-cds_view_r
       " )->set_cardinality( xco_cp_cds=>cardinality->one_to_n
        )->set_condition( lo_condition ).

      CASE ls_assocation-cardinality .
        WHEN ZDMO_cl_rap_node=>cardinality-one.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->one ).
        WHEN ZDMO_cl_rap_node=>cardinality-one_to_n.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->one_to_n ).
        WHEN ZDMO_cl_rap_node=>cardinality-zero_to_n.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->zero_to_n ).
        WHEN ZDMO_cl_rap_node=>cardinality-zero_to_one.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->zero_to_one ).
        WHEN ZDMO_cl_rap_node=>cardinality-one_to_one.
          "@todo: currently association[1] will be generated
          "fix available with 2008 HFC2
          lo_association->set_cardinality( xco_cp_cds=>cardinality->range( iv_min = 1 iv_max = 1 ) ).
      ENDCASE.

    ENDLOOP.

    LOOP AT       io_rap_bo_node->lt_additional_fields INTO DATA(additional_fields) WHERE cds_restricted_reuse_view = abap_true.
      lo_field = lo_view->add_field( xco_cp_ddl=>expression->for( additional_fields-name ) ).
      IF additional_fields-cds_view_field IS NOT INITIAL.
        lo_Field->set_alias( additional_fields-cds_view_field ).
      ENDIF.
    ENDLOOP.
**********************************************************************
** End of deletion 2020
**********************************************************************
  ENDMETHOD.


  METHOD create_custom_query.


    DATA source_method_select TYPE if_xco_gen_clas_s_fo_i_method=>tt_source .

    DATA(lo_specification) = mo_put_operation->for-clas->add_object(  io_rap_bo_node->rap_node_objects-custom_query_impl_class
                                    )->set_package( mo_package
                                    )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-custom_query_impl_class.
    generated_repository_object-object_type = 'CLAS'.
    APPEND generated_repository_object TO generated_repository_objects.

    CLEAR source_method_select.

    APPEND |DATA business_data TYPE TABLE OF { io_rap_bo_node->rap_node_objects-custom_entity }.  | TO source_method_select ##no_text.
    APPEND |DATA query_result  TYPE TABLE OF { io_rap_bo_node->data_source_name }.  | TO source_method_select ##no_text.
    APPEND |DATA total_number_of_records type int8.| TO source_method_select ##no_text.
    APPEND |DATA(top)               = io_request->get_paging( )->get_page_size( ). | TO source_method_select ##no_text.
    APPEND |DATA(skip)              = io_request->get_paging( )->get_offset( ).| TO source_method_select ##no_text.
    APPEND |DATA(requested_fields)  = io_request->get_requested_elements( ).| TO source_method_select ##no_text.
    APPEND |DATA(sort_order)        = io_request->get_sort_elements( ).| TO source_method_select ##no_text.
    APPEND |TRY.| TO source_method_select ##no_text.
    APPEND | DATA(filter_condition) = io_request->get_filter( )->get_as_ranges( ).| TO source_method_select ##no_text.
    APPEND | DATA(filter_string) = io_request->get_filter( )->get_as_sql_string( ).| TO source_method_select ##no_text.
    APPEND | "Here you have to implement your custom query| TO source_method_select ##no_text.
    APPEND | "and store the result in the internal table query_result| TO source_method_select ##no_text.
    IF io_rap_bo_node->lt_mapping IS NOT INITIAL.
      APPEND | business_data = CORRESPONDING #( query_result MAPPING| TO source_method_select ##no_text.
      LOOP AT io_rap_bo_node->lt_mapping INTO DATA(mapping_line).
        APPEND | { mapping_line-cds_view_field } = { mapping_line-dbtable_field }| TO source_method_select ##no_text.
      ENDLOOP.
      APPEND |  ).| TO source_method_select ##no_text.
    ENDIF.

    APPEND |   | TO source_method_select ##no_text.

    APPEND | IF top IS NOT INITIAL and top > 0.| TO source_method_select ##no_text.
    APPEND |   DATA(max_index) = top + skip.| TO source_method_select ##no_text.
    APPEND | ELSE. | TO source_method_select ##no_text.
    APPEND |   max_index = 0. | TO source_method_select ##no_text.
    APPEND | ENDIF. | TO source_method_select ##no_text.
    APPEND | | TO source_method_select ##no_text.
    APPEND | SELECT * FROM @business_data AS data_source_fields | TO source_method_select ##no_text.
    APPEND |    WHERE (filter_string)| TO source_method_select ##no_text.
    APPEND |    INTO TABLE @business_data| TO source_method_select ##no_text.
    APPEND |    UP TO @max_index ROWS.| TO source_method_select ##no_text.
    APPEND | | TO source_method_select ##no_text.
    APPEND |   | TO source_method_select ##no_text.
    APPEND | IF skip IS NOT INITIAL. | TO source_method_select ##no_text.
    APPEND |   DELETE business_data TO skip.| TO source_method_select ##no_text.
    APPEND | ENDIF.  | TO source_method_select ##no_text.
    APPEND |   | TO source_method_select ##no_text.

    APPEND | IF io_request->is_total_numb_of_rec_requested(  ).| TO source_method_select ##no_text.
    APPEND |   io_response->set_total_number_of_records( lines( business_data ) ).| TO source_method_select ##no_text.
    APPEND | ENDIF.| TO source_method_select ##no_text.
    APPEND | io_response->set_data( business_data ).| TO source_method_select ##no_text.
    APPEND |CATCH cx_root INTO DATA(exception).| TO source_method_select ##no_text.
    APPEND |DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).| TO source_method_select ##no_text.
    APPEND |ENDTRY.| TO source_method_select ##no_text.



    lo_specification->set_short_description( 'Custom query implementation' ) ##no_text.
    lo_specification->definition->add_interface( 'if_rap_query_provider' ).
    lo_specification->implementation->add_method( |if_rap_query_provider~select|
      )->set_source( source_method_select ) ##no_text.


  ENDMETHOD.


  METHOD create_draft_query_view.
    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .

    DATA(lo_specification) = mo_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-draft_query_view
     )->set_package( mo_package
     )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-draft_query_view.
    generated_repository_object-object_type = 'DDLS'.
    APPEND generated_repository_object TO generated_repository_objects.

    "create a view entity
    DATA(lo_view) = lo_specification->set_short_description( |Draft query view for { io_rap_bo_node->rap_node_objects-alias  }|
      )->add_view_entity( ) ##no_text.

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'NOT_REQUIRED' ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Draft query view for ' && io_rap_bo_node->rap_node_objects-alias ) ##no_text.
    lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->draft_table_name ) ).
    "add alias
    lo_view->data_source->set_alias( io_rap_bo_node->entityname ).

    DATA(viewEnhancementCategoryAnno) = lo_view->add_annotation( 'AbapCatalog.viewEnhancementCategory' )->value->build( )->begin_array(  ).
    viewEnhancementCategoryAnno->add_enum( 'PROJECTION_LIST' ).
    viewEnhancementCategoryAnno->end_array(  ).

    add_anno_abap_catalog_ext(
      io_view               = lo_view
      i_allownewdatasources = abap_false
      i_allownewcompositions = abap_false
      i_elementsuffix       = io_rap_bo_node->extensibility_element_suffix
      i_datasources         = io_rap_bo_node->entityname
      i_maximumfields       = 100
    ).

*    DATA(lo_valuebuilder) = lo_view->add_annotation( 'AbapCatalog.extensibility' )->value->build( ).
*
*    DATA(lo_record) = lo_valuebuilder->begin_record(
*        )->add_member( 'extensible' )->add_boolean( abap_true
*        )->add_member( 'elementSuffix' )->add_string( 'ZAA'
*        )->add_member( 'allowNewDatasources' )->add_boolean( abap_false
*        ).
*
*    lo_record->add_member( 'dataSources' )->begin_array(  )->add_string( CONV #( io_rap_bo_node->entityname ) )->end_array( ).
*    DATA(quota) = lo_record->add_member( 'quota' )->begin_record( ).
*    quota->add_member( 'maximumFields' )->add_number( 100 ).
*    quota->add_member( 'maximumBytes' )->add_number( 10000 ).
*    quota->end_record(  ).
*
*    lo_valuebuilder->end_record( ).




    LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_header_fields) WHERE name  <> io_rap_bo_node->field_name-client
                                                                       AND key_indicator = abap_true . "   co_client.

      lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-cds_view_field )
               )->set_key( ).
      lo_Field->set_alias( ls_header_fields-cds_view_field ).

    ENDLOOP.

    LOOP AT io_rap_bo_node->lt_fields  INTO  ls_header_fields WHERE name  <> io_rap_bo_node->field_name-client
                                                                AND key_indicator = abap_false . "   co_client.

      lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-cds_view_field ) ).
      lo_Field->set_alias( ls_header_fields-cds_view_field ).

    ENDLOOP.

*      draftentitycreationdatetime   as Draftentitycreationdatetime,
*      draftentitylastchangedatetime as Draftentitylastchangedatetime,
*      draftadministrativedatauuid   as Draftadministrativedatauuid,
*      draftentityoperationcode      as Draftentityoperationcode,
*      hasactiveentity               as Hasactiveentity,
*      draftfieldchanges             as Draftfieldchanges,
*      dummy_field                   as DummyField
    lo_field = lo_view->add_field( xco_cp_ddl=>field( 'draftentitycreationdatetime' ) )->set_alias( 'Draftentitycreationdatetime' ).
    lo_field = lo_view->add_field( xco_cp_ddl=>field( 'draftentitylastchangedatetime' ) )->set_alias( 'Draftentitylastchangedatetime' ).
    lo_field = lo_view->add_field( xco_cp_ddl=>field( 'draftadministrativedatauuid' ) )->set_alias( 'Draftadministrativedatauuid' ).
    lo_field = lo_view->add_field( xco_cp_ddl=>field( 'draftentityoperationcode' ) )->set_alias( 'Draftentityoperationcode' ).
    lo_field = lo_view->add_field( xco_cp_ddl=>field( 'hasactiveentity' ) )->set_alias( 'Hasactiveentity' ).
    lo_field = lo_view->add_field( xco_cp_ddl=>field( 'draftfieldchanges' ) )->set_alias( 'Draftfieldchanges' ).

    "dummy field should not be part of the draft query view
    "lo_field = lo_view->add_field( xco_cp_ddl=>field( 'dummy_field' ) )->set_alias( 'DummyField' ).



  ENDMETHOD.


  METHOD create_extension_include.

    DATA lv_extension_include_name TYPE sxco_ad_object_name .
    lv_extension_include_name = to_upper( io_rap_bo_node->rap_node_objects-extension_include ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.

    generated_repository_object-object_name = lv_extension_include_name.
    generated_repository_object-object_type = 'STRU'.
    APPEND generated_repository_object TO generated_repository_objects.

    "extension include must be added to draft table
    "hence both objects have to be generated at the same time

    DATA(lo_specification) = mo_draft_tabl_put_operation->for-tabl-for-structure->add_object(  lv_extension_include_name
     )->set_package( mo_package
     )->create_form_specification( ).

    "create a view entity
    lo_specification->set_short_description( |Extension include for { io_rap_bo_node->rap_node_objects-alias }| ) ##no_text.

    lo_specification->add_component( zdmo_cl_rap_node=>dummy_field_name " 'dummy_field'
       )->set_type( xco_cp_abap_dictionary=>built_in_type->char( 1 ) ).

*    lo_specification->add_annotation( 'EndUserText.label' )->value->build(  )->add_s( iv_value =  abap_true ).

    set_struct_enhancement_cat_any( lo_specification  ).

*public instance method  set_enhancement_category
*public instance method  set_field_suffix
*public instance method  set_quota_maximum_bytes
*public instance method  set_quota_maximum_fields

*@AbapCatalog.enhancement.fieldSuffix : 'ZZG'
*@AbapCatalog.enhancement.quotaMaximumFields : 500
*@AbapCatalog.enhancement.quotaMaximumBytes : 8160
    IF xco_api->on_premise_branch_is_used(  ).
      method_exists_in_interface-interface_name = 'if_xco_gen_tabl_str_s_form '.
    ELSE.
      method_exists_in_interface-interface_name = 'if_xco_cp_gen_tabl_str_s_form '.
    ENDIF.
    method_exists_in_interface-method_name    = 'SET_FIELD_SUFFIX'.
    IF xco_api->method_exists_in_interface(
            interface_name = method_exists_in_interface-interface_name
            method_name    = method_exists_in_interface-method_name
          ).
      CALL METHOD lo_specification->(method_exists_in_interface-method_name)
        EXPORTING
          iv_field_suffix = CONV char3( io_rap_bo_node->extensibility_element_suffix ).
    ENDIF.
    method_exists_in_interface-method_name    = 'SET_QUOTA_MAXIMUM_BYTES'.
    IF xco_api->method_exists_in_interface(
            interface_name = method_exists_in_interface-interface_name
            method_name    = method_exists_in_interface-method_name
          ).
      CALL METHOD lo_specification->(method_exists_in_interface-method_name)
        EXPORTING
          iv_quota_maximum_bytes = 8160.
    ENDIF.
    method_exists_in_interface-method_name    = 'SET_QUOTA_MAXIMUM_FIELDS'.
    IF xco_api->method_exists_in_interface(
            interface_name = method_exists_in_interface-interface_name
            method_name    = method_exists_in_interface-method_name
          ).
      CALL METHOD lo_specification->(method_exists_in_interface-method_name)
        EXPORTING
          iv_quota_maximum_fields = 500.
    ENDIF.

  ENDMETHOD.


  METHOD create_extension_include_view.

    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .

    DATA(lo_specification) = mo_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-extension_include_view
     )->set_package( mo_package
     )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-extension_include_view.
    generated_repository_object-object_type = 'DDLS'.
    APPEND generated_repository_object TO generated_repository_objects.

    "create a view entity
    DATA(lo_view) = lo_specification->set_short_description( |Extension include view for { io_rap_bo_node->rap_node_objects-alias  }|
      )->add_view_entity( ) ##no_text.

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'NOT_REQUIRED' ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Extension include view for ' && io_rap_bo_node->rap_node_objects-alias ) ##no_text.
    lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->table_name ) ).
    "add alias
    lo_view->data_source->set_alias( io_rap_bo_node->entityname ).

    DATA(viewEnhancementCategoryAnno) = lo_view->add_annotation( 'AbapCatalog.viewEnhancementCategory' )->value->build( )->begin_array(  ).
    viewEnhancementCategoryAnno->add_enum( 'PROJECTION_LIST' ).
    viewEnhancementCategoryAnno->end_array(  ).

*    DATA(lo_valuebuilder) = lo_view->add_annotation( 'AbapCatalog.extensibility' )->value->build( ).
*
*    DATA(lo_record) = lo_valuebuilder->begin_record(
*        )->add_member( 'extensible' )->add_boolean( abap_true
*        )->add_member( 'elementSuffix' )->add_string( 'ZAA'
*        )->add_member( 'allowNewDatasources' )->add_boolean( abap_false
*        ).
*
*    lo_record->add_member( 'dataSources' )->begin_array(  )->add_string( CONV #( io_rap_bo_node->entityname ) )->end_array( ).
*    DATA(quota) = lo_record->add_member( 'quota' )->begin_record( ).
*    quota->add_member( 'maximumFields' )->add_number( 100 ).
*    quota->add_member( 'maximumBytes' )->add_number( 10000 ).
*    quota->end_record(  ).
*
*    lo_valuebuilder->end_record( ).

    add_anno_abap_catalog_ext(
      io_view               = lo_view
      i_allownewdatasources = abap_false
      i_allownewcompositions = abap_false
      i_elementsuffix       = io_rap_bo_node->extensibility_element_suffix
      i_datasources         = io_rap_bo_node->entityname
      i_maximumfields       = 100
    ).


    LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_header_fields) WHERE name  <> io_rap_bo_node->field_name-client
                                                                       AND key_indicator = abap_true . "   co_client.

      lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-name )
               )->set_key( ).
      lo_Field->set_alias( ls_header_fields-cds_view_field ).

    ENDLOOP.

  ENDMETHOD.


  METHOD create_for_cloud_development.
    result = NEW #( json_string = json_string
                    xco_lib     = NEW ZDMO_cl_rap_xco_cloud_lib( ) ).
  ENDMETHOD.


  METHOD create_for_on_prem_development.
    result = NEW #( json_string = json_string
                    xco_lib     = NEW ZDMO_cl_rap_xco_on_prem_lib( ) ).
  ENDMETHOD.


  METHOD create_i_cds_view.

    DATA(lo_specification) = mo_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_i
     )->set_package( mo_package
     )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-cds_view_i.
    generated_repository_object-object_type = 'DDLS'.
    APPEND generated_repository_object TO generated_repository_objects.

    DATA(lo_view) = lo_specification->set_short_description( |Interface Projection View for { io_rap_bo_node->rap_node_objects-alias }|
      )->add_projection_view( )
       ##no_text.

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Projection View for ' && io_rap_bo_node->rap_node_objects-alias ) ##no_text.

    "add @AbapCatalog.extensibility annotations
    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      add_anno_abap_catalog_ext(
          io_view               = lo_view
          i_allownewdatasources = abap_false
          i_allownewcompositions = abap_true
          i_elementsuffix       = io_rap_bo_node->extensibility_element_suffix
          i_datasources         = io_rap_bo_node->entityname
          i_maximumfields       = 100
        ).
    ENDIF.

    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ENDIF.

    IF io_rap_bo_node->is_root(  ) = abap_true.
      cds_i_view_set_provider_cntrct( lo_view ).
    ENDIF.

    " set data source.
    lo_view->data_source->set_view_entity( iv_view_entity = io_rap_bo_node->rap_node_objects-cds_view_r ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields) WHERE name  <> io_rap_bo_node->field_name-client.
      DATA(lo_field) = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-cds_view_field ) ).
      IF ls_header_fields-key_indicator = abap_true  .
        lo_field->set_key(  ).
      ENDIF.
    ENDLOOP.

    "add compositions to child nodes
    IF io_rap_bo_node->has_childs(  ).
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).
        lo_view->add_field( xco_cp_ddl=>field( '_' && lo_childnode->rap_node_objects-alias ) )->set_redirected_to_compos_child( lo_childnode->rap_node_objects-cds_view_i ).
      ENDLOOP.
    ENDIF.

    "publish association to parent
    IF io_rap_bo_node->is_root(  ) = abap_false.
      lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias ) )->set_redirected_to_parent( io_rap_bo_node->parent_node->rap_node_objects-cds_view_i ).
    ENDIF.

    "for grand-child nodes we have to add an association to the root node
    IF io_rap_bo_node->is_grand_child_or_deeper(  ).
      lo_view->add_field( xco_cp_ddl=>field( '_' && io_rap_bo_node->root_node->rap_node_objects-alias ) )->set_redirected_to( io_rap_bo_node->root_node->rap_node_objects-cds_view_i ).
    ENDIF.

    "publish associations
    LOOP AT io_rap_bo_node->lt_association INTO DATA(ls_assocation).
      lo_view->add_field( xco_cp_ddl=>field( ls_assocation-name ) ).
    ENDLOOP.

    "add additional fields
    LOOP AT       io_rap_bo_node->lt_additional_fields INTO DATA(additional_fields) WHERE cds_interface_view = abap_true.
      lo_field = lo_view->add_field( xco_cp_ddl=>expression->for( CONV #( additional_fields-cds_view_field ) )  ).
      IF additional_fields-localized = abap_true.
        lo_Field->set_localized( abap_true ).
      ENDIF.
    ENDLOOP.

    "add alias
    lo_view->data_source->set_alias( io_rap_bo_node->entityname ).

  ENDMETHOD.


  METHOD create_i_cds_view_basic.

    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .

    DATA(lo_specification) = mo_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_i_basic
        )->set_package( mo_package
        )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-cds_view_i_basic.
    generated_repository_object-object_type = 'DDLS'.
    APPEND generated_repository_object TO generated_repository_objects.

    DATA(lo_view) = lo_specification->set_short_description( |Basic Interface View for { io_rap_bo_node->rap_node_objects-alias }|
      )->add_view_entity( ) ##no_text.
    ##no_text.

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Basic Interface View for ' && io_rap_bo_node->rap_node_objects-alias ) ##no_text.


    " set data source.
*    lo_view->data_source->set_view_entity( iv_view_entity = io_rap_bo_node->rap_node_objects- ).
    lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->table_name ) ).

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
        WHEN io_rap_bo_node->field_name-local_instance_last_changed_by.
          lo_field->add_annotation( 'Semantics.user.localInstanceLastChangedBy' )->value->build( )->add_boolean( abap_true ).
      ENDCASE.

    ENDLOOP.

    "add alias
    lo_view->data_source->set_alias( io_rap_bo_node->entityname ).


  ENDMETHOD.


  METHOD create_mde_view.

    DATA pos TYPE i VALUE 0.
    DATA lo_field TYPE REF TO if_xco_gen_ddlx_s_fo_field .

    DATA(lo_specification) = mo_put_operation->for-ddlx->add_object(  io_rap_bo_node->rap_node_objects-meta_data_extension " cds_view_p " mo_p_cds_header
      )->set_package( mo_package
      )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name =  io_rap_bo_node->rap_node_objects-meta_data_extension.
    generated_repository_object-object_type = 'DDLX'.
    APPEND generated_repository_object TO generated_repository_objects.

    lo_specification->set_short_description( |MDE for { io_rap_bo_node->rap_node_objects-alias }|
      )->set_layer( xco_cp_metadata_extension=>layer->customer
      )->set_view( io_rap_bo_node->rap_node_objects-cds_view_p ) ##no_text. " cds_view_p ).

    "begin_array --> square bracket open
    "Begin_record-> curly bracket open

    add_annotation_ui_header(
      EXPORTING
        io_specification = lo_specification
        io_rap_bo_node   = io_rap_bo_node
    ).

    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_all_fields INTO  DATA(ls_header_fields) WHERE name <> io_rap_bo_node->field_name-client.

      pos += 10.

      lo_field = lo_specification->add_field( ls_header_fields-cds_view_field ).

      "put facet annotation in front of the first field
      IF pos = 10.
        add_annotation_ui_facets(
          EXPORTING
            io_field       = lo_field
            io_rap_bo_node = io_rap_bo_node
        ).
      ENDIF.

      IF ls_header_fields-is_hidden = abap_true.

        add_anno_ui_hidden(
          EXPORTING
            io_field         = lo_field
            ls_header_fields = ls_header_fields
        ).

      ELSE.

        add_anno_ui_lineitem(
          EXPORTING
            io_field         = lo_field
            ls_header_fields = ls_header_fields
            position         = pos
        ).

        add_anno_ui_identification(
          EXPORTING
            io_field         = lo_field
            io_rap_bo_node   = io_rap_bo_node
            ls_header_fields = ls_header_fields
            position         = pos
        ).

        "add selection fields for semantic key fields or for the fields that are marked as object id
        add_annotation_ui_selectionfld(
          EXPORTING
            io_field         = lo_field
            io_rap_bo_node   = io_rap_bo_node
            ls_header_fields = ls_header_fields
            position         = pos
        ).
      ENDIF.
    ENDLOOP.




  ENDMETHOD.


  METHOD create_p_cds_view.

    DATA fuzzinessThreshold TYPE p LENGTH 3 DECIMALS 2.
    fuzzinessthreshold = 9 / 10.

    DATA(lo_specification) = mo_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_p
     )->set_package( mo_package
     )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-cds_view_p.
    generated_repository_object-object_type = 'DDLS'.
    APPEND generated_repository_object TO generated_repository_objects.


    DATA(lo_view) = lo_specification->set_short_description( |Projection View for { io_rap_bo_node->rap_node_objects-alias }|
      )->add_projection_view( )
       ##no_text.

    " Annotations.
    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Projection View for ' && io_rap_bo_node->rap_node_objects-alias ) ##no_text.

    "add @AbapCatalog.extensibility annotations
    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      add_anno_abap_catalog_ext(
          io_view               = lo_view
          i_allownewdatasources = abap_false
          i_allownewcompositions = abap_true
          i_elementsuffix       = io_rap_bo_node->extensibility_element_suffix
          i_datasources         = io_rap_bo_node->entityname
          i_maximumfields       = 100
        ).
    ENDIF.

    "@ObjectModel.semanticKey: ['HolidayAllID']
    IF io_rap_bo_node->mimic_adt_wizard = abap_false.
      DATA(semantic_key) = lo_view->add_annotation( 'ObjectModel.semanticKey' )->value->build( )->begin_array(  ).
      semantic_key->add_string( CONV #( io_rap_bo_node->object_id_cds_field_name ) ).
      semantic_key->end_array(  ).

      lo_view->add_annotation( 'Search.searchable' )->value->build( )->add_boolean( abap_true ) ##no_text.
    ENDIF.

    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ENDIF.

    IF io_rap_bo_node->is_root(  ) = abap_true.
      cds_p_view_set_provider_cntrct( lo_View  ).
    ENDIF.

    " Data source.
    lo_view->data_source->set_view_entity( iv_view_entity = io_rap_bo_node->rap_node_objects-cds_view_r ).


    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields) WHERE name  <> io_rap_bo_node->field_name-client.

      DATA(lo_field) = lo_view->add_field( xco_cp_ddl=>field(  ls_header_fields-cds_view_field   )
         ). "->set_alias(  ls_header_fields-cds_view_field   ).

      IF ls_header_fields-key_indicator = abap_true  .
        lo_field->set_key(  ).
      ENDIF.

      "skip setting of additional annotations if we have to mimic the
      "behavior of the ADT based generator

      IF io_rap_bo_node->mimic_adt_wizard = abap_false.

        IF ls_header_fields-key_indicator = abap_true  .
          IF io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-managed_semantic OR
             io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-unmanaged_semantic.
            lo_field->add_annotation( 'Search.defaultSearchElement' )->value->build( )->add_boolean( abap_true ).
            lo_field->add_annotation( 'Search.fuzzinessThreshold' )->value->build( )->add_number( iv_value = fuzzinessThreshold ).
          ENDIF.
        ENDIF.

        CASE ls_header_fields-name.
          WHEN io_rap_bo_node->object_id.
            IF ls_header_fields-key_indicator = abap_false.
              lo_field->add_annotation( 'Search.defaultSearchElement' )->value->build( )->add_boolean( abap_true ).
              lo_field->add_annotation( 'Search.fuzzinessThreshold' )->value->build( )->add_number( iv_value = fuzzinessThreshold ).
            ENDIF.
        ENDCASE.

        "add @Semantics annotation once available
        IF ls_header_fields-currencycode IS NOT INITIAL.
          READ TABLE io_rap_bo_node->lt_fields INTO DATA(ls_field) WITH KEY name = ls_header_fields-currencycode.
          IF sy-subrc = 0.
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

        "has to be set in 2102
        "can be omitted later
        IF ls_header_fields-is_unitofmeasure = abap_true.
          lo_field->add_annotation( 'Semantics.unitOfMeasure' )->value->build( )->add_boolean( abap_true ).
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

            "use for validation will be set to true for
            "currencycode and unitofmeasture fields

            IF ls_valuehelp-useforvalidation = abap_true.
              lo_valuebuilder->add_member( 'useForValidation' )->add_boolean( abap_true ).
            ENDIF.

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

            lo_valuebuilder->end_record( )->end_array( ).

          ENDIF.

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


    "publish associations

    LOOP AT io_rap_bo_node->lt_association INTO DATA(ls_assocation).
      lo_view->add_field( xco_cp_ddl=>field( ls_assocation-name ) ).
    ENDLOOP.


    LOOP AT       io_rap_bo_node->lt_additional_fields INTO DATA(additional_fields) WHERE cds_projection_view = abap_true.

      lo_field = lo_view->add_field( xco_cp_ddl=>expression->for( CONV #( additional_fields-cds_view_field ) )  ).

      IF additional_fields-localized = abap_true.
        lo_Field->set_localized( abap_true ).
      ENDIF.
    ENDLOOP.

    "add alias
    lo_view->data_source->set_alias( io_rap_bo_node->entityname ).

  ENDMETHOD.


  METHOD create_r_cds_view.

    DATA ls_condition_components TYPE ts_condition_components.
    DATA lt_condition_components TYPE tt_condition_components.
    DATA lo_field TYPE REF TO if_xco_gen_ddls_s_fo_field .

    DATA(lo_specification) = mo_put_operation->for-ddls->add_object( io_rap_bo_node->rap_node_objects-cds_view_r
     )->set_package( mo_package
     )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-cds_view_r.
    generated_repository_object-object_type = 'DDLS'.
    APPEND generated_repository_object TO generated_repository_objects.

    "create a view entity
    DATA(lo_view) = lo_specification->set_short_description( |CDS View for { io_rap_bo_node->rap_node_objects-alias  }|
      )->add_view_entity( ) ##no_text.

    "create a normal CDS view with DDIC view
    "maybe needed in order to generate code for a 1909 system
    "DATA(lo_view) = lo_specification->set_short_description( 'CDS View for ' &&  io_rap_bo_node->rap_node_objects-alias "mo_alias_header
    "   )->add_view( ).

    " Annotations.
    " lo_view->add_annotation( 'AbapCatalog' )->value->build( )->begin_record(
    "   )->add_member( 'sqlViewName' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-ddic_view_i ) "mo_view_header )
    "   )->add_member( 'compiler.compareFilter' )->add_boolean( abap_true
    "   )->add_member( 'preserveKey' )->add_boolean( abap_true
    "   )->end_record( ).

    lo_view->add_annotation( 'AccessControl.authorizationCheck' )->value->build( )->add_enum( 'CHECK' ).
    lo_view->add_annotation( 'Metadata.allowExtensions' )->value->build( )->add_boolean( abap_true ).
    lo_view->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'CDS View for ' && io_rap_bo_node->rap_node_objects-alias ) ##no_text. " mo_alias_header ).

    "@ObjectModel.sapObjectNodeType.name : 'ZAF_SALESORDER_01'
    IF io_rap_bo_node->add_sap_object_type = abap_true.
      lo_view->add_annotation( 'ObjectModel.sapObjectNodeType.name' )->value->build( )->add_string( CONV #( io_rap_bo_node->rap_node_objects-sap_object_node_type ) ) ##no_text. " mo_alias_header ).
    ENDIF.

    IF io_rap_bo_node->is_root( ).
      lo_view->set_root( ).
    ELSE.

      CASE io_rap_bo_node->get_implementation_type(  ) .
        WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.

          DATA(parent_uuid_cds_field_name) = io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-parent_uuid ]-cds_view_field.
          DATA(uuid_cds_field_name_in_parent) = io_rap_bo_node->parent_node->lt_fields[ name = io_rap_bo_node->parent_node->field_name-uuid ]-cds_view_field.

          DATA(lo_condition) = xco_cp_ddl=>field( parent_uuid_cds_field_name )->of_projection( )->eq(
            xco_cp_ddl=>field( uuid_cds_field_name_in_parent )->of( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias ) ).




        WHEN  ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic OR ZDMO_cl_rap_node=>implementation_type-managed_semantic.

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

      "@todo - raise an exception when being initial
      IF lo_condition IS NOT INITIAL.

        lo_view->add_association( io_rap_bo_node->parent_node->rap_node_objects-cds_view_r )->set_to_parent(
    )->set_alias( '_' && io_rap_bo_node->parent_node->rap_node_objects-alias
    )->set_condition( lo_condition ).

      ENDIF.



      IF io_rap_bo_node->is_grand_child_or_deeper(  ).

        CASE io_rap_bo_node->get_implementation_type(  ) .
          WHEN ZDMO_cl_rap_node=>implementation_type-managed_uuid.

            DATA(root_uuid_cds_field_name) = io_rap_bo_node->lt_fields[ name = io_rap_bo_node->field_name-root_uuid ]-cds_view_field.
            DATA(uuid_cds_field_name_in_root) = io_rap_bo_node->root_node->lt_fields[ name = io_rap_bo_node->root_node->field_name-uuid ]-cds_view_field.

            lo_condition = xco_cp_ddl=>field( root_uuid_cds_field_name )->of_projection( )->eq(
              xco_cp_ddl=>field( uuid_cds_field_name_in_root )->of( '_' && io_rap_bo_node->root_node->rap_node_objects-alias ) ).



          WHEN  ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic OR ZDMO_cl_rap_node=>implementation_type-managed_semantic.

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

        IF lo_condition IS NOT INITIAL.
          lo_view->add_association( io_rap_bo_node->root_node->rap_node_objects-cds_view_r
            )->set_alias( '_' && io_rap_bo_node->root_node->rap_node_objects-alias
            )->set_cardinality(  xco_cp_cds=>cardinality->one
            )->set_condition( lo_condition ).
        ENDIF.

        "@todo add an association that uses the singleton_id
        "association [1]    to zfcal_I_CALM_ALL    as _HolidayAll     on $projection.HolidayAllID = _HolidayAll.HolidayAllID


      ENDIF.

    ENDIF.

    " Data source.
    CASE io_rap_bo_node->data_source_type.
      WHEN io_rap_bo_node->data_source_types-table.
        IF io_rap_bo_node->add_basic_i_views = abap_true.
          lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->rap_node_objects-cds_view_i_basic ) ).
        ELSE.
          lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->table_name ) ).
        ENDIF.
      WHEN io_rap_bo_node->data_source_types-cds_view.
        lo_view->data_source->set_view_entity( CONV #( io_rap_bo_node->cds_view_name ) ).
    ENDCASE.

*    "add alias
*    lo_view->data_source->set_alias( io_rap_bo_node->entityname ).

    IF io_rap_bo_node->is_virtual_root(  ) = abap_true.
      "add the following statement
      "left outer join zcarrier_002 as carr on 0 = 0
      "   data(left_outer_join) = lo_view->data_source->add_left_outer_join( io_data_source = io_rap_bo_node->childnodes[ 1 ]->data_source_name ).

      " Association.
      DATA(condition) = xco_cp_ddl=>field( '0' )->eq( xco_cp_ddl=>field( '0' ) ).
      "DATA(cardinality) = xco_cp_cds=>cardinality->range( iv_min = 1 iv_max = 1 ).

      DATA mo_data_source  TYPE REF TO if_xco_ddl_expr_data_source  .
      "mo_data_source = .

      DATA(left_outer_join) = lo_view->data_source->add_left_outer_join( xco_cp_ddl=>data_source->database_table( CONV #( root_node->childnodes[ 1 ]->data_source_name ) )->set_alias( CONV #( root_node->singleton_child_tab_name ) ) ).

      "@todo - add code after HFC2 2008 has been applied
      left_outer_join->set_condition( condition ).

      lo_view->set_where( xco_cp_ddl=>field( 'I_Language.Language' )->eq( xco_cp_ddl=>expression->for( '$session.system_language' ) ) ).

    ENDIF.

    IF io_rap_bo_node->has_childs(  ).   " create_item_objects(  ).
      " Composition.

      "change to a new property "childnodes" which only contains the direct childs
      LOOP AT io_rap_bo_node->childnodes INTO DATA(lo_childnode).

        lo_view->add_composition( lo_childnode->rap_node_objects-cds_view_r "  mo_i_cds_item
          )->set_cardinality( xco_cp_cds=>cardinality->zero_to_n
          )->set_alias( '_' && lo_childnode->rap_node_objects-alias ). " mo_alias_item ).

      ENDLOOP.

    ENDIF.

    "Client field does not need to be specified in client-specific CDS view
    LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_header_fields) WHERE  name  <> io_rap_bo_node->field_name-client . "   co_client.

      IF io_rap_bo_node->add_basic_i_views = abap_true.
        IF ls_header_fields-key_indicator = abap_true.
          lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-cds_view_field )
             )->set_key( ).
        ELSE.
          lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-cds_view_field )
             ).
        ENDIF.
      ELSE.
        IF ls_header_fields-key_indicator = abap_true.
          lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-name )
             )->set_key( )->set_alias(  ls_header_fields-cds_view_field  ).
        ELSE.
          lo_field = lo_view->add_field( xco_cp_ddl=>field( ls_header_fields-name )
             )->set_alias( ls_header_fields-cds_view_field ).
        ENDIF.
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
        WHEN io_rap_bo_node->field_name-local_instance_last_changed_by.
          lo_field->add_annotation( 'Semantics.user.localInstanceLastChangedBy' )->value->build( )->add_boolean( abap_true ).
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

    "@todo
    "add association if RAP BO is extensible
    "association [1]    to ZRAP625E_SalesOrder_001 as _Extension on $projection.HeaderUUID = _Extension.HeaderUUID
    "reuse condition

    "add entries to lt_association for the above mentioned association

*      IF io_rap_bo_node->is_extensible( ) = abAP_TRUE.
*        lo_view->add_association( io_rap_bo_node->rap_node_objects-extension_include
*            )->set_alias( '_' && io_rap_bo_node->extension_association_name
*            )->set_condition( lo_condition ).
*        add_anno_abap_catalog_ext(
*          io_view               = lo_view
*          i_allownewdatasources = abap_false
*          i_elementsuffix       = io_rap_bo_node->extensibility_element_suffix
*          i_datasources         = '_' && io_rap_bo_node->extension_association_name
*          i_maximumfields       = 100
*        ).
*
*      ENDIF.
    IF io_rap_bo_node->is_extensible( ) = abAP_TRUE.

      DATA extension_assocation TYPE zdmo_cl_rap_node=>ts_assocation  .
      CLEAR ls_condition_components.
      CLEAR lt_condition_components.
      DATA ext_condition_component TYPE zdmo_cl_rap_node=>ts_condition_fields.
      DATA ext_condition_components TYPE zdmo_cl_rap_node=>tt_condition_fields .

      LOOP AT io_rap_bo_node->lt_fields  INTO  DATA(ls_key_fields) WHERE  name  <> io_rap_bo_node->field_name-client
                                                                     AND  key_indicator = abap_true. "   co_client.
        ext_condition_component-association_field = ls_key_fields-cds_view_field.
        ext_condition_component-projection_field = ls_key_fields-cds_view_field.
*        ls_condition_components-association_name = io_rap_bo_node->extension_association_name.
        APPEND ext_condition_component TO ext_condition_components.
      ENDLOOP.

      extension_assocation-cardinality = ZDMO_cl_rap_node=>cardinality-one.
      extension_assocation-name = '_' && io_rap_bo_node->extension_association_name.
      extension_assocation-target = io_rap_bo_node->rap_node_objects-extension_include_view.
      extension_assocation-condition_components = ext_condition_components.

*      append extension_assocation to io_rap_bo_node->a  lt_association.

      add_anno_abap_catalog_ext(
          io_view               = lo_view
          i_allownewdatasources = abap_false
          i_allownewcompositions = abap_true
          i_elementsuffix       = io_rap_bo_node->extensibility_element_suffix
          i_datasources         = '_' && io_rap_bo_node->extension_association_name
          i_maximumfields       = 100
        ).

    ENDIF.

    DATA(associations) = io_rap_bo_node->lt_association.

    IF extension_assocation IS NOT INITIAL.
      APPEND extension_assocation TO associations.
    ENDIF.

*    LOOP AT io_rap_bo_node->lt_association INTO DATA(ls_assocation).
    LOOP AT associations INTO DATA(ls_assocation).

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
        WHEN ZDMO_cl_rap_node=>cardinality-one.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->one ).
        WHEN ZDMO_cl_rap_node=>cardinality-one_to_n.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->one_to_n ).
        WHEN ZDMO_cl_rap_node=>cardinality-zero_to_n.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->zero_to_n ).
        WHEN ZDMO_cl_rap_node=>cardinality-zero_to_one.
          lo_association->set_cardinality( xco_cp_cds=>cardinality->zero_to_one ).
        WHEN ZDMO_cl_rap_node=>cardinality-one_to_one.
          "@todo: currently association[1] will be generated
          "fix available with 2008 HFC2
          lo_association->set_cardinality( xco_cp_cds=>cardinality->range( iv_min = 1 iv_max = 1 ) ).
      ENDCASE.

      "publish association
      lo_view->add_field( xco_cp_ddl=>field( ls_assocation-name ) ).

    ENDLOOP.

    LOOP AT       io_rap_bo_node->lt_additional_fields INTO DATA(additional_fields) WHERE cds_restricted_reuse_view = abap_true.

      lo_field = lo_view->add_field( xco_cp_ddl=>expression->for( additional_fields-name ) ).
      IF additional_fields-cds_view_field IS NOT INITIAL.
        lo_Field->set_alias( additional_fields-cds_view_field ).
      ENDIF.
    ENDLOOP.

    "add alias
    lo_view->data_source->set_alias( io_rap_bo_node->entityname ).

  ENDMETHOD.


  METHOD create_service_binding.
**********************************************************************
** Begin of deletion 2020
**********************************************************************
    DATA lv_service_binding_name TYPE sxco_srvb_object_name.
    lv_service_binding_name = to_upper( io_rap_bo_node->root_node->rap_root_node_objects-service_binding ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = lv_service_binding_name.
    generated_repository_object-object_type = 'SRVB'.
    APPEND generated_repository_object TO generated_repository_objects.

    DATA lv_service_definition_name TYPE sxco_srvd_object_name.
    lv_service_definition_name = to_upper( io_rap_bo_node->root_node->rap_root_node_objects-service_definition ).

    DATA(lo_specification_header) = mo_srvb_put_operation->for-srvb->add_object(   lv_service_binding_name
                                    )->set_package( mo_package
                                    )->create_form_specification( ).

    lo_specification_header->set_short_description( |Service binding for { io_rap_bo_node->root_node->entityname }| ) ##no_text.


    CASE io_rap_bo_node->root_node->binding_type.
      WHEN io_rap_bo_node->binding_type_name-odata_v4_ui.
        lo_specification_header->set_binding_type( xco_cp_service_binding=>binding_type->odata_v4_ui ).
      WHEN io_rap_bo_node->binding_type_name-odata_v2_ui.
        lo_specification_header->set_binding_type( xco_cp_service_binding=>binding_type->odata_v2_ui ).
      WHEN io_rap_bo_node->binding_type_name-odata_v4_web_api.
        lo_specification_header->set_binding_type( xco_cp_service_binding=>binding_type->odata_v4_web_api ).
      WHEN io_rap_bo_node->binding_type_name-odata_v2_web_api..
        lo_specification_header->set_binding_type( xco_cp_service_binding=>binding_type->odata_v2_web_api ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
          EXPORTING
            textid     = ZDMO_cx_rap_generator=>invalid_binding_type
            mv_value   = io_rap_bo_node->root_node->binding_type
            mv_value_2 = io_rap_bo_node->supported_binding_types.
    ENDCASE.


    lo_specification_header->add_service( )->add_version( '0001' )->set_service_definition( lv_service_definition_name ).


**********************************************************************
** End of deletion 2020
**********************************************************************
  ENDMETHOD.


  METHOD create_service_definition.


    TYPES: BEGIN OF ty_cds_views_used_by_assoc,
             name   TYPE ZDMO_cl_rap_node=>ts_assocation-name,    "    sxco_ddef_alias_name,
             target TYPE ZDMO_cl_rap_node=>ts_assocation-target,
           END OF ty_cds_views_used_by_assoc.
    DATA  lt_cds_views_used_by_assoc  TYPE STANDARD TABLE OF ty_cds_views_used_by_assoc.
    DATA  ls_cds_views_used_by_assoc  TYPE ty_cds_views_used_by_assoc.

    DATA(lo_specification_header) = mo_put_operation->for-srvd->add_object(  io_rap_bo_node->rap_root_node_objects-service_definition
                                    )->set_package( mo_package
                                    )->create_form_specification( ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_root_node_objects-service_definition.
    generated_repository_object-object_type = 'SRVD'.
    APPEND generated_repository_object TO generated_repository_objects.

    lo_specification_header->set_short_description( |Service definition for { io_rap_bo_node->root_node->entityname }| ) ##no_text.

    set_service_definition_annos(
      io_specification = lo_specification_header
      io_rap_bo_node   = root_node
    ).

*    IF root_node->is_extensible(  ) = abap_true.
*      "add @AbapCatalog.extensibility.extensible: true
*      lo_specification_header->add_annotation( 'AbapCatalog.extensibility.extensible' )->value->build( )->add_boolean( abap_true ).
*    ENDIF.
*
*    lo_specification_header->add_annotation( 'ObjectModel.leadingEntity.name' )->value->build( )->add_string( CONV #( root_node->rap_node_objects-cds_view_p ) ).

    "add exposure for root node

    IF root_node->generate_custom_entity(  ).
      lo_specification_header->add_exposure( root_node->rap_node_objects-cds_view_r )->set_alias( root_node->rap_node_objects-alias ).
    ELSE.
      lo_specification_header->add_exposure( root_node->rap_node_objects-cds_view_p )->set_alias( root_node->rap_node_objects-alias ).
    ENDIF.

*    CASE root_node->data_source_type.
*      WHEN root_node->data_source_types-table OR root_node->data_source_types-cds_view.
*        lo_specification_header->add_exposure( root_node->rap_node_objects-cds_view_p )->set_alias( root_node->rap_node_objects-alias ).
*
*      WHEN root_node->data_source_types-structure OR root_node->data_source_types-abap_type.
*        lo_specification_header->add_exposure( root_node->rap_node_objects-cds_view_r )->set_alias( root_node->rap_node_objects-alias ).
*    ENDCASE.
    "add exposure for all child nodes
    LOOP AT root_node->all_childnodes INTO DATA(lo_childnode).
      "add all nodes to the service definition
      IF lo_childnode->generate_custom_entity(  ).
        lo_specification_header->add_exposure( lo_childnode->rap_node_objects-cds_view_r )->set_alias( lo_childnode->rap_node_objects-alias ).
      ELSE.
        lo_specification_header->add_exposure( lo_childnode->rap_node_objects-cds_view_p )->set_alias( lo_childnode->rap_node_objects-alias ).
      ENDIF.
*      CASE lo_childnode->data_source_type.
*        WHEN lo_childnode->data_source_types-table OR lo_childnode->data_source_types-cds_view.
*          lo_specification_header->add_exposure( lo_childnode->rap_node_objects-cds_view_p )->set_alias( lo_childnode->rap_node_objects-alias ).
*        WHEN lo_childnode->data_source_types-abap_type OR lo_childnode->data_source_types-structure.
*          lo_specification_header->add_exposure( lo_childnode->rap_node_objects-cds_view_r )->set_alias( lo_childnode->rap_node_objects-alias ).
*      ENDCASE.

      "create a list of all CDS views used in associations to the service definition
      LOOP AT lo_childnode->lt_association INTO DATA(ls_assocation).
        "remove the first character which is an underscore
        ls_cds_views_used_by_assoc-name = substring( val = ls_assocation-name off = 1 ).
        ls_cds_views_used_by_assoc-target =  ls_assocation-target.
        COLLECT ls_cds_views_used_by_assoc INTO lt_cds_views_used_by_assoc.
      ENDLOOP.
      LOOP AT lo_childnode->lt_valuehelp INTO DATA(ls_valuehelp).
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


  METHOD create_table.

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.

    DATA name_of_generated_table TYPE sxco_dbt_object_name.

    IF is_draft_table = abap_true.
      name_of_generated_table = io_rap_bo_node->draft_table_name.
    ELSE.
      name_of_generated_table = io_rap_bo_node->table_name.
    ENDIF.


    DATA(lo_specification) = mo_draft_tabl_put_operation->for-tabl-for-database_table->add_object( name_of_generated_table
                                  )->set_package( mo_package
                                  )->create_form_specification( ).


    IF is_draft_table = abap_true.
      generated_repository_object-object_name = name_of_generated_table.
      lo_specification->set_short_description( | Draft table for entity { io_rap_bo_node->rap_node_objects-cds_view_r } | ) ##no_text.
    ELSE.
      generated_repository_object-object_name = name_of_generated_table.
      lo_specification->set_short_description( | Table for entity { io_rap_bo_node->rap_node_objects-cds_view_r } | ) ##no_text.
    ENDIF.
    generated_repository_object-object_type = 'TABL'.
    APPEND generated_repository_object TO generated_repository_objects.


    DATA database_table_field  TYPE REF TO if_xco_gen_tabl_dbt_s_fo_field  .

    "tables must be client dependent
    "and the key field must be the first field of the table

*    IF is_draft_table = abap_true AND io_rap_bo_node->is_virtual_root(  ) = abap_true.
    database_table_field = lo_specification->add_field( 'MANDT' ).
    database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->clnt ).
    database_table_field->set_not_null( ).
    database_table_field->set_key_indicator(  ).
*    ENDIF.

    LOOP AT io_rap_bo_node->lt_fields INTO DATA(table_field_line)
                                      WHERE name  <> io_rap_bo_node->field_name-client.

      DATA(cds_field_name_upper) = to_upper( table_field_line-cds_view_field ).
      DATA(table_field_name_upper) = to_upper( table_field_line-name ).

      IF is_draft_table = abap_true.
        database_table_field = lo_specification->add_field( CONV #( cds_field_name_upper ) ).
      ELSE.
        database_table_field = lo_specification->add_field( CONV #( table_field_name_upper ) ).
      ENDIF.

      IF table_field_line-is_data_element = abap_true.
        database_table_field->set_type( xco_cp_abap_dictionary=>data_element( table_field_line-data_element ) ).
      ENDIF.
      IF table_field_line-is_built_in_type = abap_true.

*        database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->for(
*                                        iv_type     = to_upper( table_field_line-built_in_type )
*                                        iv_length   = table_field_line-built_in_type_length
*                                        iv_decimals = table_field_line-built_in_type_decimals
*                                        ) ).
        CASE  to_lower( table_field_line-built_in_type ).
          WHEN 'accp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->accp ).
          WHEN 'clnt'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->clnt ).
          WHEN 'cuky'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->cuky ).
          WHEN 'dats'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dats ).
          WHEN 'df16_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_raw ).
          WHEN 'df34_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_raw ).
          WHEN 'fltp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->fltp ).
          WHEN 'int1'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int1 ).
          WHEN 'int2'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int2 ).
          WHEN 'int4'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int4 ).
          WHEN 'int8'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int8 ).
          WHEN 'lang'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lang ).
          WHEN 'tims'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->tims ).
          WHEN 'char'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->char( table_field_line-built_in_type_length ) ).
          WHEN 'curr'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->curr(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'dec'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'df16_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'df34_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'lchr' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lchr( table_field_line-built_in_type_length ) ).
          WHEN 'lraw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lraw( table_field_line-built_in_type_length ) ).
          WHEN 'numc'   .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->numc( table_field_line-built_in_type_length ) ).
          WHEN 'quan' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->quan(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                              ) ).
          WHEN 'raw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->raw( table_field_line-built_in_type_length ) ).
          WHEN 'rawstring'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->rawstring( table_field_line-built_in_type_length ) ).
          WHEN 'sstring' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->sstring( table_field_line-built_in_type_length ) ).
          WHEN 'string' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->string( table_field_line-built_in_type_length ) ).
          WHEN 'unit'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->unit( table_field_line-built_in_type_length ) ).
          WHEN OTHERS.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->for(
                                              iv_type     = to_upper( table_field_line-built_in_type )
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
        ENDCASE.




      ENDIF.
      IF table_field_line-key_indicator = abap_true.
        database_table_field->set_key_indicator( ).
        "not_null must not be set for non-key fields of a draft table
        "this is because otherwise one would not be able to store data in the draft table
        "which is inconsistent and still being worked on
        "for non-key fields this is set like in the ADT quick fix that generates a draft table
        IF table_field_line-not_null = abap_true.
          database_table_field->set_not_null( ).
        ENDIF.
      ENDIF.

      IF table_field_line-currencycode IS NOT INITIAL.
        DATA(currkey_dbt_field_upper) = to_upper( table_field_line-currencycode ).
        "get the cds view field name of the currency or quantity filed
        DATA(cds_view_ref_field_name) = io_rap_bo_node->lt_fields[ name = currkey_dbt_field_upper ]-cds_view_field .
        DATA(dbt_ref_field_name) = io_rap_bo_node->lt_fields[ name = currkey_dbt_field_upper ]-name.
        IF is_draft_table = abap_true.
          database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( io_rap_bo_node->draft_table_name ) ) )->set_reference_field( to_upper( cds_view_ref_field_name ) ).
        ELSE.
          database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( io_rap_bo_node->table_name ) ) )->set_reference_field( to_upper( dbt_ref_field_name ) ).
        ENDIF.
      ENDIF.
      IF table_field_line-unitofmeasure IS NOT INITIAL.
        DATA(quantity_dbt_field_upper) = to_upper( table_field_line-unitofmeasure ).
        cds_view_ref_field_name = io_rap_bo_node->lt_fields[ name = quantity_dbt_field_upper ]-cds_view_field .
        dbt_ref_field_name = io_rap_bo_node->lt_fields[ name = quantity_dbt_field_upper ]-name.
        IF is_draft_table = abap_true.
          database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( io_rap_bo_node->draft_table_name ) ) )->set_reference_field( to_upper( cds_view_ref_field_name ) ).
        ELSE.
          database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( io_rap_bo_node->table_name ) ) )->set_reference_field( to_upper( dbt_ref_field_name ) ).
        ENDIF.
      ENDIF.
    ENDLOOP.

**********************************************************************
** Begin of deletion 2020
**********************************************************************
    IF is_draft_table = abap_true.
      lo_specification->add_include( )->set_structure( iv_structure = CONV #( to_upper( 'sych_bdl_draft_admin_inc' ) )  )->set_group_name( to_upper( '%admin' )  ).
    ENDIF.
**********************************************************************
** End of deletion 2020
**********************************************************************

    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      lo_specification->add_include( )->set_structure( iv_structure = CONV #( to_upper( io_rap_bo_node->rap_node_objects-extension_include ) )  ).
      set_table_enhancement_cat_any( lo_specification  ).
    ENDIF.

    "add additional fields if provided
    LOOP AT       io_rap_bo_node->lt_additional_fields INTO DATA(additional_fields) WHERE draft_table = abap_true.

      database_table_field = lo_specification->add_field( CONV #( to_upper( additional_fields-cds_view_field ) ) ).

      IF additional_fields-data_element IS NOT INITIAL.
        database_table_field->set_type( xco_cp_abap_dictionary=>data_element( to_upper( additional_fields-data_element ) ) ).
      ELSE.

        CASE  to_lower( additional_fields-built_in_type ).
          WHEN 'accp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->accp ).
          WHEN 'clnt'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->clnt ).
          WHEN 'cuky'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->cuky ).
          WHEN 'dats'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dats ).
          WHEN 'df16_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_raw ).
          WHEN 'df34_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_raw ).
          WHEN 'fltp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->fltp ).
          WHEN 'int1'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int1 ).
          WHEN 'int2'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int2 ).
          WHEN 'int4'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int4 ).
          WHEN 'int8'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int8 ).
          WHEN 'lang'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lang ).
          WHEN 'tims'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->tims ).
          WHEN 'char'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->char( additional_fields-built_in_type_length ) ).
          WHEN 'curr'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->curr(
                                              iv_length   = additional_fields-built_in_type_length
                                              iv_decimals = additional_fields-built_in_type_decimals
                                            ) ).
          WHEN 'dec'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dec(
                                              iv_length   = additional_fields-built_in_type_length
                                              iv_decimals = additional_fields-built_in_type_decimals
                                            ) ).
          WHEN 'df16_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_dec(
                                              iv_length   = additional_fields-built_in_type_length
                                              iv_decimals = additional_fields-built_in_type_decimals
                                            ) ).
          WHEN 'df34_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_dec(
                                              iv_length   = additional_fields-built_in_type_length
                                              iv_decimals = additional_fields-built_in_type_decimals
                                            ) ).
          WHEN 'lchr' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lchr( additional_fields-built_in_type_length ) ).
          WHEN 'lraw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lraw( additional_fields-built_in_type_length ) ).
          WHEN 'numc'   .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->numc( additional_fields-built_in_type_length ) ).
          WHEN 'quan' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->quan(
                                              iv_length   = additional_fields-built_in_type_length
                                              iv_decimals = additional_fields-built_in_type_decimals
                                              ) ).
          WHEN 'raw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->raw( additional_fields-built_in_type_length ) ).
          WHEN 'rawstring'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->rawstring( additional_fields-built_in_type_length ) ).
          WHEN 'sstring' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->sstring( additional_fields-built_in_type_length ) ).
          WHEN 'string' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->string( additional_fields-built_in_type_length ) ).
          WHEN 'unit'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->unit( additional_fields-built_in_type_length ) ).
          WHEN OTHERS.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->for(
                                              iv_type     = to_upper( additional_fields-built_in_type )
                                              iv_length   = additional_fields-built_in_type_length
                                              iv_decimals = additional_fields-built_in_type_decimals
                                            ) ).
        ENDCASE.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD create_with_rap_node_object.
    result = NEW #( io_root_node = rap_node ).
  ENDMETHOD.


  METHOD exception_occured.
    rv_exception_occured = put_exception_occured.
  ENDMETHOD.


  METHOD generate_bo.

    DATA framework_message TYPE zdmo_cl_rap_node=>t_framework_message_fields.

    DATA(rap_bo_name) = get_rap_bo_name(  ).

    DATA log_entries TYPE STANDARD TABLE OF t_log_entry.
    DATA log_entry TYPE t_log_entry.
    DATA task_name TYPE string.

    log_entry-text = |Start generating { rap_bo_name }|.
    log_entry-detaillevel = 1.
    log_entry-severity = 'S'.
    APPEND log_entry TO log_entries.

    add_log_entries_for_rap_bo(
      EXPORTING
        i_rap_bo_name = rap_bo_name
        i_log_entries = log_entries
    ).

    put_exception_occured = abap_false.

    "do not generate repository objects
    "used for testing purposes to allow skip of generation by only changing the json file
    IF root_node->generate_only_node_hierachy = abap_true.
      EXIT.
    ENDIF.

    IF root_node->multi_edit = abap_true.
      root_node = root_node->add_virtual_root_node( ).
    ENDIF.

    assign_package( ).

    TRY.
        " on premise create draft tables first
        " uses mo_draft_tabl_put_opertion
        IF root_node->draft_enabled = abap_true OR
           root_node->create_table = abap_true OR
           root_node->is_extensible(  ) = abap_true.

          "create extension includes together with tables
          IF root_node->is_extensible(  ) = abap_true.
            create_extension_include( root_node ).
            LOOP AT root_node->all_childnodes INTO DATA(lo_child_node).
              create_extension_include( lo_child_node ).
            ENDLOOP.
          ENDIF.

          "create draft tables
          IF root_node->draft_enabled = abap_true.
            task_name = 'create draft tables'.
            create_table(
              EXPORTING
                io_rap_bo_node = root_node
                is_draft_table = abap_true
            ).
            LOOP AT root_node->all_childnodes INTO lo_child_node.
              create_table(
                EXPORTING
                  io_rap_bo_node = lo_child_node
                  is_draft_table = abap_true
              ).
            ENDLOOP.
          ENDIF.

          "create tables
          IF root_node->create_table = abap_true.
            task_name = 'create tables'.
            create_table(
              EXPORTING
                io_rap_bo_node = root_node
                is_draft_table = abap_false
            ).
            LOOP AT root_node->all_childnodes INTO lo_child_node.
              create_table(
                EXPORTING
                  io_rap_bo_node = lo_child_node
                  is_draft_table = abap_false
              ).
            ENDLOOP.
          ENDIF.




          DATA lo_result TYPE REF TO if_xco_gen_o_put_result .

          IF root_node->skip_activation = abap_true.

**********************************************************************
** Begin of insertion 2020
**********************************************************************
*            lo_result = mo_draft_tabl_put_opertion->execute( VALUE #( ( xco_cp_generation=>put_operation_option->skip_activation ) ) ).
**********************************************************************
** End of deletion 2020
**********************************************************************
**********************************************************************
** Begin of insertion 2020
**********************************************************************
            lo_result = mo_draft_tabl_put_operation->execute(  ).
**********************************************************************
** End of insertion 2020
**********************************************************************
          ELSE.
            lo_result = mo_draft_tabl_put_operation->execute(  ).
          ENDIF.



          DATA(lo_findings) = lo_result->findings.
          DATA(lt_findings) = lo_findings->get( ).

          add_findings_to_output(
            i_task_name = 'Generating draft tables'
            i_findings  = lo_findings
          ).

**********************************************************************
          "add draft structures
          "only needed for on premise systems with older release
          "method is not implemented for xco cloud api
**********************************************************************
          IF xco_api->on_premise_branch_is_used(  ).

            IF root_node->draft_enabled = abap_true.
              xco_api->add_draft_include( root_node->draft_table_name ).
              LOOP AT root_node->all_childnodes INTO lo_child_node.
                xco_api->add_draft_include( lo_child_node->draft_table_name ).
              ENDLOOP.
            ENDIF.

            IF root_node->is_extensible(  ) = abap_true.
              xco_api->add_enh_cat_and_anno_to_struct(
                ext_include_structure_name   = root_node->rap_node_objects-extension_include
                extensibility_element_suffix = root_node->extensibility_element_suffix
                ).
              "the tables used as a data source have to be draft enabled
              "so we only have to change the draft tables
              IF root_node->draft_enabled = abap_true.
                xco_api->add_enh_cat_to_table( root_node->draft_table_name ).
              ENDIF.
              LOOP AT root_node->all_childnodes INTO lo_child_node.
                xco_api->add_enh_cat_and_anno_to_struct(
                  ext_include_structure_name   = lo_child_node->rap_node_objects-extension_include
                  extensibility_element_suffix = lo_child_node->extensibility_element_suffix
                  ).
                "the tables used as a data source have to be draft enabled
                "so we only have to change the draft tables
                IF root_node->draft_enabled = abap_true.
                  xco_api->add_enh_cat_to_table( lo_child_node->table_name ).
                ENDIF.
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDIF.

        DATA has_extension_include TYPE abap_bool.

        IF root_node->data_source_type = zdmo_cl_rap_node=>data_source_types-table AND
          root_node->is_extensible(  ) = abap_true.

          "check table of root node
          DATA(database_table) = xco_api->get_database_table( iv_name = to_upper( root_node->data_source_name ) ).

          "@todo check why table is not found when being generated
          IF database_table->exists(  ).
            check_and_add_ext_incl_struc( root_node ).
          ENDIF.

          LOOP AT root_node->all_childnodes INTO DATA(child_nodes_add_incl).

            "check table of root node
            DATA(database_table_child) = xco_api->get_database_table( iv_name = to_upper( child_nodes_add_incl->data_source_name ) ).

            "@todo check why table is not found when being generated
            IF database_table_child->exists(  ).
              check_and_add_ext_incl_struc( child_nodes_add_incl ).
            ENDIF.


          ENDLOOP.

          mo_patch_operation->execute( ).

        ENDIF.

        SELECT SINGLE * FROM ZDMO_R_RAPG_ProjectTP   WHERE boname = @rap_bo_name
              INTO @DATA(rap_generator_bo).


        "if rap generator is called via the behavior implementation class a table entry will exist.
        "if rap generator class is called via command-line no table entry will exist.
        "we will hence create an entity in the RAP BO

        IF rap_generator_bo IS INITIAL.
*          store_bo(  ).
        ENDIF.


        task_name = 'create entities'.
        IF root_node->generate_custom_entity(  ).
          create_custom_entity( root_node ).
          create_custom_query( root_node ).
        ELSE.
          create_r_cds_view( root_node ).
          IF root_node->is_virtual_root(  ) = abap_false.
            create_i_cds_view( root_node ).
          ENDIF.
          create_p_cds_view( root_node ).
          create_mde_view( root_node ).
        ENDIF.

        IF root_node->transactional_behavior = abap_true.
          task_name = 'create bdef'.
          create_bdef( root_node ).
        ENDIF.

        IF root_node->generate_custom_entity(  ) = abap_false AND
           root_node->transactional_behavior = abap_true.
          task_name = 'create projection bdef'.
          create_bdef_p( root_node ).
          create_bdef_i( root_node ).
        ENDIF.


        IF root_node->generate_bil(  ).
          task_name = 'create BIL'.
          create_bil( root_node ).
        ENDIF.



        IF root_node->add_basic_i_views = abap_true.
          task_name = 'create basic i view'.
          create_i_cds_view_basic( root_node ).
        ENDIF.

        IF root_node->add_sap_object_type = abap_true.
          create_sap_object_type( root_node ).
          create_sap_object_node_type( root_node ).
        ENDIF.

        LOOP AT root_node->all_childnodes INTO DATA(lo_bo_node).

          IF root_node->add_sap_object_type = abap_true.
            create_sap_object_node_type( lo_bo_node ).
          ENDIF.

          IF lo_bo_node->generate_custom_entity(  ).
            create_custom_entity( lo_bo_node ).
            create_custom_query( lo_bo_node ).
          ELSE.
            create_r_cds_view( lo_bo_node ).
            IF lo_bo_node->root_node->is_virtual_root(  ) = abap_false.
              create_i_cds_view( lo_bo_node ).
            ENDIF.
            create_p_cds_view( lo_bo_node ).
            create_mde_view( lo_bo_node ).
          ENDIF.

          IF lo_bo_node->add_basic_i_views = abap_true.
            task_name = 'create basic i view'.
            create_i_cds_view_basic( lo_bo_node ).
          ENDIF.

          IF lo_bo_node->get_implementation_type( ) = lo_bo_node->implementation_type-unmanaged_semantic.
            create_control_structure( lo_bo_node ).
          ENDIF.

          IF lo_bo_node->is_extensible(  ) = abap_true.
*            create_extension_include( lo_bo_node ).
            create_extension_include_view( lo_bo_node   ).
          ENDIF.

          IF lo_bo_node->is_extensible(  ) = abap_true AND
             lo_bo_node->draft_enabled = abap_true.
            create_draft_query_view( lo_bo_node ).
          ENDIF.

          IF lo_bo_node->generate_bil(  ).
            create_bil( lo_bo_node ).
          ENDIF.

        ENDLOOP.

        IF root_node->is_extensible(  ) = abap_true.
*          create_extension_include( root_node ).
          create_extension_include_view( root_node   ).
        ENDIF.

        IF root_node->is_extensible(  ) = abap_true AND
         root_node->draft_enabled = abap_true.
          create_draft_query_view( root_node ).
        ENDIF.

        IF root_node->get_implementation_type( ) = root_node->implementation_type-unmanaged_semantic.
          create_control_structure( root_node ).
        ENDIF.

        IF root_node->publish_service = abap_true.
          create_service_definition( root_node ).
        ENDIF.




        "start to create all objects beside service binding

        IF root_node->skip_activation = abap_true.
          task_name = 'Generating cds views, bdef, bil and service defintion'.
**********************************************************************
** Start of deletion 2020
**********************************************************************
*          lo_result = mo_put_operation->execute( VALUE #( ( xco_cp_generation=>put_operation_option->skip_activation ) ) ).
**********************************************************************
** End of deletion 2020
**********************************************************************
**********************************************************************
** End of insertion 2020
**********************************************************************
          lo_result = mo_put_operation->execute(  ).
**********************************************************************
** End of insertion 2020
**********************************************************************
        ELSE.
          lo_result = mo_put_operation->execute(  ).
        ENDIF.

        lo_findings = lo_result->findings.

        lo_findings = lo_result->findings.
        lt_findings = lo_findings->get( ).

        add_findings_to_output(
          i_task_name = 'Generating cds views, bdef, bil and service defintion'
          i_findings  = lo_findings
        ).

        framework_message-message = 'Messages and warnings from ADT:'.
        framework_message-severity = 'I'.
        APPEND framework_message TO framework_messages.

        IF lt_findings IS NOT INITIAL.
          LOOP AT lt_findings INTO DATA(ls_findings).
            framework_message-severity = ls_findings->message->value-msgty.
            framework_message-object_type = ls_findings->object_type.
            framework_message-object_name = ls_findings->object_name.
            framework_message-message = ls_findings->message->get_text(  ).
            APPEND framework_message TO framework_messages.
          ENDLOOP.
        ENDIF.

        "if skip_activation is true the service definition will not be activated.
        "it is hence not possible to generate a service binding on top
        IF root_node->publish_service = abap_true AND root_node->skip_activation = abap_false.

          create_service_binding( root_node ).

          "service binding needs a separate put operation
          lo_result = mo_srvb_put_operation->execute(  ).
          lo_findings = lo_result->findings.

          add_findings_to_output(
            i_task_name = 'Generate service binding'
            i_findings  = lo_findings
          ).

          DATA(lt_srvb_findings) = lo_findings->get( ).

          IF lt_srvb_findings IS NOT INITIAL.

            CLEAR framework_message.

            LOOP AT lt_srvb_findings INTO ls_findings.

              framework_message-severity = ls_findings->message->value-msgty.
              framework_message-object_type = ls_findings->object_type.
              framework_message-object_name = ls_findings->object_name.
              framework_message-message = ls_findings->message->get_text(  ).
              APPEND framework_message TO framework_messages.

            ENDLOOP.
          ENDIF.

          CLEAR log_entries.
          log_entry-text = |Start publish service binding { root_node->rap_root_node_objects-service_binding }|.
          log_entry-detaillevel = 1.
          log_entry-severity = 'S'.
          APPEND log_entry TO log_entries.

          add_log_entries_for_rap_bo(
            EXPORTING
              i_rap_bo_name = rap_bo_name
              i_log_entries = log_entries
          ).

          DATA service_binding TYPE sxco_srvb_object_name.
          service_binding =  root_node->rap_root_node_objects-service_binding   .
          xco_api->publish_service_binding( service_binding ).

        ENDIF.


        "if skip_activation is true the service definition will not be activated.
        "it is hence not possible to generate a service binding on top
        "we will thus have no service binding that can be used for registration




        IF root_node->manage_business_configuration = abap_true AND root_node->skip_activation = abap_false.

          zz_add_business_configuration( CHANGING c_framework_messages = framework_messages ).

        ENDIF.

        CLEAR log_entries.
        log_entry-text = |Generation finished|.
        log_entry-detaillevel = 1.
        log_entry-severity = 'S'.
        APPEND log_entry TO log_entries.
        add_log_entries_for_rap_bo(
                    EXPORTING
                      i_rap_bo_name = rap_bo_name
                      i_log_entries = log_entries
                  ).
      CATCH cx_xco_gen_put_exception INTO DATA(put_exception).
        put_exception_occured = abap_true.
        lo_findings = put_exception->findings.
        lt_findings = lo_findings->get( ).

        add_findings_to_output(
          i_task_name = 'Exception occured'
          i_findings  = lo_findings
        ).

        CLEAR framework_message.
        framework_message-message =  'PUT operation failed:'.
        APPEND framework_message TO framework_messages.

        IF lt_findings IS NOT INITIAL.
          CLEAR framework_message.
          LOOP AT lt_findings INTO ls_findings.

            framework_message-severity = ls_findings->message->value-msgty.
            framework_message-object_type = ls_findings->object_type.
            framework_message-object_name = ls_findings->object_name.
            framework_message-message = ls_findings->message->get_text(  ).
            APPEND framework_message TO framework_messages.

          ENDLOOP.
        ENDIF.

      CATCH cx_root INTO DATA(lx_root_exception).  "if nothing else has been catched so far

        CLEAR framework_message.
        framework_message-message = lx_root_exception->get_text( ).
        APPEND framework_message TO framework_messages.

    ENDTRY.



    IF root_node->is_extensible(  ) = abap_true.

      DATA released_object  TYPE string .

      TRY.

          CLEAR log_entries.
          log_entry-text = |Start C0- and C1 release|.
          log_entry-detaillevel = 1.
          log_entry-severity = 'S'.
          APPEND log_entry TO log_entries.
          add_log_entries_for_rap_bo(
                                         EXPORTING
                                           i_rap_bo_name = rap_bo_name
                                           i_log_entries = log_entries
                                       ).

          "release root node objects





*          DATA(api_state_handler_service_def) = cl_abap_api_state=>create_instance( api_key = VALUE #(
*               object_type     = 'SRVD'
*               object_name     = to_upper( |{ root_node->rap_root_node_objects-service_definition }| ) "'ZRAP630UI_Shop_051' )
*               ) ).



          DATA(api_state_handler_tabl) = cl_abap_api_state=>create_instance( api_key = VALUE #(
                object_type     = 'TABL'
                object_name     = to_upper( |{ root_node->data_source_name }| ) "'zrap630sshop_051' )
                ) ).

*         api_state_handler_tabl->release(
*              EXPORTING
*                release_contract         = 'C0'
*                use_in_cloud_development = abap_true
*                use_in_key_user_apps     = abap_false
*                request                  = CONV #( root_node->transport_request )
*       ).

**********************************************************************

          released_object = root_node->rap_root_node_objects-behavior_definition_r.

          DATA(api_state_handler_r_bdef) = cl_abap_api_state=>create_instance(
               api_key = VALUE #(
               object_type     = 'BDEF'
               object_name     = to_upper( released_object ) "'ZRAP630R_ShopTP_051' )
           ) ).

          api_state_handler_r_bdef->release(
                              EXPORTING
                                release_contract         = 'C0'
                                use_in_cloud_development = abap_true
                                use_in_key_user_apps     = abap_false
                                request                  = CONV #( root_node->transport_request )
                            ).

          released_object = root_node->rap_root_node_objects-behavior_definition_i.

          DATA(api_state_handler_i_bdef) = cl_abap_api_state=>create_instance(
                     api_key = VALUE #(
                     object_type     = 'BDEF'
                     object_name     = to_upper( released_object ) "'ZRAP630i_ShopTP_051' )
                      ) ).

          "i-bdef must first be C1 and then C0 released

          api_state_handler_i_bdef->release(
            EXPORTING
              release_contract         = 'C1'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
          ).

          api_state_handler_i_bdef->release(
            EXPORTING
              release_contract         = 'C0'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
          ).

          released_object = root_node->rap_root_node_objects-behavior_definition_p.

          DATA(api_state_handler_p_bdef) = cl_abap_api_state=>create_instance(
               api_key = VALUE #(
               object_type     = 'BDEF'
               object_name     = to_upper( released_object ) "'ZRAP630c_ShopTP_051' )
                ) ).

          api_state_handler_p_bdef->release(
            EXPORTING
              release_contract         = 'C0'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
          ).

          CLEAR log_entries.
          log_entry-text = |BDEF's released|.
          log_entry-detaillevel = 1.
          log_entry-severity = 'S'.
          APPEND log_entry TO log_entries.
          add_log_entries_for_rap_bo(
                                         EXPORTING
                                           i_rap_bo_name = rap_bo_name
                                           i_log_entries = log_entries
                                           ).

          WAIT UP TO 1 SECONDS.
          COMMIT WORK.

          released_object = root_node->rap_node_objects-extension_include.

          DATA(api_state_handler_struct) = cl_abap_api_state=>create_instance( api_key = VALUE #(
               object_type     = 'TABL'
               object_name     = to_upper( released_object ) "'zrap630sshop_051' )
               ) ).

          api_state_handler_struct->release(
             EXPORTING
               release_contract         = 'C0'
               use_in_cloud_development = abap_true
               use_in_key_user_apps     = abap_false
               request                  = CONV #( root_node->transport_request )
           ).
          WAIT UP TO 1 SECONDS.
          COMMIT WORK.
          released_object =   root_node->rap_node_objects-extension_include_view.

          DATA(api_state_handler_ext_view) = cl_abap_api_state=>create_instance( api_key = VALUE #(
               object_type     = 'DDLS'
               object_name     = to_upper( released_object ) "'ZRAP630E_Shop_051' )
               sub_object_type = 'CDS_STOB'
               sub_object_name     = to_upper( released_object ) "'ZRAP630E_Shop_051' )
               ) ).

          api_state_handler_ext_view->release(
            EXPORTING
              release_contract         = 'C0'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
          ).

          released_object = root_node->rap_node_objects-draft_query_view.
          WAIT UP TO 1 SECONDS.
          COMMIT WORK.
          DATA(api_state_handler_D_qu_view) = cl_abap_api_state=>create_instance( api_key = VALUE #(
               object_type     = 'DDLS'
               object_name     = to_upper( released_object ) "'ZRAP630R_Shop_D_051' )
               sub_object_type = 'CDS_STOB'
               sub_object_name     = to_upper( released_object ) "'ZRAP630R_Shop_D_051' )
               ) ).

          api_state_handler_d_qu_view->release(
                EXPORTING
                  release_contract         = 'C0'
                  use_in_cloud_development = abap_true
                  use_in_key_user_apps     = abap_false
                  request                  = CONV #( root_node->transport_request )
              ).

          WAIT UP TO 1 SECONDS.
          COMMIT WORK.

          released_object = root_node->rap_node_objects-cds_view_r.

          DATA(api_state_handler_r_view) = cl_abap_api_state=>create_instance( api_key = VALUE #(
               object_type     = 'DDLS'
               object_name     = to_upper( released_object ) "'ZRAP630R_ShopTP_051' )
               sub_object_type = 'CDS_STOB'
               sub_object_name     = to_upper( released_object ) " 'ZRAP630R_ShopTP_051' )
               ) ).

          api_state_handler_r_view->release(
          EXPORTING
            release_contract         = 'C0'
            use_in_cloud_development = abap_true
            use_in_key_user_apps     = abap_false
            request                  = CONV #( root_node->transport_request )
        ).

          released_object = root_node->rap_node_objects-cds_view_i.
          WAIT UP TO 1 SECONDS.
          COMMIT WORK.
          DATA(api_state_handler_i_view) = cl_abap_api_state=>create_instance( api_key = VALUE #(
               object_type     = 'DDLS'
               object_name     = to_upper( released_object ) "'ZRAP630i_ShopTP_051' )
               sub_object_type = 'CDS_STOB'
               sub_object_name     = to_upper( released_object )  " 'ZRAP630i_ShopTP_051' )
               ) ).

          "cds interface view must first be C1 and then C0 released

          api_state_handler_i_view->release(
            EXPORTING
              release_contract         = 'C1'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
          ).
          WAIT UP TO 1 SECONDS.
          COMMIT WORK.
          api_state_handler_i_view->release(
            EXPORTING
              release_contract         = 'C0'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
          ).

          released_object = root_node->rap_node_objects-cds_view_p.
          WAIT UP TO 1 SECONDS.
          COMMIT WORK.
          DATA(api_state_handler_c_view) = cl_abap_api_state=>create_instance( api_key = VALUE #(
               object_type     = 'DDLS'
               object_name     = to_upper( released_object ) "'ZRAP630c_ShopTP_051' )
               sub_object_type = 'CDS_STOB'
               sub_object_name     = to_upper( released_object ) " 'ZRAP630c_ShopTP_051' )
               ) ).

          api_state_handler_c_view->release(
            EXPORTING
              release_contract         = 'C0'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
          ).
          WAIT UP TO 1 SECONDS.
          COMMIT WORK.
          CLEAR log_entries.
          log_entry-text = |Root node objects { root_node->entityname } released|.
          log_entry-detaillevel = 1.
          log_entry-severity = 'S'.
          APPEND log_entry TO log_entries.
          add_log_entries_for_rap_bo(
                                         EXPORTING
                                           i_rap_bo_name = rap_bo_name
                                           i_log_entries = log_entries
                                       ).

          "release cds views of child nodes
          LOOP AT root_node->all_childnodes INTO DATA(child_node).

            released_object = child_node->rap_node_objects-extension_include.

            api_state_handler_struct = cl_abap_api_state=>create_instance( api_key = VALUE #(
                  object_type     = 'TABL'
                  object_name     = to_upper( released_object ) "'zrap630sshop_051' )
                  ) ).

            api_state_handler_struct->release(
                                 EXPORTING
                                   release_contract         = 'C0'
                                   use_in_cloud_development = abap_true
                                   use_in_key_user_apps     = abap_false
                                   request                  = CONV #( root_node->transport_request )
                               ).

            released_object = child_node->rap_node_objects-extension_include_view.

            api_state_handler_ext_view = cl_abap_api_state=>create_instance( api_key = VALUE #(
                 object_type     = 'DDLS'
                 object_name     = to_upper( released_object ) "'ZRAP630E_Shop_051' )
                 sub_object_type = 'CDS_STOB'
                 sub_object_name     = to_upper( released_object ) "'ZRAP630E_Shop_051' )
                 ) ).

            api_state_handler_ext_view->release(
              EXPORTING
                release_contract         = 'C0'
                use_in_cloud_development = abap_true
                use_in_key_user_apps     = abap_false
                request                  = CONV #( root_node->transport_request )
            ).

            released_object = child_node->rap_node_objects-draft_query_view.

            api_state_handler_D_qu_view = cl_abap_api_state=>create_instance( api_key = VALUE #(
                 object_type     = 'DDLS'
                 object_name     = to_upper( |{ child_node->rap_node_objects-draft_query_view }| ) "'ZRAP630R_Shop_D_051' )
                 sub_object_type = 'CDS_STOB'
                 sub_object_name     = to_upper( |{ child_node->rap_node_objects-draft_query_view }| ) "'ZRAP630R_Shop_D_051' )
                 ) ).

            api_state_handler_d_qu_view->release(
                  EXPORTING
                    release_contract         = 'C0'
                    use_in_cloud_development = abap_true
                    use_in_key_user_apps     = abap_false
                    request                  = CONV #( root_node->transport_request )
                ).



            released_object = child_node->rap_node_objects-cds_view_r.

            api_state_handler_r_view = cl_abap_api_state=>create_instance( api_key = VALUE #(
                 object_type     = 'DDLS'
                 object_name     = to_upper( released_object ) "'ZRAP630R_ShopTP_051' )
                 sub_object_type = 'CDS_STOB'
                 sub_object_name     = to_upper( released_object ) " 'ZRAP630R_ShopTP_051' )
                 ) ).

            api_state_handler_r_view->release(
            EXPORTING
              release_contract         = 'C0'
              use_in_cloud_development = abap_true
              use_in_key_user_apps     = abap_false
              request                  = CONV #( root_node->transport_request )
            ).


            released_object = child_node->rap_node_objects-cds_view_i.

            api_state_handler_i_view = cl_abap_api_state=>create_instance( api_key = VALUE #(
                 object_type     = 'DDLS'
                 object_name     = to_upper( released_object ) "'ZRAP630i_ShopTP_051' )
                 sub_object_type = 'CDS_STOB'
                 sub_object_name     = to_upper( released_object )  " 'ZRAP630i_ShopTP_051' )
                 ) ).

            api_state_handler_i_view->release(
              EXPORTING
                release_contract         = 'C1'
                use_in_cloud_development = abap_true
                use_in_key_user_apps     = abap_false
                request                  = CONV #( root_node->transport_request )
            ).

            api_state_handler_i_view->release(
              EXPORTING
                release_contract         = 'C0'
                use_in_cloud_development = abap_true
                use_in_key_user_apps     = abap_false
                request                  = CONV #( root_node->transport_request )
            ).

            released_object = child_node->rap_node_objects-cds_view_p.

            api_state_handler_c_view = cl_abap_api_state=>create_instance( api_key = VALUE #(
                 object_type     = 'DDLS'
                 object_name     = to_upper( released_object ) "'ZRAP630c_ShopTP_051' )
                 sub_object_type = 'CDS_STOB'
                 sub_object_name     = to_upper( released_object ) " 'ZRAP630c_ShopTP_051' )
                 ) ).

            api_state_handler_c_view->release(
              EXPORTING
                release_contract         = 'C0'
                use_in_cloud_development = abap_true
                use_in_key_user_apps     = abap_false
                request                  = CONV #( root_node->transport_request )
       ).

            CLEAR log_entries.
            log_entry-text = |Child node objects { child_node->entityname } released|.
            log_entry-detaillevel = 1.
            log_entry-severity = 'S'.
            APPEND log_entry TO log_entries.
            add_log_entries_for_rap_bo(
                                           EXPORTING
                                             i_rap_bo_name = rap_bo_name
                                             i_log_entries = log_entries
                                         ).

          ENDLOOP.



          "release service definition
          "cannot be performed yet since the appropriate annotation cannot be yet set programmatically via XCO

*          api_state_handler_service_def->release(
*                 EXPORTING
*                   release_contract         = 'C0'
*                   use_in_cloud_development = abap_true
*                   use_in_key_user_apps     = abap_false
*                   request                  = CONV #( root_node->transport_request )
*          ).


          CLEAR log_entries.
          log_entry-text = |C0- and C1 release finished|.
          log_entry-detaillevel = 1.
          log_entry-severity = 'S'.
          APPEND log_entry TO log_entries.
          add_log_entries_for_rap_bo(
                                EXPORTING
                                  i_rap_bo_name = rap_bo_name
                                  i_log_entries = log_entries
                              ).
        CATCH cx_abap_api_state INTO DATA(lx_abap_api_state). " API State Handler
          DATA(lt_msg) = lx_abap_api_state->get_text( ).
          CLEAR log_entries.
          log_entry-text = |C0- or C1 release of { released_object } failed.|.
          log_entry-detaillevel = 1.
          log_entry-severity = 'E'.
          APPEND log_entry TO log_entries.
          add_log_entries_for_rap_bo(
                      EXPORTING
                        i_rap_bo_name = rap_bo_name
                        i_log_entries = log_entries
                    ).
          CLEAR log_entries.
          log_entry-text = lt_msg .
          APPEND log_entry TO log_entries.
          add_log_entries_for_rap_bo(
                      EXPORTING
                        i_rap_bo_name = rap_bo_name
                        i_log_entries = log_entries
                    ).
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD get_generated_repo_objects.
    r_generated_repository_objects = generated_repository_objects.
  ENDMETHOD.


  METHOD get_rap_bo_name.
    IF root_node->is_consistent( ).
      rap_bo_name = root_node->rap_root_node_objects-behavior_definition_r.
    ENDIF.
  ENDMETHOD.


  METHOD get_transport_layer.

    DATA(lo_package) = io_package.
    DO.
      DATA(ls_package) = lo_package->read( ).
      IF ls_package-property-transport_layer->value EQ '$SPL'.
        lo_package = ls_package-property-super_package.
        CONTINUE.
      ENDIF.
      ro_transport_layer = ls_package-property-transport_layer.
      EXIT.
    ENDDO.
  ENDMETHOD.


  METHOD put_operation_execute.
    super->put_operation_execute(
      EXPORTING
        i_put_operation   = i_put_operation
        i_skip_activation = i_skip_activation
      RECEIVING
        r_result          = r_result
    ).
  ENDMETHOD.


  METHOD zz_add_business_configuration.

    DATA framework_message TYPE zdmo_cl_rap_node=>t_framework_message_fields.

    TRY.
        CLEAR framework_message.
        framework_message-message = 'Messages from business configuration registration'.
        framework_message-severity = 'I'.
        APPEND framework_message TO c_framework_messages.


        DATA(lo_business_configuration) = mbc_cp_api=>business_configuration(
          iv_identifier = root_node->manage_business_config_names-identifier
          iv_namespace  = root_node->manage_business_config_names-namespace
        ).

        lo_business_configuration->create(
          iv_name                      = root_node->manage_business_config_names-name
          iv_description               = root_node->manage_business_config_names-description
          iv_service_binding           = CONV #( to_upper( root_node->rap_root_node_objects-service_binding ) )
          iv_service_name              = CONV #( to_upper( root_node->rap_root_node_objects-service_binding ) )
          iv_service_version           = 0001
          iv_root_entity_set           = root_node->entityname
          iv_transport                 = CONV #( mo_transport )
          iv_skip_root_entity_list_rep = root_node->is_virtual_root( )
        ).

        CLEAR framework_message.
        framework_message-severity = 'S'.
        framework_message-message = |{ root_node->manage_business_config_names-identifier } registered successfully.| .
        APPEND framework_message TO  c_framework_messages.

      CATCH cx_mbc_api_exception INTO DATA(lx_mbc_api_exception).

        put_exception_occured = abap_true.

        DATA(lt_messages) = lx_mbc_api_exception->if_xco_news~get_messages( ).

        CLEAR framework_message.
        LOOP AT lt_messages INTO DATA(lo_message).
          framework_message-severity = lo_message->value-msgty.
          framework_message-message =  lo_message->get_text( ).
          APPEND framework_message TO c_framework_messages.
        ENDLOOP.
    ENDTRY.

  ENDMETHOD.




  METHOD check_and_add_ext_incl_struc.

    DATA has_extension_include TYPE abap_bool.
    DATA(database_table) = xco_api->get_database_table( iv_name = to_upper( i_node->data_source_name ) ).
    DATA include_structure_name TYPE sxco_ad_object_name  .
    include_structure_name = i_node->rap_node_objects-extension_include.

    DATA(database_table_content) = database_table->content( ).
    DATA(enhancement_category) = database_table_content->get_enhancement_category( )->value.
    IF enhancement_category EQ zdmo_cl_rap_node=>enhancement_category-can_be_enhanced_deep.
      DATA(include_structures_of_table) = database_table_content->get_includes( ).
      LOOP AT include_structures_of_table INTO DATA(my_include_struc).
*        DATA(include_structure) = xco_api->get_structure( iv_name = to_upper( my_include_struc-structure->name ) ).
*        DATA(struc_content) = include_structure->content( ).
*        IF struc_content->get_enhancement_category(  )->value EQ zdmo_cl_rap_node=>enhancement_category-can_be_enhanced_deep.
        IF my_include_struc-structure->name = include_structure_name.
          has_extension_include = abap_true.
*          DATA(field_suffix)  = struc_content->get_field_suffix( ).
        ENDIF.
      ENDLOOP.
      IF has_extension_include = abap_false.
        DATA(inlcude_was_added) = add_include_structure_to_table( i_node ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD create_sap_object_node_type.

    DATA(lo_specification) = mo_put_operation->for-nont->add_object( io_rap_bo_node->rap_node_objects-sap_object_node_type
       )->set_package( mo_package
       )->create_form_specification( ).

    lo_specification->set_short_description( 'Generated SAP Object Node Type' ).

    lo_specification->set_name( io_rap_bo_node->rap_node_objects-sap_object_node_type
      )->set_sap_object_type( io_rap_bo_node->root_node->rap_root_node_objects-sap_object_type ).

    lo_specification->set_root_node( io_rap_bo_node->is_root(  )  ).

    "add object name and type to list of generated repository objects
    CLEAR generated_repository_object.
    generated_repository_object-object_name = io_rap_bo_node->rap_node_objects-sap_object_node_type.
    generated_repository_object-object_type = 'NONT'.
    APPEND generated_repository_object TO generated_repository_objects.



  ENDMETHOD.

  METHOD create_sap_object_type.

    DATA(lo_specification) = mo_put_operation->for-ront->add_object( io_rap_bo_node->rap_root_node_objects-sap_object_type
      )->set_package( io_rap_bo_node->package
      )->create_form_specification( ).
    lo_specification->set_short_description( 'Generated SAP Object Type' ).

    DATA(lo_type_category) = xco_cp_sap_object_type=>type_category->business_object.

    lo_specification->set_type_category( lo_type_category
      )->set_name( io_rap_bo_node->rap_root_node_objects-sap_object_type ).

  ENDMETHOD.

  METHOD store_bo.

    " data is stored in root_node

    DATA update_bonodes TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Node.


    DATA update_fields TYPE TABLE FOR UPDATE ZDMO_R_RAPG_FieldTP.
    DATA update_field TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_FieldTP.

    DATA cid TYPE i.



    DATA xco_lib TYPE REF TO zdmo_cl_rap_xco_lib.
    DATA(xco_on_prem_library) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.

*    WAIT UP TO 5 SECONDS.

    IF root_node->data_source_type = root_node->data_source_types-table.
      DATA(lo_database_table) = xco_lib->get_database_table( CONV  sxco_dbt_object_name( root_node->data_source_name ) ).
      IF lo_database_table->exists(  ) = abap_false.
        COMMIT WORK.
      ENDIF.
      lo_database_table = xco_lib->get_database_table( CONV  sxco_dbt_object_name( root_node->data_source_name ) ).
      IF lo_database_table->exists(  ) = abap_false.
        RETURN.
      ENDIF.
    ENDIF.

    "create BO and root node via action

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
      ENTITY Project
        EXECUTE createProjectAndRootNode  "  createBOandRootNode
          FROM VALUE #( (
          %cid = 'ROOT1'
          %param-BdefImplementationType =  root_node->get_implementation_type( )
          %param-BindingType = root_node->binding_type
          %param-DraftEnabled = root_node->draft_enabled
          %param-entityname = root_node->EntityName
          %param-data_source_name = root_node->data_source_name
          %param-DataSourceType = root_node->data_source_type
          %param-package_name = root_node->package
          %param-isExtensible = root_node->is_extensible(  )
          ) )
             " check result
      MAPPED   DATA(mapped)
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    CHECK mapped-project[] IS NOT INITIAL.


    "get copied root node
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP
                  ENTITY Project BY \_node
                  ALL  FIELDS
                  WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                  RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
                  RESULT DATA(copied_root_nodes).

    CHECK lines( copied_root_nodes ) = 1.

    DATA(copied_root_node) = copied_root_nodes[ 1 ].

    "set fields for copied header and root node

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
    ENTITY Project
    UPDATE FIELDS ( AddToManageBusinessConfig
                    CustomizingTable
                    MultiInlineEdit
                    Suffix
                    Prefix
                    SkipActivation
                    AddIViewBasic
*                    isExtensible
                    "extensibilityElementSuffix
                    )
    WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on
                    RapboUUID = mapped-project[ 1 ]-RapboUUID

                    AddToManageBusinessConfig = root_node->manage_business_configuration
                    CustomizingTable = root_node->is_customizing_table
                    MultiInlineEdit = root_node->multi_edit

                    Suffix = root_node->Suffix
                    Prefix = root_node->Prefix
                    SkipActivation = root_node->skip_activation

                    AddIViewBasic = root_node->add_basic_i_views
*                    isExtensible = rapbo-isExtensible
                    extensibilityElementSuffix = root_node->extensibility_element_suffix
                    ) )

     FAILED   DATA(failed_update_root_bo_node)
     REPORTED DATA(reported_update_root_bo_node).

    "in a second modify we set the field names according to the data from the source project
    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
    ENTITY Node
    UPDATE FIELDS (
*                      DataSource
                    FieldNameCreatedAt
                    FieldNameCreatedby
                    FieldNameEtagMaster
                    FieldNameLastChangedAt
                    FieldNameLastChangedBy
                    FieldNameLocLastChangedAt
                    FieldNameObjectID
                    FieldNameParentUUID
                    FieldNameRootUUID
                    FieldNameTotalEtag
                    FieldNameUUID
                    ExtensibilityElementSuffix
                    )
    WITH VALUE #( (
                    NodeUUID = copied_root_node-NodeUUID
                    %is_draft = if_abap_behv=>mk-on
*                      DataSource = root_node-DataSource
                    "check if the following fields have to be set using a seperate EML call
                    FieldNameCreatedAt = root_node->field_name-created_at
                    FieldNameCreatedby = root_node->field_name-created_by
                    FieldNameEtagMaster = root_node->Field_Name-etag_master
                    FieldNameLastChangedAt = root_node->Field_Name-last_changed_at
                    FieldNameLastChangedBy = root_node->Field_Name-last_changed_by
                    FieldNameLocLastChangedAt = root_node->Field_Name-local_instance_last_changed_at
                    FieldNameObjectID = root_node->object_id
                    FieldNameParentUUID = root_node->Field_Name-parent_uuid
                    FieldNameRootUUID = root_node->Field_Name-Root_UUID
                    FieldNameTotalEtag = root_node->Field_Name-total_etag
                    FieldNameUUID = root_node->Field_Name-uuid
                    ExtensibilityElementSuffix = root_node->extensibility_element_suffix
                    ) )
     FAILED   DATA(failed_update_root_bo_node2)
     REPORTED DATA(reported_update_root_bo_node2).





    "read copied project header data
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP
    ENTITY Project
    ALL FIELDS
    WITH VALUE #( ( %is_draft        = if_abap_behv=>mk-on
                    RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
    RESULT DATA(copied_rapbos).

    CHECK lines( copied_rapbos ) = 1.


    "get created fields
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP
                  ENTITY node
                  BY \_field
                  ALL  FIELDS
                  WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                  NodeUUID    = copied_root_nodes[ 1 ]-NodeUUID  ) )
                  RESULT DATA(new_fields).


*  rapbo_node-EntityName
    "When the project is marked as extensible tables of the source project have a dummy field.

    LOOP AT new_fields INTO DATA(new_field).
      IF line_exists( root_node->lt_fields[ name = new_field-dbtablefield  ] ).
        update_field-FieldUUID = new_field-FieldUUID.
        update_field-%is_draft = if_abap_behv=>mk-on.
        update_field-CdsViewField = root_node->lt_fields[ name = new_field-dbtablefield  ]-cds_view_field.
        APPEND update_field TO update_fields.
      ENDIF.
    ENDLOOP.



    " loop at nodes of the source project beside the root node

    LOOP AT root_node->all_childnodes INTO DATA(rapbo_node).

      cid += 1.

      "get copied rapbo nodes
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP
                    ENTITY Project BY \_node
                    ALL  FIELDS
                    WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                    RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
                    RESULT DATA(copied_rapbo_nodes).

      "get uuid of parent node
      DATA(uuid_of_parent_node) = copied_rapbo_nodes[ EntityName = rapbo_node->parent_node->EntityName ]-NodeUUID.

      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
      ENTITY node
        EXECUTE addChildNode
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = uuid_of_parent_node )
                              %param-entity_name = rapbo_node->EntityName
                              %param-DataSourceName = rapbo_node->data_source_name
                              %param-DataSourceType = root_node->data_source_type
          ) )

      MAPPED   DATA(mapped_add_child)
      FAILED   DATA(failed_add_child)
      REPORTED DATA(reported_add_child).

      "in a second modify we set the field names according to the data from the source project
      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
      ENTITY Node
      UPDATE FIELDS (
*                        DataSource
                      FieldNameCreatedAt FieldNameCreatedby FieldNameEtagMaster FieldNameLastChangedAt FieldNameLastChangedBy
                      FieldNameLocLastChangedAt FieldNameObjectID FieldNameParentUUID FieldNameRootUUID FieldNameTotalEtag
                      FieldNameUUID
                      extensibilityElementSuffix
                      )
      WITH VALUE #( (

                                 NodeUUID = mapped_add_child-node[ 1 ]-NodeUUID
                                 %is_draft = if_abap_behv=>mk-on
*                                   DataSource = rapbo_node-DataSource
                                 "check if the following fields have to be set using a seperate EML call
                                 fieldnamecreatedat = rapbo_node->field_name-created_at
                                 fieldnamecreatedby = rapbo_node->field_name-created_by
                                 fieldnameetagmaster = rapbo_node->field_name-etag_master
                                 fieldnamelastchangedat = rapbo_node->field_name-last_changed_at
                                 fieldnamelastchangedby = rapbo_node->field_name-last_changed_by
                                 fieldnameloclastchangedat = rapbo_node->field_name-local_instance_last_changed_at
                                 fieldnameobjectid = rapbo_node->object_id
                                 fieldnameparentuuid = rapbo_node->field_name-parent_uuid
                                 fieldnamerootuuid = rapbo_node->field_name-root_uuid
                                 fieldnametotaletag = rapbo_node->field_name-total_etag
                                 FieldNameUUID = rapbo_node->field_name-uuid
                                 extensibilityElementSuffix = rapbo_node->extensibility_element_suffix

                      ) )
       FAILED   DATA(failed_update_child_bo_node2)
       REPORTED DATA(reported_update_child_bo_node2).


*        LOOP AT mapped_add_child-field INTO DATA(mapped_add_child_field).

* ENTITY Project BY \_node
*                      ALL  FIELDS
*                      WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
*                                      RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
*                      RESULT DATA(copied_rapbo_nodes).

      "get created fields
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP
                    ENTITY node
                    BY \_field
                    ALL  FIELDS
                    WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                    NodeUUID    = mapped_add_child-node[ 1 ]-NodeUUID  ) )
                    RESULT new_fields.


*  rapbo_node-EntityName

*LOOP AT new_fields INTO DATA(new_field).
*      IF line_exists( root_node->lt_fields[ name = new_field-dbtablefield  ] ).
*        update_field-FieldUUID = new_field-FieldUUID.
*        update_field-%is_draft = if_abap_behv=>mk-on.
*        update_field-CdsViewField = root_node->lt_fields[ name = new_field-dbtablefield  ]-cds_view_field.
*        APPEND update_field TO update_fields.
*      ENDIF.
*    ENDLOOP.


      LOOP AT new_fields INTO new_field.
        IF line_exists( rapbo_node->lt_fields[ name = new_field-dbtablefield  ] ).
          update_field-FieldUUID = new_field-FieldUUID.
          update_field-%is_draft = if_abap_behv=>mk-on.
          update_field-CdsViewField = rapbo_node->lt_fields[ name = new_field-dbtablefield  ]-cds_view_field.
          APPEND update_field TO update_fields.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
            ENTITY Field
            UPDATE FIELDS (
                            CdsViewField
                            )
                          WITH
                      update_fields
                   FAILED   DATA(failed_update_child_bo_node3)
                   REPORTED DATA(reported_update_child_bo_node3).

*    APPEND VALUE #(
*     "von der quelle hier im Schlüssel
*                     rapbouuid  = rapbo-RapboUUID "  mapped-rapgeneratorbo[ 1 ]-RapNodeUUID
*                     %is_draft = rapbo-%is_draft "  mapped-rapgeneratorbo[ 1 ]-%is_draft
*                     "hier steht was rauskommt
*                     "also mapping der alten auf neue keys
*                     %param = VALUE #( %is_draft = mapped-project[ 1 ]-%is_draft
*                                       %key      = mapped-project[ 1 ]-%key ) ) TO result.

  ENDMETHOD.

ENDCLASS.
