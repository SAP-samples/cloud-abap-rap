CLASS zdmo_bp_rapg_all DEFINITION
PUBLIC
ABSTRACT
FINAL FOR BEHAVIOR OF zdmo_r_rapg_projecttp.

  PUBLIC SECTION.

    TYPES: BEGIN OF t_rap_bo_node,
             uuid TYPE sysuuid_x16,
             node TYPE REF TO zdmo_cl_rap_node,
           END OF t_rap_bo_node.

    TYPES t_rap_bo_nodes TYPE STANDARD TABLE OF t_rap_bo_node.

    CLASS-DATA rap_bo_nodes TYPE t_rap_bo_nodes READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZDMO_BP_RAPG_ALL IMPLEMENTATION.
ENDCLASS.
