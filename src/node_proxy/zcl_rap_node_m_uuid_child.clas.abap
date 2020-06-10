CLASS zcl_rap_node_m_uuid_child DEFINITION
  PUBLIC
  INHERITING FROM zcl_rap_node
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
                VALUE(iv_entity_name) TYPE sxco_ddef_alias_name
      RAISING   zcx_rap_generator.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_rap_node_m_uuid_child IMPLEMENTATION.

  METHOD constructor.

    super->constructor(
      EXPORTING
        iv_entity_name         =  iv_entity_name
    ).

    entityname = iv_entity_name .
    implementationtype = implementation_type-managed_uuid.

  ENDMETHOD.

ENDCLASS.
