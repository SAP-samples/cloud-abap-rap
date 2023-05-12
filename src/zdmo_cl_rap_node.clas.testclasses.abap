*"* use this source file for your ABAP unit test classes
CLASS ltc_rap_node DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.
  PUBLIC SECTION.

  PRIVATE SECTION.

    CONSTANTS:
      gc_namespace_z                 TYPE sxco_ar_object_name VALUE 'Z',
      gc_namespace_contains_blanks   TYPE sxco_ar_object_name VALUE 'Z T',
      gc_namespace_contains_nonalpha TYPE sxco_ar_object_name VALUE 'Z$T',
      gc_root_entity_name            TYPE sxco_ddef_alias_name VALUE 'Travel',
      gc_root_entity_name_too_long   TYPE sxco_ddef_alias_name VALUE 'T012345678901234567890123456789',
      gc_root_ent_contains_blanks    TYPE sxco_ddef_alias_name VALUE 'Trav  el',
      gc_root_ent_contains_nonalpha  TYPE sxco_ddef_alias_name VALUE 'Trave&l',
      gc_prefix_rap                  TYPE sxco_ar_object_name VALUE 'RAP_',
      gc_prefix_contains_blanks      TYPE sxco_ar_object_name VALUE 'R AP_',
      gc_prefix_contains_nonalpha    TYPE sxco_ar_object_name VALUE 'R%P_',
      gc_suffix_4711                 TYPE sxco_ar_object_name VALUE '_4711',
      gc_suffix_contains_blanks      TYPE sxco_ar_object_name VALUE '_4 11',
      gc_suffix_contains_nonalpha    TYPE sxco_ar_object_name VALUE '_4&11',
      gc_protocol_version_odata_v4   TYPE sxco_ar_object_name VALUE '_O4',
      gc_binding_ui                  TYPE sxco_ar_object_name VALUE 'UI_',
      gc_ddic_view_i_name_z          TYPE sxco_dbt_object_name  VALUE 'TRAV00',
      gc_entity_child1               TYPE sxco_ddef_alias_name VALUE 'Booking',
      gc_entity_child2               TYPE sxco_ddef_alias_name VALUE 'Booking2',
      gc_entity_grandchild11         TYPE sxco_ddef_alias_name VALUE 'BookingSuppl',
      "managed uuid scenario with data source table
      gc_root_table_mu               TYPE sxco_dbt_object_name  VALUE 'ZDMO_rapgen_bo',
      gc_child_table_mu              TYPE sxco_dbt_object_name  VALUE 'ZDMO_rapgen_node',
      gc_grandchild_table_mu         TYPE sxco_dbt_object_name  VALUE 'ZDMO_a_bksuppl_d',

      gc_root_table_uuid             TYPE string VALUE 'travel_uuid',
      gc_child_table_uuid            TYPE string VALUE 'booking_uuid',
      gc_grand_child_table_uuid      TYPE string VALUE 'booksuppl_uuid',
      "object id
      gc_root_table_sem_key_mu       TYPE string VALUE 'TRAVEL_ID',
      gc_child_table_sem_key_mu      TYPE string VALUE 'BOOKING_ID',
      gc_grandchild_table_sem_key_mu TYPE string VALUE 'booking_supplement_id',
      gc_etag_master_mu              TYPE string VALUE 'lastchangedat',
      "view
      gc_view_name                   TYPE string VALUE 'I_Country',
      gc_view_object_id              TYPE sxco_ad_field_name  VALUE 'Country',
      gc_view_etag_master            TYPE string VALUE 'CountryThreeLetterISOCode',
      "view entity
      gc_view_entity_name            TYPE string VALUE 'DDCDS_CUSTOMER_DOMAIN_VALUE',
      gc_view_entity_object_id       TYPE sxco_ad_field_name  VALUE 'domain_name',
      gc_view_entity_etag_master     TYPE string VALUE 'value_high',
      "abstract entity
      "ZDMO_TEST_ABSTRACT_CHILDENTITY
      gc_abstract_entity_name        TYPE string VALUE 'D_SELECTCUSTOMIZINGTRANSPTREQP ',
      gc_abstract_entity_object_id   TYPE sxco_ad_field_name  VALUE 'TransportRequestID',
      gc_abstract_entity_etag_master TYPE string VALUE 'TransportRequestID'
      .


    .

    TYPES:
      BEGIN OF ts_field,
        name               TYPE sxco_ad_object_name,
        doma               TYPE sxco_ad_object_name,
        key_indicator      TYPE abap_bool,
        not_null           TYPE abap_bool,
        domain_fixed_value TYPE abap_bool,
        cds_view_field     TYPE sxco_cds_field_name,
      END OF ts_field.

    DATA:
      mo_cut     TYPE REF TO zdmo_cl_rap_node,
      mo_xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS: setup,
      teardown,
      set_namespace FOR TESTING RAISING cx_static_check,
      set_prefix FOR TESTING RAISING cx_static_check,
      set_suffix FOR TESTING RAISING cx_static_check,
      set_cds_view_i_name FOR TESTING RAISING cx_static_check,
      set_cds_view_p_name FOR TESTING RAISING cx_static_check,
      set_mde_name FOR TESTING RAISING cx_static_check,

      set_behavior_def_i_name FOR TESTING RAISING cx_static_check ,
      set_behavior_def_p_name FOR TESTING RAISING cx_static_check ,
      set_behavior_impl_name FOR TESTING RAISING cx_static_check ,
      set_service_definition_name FOR TESTING RAISING cx_static_check,
      set_service_binding_name FOR TESTING RAISING cx_static_check,
      set_entityname FOR TESTING RAISING cx_static_check,
      create_a_root_node FOR TESTING RAISING cx_static_check,
      create_root_with_childs FOR TESTING RAISING cx_static_check,

      set_table FOR TESTING RAISING cx_static_check,
      get_fields_from_table FOR TESTING RAISING cx_static_check,
      get_fields_from_view FOR TESTING RAISING cx_static_check,
      get_fields_from_view_entity FOR TESTING RAISING cx_static_check,
      get_fields_from_abstractentity FOR TESTING RAISING cx_static_check,
      check_for_key_field_uuid FOR TESTING RAISING cx_static_check,
      check_for_parent_key_field FOR TESTING RAISING cx_static_check,
      check_for_client_field FOR TESTING RAISING cx_static_check,
      check_for_root_key_field FOR TESTING RAISING cx_static_check,
      check_set_objectid_wo_data_src FOR TESTING RAISING cx_static_check,
      "managed scenario
      create_root_with_childs_u FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS zdmo_cl_rap_node DEFINITION LOCAL FRIENDS ltc_rap_node.

CLASS ltc_rap_node IMPLEMENTATION.

  METHOD class_setup.
    "create test doubles for the following tables that are read or written to by this class
    "this should be only done once we thus do this in the class method class_setup



  ENDMETHOD.

  METHOD class_teardown.

  ENDMETHOD.

  METHOD setup.

    "mo_xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).
    mo_xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).

    "create test data so that three different nodes can be created

    DATA lt_fields_gc_root_mu TYPE STANDARD TABLE OF ts_field WITH DEFAULT KEY.
    DATA lt_fields_gc_child_mu TYPE STANDARD TABLE OF ts_field WITH DEFAULT KEY.
    DATA lt_fields_gc_grandchild_mu TYPE STANDARD TABLE OF ts_field WITH DEFAULT KEY.

    lt_fields_gc_root_mu = VALUE #(
    ( name = 'CLIENT' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Client' )
    ( name = 'UUID' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Uuid' )
    ( name = 'TRAVEL_ID' cds_view_field = 'TravelId' )
    ( name = 'AGENCY_ID' cds_view_field = 'AgencyId' )
    ( name = 'CUSTOMER_ID' cds_view_field = 'CustomerId' )
    ( name = 'BEGIN_DATE' cds_view_field = 'BeginDate' )
    ( name = 'END_DATE' cds_view_field = 'EndDate' )
    ( name = 'BOOKING_FEE' cds_view_field = 'BookingFee' )
    ( name = 'TOTAL_PRICE' cds_view_field = 'TotalPrice' )
    ( name = 'CURRENCY_CODE' cds_view_field = 'CurrencyCode' )
    ( name = 'DESCRIPTION' cds_view_field = 'Description' )
    ( name = 'OVERALL_STATUS' cds_view_field = 'OverallStatus' )
    ( name = 'CREATED_BY' cds_view_field = 'CreatedBy' )
    ( name = 'CREATED_AT' cds_view_field = 'CreatedAt' )
    ( name = 'LAST_CHANGED_BY' cds_view_field = 'LastChangedBy' )
    ( name = 'LAST_CHANGED_AT' cds_view_field = 'LastChangedAt' )
    ).

    lt_fields_gc_child_mu = VALUE #(
    ( name = 'CLIENT' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Client' )
    ( name = 'UUID' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Uuid' )
    ( name = 'PARENT_UUID' cds_view_field = 'ParentUuid' )
    ( name = 'BOOKING_ID' cds_view_field = 'BookingId' )
    ( name = 'BOOKING_DATE' cds_view_field = 'BookingDate' )
    ( name = 'CUSTOMER_ID' cds_view_field = 'CustomerId' )
    ( name = 'CARRIER_ID' cds_view_field = 'CarrierId' )
    ( name = 'CONNECTION_ID' cds_view_field = 'ConnectionId' )
    ( name = 'FLIGHT_DATE' cds_view_field = 'FlightDate' )
    ( name = 'FLIGHT_PRICE' cds_view_field = 'FlightPrice' )
    ( name = 'CURRENCY_CODE' cds_view_field = 'CurrencyCode' )
    ( name = 'BOOKING_STATUS' cds_view_field = 'BookingStatus' )
    ).

    lt_fields_gc_grandchild_mu = VALUE #(
    ( name = 'CLIENT' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Client' )
    ( name = 'UUID' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Uuid' )
    ( name = 'PARENT_UUID' cds_view_field = 'ParentUuid' )
    ( name = 'ROOT_UUID' cds_view_field = 'RootUuid' )
    ( name = 'BOOKING_SUPPL_ID' cds_view_field = 'BookingSupplId' )
    ( name = 'ARTICLE' cds_view_field = 'Article' )
    ).

  ENDMETHOD.

  METHOD teardown.
    "teardown is called for every test. So if data exists it should be cleared
  ENDMETHOD.

  METHOD set_namespace.

    DATA : lv_namespace TYPE string.

    "Given is a node object
    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).

        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    "When the namespace is set to 'Z'
    "Then the member variable namespace of the node must have the value 'Z' as well
    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z  ).
        lv_namespace = mo_cut->namespace.
        cl_abap_unit_assert=>assert_equals( exp = gc_namespace_z act = lv_namespace ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    "When a namespace that contains blanks is set then an exception with
    "message id : ZDMO_cx_rap_generator=>contains_spaces-msgid
    "message number : ZDMO_cx_rap_generator=>contains_spaces-msgno
    "must be raised

    TRY.
        mo_cut->set_namespace( gc_namespace_contains_blanks ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator .
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).
    ENDTRY.

    "When a namespace that contains non alpha numeric characters is set
    "then an exception with
    "message id : ZDMO_cx_rap_generator=>NON_ALPHA_NUMERIC_CHARACTERS-msgid
    "message number : ZDMO_cx_rap_generator=>NON_ALPHA_NUMERIC_CHARACTERS-msgno
    "must be raised

    TRY.
        mo_cut->set_namespace( gc_namespace_contains_nonalpha ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).
    ENDTRY.
  ENDMETHOD.

  METHOD set_prefix.

    DATA : lv_prefix TYPE string.

    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_prefix( gc_prefix_rap ).

        lv_prefix = mo_cut->prefix.
        cl_abap_unit_assert=>assert_equals( exp = gc_prefix_rap act = lv_prefix ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_prefix( gc_prefix_contains_blanks ).
        lv_prefix = mo_cut->prefix.
        cl_abap_unit_assert=>assert_equals( exp = gc_prefix_rap act = lv_prefix ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator .
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).
    ENDTRY.

    TRY.
        mo_cut->set_prefix( gc_prefix_contains_nonalpha ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator .
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_suffix.

    DATA : lv_suffix TYPE string.

    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        lv_suffix = mo_cut->suffix.
        cl_abap_unit_assert=>assert_equals( exp = gc_suffix_4711 act = lv_suffix ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_suffix( gc_suffix_contains_blanks ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator .
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).
    ENDTRY.

    TRY.
        mo_cut->set_suffix( gc_suffix_contains_nonalpha ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator .
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).
        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_cds_view_i_name.
    "check
    DATA(lv_expected_name) = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.
    DATA lv_name TYPE string.
    " Given is a node object

    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_name_cds_i_view(  ).
        lv_name = mo_cut->rap_node_objects-cds_view_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_cds_view_p_name.
    "check
    "|{ namespace }C_{ prefix }{ entityname }{ suffix }|.
    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.
    DATA lv_name TYPE string.

    " Given is a node object
    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_name_cds_p_view(  ).
        lv_name = mo_cut->rap_node_objects-cds_view_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_mde_name.
    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.
    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_name_mde(  ).
        lv_name = mo_cut->rap_node_objects-meta_data_extension.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD set_behavior_def_i_name.
    "check
    TEST-INJECTION runs_as_cut.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    DATA(lv_expected_name) = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA lv_name TYPE string.
    " Given is a node object

    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_name_behavior_def_r(  ).
        lv_name = mo_cut->rap_root_node_objects-behavior_definition_r.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_behavior_def_p_name.

    TEST-INJECTION runs_as_cut.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_name_behavior_def_p(  ).
        lv_name = mo_cut->rap_root_node_objects-behavior_definition_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_behavior_impl_name.

    DATA(lv_expected_name) = |{ gc_namespace_z  }BP_I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA lv_name TYPE string.
    " Given is a node object

    TRY.
        mo_cut = NEW #( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_entity_name( gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_name_behavior_impl(  ).
        lv_name = mo_cut->rap_node_objects-behavior_implementation.

        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_entityname.

    DATA(lv_expected_name) = gc_root_entity_name .

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( ).
        mo_cut->set_entity_name( gc_root_entity_name ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    lv_name = mo_cut->entityname.
    cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

    TRY.
        mo_cut = NEW #( ).
        mo_cut->set_entity_name( gc_root_ent_contains_blanks ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>contains_spaces-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.

    TRY.
        mo_cut = NEW #(  ).
        mo_cut->set_entity_name( gc_root_ent_contains_nonalpha ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator .

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>non_alpha_numeric_characters-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.

  ENDMETHOD.

  METHOD set_service_binding_name.

    TEST-INJECTION runs_as_cut.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    "WHEN binding_type_name-odata_v4_ui.
    " protocol_version = protocol_version_suffix-odata_v4.
    " binding = binding_type_prefix-ui.
    " DATA(lv_name) =  |{ namespace }{ binding }{ prefix }{ entityname }{ suffix }{ protocol_version }|.
    DATA(lv_expected_name) = |{ gc_namespace_z  }{ gc_binding_ui }{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }{ gc_protocol_version_odata_v4 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( ).

      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
*          gc_protocol_version_odata_v4   TYPE sxco_ar_object_name VALUE '_O4',
*      gc_binding_ui                  TYPE sxco_ar_object_name VALUE 'UI_',
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_binding_type( mo_cut->binding_type_name-odata_v4_ui ).

        mo_cut->set_name_service_binding( ).
        lv_name = mo_cut->rap_root_node_objects-service_binding.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    " lv_expected_name = |{ gc_namespace_z  }UI_{ gc_root_entity_name_too_long }_M|.

    TRY.
        mo_cut = NEW #( ).
        mo_cut->set_entity_name(  gc_root_entity_name_too_long ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        "mo_cut->set_prefix( gc_prefix_rap ).
        "mo_cut->set_suffix( gc_suffix_1234 ).
        mo_cut->set_name_service_binding( ).
        lv_name = mo_cut->rap_root_node_objects-service_binding.
        cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>is_too_long not raised' ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>is_too_long-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>is_too_long-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.

  ENDMETHOD.

  METHOD set_service_definition_name.
    TEST-INJECTION runs_as_cut.
      is_test_run = abap_true.
    END-TEST-INJECTION.

    " DATA(lv_name) =  |{ namespace }{ prefix }{ entityname }{ suffix }|..
    DATA(lv_expected_name) = |{ gc_namespace_z  }{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA lv_name TYPE string.
    " Given is a node object
    TRY.
        mo_cut = NEW #( ).
        mo_cut->set_entity_name(  gc_root_entity_name ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_name_service_definition(  ).
        lv_name = mo_cut->rap_root_node_objects-service_definition.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_a_root_node.
    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA lv_name TYPE string.
    DATA root_node_flag TYPE abap_boolean.


    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_is_root_node( ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_data_source_type( mo_cut->data_source_types-table ).
        "parameters are not mandatory
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        "node specific settings
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_data_source( CONV #( gc_root_table_MU ) ).
        mo_cut->set_object_id(   CONV #( gc_root_table_sem_key_mu  ) ).
        mo_cut->set_field_name_uuid( gc_root_table_uuid  ).
        mo_cut->finalize( ).
        lv_name = mo_cut->rap_node_objects-cds_view_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).
        root_node_flag = mo_cut->is_root_node.
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = root_node_flag ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_root_with_childs.

    DATA lv_name TYPE string.
    DATA lv_expected_name TYPE string.

    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_is_root_node( ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_data_source_type( mo_cut->data_source_types-table ).
        "parameters are not mandatory
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        "node specific settings
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_data_source( CONV #( gc_root_table_MU ) ).
        mo_cut->set_object_id(   CONV #( gc_root_table_sem_key_mu  ) ).
        mo_cut->set_field_name_uuid( to_upper( 'travel_uuid' ) ).
        mo_cut->finalize(  ).


        DATA(child1_bo) = mo_cut->add_child( ).
        child1_bo->set_entity_name( gc_entity_child1 ).
        child1_bo->set_data_source( 'ZDMO_a_booking_d' ).
        child1_bo->set_object_id( 'BOOKING_ID' ).
        child1_bo->set_field_name_uuid( to_upper( 'booking_uuid' ) ).
        child1_bo->finalize(  ).

        DATA(child2_bo) = mo_cut->add_child( ).
        child2_bo->set_entity_name( gc_entity_child2 ).
        child2_bo->set_data_source( 'ZDMO_a_booking_d' ).
        child2_bo->set_object_id( 'BOOKING_ID' ).
        child2_bo->set_field_name_uuid( to_upper( 'booking_uuid' ) ).
        child2_bo->finalize(  ).

        DATA(child11_bo) = child1_bo->add_child( ).
        child11_bo->set_entity_name( gc_entity_grandchild11  ).
        child11_bo->set_data_source( 'ZDMO_a_bksuppl_d' ).
        child11_bo->set_object_id( to_upper( 'booking_supplement_id' ) ).
        child11_bo->set_field_name_uuid( to_upper( 'booksuppl_uuid' ) ).
        child11_bo->finalize(  ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        lv_expected_name = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.
        lv_name = mo_cut->rap_root_node_objects-behavior_definition_r.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_entity_child1 }{ gc_suffix_4711 }|.
        lv_name = child1_bo->rap_node_objects-cds_view_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }BP_I_{ gc_prefix_rap }{ gc_entity_child2 }{ gc_suffix_4711 }|.
        lv_name = child2_bo->rap_node_objects-behavior_implementation.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_entity_grandchild11 }{ gc_suffix_4711 }|.
        lv_name = child11_bo->rap_node_objects-cds_view_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_root_entity_name }|.
        lv_name = child11_bo->root_node->entityname.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_fields_from_table.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA(lv_tablename) = gc_grandchild_table_mu.
    "DATA(lv_tablename) = gc_child_table.

    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-table ).
        mo_cut->set_entity_name(  gc_root_entity_name ).
        "ZDMO_agency
        mo_cut->set_table( CONV #( lv_tablename ) ).
        mo_cut->get_fields( ).
        DATA(lt_fields) = mo_cut->lt_fields.
        "cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>root_cause_exception not raised' ).
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

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).


    ENDTRY.


    "ZDMO_cx_rap_generator=>table_does_not_exist
  ENDMETHOD.


  METHOD get_fields_from_view.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA(lv_view_name) = gc_view_name.
    "DATA(lv_tablename) = gc_child_table.

    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-unmanaged_semantic ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-cds_view ).
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_object_id( CONV #( gc_view_object_id ) ).
        mo_cut->set_field_name_etag_master( gc_view_etag_master ).
        "ZDMO_agency
        mo_cut->set_cds_view( CONV #( lv_view_name ) ).
        mo_cut->get_fields( ).
        DATA(lt_fields) = mo_cut->lt_fields.
        "cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>root_cause_exception not raised' ).
        cl_abap_unit_assert=>assert_not_initial(
          EXPORTING
            act              = lt_fields
            msg              = 'No fields retrieved'
        ).
*        LOOP AT mo_cut->lt_fields  INTO  DATA(ls_header_fields) WHERE  name  <> mo_cut->field_name-client.
*          IF ls_header_fields-name = mo_cut->field_name-etag_master.
*            DATA(lv_etag_master) = ls_header_fields-name.
*          ENDIF.
*        ENDLOOP.
        READ TABLE mo_cut->lt_fields WITH KEY name = mo_cut->field_name-etag_master INTO DATA(ls_etag_master).
        IF sy-subrc = 0.
          DATA(lv_etag_master) = ls_etag_master-name.
        ENDIF.
        cl_abap_unit_assert=>assert_equals( msg = |View { lv_view_name } has no field { mo_cut->field_name-etag_master }| exp = mo_cut->field_name-etag_master act = lv_etag_master ).


        DATA(no_data_element_internal_type) = abap_false.

        LOOP AT mo_cut->lt_fields  INTO  DATA(ls_header_fields).

          IF ls_header_fields-is_built_in_type = abap_false AND
             ls_header_fields-is_data_element = abap_false.

            cl_abap_unit_assert=>fail( msg = |Data source: { mo_cut->data_source_name } Field: { ls_header_Fields-name }  No data element and internal type found. | ).

          ENDIF.
        ENDLOOP.


      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).


    ENDTRY.



  ENDMETHOD.

  METHOD get_fields_from_view_entity.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA(lv_view_name) = gc_view_entity_name.
    "DATA(lv_tablename) = gc_child_table.

    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-unmanaged_semantic ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-cds_view ).
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_object_id( CONV #( gc_view_entity_object_id ) ).
        mo_cut->set_field_name_etag_master( gc_view_entity_etag_master ).
        "ZDMO_agency
        mo_cut->set_cds_view( CONV #( lv_view_name ) ).
        mo_cut->get_fields( ).
        DATA(lt_fields) = mo_cut->lt_fields.
        "cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>root_cause_exception not raised' ).
        cl_abap_unit_assert=>assert_not_initial(
          EXPORTING
            act              = lt_fields
            msg              = 'No fields retrieved'
        ).

*        LOOP AT mo_cut->lt_fields  INTO  DATA(ls_header_fields) WHERE  name  <> mo_cut->field_name-client.
*          IF ls_header_fields-name = mo_cut->field_name-etag_master.
*            DATA(lv_etag_master) = ls_header_fields-name.
*          ENDIF.
*        ENDLOOP.

        READ TABLE mo_cut->lt_fields WITH KEY name = mo_cut->field_name-etag_master INTO DATA(ls_etag_master).
        IF sy-subrc = 0.
          DATA(lv_etag_master) = ls_etag_master-name.
        ENDIF.

        cl_abap_unit_assert=>assert_equals( msg = |View { lv_view_name } has no field { mo_cut->field_name-etag_master }| exp = mo_cut->field_name-etag_master act = lv_etag_master ).


        DATA(no_data_element_internal_type) = abap_false.

        LOOP AT mo_cut->lt_fields  INTO  DATA(ls_header_fields).

          IF ls_header_fields-is_built_in_type = abap_false AND
             ls_header_fields-is_data_element = abap_false.

            cl_abap_unit_assert=>fail( msg = |Data source: { mo_cut->data_source_name } Field: { ls_header_Fields-name }  No data element and internal type found. | ).

          ENDIF.
        ENDLOOP.


      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).


    ENDTRY.



  ENDMETHOD.


  METHOD get_fields_from_abstractentity.

    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    DATA(lv_view_name) = gc_abstract_entity_name.
    "DATA(lv_tablename) = gc_child_table.

    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-unmanaged_semantic ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-cds_view ).
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_object_id( CONV #( gc_abstract_entity_object_id ) ).
        mo_cut->set_field_name_etag_master( gc_abstract_entity_etag_master ).
        "ZDMO_agency
        mo_cut->set_cds_view( CONV #( lv_view_name ) ).
        mo_cut->get_fields( ).
        DATA(lt_fields) = mo_cut->lt_fields.
        "cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>root_cause_exception not raised' ).
        cl_abap_unit_assert=>assert_not_initial(
          EXPORTING
            act              = lt_fields
            msg              = 'No fields retrieved'
        ).
*        LOOP AT mo_cut->lt_fields  INTO  DATA(ls_header_fields) WHERE  name  <> mo_cut->field_name-client.
*          IF ls_header_fields-name = mo_cut->field_name-etag_master.
*            DATA(lv_etag_master) = ls_header_fields-name.
*          ENDIF.
*        ENDLOOP.

        READ TABLE mo_cut->lt_fields WITH KEY name = mo_cut->field_name-etag_master INTO DATA(ls_etag_master).
        IF sy-subrc = 0.
          DATA(lv_etag_master) = ls_etag_master-name.
        ENDIF.

        cl_abap_unit_assert=>assert_equals( msg = |View { lv_view_name } has no field { mo_cut->field_name-etag_master }| exp = mo_cut->field_name-etag_master act = lv_etag_master ).


        DATA(no_data_element_internal_type) = abap_false.

        LOOP AT mo_cut->lt_fields  INTO  DATA(ls_header_fields).

          IF ls_header_fields-is_built_in_type = abap_false AND
             ls_header_fields-is_data_element = abap_false.

            cl_abap_unit_assert=>fail( msg = |Data source: { mo_cut->data_source_name } Field: { ls_header_Fields-name }  No data element and internal type found. | ).

          ENDIF.
        ENDLOOP.


      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).


    ENDTRY.



  ENDMETHOD.


  METHOD set_table.
    DATA(lv_expected_name) = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.

    TRY.
        mo_cut = NEW zdmo_cl_rap_node(  ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.


    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).

        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_table( 'DoesNotExist' ).
        cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>table_does_not_exist not raised' ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>table_does_not_exist-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>table_does_not_exist-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.
    "ZDMO_cx_rap_generator=>table_does_not_exist
  ENDMETHOD.

  METHOD check_set_objectid_wo_data_src.
    TRY.
        mo_cut = NEW zdmo_cl_rap_node( ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.





    TRY.
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_is_root_node(  ).
        mo_cut->set_data_source_type( mo_cut->data_source_types-table ).
        mo_cut->set_implementation_type( mo_cut->implementation_type-managed_uuid  ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        "mo_cut->set_table( CONV #( gc_root_table_MU ) ).
        mo_cut->set_object_id(   CONV #( gc_root_table_sem_key_mu  ) ).
        mo_cut->finalize(  ).
        cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>no_datasource_set not raised' ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>no_data_source_set-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>no_data_source_set-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.

  ENDMETHOD.

  METHOD check_for_key_field_uuid.

    TEST-INJECTION get_mock_data_fields.

      lt_fields = VALUE #(
     ( name = 'CLIENT' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Client' )
     "( name = 'UUID' key_indicator = 'X'  not_null = 'X' cds_view_field = 'Uuid' )
     ( name = 'TRAVEL_ID' cds_view_field = 'TravelId' )
     ( name = 'AGENCY_ID' cds_view_field = 'AgencyId' )
     ( name = 'CUSTOMER_ID' cds_view_field = 'CustomerId' )
     ( name = 'BEGIN_DATE' cds_view_field = 'BeginDate' )
     ( name = 'END_DATE' cds_view_field = 'EndDate' )
     ( name = 'BOOKING_FEE' cds_view_field = 'BookingFee' )
     ( name = 'TOTAL_PRICE' cds_view_field = 'TotalPrice' )
     ( name = 'CURRENCY_CODE' cds_view_field = 'CurrencyCode' )
     ( name = 'DESCRIPTION' cds_view_field = 'Description' )
     ( name = 'OVERALL_STATUS' cds_view_field = 'OverallStatus' )
     ( name = 'CREATED_BY' cds_view_field = 'CreatedBy' )
     ( name = 'CREATED_AT' cds_view_field = 'CreatedAt' )
     ( name = 'LAST_CHANGED_BY' cds_view_field = 'LastChangedBy' )
     ( name = 'LAST_CHANGED_AT' cds_view_field = 'LastChangedAt' )
     ).

    END-TEST-INJECTION.


    TRY.

        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).

      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.





    TRY.
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-table ).

        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).


        mo_cut->set_data_source( CONV #( gc_root_table_MU ) ).
        mo_cut->set_object_id( CONV sxco_ad_field_name( gc_root_table_sem_key_mu )    ).
        mo_cut->finalize(  ).

        cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>field_uuid_missing not raised' ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>field_uuid_missing-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>field_uuid_missing-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.


  ENDMETHOD.

  METHOD check_for_client_field.
    TEST-INJECTION get_mock_data_fields.

      lt_fields = VALUE #(
     ( name = 'WRONGCLIENT' key_indicator = 'X'   not_null = 'X' cds_view_field = 'Client' )
     ( name = 'UUID' key_indicator = 'X'  data_element = 'SYSUUID_X16' not_null = 'X' cds_view_field = 'Uuid' )
     ( name = 'TRAVEL_ID' cds_view_field = 'TravelId' )
     ( name = 'AGENCY_ID' cds_view_field = 'AgencyId' )
     ( name = 'CUSTOMER_ID' cds_view_field = 'CustomerId' )
     ( name = 'BEGIN_DATE' cds_view_field = 'BeginDate' )
     ( name = 'END_DATE' cds_view_field = 'EndDate' )
     ( name = 'BOOKING_FEE' cds_view_field = 'BookingFee' )
     ( name = 'TOTAL_PRICE' cds_view_field = 'TotalPrice' )
     ( name = 'CURRENCY_CODE' cds_view_field = 'CurrencyCode' )
     ( name = 'DESCRIPTION' cds_view_field = 'Description' )
     ( name = 'OVERALL_STATUS' cds_view_field = 'OverallStatus' )
     ( name = 'CREATED_BY' cds_view_field = 'CreatedBy' )
     ( name = 'CREATED_AT' cds_view_field = 'CreatedAt' )
     ( name = 'LAST_CHANGED_BY' cds_view_field = 'LastChangedBy' )
     ( name = 'LAST_CHANGED_AT' cds_view_field = 'LastChangedAt' )
     ).

    END-TEST-INJECTION.


    TRY.

        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).

      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.





    TRY.
        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-table ).

        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).


        mo_cut->set_data_source( CONV #( gc_root_table_MU ) ).
        mo_cut->set_object_id( CONV sxco_ad_field_name( gc_root_table_sem_key_mu )    ).
        mo_cut->finalize(  ).

        cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>CLNT_is_not_key_field not raised' ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>CLNT_is_not_key_field-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>CLNT_is_not_key_field-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).

    ENDTRY.

  ENDMETHOD.

  METHOD check_for_parent_key_field.
    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.





    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).


        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_root( mo_cut  ).
        mo_cut->set_parent( mo_cut ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-table ).
        mo_cut->set_object_id( CONV #( gc_root_table_sem_key_mu ) ).
        mo_cut->set_table( CONV #( gc_root_table_MU ) ).
        mo_cut->set_field_name_uuid( gc_root_table_uuid  ).
        mo_cut->set_object_id( CONV sxco_ad_field_name( gc_root_table_sem_key_mu )    ).
        " mo_cut->set_semantic_key_fields( VALUE #( ( CONV #( gc_root_table_sem_key_mu  ) ) ) ).
        mo_cut->finalize(  ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        DATA(child1_bo) = mo_cut->add_child(  ).
        child1_bo->set_entity_name( gc_entity_child1 ).
        child1_bo->set_table( iv_table = CONV #( gc_child_table_MU ) ).
        child1_bo->set_object_id( CONV #( gc_child_table_sem_key_mu ) ).
        child1_bo->set_field_name_uuid( gc_child_table_uuid  ).
        child1_bo->set_field_name_parent_uuid( 'does_not_exist'  ).
        child1_bo->finalize(  ).

        cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>field_parent_uuid_missing not raised' ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>field_parent_uuid_missing-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>field_parent_uuid_missing-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.

  ENDMETHOD.

  METHOD check_for_root_key_field.
    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.





    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-managed_uuid ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-table ).

        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_root( mo_cut  ).
        mo_cut->set_parent( mo_cut ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_object_id( CONV #( gc_root_table_sem_key_mu ) ).
        mo_cut->set_table( CONV #( gc_root_table_MU ) ).
        mo_cut->set_field_name_uuid( gc_root_table_uuid ).
        "mo_cut->set_semantic_key_fields( VALUE #( ( CONV #( gc_root_table_sem_key_mu  ) ) ) ).
        mo_cut->finalize(  ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        DATA(child1_bo) = mo_cut->add_child( ).
        child1_bo->set_entity_name( gc_entity_child1 ).
        child1_bo->set_table( iv_table = CONV #( gc_child_table_MU ) ).
        "child1_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( CONV #( gc_child_table_sem_key_mu ) ) ) ).
        child1_bo->set_object_id( CONV #( gc_child_table_sem_key_mu ) ).
        child1_bo->set_field_name_uuid( gc_child_table_uuid ).
        child1_bo->finalize(  ).


      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).

    ENDTRY.

    TRY.
        DATA(child11_bo) = child1_bo->add_child( ).
        child11_bo->set_entity_name( gc_entity_grandchild11 ).
        child11_bo->set_table( iv_table = CONV #( gc_grandchild_table_mu ) ).
        "child11_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( CONV #( gc_child_table_sem_key_mu ) ) ) ).
        child11_bo->set_object_id( CONV #( gc_grandchild_table_sem_key_mu ) ).
        child11_bo->set_field_name_uuid( gc_grand_child_table_uuid ).
        child11_bo->set_field_name_root_uuid( 'does_not_exist' ).
        child11_bo->finalize(  ).

        cl_abap_unit_assert=>fail( msg = 'Exception ZDMO_cx_rap_generator=>field_root_uuid_missing not raised' ).
      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>field_root_uuid_missing-msgid
                                            act = lx_rap_generator->if_t100_message~t100key-msgid ).

        cl_abap_unit_assert=>assert_equals( exp = ZDMO_cx_rap_generator=>field_root_uuid_missing-msgno
                                            act = lx_rap_generator->if_t100_message~t100key-msgno ).


    ENDTRY.
  ENDMETHOD.

  METHOD create_root_with_childs_u.
    DATA lv_name TYPE string.
    DATA lv_expected_name TYPE string.

    TRY.
        mo_cut = NEW zdmo_cl_rap_node( mo_xco_lib ).
      CATCH ZDMO_cx_rap_generator INTO DATA(lx_rap_generator).
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.
        mo_cut->set_is_root_node(  ).
        mo_cut->set_implementation_type( zdmo_cl_rap_node=>implementation_type-unmanaged_semantic ).

        mo_cut->set_entity_name(  gc_root_entity_name ).
        mo_cut->set_root( mo_cut  ).
        mo_cut->set_parent( mo_cut ).
        mo_cut->set_object_id(   CONV #( gc_root_table_sem_key_mu  ) ).
        mo_cut->set_data_source_type( zdmo_cl_rap_node=>data_source_types-table ).
        mo_cut->set_namespace( gc_namespace_z ).
        mo_cut->set_prefix( gc_prefix_rap ).
        mo_cut->set_suffix( gc_suffix_4711 ).
        mo_cut->set_table( 'ZDMO_TRAVEL' ).
        mo_cut->set_semantic_key_fields( VALUE #( ( 'TRAVEL_ID' ) ) ).
        mo_cut->set_field_name_etag_master( gc_etag_master_mu ).
        mo_cut->finalize(  ).

        DATA(child1_bo) = mo_cut->add_child(  ).
        child1_bo->set_entity_name( gc_entity_child1 ).
        child1_bo->set_table( iv_table = 'ZDMO_BOOKING' ).
        child1_bo->set_object_id( 'BOOKING_ID' ).
        child1_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_ID' ) ( 'TRAVEL_ID' ) ) ).
        child1_bo->finalize(  ).

        DATA(child2_bo) = mo_cut->add_child(  ).
        child2_bo->set_entity_name( gc_entity_child2 ).
        child2_bo->set_table( iv_table = 'ZDMO_BOOKING' ).
        child2_bo->set_object_id( 'BOOKING_ID' ).
        child2_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_ID' ) ( 'TRAVEL_ID' ) ) ).
        child2_bo->finalize(  ).


        DATA(child11_bo) = child1_bo->add_child(  ).
        child11_bo->set_entity_name( gc_entity_grandchild11 ).
        child11_bo->set_table( iv_table = 'ZDMO_BOOK_SUPPL' ).
        child11_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_SUPPLEMENT_ID' ) ( 'BOOKING_ID' ) ( 'TRAVEL_ID' ) ) ).
        child11_bo->set_object_id( 'BOOKING_SUPPLEMENT_ID').
        child11_bo->finalize(  ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.

    TRY.

        lv_expected_name = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_root_entity_name }{ gc_suffix_4711 }|.
        lv_name = mo_cut->rap_root_node_objects-behavior_definition_r.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }I_{ gc_prefix_rap }{ gc_entity_child1 }{ gc_suffix_4711 }|.
        lv_name = child1_bo->rap_node_objects-cds_view_i.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }BP_I_{ gc_prefix_rap }{ gc_entity_child2 }{ gc_suffix_4711 }|.
        lv_name = child2_bo->rap_node_objects-behavior_implementation.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_namespace_z  }C_{ gc_prefix_rap }{ gc_entity_grandchild11 }{ gc_suffix_4711 }|.
        lv_name = child11_bo->rap_node_objects-cds_view_p.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

        lv_expected_name = |{ gc_root_entity_name }|.
        lv_name = child11_bo->root_node->entityname.
        cl_abap_unit_assert=>assert_equals( exp = lv_expected_name act = lv_name ).

      CATCH ZDMO_cx_rap_generator INTO lx_rap_generator.
        cl_abap_unit_assert=>fail( msg = lx_rap_generator->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
