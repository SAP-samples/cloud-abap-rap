CLASS zdmo_cl_rap_generator_base DEFINITION ABSTRACT
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA : mo_environment             TYPE REF TO if_xco_cp_gen_env_dev_system,
           mo_put_operation           TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_draft_tabl_put_opertion TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_put_operation1          TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_put_operation2          TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_srvb_put_operation      TYPE REF TO if_xco_cp_gen_d_o_put.
    METHODS get_environment IMPORTING i_transport          TYPE sxco_transport OPTIONAL
                            RETURNING VALUE(r_environment) TYPE REF TO if_xco_cp_gen_env_dev_system.
    METHODS get_put_operation IMPORTING i_environment          TYPE REF TO if_xco_cp_gen_env_dev_system
                              RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_cp_gen_d_o_put .
    METHODS get_put_operation_for_devc IMPORTING i_environment          TYPE REF TO if_xco_cp_gen_env_dev_system
                                       RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_cp_gen_devc_d_o_put  .
*    DATA : mo_environment             TYPE REF TO if_xco_gen_environment,
*           mo_put_operation           TYPE REF TO if_xco_gen_o_mass_put,
*           mo_put_operation1          TYPE REF TO if_xco_gen_o_mass_put,
*           mo_put_operation2          TYPE REF TO if_xco_gen_o_mass_put,
*           mo_draft_tabl_put_opertion TYPE REF TO if_xco_gen_o_mass_put,
*           mo_srvb_put_operation      TYPE REF TO if_xco_gen_o_mass_put.
*    METHODS get_environment IMPORTING i_transport          TYPE sxco_transport OPTIONAL
*                            RETURNING VALUE(r_environment) TYPE REF TO if_xco_gen_environment.
*    METHODS get_put_operation_for_devc IMPORTING i_environment          TYPE REF TO if_xco_gen_environment
*                                       RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_gen_devc_o_put     .
*    METHODS get_put_operation IMPORTING i_environment          TYPE REF TO if_xco_gen_environment
*                              RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_gen_o_mass_put  .

  PROTECTED SECTION.
    METHODS cds_p_view_set_provider_cntrct IMPORTING i_projection_view_spcification TYPE REF TO if_xco_gen_ddls_s_fo_p_view .
    METHODS cds_i_view_set_provider_cntrct IMPORTING i_interface_view_spcification TYPE REF TO if_xco_gen_ddls_s_fo_p_view .

    METHODS put_operation_execute IMPORTING i_put_operation   TYPE REF TO if_xco_cp_gen_d_o_put
                                            i_skip_activation TYPE abap_boolean OPTIONAL
                                  RETURNING VALUE(r_result)   TYPE REF TO if_xco_gen_o_put_result.
*    METHODS put_operation_execute IMPORTING i_put_operation   TYPE REF TO if_xco_gen_o_mass_put
*                                            i_skip_activation TYPE abap_boolean OPTIONAL
*                                  RETURNING VALUE(r_result)   TYPE REF TO if_xco_gen_o_put_result.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_BASE IMPLEMENTATION.


  METHOD cds_i_view_set_provider_cntrct.
    "valid as of 2022
    i_interface_view_spcification->set_provider_contract( io_provider_contract = xco_cp_cds=>provider_contract->transactional_interface ).
  ENDMETHOD.


  METHOD cds_p_view_set_provider_cntrct.
    "valid as of 2022
    i_projection_view_spcification->set_provider_contract( io_provider_contract = xco_cp_cds=>provider_contract->transactional_query ).
  ENDMETHOD.


  METHOD get_environment.
    r_environment = xco_cp_generation=>environment->dev_system( i_transport )  .
*    IF i_transport IS NOT INITIAL.
*      r_environment = xco_generation=>environment->transported( i_transport ).
*    ELSE.
*      r_environment = xco_generation=>environment->local.
*    ENDIF.
  ENDMETHOD.


  METHOD get_put_operation.
    r_put_operation = i_environment->create_put_operation(  ).
*    r_put_operation = i_environment->create_mass_put_operation( ).
  ENDMETHOD.


  METHOD get_put_operation_for_devc.
    "on prem interface of environment does not offer "for-devc"
    r_put_operation = i_environment->for-devc->create_put_operation( ).
*    r_put_operation = i_environment->for-devc->create_put_operation( ).
  ENDMETHOD.


  METHOD put_operation_execute.
    "On premise there is no skip activation available
*    IF i_skip_activation = abap_true.
*      i_put_operation->add_option( XCO_GENERATION=>OPTION->SKIP_ACTIVATION  ).
*      r_result =  i_put_operation->execute(  ).
*      RETURN.
*    ENDIF.
    r_result =  i_put_operation->execute( ).
  ENDMETHOD.
ENDCLASS.
