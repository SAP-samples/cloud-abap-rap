CLASS zdmo_cl_rap_xco_lib DEFINITION ABSTRACT
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES t_abap_obj_directory_entries TYPE STANDARD TABLE OF I_CustABAPObjDirectoryEntry WITH DEFAULT KEY.
    TYPES t_abap_obj_directory_entry TYPE I_CustABAPObjDirectoryEntry.

    DATA todos TYPE TABLE OF string WITH EMPTY KEY READ-ONLY.

    METHODS get_service_definition     IMPORTING iv_name                      TYPE sxco_srvd_object_name
                                       RETURNING VALUE(ro_service_definition) TYPE REF TO if_xco_service_definition  .
    METHODS get_service_binding        IMPORTING iv_name                   TYPE sxco_srvb_object_name
                                       RETURNING VALUE(ro_service_binding) TYPE REF TO if_xco_service_binding  .
    METHODS get_behavior_definition    IMPORTING iv_name                       TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_behavior_definition) TYPE REF TO if_xco_behavior_definition  .
    METHODS get_class                  IMPORTING iv_name         TYPE  sxco_ao_object_name "sxco_cds_object_name
                                       RETURNING VALUE(ro_class) TYPE REF TO if_xco_ao_class  .
    METHODS get_package                IMPORTING iv_name           TYPE sxco_package
                                       RETURNING VALUE(ro_package) TYPE REF TO if_xco_package   .
    METHODS get_database_table         IMPORTING iv_name         TYPE sxco_dbt_object_name
                                       RETURNING VALUE(ro_table) TYPE REF TO if_xco_database_table  .
    METHODS get_structure              IMPORTING iv_name             TYPE  sxco_ad_object_name
                                       RETURNING VALUE(ro_structure) TYPE REF TO if_xco_ad_structure   .
    METHODS get_data_definition        IMPORTING iv_name                   TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_data_definition) TYPE REF TO if_xco_data_definition .
    METHODS get_metadata_extension     IMPORTING iv_name                      TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_metadata_extension) TYPE REF TO if_xco_metadata_extension  .
    METHODS get_view_entity            IMPORTING iv_name               TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_view_entity) TYPE REF TO if_xco_cds_view_entity .
    METHODS get_view                   IMPORTING iv_name        TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_view) TYPE REF TO if_xco_cds_view .
    METHODS get_entity                 IMPORTING iv_name          TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_entity) TYPE REF TO if_xco_cds_entity .
    METHODS get_abstract_entity        IMPORTING iv_name                   TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_abstract_entity) TYPE REF TO if_xco_cds_entity .
    METHODS get_aggregated_annotations IMPORTING io_field                         TYPE REF TO if_xco_cds_field
                                       RETURNING VALUE(ro_aggregated_annotations) TYPE REF TO if_xco_cds_annotations .
    METHODS add_draft_include          IMPORTING table_name TYPE sxco_dbt_object_name.
    METHODS method_exists_in_interface IMPORTING interface_name       TYPE any
                                                 method_name          TYPE c
                                       RETURNING VALUE(method_exists) TYPE abap_bool.
    METHODS method_exists_in_class IMPORTING class_name           TYPE any
                                             method_name          TYPE c
                                   RETURNING VALUE(method_exists) TYPE abap_bool.
    METHODS attribute_exists_in_class IMPORTING class_name              TYPE any
                                                attribute_name          TYPE c
                                      RETURNING VALUE(attribute_exists) TYPE abap_bool.
    METHODS attribute_exists_in_interface IMPORTING interface_name          TYPE any
                                                    attribute_name          TYPE c
                                          RETURNING VALUE(attribute_exists) TYPE abap_bool.

    METHODS  get_tables                IMPORTING it_filters       TYPE sxco_t_ar_filters OPTIONAL "io_filter type ref to if_xco_ar_filter OPTIONAL
                                       RETURNING VALUE(rt_tables) TYPE sxco_t_database_tables.
    METHODS  get_structures            IMPORTING it_filters           TYPE sxco_t_ar_filters OPTIONAL "io_filter type ref to if_xco_ar_filter OPTIONAL
                                       RETURNING VALUE(rt_structures) TYPE sxco_t_ad_structures .
    METHODS  get_views                 IMPORTING it_filters                 TYPE sxco_t_ar_filters OPTIONAL"type ref to if_xco_ar_filter OPTIONAL
                                       RETURNING VALUE(rt_data_definitions) TYPE sxco_t_data_definitions .
    METHODS  get_packages              IMPORTING it_filters         TYPE sxco_t_ar_filters OPTIONAL"io_filter type ref to if_xco_ar_filter OPTIONAL
                                       RETURNING VALUE(rt_packages) TYPE sxco_t_packages  .

    METHODS  todo                      IMPORTING todo TYPE string.

    METHODS  on_premise_branch_is_used RETURNING VALUE(r_value) TYPE abap_bool.

    METHODS get_abap_language_version  IMPORTING iv_name                        TYPE sxco_package
                                       RETURNING VALUE(r_abap_language_version) TYPE sychar01 .


    METHODS get_root_exception IMPORTING ix_exception   TYPE REF TO cx_root
                               RETURNING VALUE(rx_root) TYPE REF TO cx_root  .

    METHODS publish_service_binding IMPORTING i_service_binding TYPE sxco_srvb_object_name
                                    RAISING   zdmo_cx_rap_generator.

    METHODS un_publish_service_binding IMPORTING i_service_binding TYPE sxco_srvb_object_name
                                       RAISING   zdmo_cx_rap_generator .

    METHODS service_binding_is_published IMPORTING i_service_binding     TYPE sxco_srvb_object_name
                                         RETURNING VALUE(r_is_published) TYPE abap_bool
                                         RAISING   zdmo_cx_rap_generator.

    METHODS get_ABAP_Obj_Directory_Entry IMPORTING i_ABAP_Object_Type                   TYPE t_abap_obj_directory_entry-ABAPObjectType "trobjtype "= 'DEVC'
                                                   i_ABAP_Object_Category               TYPE t_abap_obj_directory_entry-ABAPObjectCategory "= 'R3TR'
                                                   i_ABAP_Object                        TYPE t_abap_obj_directory_entry-ABAPObject " @delete_objects_in_package
                                         RETURNING VALUE(r_ABAP_Object_Directory_Entry) TYPE t_abap_obj_directory_entry.

    METHODS get_objects_in_package IMPORTING i_package                 TYPE sxco_package
                                   RETURNING VALUE(r_objects_in_package) TYPE t_abap_obj_directory_entries.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_XCO_LIB IMPLEMENTATION.


  METHOD add_draft_include.

  ENDMETHOD.


  METHOD attribute_exists_in_class.
    attribute_exists = abap_false.
    DATA(descr_ref_class) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( class_name ) ).
    IF line_exists( descr_ref_class->attributes[ name = to_upper( attribute_name ) ]  ).
      attribute_exists = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD attribute_exists_in_interface.
    attribute_exists = abap_false.
    DATA(descr_ref_intf) = CAST cl_abap_intfdescr( cl_abap_typedescr=>describe_by_name( interface_name ) ).
    IF line_exists( descr_ref_intf->attributes[ name = to_upper( attribute_name ) ]  ).
      attribute_exists = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD get_abap_language_version.
    r_abap_language_version = ZDMO_cl_rap_node=>package_abap_language_version-abap_for_sap_cloud_platform. "abap_language_version-abap_for_cloud_development.
  ENDMETHOD.


  METHOD get_abap_obj_directory_entry.

  ENDMETHOD.


  METHOD get_abstract_entity.

  ENDMETHOD.


  METHOD get_aggregated_annotations.

  ENDMETHOD.


  METHOD get_behavior_definition.

  ENDMETHOD.


  METHOD get_class.

  ENDMETHOD.


  METHOD get_database_table.

  ENDMETHOD.


  METHOD get_data_definition.

  ENDMETHOD.


  METHOD get_entity.

  ENDMETHOD.


  METHOD get_metadata_extension.

  ENDMETHOD.


  METHOD get_objects_in_package.

  ENDMETHOD.


  METHOD get_package.

  ENDMETHOD.


  METHOD get_packages.

  ENDMETHOD.


  METHOD get_root_exception.
    rx_root = ix_exception.
    WHILE rx_root->previous IS BOUND.
      rx_root ?= rx_root->previous.
    ENDWHILE.
  ENDMETHOD.


  METHOD get_service_binding.

  ENDMETHOD.


  METHOD get_service_definition.

  ENDMETHOD.


  METHOD get_structure.

  ENDMETHOD.


  METHOD get_structures.

  ENDMETHOD.


  METHOD get_tables.

  ENDMETHOD.


  METHOD get_view.

  ENDMETHOD.


  METHOD get_views.

  ENDMETHOD.


  METHOD get_view_entity.

  ENDMETHOD.


  METHOD method_exists_in_class.
    method_exists = abap_false.
    DATA(descr_ref_class) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( class_name ) ).
    IF line_exists( descr_ref_class->methods[ name = to_upper( method_name ) ] ).
      method_exists = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD method_exists_in_interface.
    method_exists = abap_false.
    DATA(descr_ref_intf) = CAST cl_abap_intfdescr( cl_abap_typedescr=>describe_by_name( interface_name ) ).
    IF line_exists( descr_ref_intf->methods[ name = to_upper( method_name ) ] ).
      method_exists = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD on_premise_branch_is_used.
    r_value = abap_false.
  ENDMETHOD.


  METHOD publish_service_binding.

  ENDMETHOD.


  METHOD service_binding_is_published.

  ENDMETHOD.


  METHOD todo.
    APPEND todo TO todos.
  ENDMETHOD.


  METHOD un_publish_service_binding.
*    RAISE EXCEPTION TYPE zdmo_cx_rap_generator
*      EXPORTING
*        textid   = zdmo_cx_rap_generator=>method_not_implemented
*        mv_value = 'un_publish_service_binding'.
  ENDMETHOD.
ENDCLASS.
