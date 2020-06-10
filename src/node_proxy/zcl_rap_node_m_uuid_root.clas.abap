CLASS zcl_rap_node_m_uuid_root DEFINITION
  PUBLIC
  INHERITING FROM zcl_rap_node
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
                VALUE(iv_entity_name) TYPE sxco_ddef_alias_name
      RAISING   zcx_rap_generator.


    METHODS add_to_all_childnodes
      IMPORTING
        VALUE(io_child_node) TYPE REF TO zcl_rap_node.


  PROTECTED SECTION.



  PRIVATE SECTION.



ENDCLASS.



CLASS zcl_rap_node_m_uuid_root IMPLEMENTATION.

  METHOD constructor.

    super->constructor(
      EXPORTING
        iv_entity_name         = iv_entity_name
    ).

    entityname = iv_entity_name .
    implementationtype = implementation_type-managed_uuid.
    set_root( me ).
    set_parent( me ).
    is_root_node = abap_true.

    TEST-SEAM test_run_base_class.
      is_test_run = abap_false.
    end-test-SEAM.

  ENDMETHOD.



  METHOD add_to_all_childnodes.
    APPEND io_child_node TO all_childnodes.
  ENDMETHOD.

ENDCLASS.
