CLASS /dmo/cl_rap_xco_on_prem_lib DEFINITION INHERITING FROM /dmo/cl_rap_xco_lib
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
    METHODS add_draft_include REDEFINITION.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /dmo/cl_rap_xco_on_prem_lib IMPLEMENTATION.


  METHOD  get_aggregated_annotations.
*    ro_aggregated_annotations = xco_cds=>annotations->aggregated->of( io_field ).
  ENDMETHOD.


  METHOD  get_behavior_definition.
*    ro_behavior_definition = xco_abap_repository=>object->bdef->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_class.
*    ro_class = xco_abap_repository=>object->clas->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_database_table.
*    ro_table = xco_abap_repository=>object->tabl->database_table->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_data_definition.
*    ro_data_definition = xco_abap_repository=>object->ddls->for( iv_name  ).
  ENDMETHOD.


  METHOD get_entity.
*    ro_entity = xco_cds=>view_entity( iv_name ).
  ENDMETHOD.


  METHOD  get_metadata_extension.
*    ro_metadata_extension  = xco_abap_repository=>object->ddlx->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_package.
*    ro_package = xco_abap_repository=>object->devc->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_service_binding.
*    ro_service_binding = xco_abap_repository=>object->srvb->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_service_definition.
*    ro_service_definition = xco_abap_repository=>object->srvd->for( iv_name  ).
  ENDMETHOD.


  METHOD  get_structure.
*    ro_structure = xco_abap_repository=>object->tabl->structure->for( iv_name  ).
  ENDMETHOD.


  METHOD get_view.
*    ro_view = xco_cds=>view( iv_name ).
  ENDMETHOD.


  METHOD get_view_entity.
*    ro_view_entity = xco_cds=>view_entity( iv_name ).
  ENDMETHOD.

  METHOD get_abstract_entity.
*    ro_abstract_entity = xco_cds=>abstract_entity( iv_name ).
  ENDMETHOD.

  METHOD add_draft_include.
*    DATA:
*      draft_template_table_name TYPE ddobjname,
*      draft_table_name          TYPE ddobjname,
*      lv_return                 TYPE syst_subrc,
*      lt_dd03p                  TYPE TABLE OF dd03p,
*      lt_dd03p_draft            TYPE TABLE OF dd03p,
*      lt_dd12v                  TYPE TABLE OF dd12v,
*      lt_dd17v                  TYPE TABLE OF dd17v,
*      ls_dd02v                  TYPE dd02v,
*      ls_dd09l                  TYPE dd09l,
*      state                     TYPE ddgotstate,
*      position                  TYPE i.
*
*    FIELD-SYMBOLS:
*      <ls_dd03p>           TYPE dd03p.
*
*    draft_template_table_name  = '/DMO/DRAFT_INCL'.
*    draft_table_name  = table_name.
*
*    "get information about draft include from template table
*
*    CALL FUNCTION 'DDIF_TABL_GET'
*      EXPORTING
*        name          = draft_template_table_name
*        state         = 'A'
*      IMPORTING
*        gotstate      = state
*        dd02v_wa      = ls_dd02v
*        dd09l_wa      = ls_dd09l
*      TABLES
*        dd03p_tab     = lt_dd03p_draft
*        dd12v_tab     = lt_dd12v
*        dd17v_tab     = lt_dd17v
*      EXCEPTIONS
*        illegal_input = 1
*        OTHERS        = 2.
*
*    IF sy-subrc <> 0.
*      "RAISE EXCEPTION TYPE cx_cnv_indx_iuuc.
*      ASSERT 1 = 0.
*
*    ENDIF.
*
*    "get draft table information.
*    CALL FUNCTION 'DDIF_TABL_GET'
*      EXPORTING
*        name          = draft_table_name
*        state         = 'A'
*      IMPORTING
*        gotstate      = state
*        dd02v_wa      = ls_dd02v
*        dd09l_wa      = ls_dd09l
*      TABLES
*        dd03p_tab     = lt_dd03p
*        dd12v_tab     = lt_dd12v
*        dd17v_tab     = lt_dd17v
*      EXCEPTIONS
*        illegal_input = 1
*        OTHERS        = 2.
*
*    IF sy-subrc <> 0.
*      ASSERT 1 = 0.
*    ENDIF.
*
*    "add draft include structure to draft table
*    IF lt_dd03p IS NOT INITIAL.
*
*
*      position = lines( lt_dd03p ).
*
*
*      LOOP AT lt_dd03p_draft INTO DATA(ls_dd03p_draft)  .
*        ls_dd03p_draft-tabname = draft_table_name.
*
*        CASE ls_dd03p_draft-fieldname.
*          WHEN '.INCLUDE'.
*            position += 1.
*            ls_dd03p_draft-position = position.
*            APPEND ls_dd03p_draft TO lt_dd03p.
*          WHEN 'DRAFTENTITYCREATIONDATETIME' .
*            position += 1.
*            ls_dd03p_draft-position = position.
*            APPEND ls_dd03p_draft TO lt_dd03p.
*          WHEN 'DRAFTENTITYLASTCHANGEDATETIME'.
*            position += 1.
*            ls_dd03p_draft-position = position.
*            APPEND ls_dd03p_draft TO lt_dd03p.
*          WHEN 'DRAFTADMINISTRATIVEDATAUUID' .
*            position += 1.
*            ls_dd03p_draft-position = position.
*            APPEND ls_dd03p_draft TO lt_dd03p.
*          WHEN 'DRAFTENTITYOPERATIONCODE' .
*            position += 1.
*            ls_dd03p_draft-position = position.
*            APPEND ls_dd03p_draft TO lt_dd03p.
*          WHEN 'HASACTIVEENTITY' .
*            position += 1.
*            ls_dd03p_draft-position = position.
*            APPEND ls_dd03p_draft TO lt_dd03p.
*          WHEN'DRAFTFIELDCHANGES'.
*            position += 1.
*            ls_dd03p_draft-position = position.
*            APPEND ls_dd03p_draft TO lt_dd03p.
*        ENDCASE.
*      ENDLOOP.
*    ELSE.
*      ASSERT 1 = 0.
*    ENDIF.
*
*    "change draft table
*    CALL FUNCTION 'DDIF_TABL_PUT'
*      EXPORTING
*        name              = draft_table_name
*        dd02v_wa          = ls_dd02v
*        dd09l_wa          = ls_dd09l
*      TABLES
*        dd03p_tab         = lt_dd03p
*      EXCEPTIONS
*        tabl_not_found    = 1
*        name_inconsistent = 2
*        tabl_inconsistent = 3
*        put_failure       = 4
*        put_refused       = 5
*        OTHERS            = 6.
*
*    IF sy-subrc <> 0.
*      ASSERT 1 = 0.
*    ELSE.
*
*      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
*        EXPORTING
*          name        = draft_table_name
*          auth_chk    = ' '
*        IMPORTING
*          rc          = lv_return
*        EXCEPTIONS
*          not_found   = 1
*          put_failure = 2
*          OTHERS      = 3.
*      IF sy-subrc <> 0.
*        ASSERT 1 = 0.
*      ENDIF.
*    ENDIF.

  ENDMETHOD.


ENDCLASS.
