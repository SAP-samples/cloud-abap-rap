CLASS /dmo/cl_rap_xco_lib DEFINITION ABSTRACT
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

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
    METHODS get_abstract_entity        IMPORTING iv_name          TYPE sxco_cds_object_name
                                       RETURNING VALUE(ro_abstract_entity) TYPE REF TO if_xco_cds_entity .
    METHODS get_aggregated_annotations IMPORTING io_field                         TYPE REF TO if_xco_cds_field
                                       RETURNING VALUE(ro_aggregated_annotations) TYPE REF TO if_xco_cds_annotations .
    METHODS add_draft_include          IMPORTING table_name TYPE sxco_dbt_object_name.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /dmo/cl_rap_xco_lib IMPLEMENTATION.


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


  METHOD get_package.

  ENDMETHOD.

  METHOD get_service_binding.

  ENDMETHOD.


  METHOD get_service_definition.

  ENDMETHOD.


  METHOD get_structure.

  ENDMETHOD.


  METHOD get_view.

  ENDMETHOD.


  METHOD get_view_entity.

  ENDMETHOD.

  METHOD add_draft_include.

  ENDMETHOD.

  METHOD get_abstract_entity.

  ENDMETHOD.

ENDCLASS.
