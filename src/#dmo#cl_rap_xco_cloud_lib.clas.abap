CLASS /dmo/cl_rap_xco_cloud_lib DEFINITION INHERITING FROM /dmo/cl_rap_xco_lib
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


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /dmo/cl_rap_xco_cloud_lib IMPLEMENTATION.


  METHOD  get_aggregated_annotations.
    ro_aggregated_annotations = xco_cp_cds=>annotations->aggregated->of( io_field ).
  ENDMETHOD.


  METHOD  get_behavior_definition.
    ro_behavior_definition = xco_cp_abap_repository=>object->bdef->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_class.
    ro_class = xco_cp_abap_repository=>object->clas->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_database_table.
    ro_table = xco_cp_abap_repository=>object->tabl->database_table->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_data_definition.
    ro_data_definition = xco_cp_abap_repository=>object->ddls->for( iv_name  ).
  ENDMETHOD.


  METHOD get_entity.
    ro_entity = xco_cp_cds=>entity( iv_name ).
  ENDMETHOD.


  METHOD  get_metadata_extension.
    ro_metadata_extension  = xco_cp_abap_repository=>object->ddlx->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_package.
    ro_package = xco_cp_abap_repository=>object->devc->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_service_binding.
    ro_service_binding = xco_cp_abap_repository=>object->srvb->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_service_definition.
    ro_service_definition = xco_cp_abap_repository=>object->srvd->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_structure.
    ro_structure = xco_cp_abap_repository=>object->tabl->structure->for( iv_name  ).
  ENDMETHOD.


  METHOD get_view.
    ro_view = xco_cp_cds=>view( iv_name ).
  ENDMETHOD.


  METHOD get_view_entity.
    ro_view_entity = xco_cp_cds=>view_entity( iv_name ).
  ENDMETHOD.

  METHOD get_abstract_entity.
    ro_abstract_entity = xco_cp_cds=>abstract_entity( iv_name ).
  ENDMETHOD.

ENDCLASS.
