CLASS ltc_rap_root_node DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS:
      gc_namespace_z                 TYPE sxco_ar_object_name VALUE 'Z',
      gc_namespace_contains_blanks   TYPE sxco_ar_object_name VALUE 'Z T',
      gc_namespace_contains_nonalpha TYPE sxco_ar_object_name VALUE 'Z$T',
      gc_root_entity_name            TYPE sxco_ddef_alias_name VALUE 'Travel',
      gc_root_ent_contains_blanks    TYPE sxco_ddef_alias_name VALUE 'Trav  el',
      gc_root_ent_contains_nonalpha  TYPE sxco_ddef_alias_name VALUE 'Trave&l',
      gc_prefix_rap                  TYPE sxco_ar_object_name VALUE 'RAP_',
      gc_prefix_contains_blanks      TYPE sxco_ar_object_name VALUE 'R AP_',
      gc_prefix_contains_nonalpha    TYPE sxco_ar_object_name VALUE 'R%P_',
      gc_suffix_1234                 TYPE sxco_ar_object_name VALUE '_1234',
      gc_suffix_contains_blanks      TYPE sxco_ar_object_name VALUE '_1 34',
      gc_suffix_contains_nonalpha    TYPE sxco_ar_object_name VALUE '_1&34',
      gc_ddic_view_i_name_z          TYPE sxco_dbt_object_name  VALUE 'TRAV00'.


    DATA:
       mo_cut TYPE REF TO zcl_rap_node.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      create_a_root_node FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS zcl_rap_node_m_uuid_root DEFINITION LOCAL FRIENDS ltc_rap_root_node.

CLASS ltc_rap_root_node IMPLEMENTATION.

  METHOD class_setup.
    "create test doubles for the following tables that are read or written to by this class
    "this should be only done once we thus do this in the class method class_setup
  ENDMETHOD.

  METHOD class_teardown.

  ENDMETHOD.

  METHOD setup.
    "create test data so that three different nodes can be created
  ENDMETHOD.

  METHOD teardown.
    "teardown is called for every test. So if data exists it should be cleared
  ENDMETHOD.



  METHOD create_a_root_node.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.



    TRY.
        mo_cut = NEW zcl_rap_node_m_uuid_root( gc_root_entity_name ).
      CATCH zcx_rap_generator.
        cl_abap_unit_assert=>fail(  ).
    ENDTRY.

    TRY.
        mo_cut->set_root( mo_cut  ).
        mo_cut->set_parent( mo_cut ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).

        mo_cut->finalize(  ).
        lv_name = mo_cut->rap_node_objects-cds_view_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator.
        cl_abap_unit_assert=>fail(  ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
