*"* use this source file for your ABAP unit test classes
CLASS ltc_rap_node DEFINITION FINAL FOR TESTING
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
      gc_ddic_view_i_name_z          TYPE sxco_dbt_object_name  VALUE 'TRAV00',
      gc_entity_child1               TYPE sxco_ddef_alias_name VALUE 'Booking',
      gc_entity_child2               TYPE sxco_ddef_alias_name VALUE 'Booking2',
      gc_entity_grandchild11         TYPE sxco_ddef_alias_name VALUE 'BookingSuppl',
      gc_root_table                  TYPE sxco_dbt_object_name  VALUE 'ZRAP_TRAVEL_DEMO',
      gc_child_table                 TYPE sxco_dbt_object_name  VALUE 'ZRAP_BOOK_DEMO',
      gc_grandchild_table            TYPE sxco_dbt_object_name  VALUE 'ZRAP_BOOKS_DEMO'.


    DATA:
       mo_cut TYPE REF TO zcl_rap_node.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      set_namespace FOR TESTING RAISING cx_static_check,
      set_prefix FOR TESTING RAISING cx_static_check,
      set_suffix FOR TESTING RAISING cx_static_check,
      set_cds_view_i_name FOR TESTING RAISING cx_static_check,
      set_cds_view_p_name FOR TESTING RAISING cx_static_check,
      set_mde_name FOR TESTING RAISING cx_static_check,
      set_ddic_view_i_name FOR TESTING RAISING cx_static_check,
      set_behavior_def_i_name FOR TESTING RAISING cx_static_check ,
      set_behavior_def_p_name FOR TESTING RAISING cx_static_check ,
      set_behavior_impl_name FOR TESTING RAISING cx_static_check ,
      set_service_definition_name FOR TESTING RAISING cx_static_check,
      set_service_binding_name FOR TESTING RAISING cx_static_check,
      set_entityname FOR TESTING RAISING cx_static_check,
      create_a_root_node FOR TESTING RAISING cx_static_check,
      create_root_with_childs FOR TESTING RAISING cx_static_check,
      set_table FOR TESTING RAISING cx_static_check,
      get_fields FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS Zcl_rap_node DEFINITION LOCAL FRIENDS ltc_rap_node.

CLASS ltc_rap_node IMPLEMENTATION.

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

  METHOD set_namespace.

    DATA : lv_namespace TYPE string.

    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).

        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    " When the namespace is set to 'Z'
    " Then the member variable namespace of the node must have the value 'Z' as well
    TRY.
        mo_cut->set_namespace( gc_namespace_z  ).
        lv_namespace = mo_cut->namespace.
        cl_abap_unit_assert=>assert_equals( exp = gc_namespace_z act = lv_namespace ).
      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    " When the a namespace that contains blanks is set
    "then an exception with
    "message id : zcx_rap_generator=>contains_spaces-msgid
    "message number : zcx_rap_generator=>contains_spaces-msgno
    "must be raised

    TRY.

        mo_cut->set_namespace( gc_namespace_contains_blanks ).

      CATCH zcx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.

    "When a namespace that contains non alpha numeric characters is set
    "then an exception with
    "message id : zcx_rap_generator=>NON_ALPHA_NUMERIC_CHARACTERS-msgid
    "message number : zcx_rap_generator=>NON_ALPHA_NUMERIC_CHARACTERS-msgno
    "must be raised

    TRY.

        mo_cut->set_namespace( gc_namespace_contains_nonalpha ).

      CATCH zcx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.

  ENDMETHOD.

  METHOD set_prefix.

    DATA : lv_prefix TYPE string.

    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.

        mo_cut->set_prefix( gc_prefix_rap ).

        lv_prefix = mo_cut->prefix.
        cl_abap_unit_assert=>assert_equals( exp = gc_prefix_rap act = lv_prefix ).
      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.

        mo_cut->set_prefix( gc_prefix_contains_blanks ).
        lv_prefix = mo_cut->prefix.
        cl_abap_unit_assert=>assert_equals( exp = gc_prefix_rap act = lv_prefix ).

      CATCH zcx_rap_generator INTO lx_rap_generator .



        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.

    TRY.

        mo_cut->set_prefix( gc_prefix_contains_nonalpha ).

      CATCH zcx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.

  ENDMETHOD.

  METHOD set_suffix.

    DATA : lv_suffix TYPE string.

    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.

        mo_cut->set_suffix( gc_suffix_1234 ).

        lv_suffix = mo_cut->suffix.
        cl_abap_unit_assert=>assert_equals( exp = gc_suffix_1234 act = lv_suffix ).
      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.

        mo_cut->set_suffix( gc_suffix_contains_blanks ).

      CATCH zcx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.

    TRY.

        mo_cut->set_suffix( gc_suffix_contains_nonalpha ).

      CATCH zcx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.

  ENDMETHOD.


  METHOD set_cds_view_i_name.

    "check

    DATA(lv_expected_name) = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_cds_view_i_name(  ).
        lv_name = mo_cut->rap_node_objects-cds_view_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_cds_view_p_name.
    "check

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_cds_view_p_name(  ).
        lv_name = mo_cut->rap_node_objects-cds_view_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD set_mde_name.
    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_mde_name(  ).
        lv_name = mo_cut->rap_node_objects-meta_data_extension.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD set_ddic_view_i_name.

    "in set_ddic_view_i_name the object me->root_node is initial when run under test
    "setting the root node as me is only possible for root nodes.
    "hence we skipt this code

    TEST-INJECTION is_not_a_root_node.
    END-TEST-INJECTION.

    "ZRAP_TRAVE00_048
    DATA(lv_expected_name) = |{ gc_namespace_z  }{ gc_prefix_rap }{ gc_ddic_view_i_name_z }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_ddic_view_i_name(  ).

        lv_name = mo_cut->rap_node_objects-ddic_view_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD set_behavior_def_i_name.
    "check
    TEST-INJECTION test_run_base_class.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    DATA(lv_expected_name) = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_behavior_def_i_name(  ).
        lv_name = mo_cut->rap_root_node_objects-behavior_definition_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD set_behavior_def_p_name.

    TEST-INJECTION test_run_base_class.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_behavior_def_p_name(  ).
        lv_name = mo_cut->rap_root_node_objects-behavior_definition_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_behavior_impl_name.

    DATA(lv_expected_name) = |{ gc_namespace_z  }BP_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_behavior_impl_name(  ).
        lv_name = mo_cut->rap_node_objects-behavior_implementation.

        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_entityname.

    DATA(lv_expected_name) = gc_root_entity_name .

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    lv_name = mo_cut->entityname.
    cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).



    TRY.
        mo_cut = NEW #( gc_root_ent_contains_blanks ).

      CATCH zcx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.

    TRY.

        mo_cut = NEW #( gc_root_ent_contains_nonalpha ).

      CATCH zcx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.


  ENDMETHOD.

  METHOD set_service_binding_name.
    TEST-INJECTION test_run_base_class.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    " DATA(lv_name) =  |{ namespace }UI_{ prefix }{ entityname }_M{ suffix }|.
    DATA(lv_expected_name) = |{ gc_namespace_z  }UI_{ gc_prefix_rap }{ gc_root_entity_name }_M{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_service_binding_name( ).
        lv_name = mo_cut->rap_root_node_objects-service_binding.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD set_service_definition_name.
    TEST-INJECTION test_run_base_class.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    " DATA(lv_name) =  |{ namespace }UI_{ prefix }{ entityname }_M{ suffix }|.
    DATA(lv_expected_name) = |{ gc_namespace_z  }UI_{ gc_prefix_rap }{ gc_root_entity_name }_M{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_service_definition_name(  ).
        lv_name = mo_cut->rap_root_node_objects-service_definition.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_a_root_node.
    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.



    TRY.
        mo_cut = NEW zcl_rap_node_m_uuid_root( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
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

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_root_with_childs.

    DATA lv_name TYPE string.
    DATA lv_expected_name TYPE string.

    TRY.
        mo_cut = NEW zcl_rap_node_m_uuid_root( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_root( mo_cut  ).
        mo_cut->set_parent( mo_cut ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_1234 ).

        mo_cut->finalize(  ).

        DATA(child1_bo) = mo_cut->add_child( gc_entity_child1 ).
        child1_bo->set_table( iv_table = 'zrap_book_demo' ).
        child1_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_ID' ) ) ).


        DATA(child2_bo) = mo_cut->add_child( gc_entity_child2 ).
        child2_bo->set_table( iv_table = 'zrap_book_demo' ).
        child2_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_ID' ) ) ).

        DATA(child11_bo) = child1_bo->add_child( gc_entity_grandchild11 ).
        child11_bo->set_table( iv_table = 'zrap_books_demo' ).
        child11_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_SUPPL_ID' ) ) ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        lv_expected_name = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.
        lv_name = mo_cut->rap_root_node_objects-behavior_definition_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_entity_child1 }{ gc_suffix_1234 }|.
        lv_name = child1_bo->rap_node_objects-cds_view_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }BP_{ gc_prefix_rap }{ gc_entity_child2 }{ gc_suffix_1234 }|.
        lv_name = child2_bo->rap_node_objects-behavior_implementation.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_entity_grandchild11 }{ gc_suffix_1234 }|.
        lv_name = child11_bo->rap_node_objects-cds_view_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_root_entity_name }|.
        lv_name = child11_bo->root_node->entityname.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH zcx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_fields.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.
    data(lv_tablename) = gc_grandchild_table.
    "DATA(lv_tablename) = gc_child_table.

    TRY.
        mo_cut = NEW zcl_rap_node_m_uuid_root( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        "/dmo/agency
        mo_cut->set_table( CONV #( lv_tablename ) ).
        mo_cut->get_fields( ).
        DATA(lt_fields) = mo_cut->lt_fields.
        "cl_abap_unit_assert=>fail( msg = 'Exception zcx_rap_generator=>root_cause_exception not raised' ).
        cl_abap_unit_assert=>assert_not_initial(
          EXPORTING
            act              = lt_fields
            msg              = 'No fields retrieved'
        ).
        LOOP AT mo_cut->lt_fields  INTO  DATA(ls_header_fields) WHERE  name  <> mo_cut->field_name-client.
          IF ls_header_fields-name = mo_cut->field_name-root_uuid.
            DATA(lv_root_uuid) = ls_header_fields-name.
          ENDIF.
        ENDLOOP.

        cl_abap_unit_assert=>assert_equals( msg = |Table { lv_tablename } has no field { mo_cut->field_name-root_uuid }| exp = mo_cut->field_name-root_uuid act = lv_root_uuid ).

      CATCH zcx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).


    ENDTRY.


    "zcx_rap_generator=>table_does_not_exist
  ENDMETHOD.

  METHOD set_table.
    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_1234 }|.

    DATA lv_name TYPE string.



    TRY.
        mo_cut = NEW zcl_rap_node_m_uuid_root( gc_root_entity_name ).
      CATCH zcx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.


    TRY.
        mo_cut->set_table( 'DoesNotExist' ).
        cl_abap_unit_assert=>fail( msg = 'Exception zcx_rap_generator=>table_does_not_exist not raised' ).
      CATCH zcx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>table_does_not_exist-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = zcx_rap_generator=>table_does_not_exist-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.
    "zcx_rap_generator=>table_does_not_exist
  ENDMETHOD.

ENDCLASS.
