CLASS zdmo_cl_rap_xco_cloud_lib DEFINITION INHERITING FROM ZDMO_cl_rap_xco_lib
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
    METHODS get_views REDEFINITION.
    METHODS get_tables REDEFINITION.
    METHODS get_structures REDEFINITION.
    METHODS get_packages REDEFINITION.
    METHODS service_binding_is_published REDEFINITION.
    METHODS get_abap_obj_directory_entry REDEFINITION.
    METHODS get_objects_in_package REDEFINITION.

    METHODS publish_service_binding REDEFINITION.
    METHODS un_publish_service_binding REDEFINITION.

    METHODS get_sap_object_node_type REDEFINITION.
    METHODS get_sap_object_type REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.



ENDCLASS.



CLASS zdmo_cl_rap_xco_cloud_lib IMPLEMENTATION.


  METHOD get_abap_obj_directory_entry.
    SELECT SINGLE * FROM
     I_CustABAPObjDirectoryEntry "ObjDirectoryEntry
     WHERE ABAPObjectType = @i_abap_object_type
       AND ABAPObjectCategory = @i_abap_object_category
       AND ABAPObject = @i_abap_object
       INTO CORRESPONDING FIELDS OF @r_abap_object_directory_entry.
  ENDMETHOD.


  METHOD get_abstract_entity.
    ro_abstract_entity = xco_cp_cds=>abstract_entity( iv_name ).
  ENDMETHOD.


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


  METHOD get_objects_in_package.
    SELECT * FROM I_CustABAPObjDirectoryEntry WHERE ABAPPackage = @i_package
                                              INTO CORRESPONDING FIELDS OF TABLE @r_objects_in_package .
  ENDMETHOD.


  METHOD  get_package.
    ro_package = xco_cp_abap_repository=>object->devc->for( iv_name  ).
  ENDMETHOD.


  METHOD get_packages.
    IF it_filters IS NOT INITIAL.
      rt_packages =  xco_cp_abap_repository=>objects->devc->where( it_Filters
*       VALUE #(
*                                              ( io_filter )
*                                              )
                                              )->in( xco_cp_abap=>repository )->get( ).
    ELSE.
      rt_packages = xco_cp_abap_repository=>objects->devc->all->in( xco_cp_abap=>repository )->get( ).
    ENDIF.
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


  METHOD get_structures.
    IF it_filters IS NOT INITIAL.
      rt_structures =  xco_cp_abap_repository=>objects->tabl->structures->where( it_filters
*       VALUE #(
*                                              ( io_filter )
*                                              )
                                              )->in( xco_cp_abap=>repository )->get( ).
    ELSE.
      rt_structures = xco_cp_abap_repository=>objects->tabl->structures->all->in( xco_cp_abap=>repository )->get( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_tables.
    IF it_filters IS NOT INITIAL.
      rt_tables = xco_cp_abap_repository=>objects->tabl->database_tables->where( it_filters
*      VALUE #(
*                                  ( io_filter )
*                                  )
                                  )->in( xco_cp_abap=>repository )->get( ).

    ELSE.
      rt_tables = xco_cp_abap_repository=>objects->tabl->database_tables->all->in( xco_cp_abap=>repository )->get( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_view.
    ro_view = xco_cp_cds=>view( iv_name ).
  ENDMETHOD.


  METHOD get_views.
    IF it_filters IS NOT INITIAL.
      rt_data_definitions =  xco_cp_abap_repository=>objects->ddls->where( it_filters
*                                             VALUE #(
*                                              ( io_filter )
*                                              )
                                              )->in( xco_cp_abap=>repository )->get( ).
    ELSE.
      rt_data_definitions = xco_cp_abap_repository=>objects->ddls->all->in( xco_cp_abap=>repository )->get( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_view_entity.
    ro_view_entity = xco_cp_cds=>view_entity( iv_name ).
  ENDMETHOD.


  METHOD publish_service_binding.
*    DATA(lo_service_binding) = xco_cp_abap_repository=>object->srvb->for( '$SERVICE_BINDING_NAME$' ).

    DATA(lo_service_binding) = get_service_binding( i_service_binding ).

    " First we check whether the local service endpoint for LO_SERVICE_BINDING is
    " currently published.
    DATA(lv_is_published) = xco_cp_service_binding=>local_service_endpoint->odata_v4->is_published( lo_service_binding ).

    " Depending on whether the local service endpoint is currently published we either
    " trigger an unpublish or a publish of the local service endpoint.
    DATA lo_operation TYPE REF TO if_xco_srvb_operation.

    IF lv_is_published EQ abap_false.
*      lo_operation = xco_cp_service_binding=>local_service_endpoint->odata_v4->operation->unpublish( lo_service_binding ).
*    ELSE.
      lo_operation = xco_cp_service_binding=>local_service_endpoint->odata_v4->operation->publish( lo_service_binding ).
      " Note that both a publish as well as an unpublish operation are concrete
      " realizations of an IF_XCO_SRVB_OPERATION and can thus be treated uniformly.
      " Regardless of the concrete realization of the operation, its execution can
      " always be triggered via the method EXECUTE.
      lo_operation->execute( ).
    ENDIF.


  ENDMETHOD.


  METHOD service_binding_is_published.
    r_is_published = abap_false.

    "object names in I_CustABAPObjDirectoryEntry are stored in upper case
    "( ABAPObjectCategory = 'R3TR' ABAPObjectType = 'SIA6' ABAPObject = 'ZUI_BDTSTRAVEL_O4_0001_G4BA_IBS'

    DATA(filter_string) = to_upper( i_service_binding && '%' ).

    SELECT * FROM I_CustABAPObjDirectoryEntry WHERE ABAPObject LIKE @filter_string
                                                AND ABAPObjectType = 'SIA6'
                                               INTO TABLE @DATA(published_srvb_entries).

    IF lines( published_srvb_entries ) > 0.
      r_is_published = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD un_publish_service_binding.

    DATA(lo_service_binding) = get_service_binding( i_service_binding ).

    " First we check whether the local service endpoint for LO_SERVICE_BINDING is
    " currently published.
    DATA(lv_is_published) = xco_cp_service_binding=>local_service_endpoint->odata_v4->is_published( lo_service_binding ).

    " Depending on whether the local service endpoint is currently published we either
    " trigger an unpublish or a publish of the local service endpoint.
    DATA lo_operation TYPE REF TO if_xco_srvb_operation.

    IF lv_is_published EQ abap_true.
      lo_operation = xco_cp_service_binding=>local_service_endpoint->odata_v4->operation->unpublish( lo_service_binding ).
*    ELSE.
*      lo_operation = xco_cp_service_binding=>local_service_endpoint->odata_v4->operation->publish( lo_service_binding ).
      " Note that both a publish as well as an unpublish operation are concrete
      " realizations of an IF_XCO_SRVB_OPERATION and can thus be treated uniformly.
      " Regardless of the concrete realization of the operation, its execution can
      " always be triggered via the method EXECUTE.
      lo_operation->execute( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_sap_object_node_type.
    ro_sap_object_node_type = xco_cp_abap_repository=>object->nont->for( iv_name ).
  ENDMETHOD.

  METHOD get_sap_object_type.
    ro_sap_object_type = xco_cp_abap_repository=>object->ront->for( iv_name ).
  ENDMETHOD.

ENDCLASS.
