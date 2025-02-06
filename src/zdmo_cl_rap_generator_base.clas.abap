CLASS zdmo_cl_rap_generator_base DEFINITION ABSTRACT
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA : mo_environment               TYPE REF TO if_xco_cp_gen_env_dev_system,
           mo_put_operation             TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_draft_tabl_put_operation  TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_put_operation1            TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_put_operation2            TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_srvb_put_operation        TYPE REF TO if_xco_cp_gen_d_o_put,
           mo_patch_operation           TYPE REF TO if_xco_cp_gen_o_patch_mass,
           mo_bdef_specification        TYPE REF TO if_xco_cp_gen_bdef_s_form,
           mo_table_specification       TYPE REF TO if_xco_cp_gen_tabl_dbt_s_form,
           mo_struct_specification      TYPE REF TO if_xco_cp_gen_tabl_str_s_form,
           mo_service_def_specification TYPE REF TO if_xco_cp_gen_srvd_s_form.
    METHODS get_environment IMPORTING i_transport          TYPE sxco_transport OPTIONAL
                            RETURNING VALUE(r_environment) TYPE REF TO if_xco_cp_gen_env_dev_system.
    METHODS get_put_operation IMPORTING i_environment          TYPE REF TO if_xco_cp_gen_env_dev_system
                              RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_cp_gen_d_o_put .
    METHODS get_put_operation_for_devc IMPORTING i_environment          TYPE REF TO if_xco_cp_gen_env_dev_system
                                       RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_cp_gen_devc_d_o_put  .
    METHODS get_patch_operation IMPORTING i_environment            TYPE REF TO if_xco_cp_gen_env_dev_system
                                RETURNING VALUE(r_patch_operation) TYPE REF TO if_xco_cp_gen_o_patch_mass.
*    DATA : mo_environment             TYPE REF TO if_xco_gen_environment,
*           mo_put_operation           TYPE REF TO if_xco_gen_o_mass_put,
*           mo_put_operation1          TYPE REF TO if_xco_gen_o_mass_put,
*           mo_put_operation2          TYPE REF TO if_xco_gen_o_mass_put,
*           mo_draft_tabl_put_operation TYPE REF TO if_xco_gen_o_mass_put,
*           mo_srvb_put_operation      TYPE REF TO if_xco_gen_o_mass_put,
*           mo_patch_operation         type ref to if_xco_gen_o_patch_mass,
*           mo_bdef_specification       TYPE REF TO if_xco_gen_bdef_s_form,
*           mo_table_specification       TYPE REF TO if_xco_gen_tabl_dbt_s_form,
*           mo_struct_specification      TYPE REF TO if_xco_gen_tabl_str_s_form,
*           mo_service_def_specification TYPE REF TO if_xco_gen_srvd_s_form.
*    METHODS get_environment IMPORTING i_transport          TYPE sxco_transport OPTIONAL
*                            RETURNING VALUE(r_environment) TYPE REF TO if_xco_gen_environment.
*    METHODS get_put_operation_for_devc IMPORTING i_environment          TYPE REF TO if_xco_gen_environment
*                                       RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_gen_devc_o_put     .
*    METHODS get_put_operation IMPORTING i_environment          TYPE REF TO if_xco_gen_environment
*                              RETURNING VALUE(r_put_operation) TYPE REF TO if_xco_gen_o_mass_put  .
*    METHODS get_patch_operation IMPORTING i_environment            TYPE REF TO if_xco_gen_environment
*                                RETURNING VALUE(r_patch_operation) TYPE REF TO if_xco_gen_o_patch_mass.

  PROTECTED SECTION.
    METHODS cds_p_view_set_provider_cntrct IMPORTING i_projection_view_spcification TYPE REF TO if_xco_gen_ddls_s_fo_p_view .
    METHODS cds_i_view_set_provider_cntrct IMPORTING i_interface_view_spcification TYPE REF TO if_xco_gen_ddls_s_fo_p_view .
    METHODS set_extensible_for_mapping IMPORTING io_mapping TYPE REF TO if_xco_gen_bdef_s_fo_b_mapping .
    METHODS set_bdef_extensible_options IMPORTING io_specification LIKE mo_bdef_specification.
    METHODS set_table_enhancement_cat_any  IMPORTING io_specification LIKE mo_table_specification.
    METHODS set_struct_enhancement_cat_any  IMPORTING io_specification LIKE mo_struct_specification.
    METHODS set_service_definition_annos IMPORTING io_specification LIKE mo_service_def_specification
                                                   io_rap_bo_node   TYPE REF TO zdmo_cl_rap_node.
    METHODS add_include_structure_to_table IMPORTING io_rap_bo_node   TYPE REF TO ZDMO_cl_rap_node
                                           RETURNING VALUE(r_success) TYPE abap_bool.



    METHODS put_operation_execute IMPORTING i_put_operation   TYPE REF TO if_xco_cp_gen_d_o_put
                                            i_skip_activation TYPE abap_boolean OPTIONAL
                                  RETURNING VALUE(r_result)   TYPE REF TO if_xco_gen_o_put_result.
*    METHODS put_operation_execute IMPORTING i_put_operation   TYPE REF TO if_xco_gen_o_mass_put
*                                            i_skip_activation TYPE abap_boolean OPTIONAL
*                                  RETURNING VALUE(r_result)   TYPE REF TO if_xco_gen_o_put_result.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_BASE IMPLEMENTATION.


  METHOD add_include_structure_to_table.

    DATA extension_include_name TYPE sxco_ad_object_name .
    DATA  table_name  TYPE sxco_dbt_object_name  .

    extension_include_name = to_upper( io_rap_bo_node->rap_node_objects-extension_include ).
    table_name = to_upper( io_rap_bo_node->data_source_name ).

    DATA(xco_library) = NEW zdmo_cl_rap_xco_on_prem_lib( ).

    IF xco_library->on_premise_branch_is_used(  ).
      xco_library->add_include_structure_to_table(
        table_name             = table_name
        extension_include_name = extension_include_name
      ).
    ELSE.
      "valid only for cloud
      DATA(lo_change_specification) = mo_patch_operation->for-tabl-for-database_table->add_object( table_name )->create_change_specification( ).
      lo_change_specification->for-insert->add_include( )->set_structure( extension_include_name ).
    ENDIF.

  ENDMETHOD.


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


  METHOD get_patch_operation.
    r_patch_operation = i_environment->create_patch_operation(  ).
*   r_patch_operation = i_environment->create_mass_patch_operation(  ).
  ENDMETHOD.


  METHOD get_put_operation.
    r_put_operation = i_environment->create_put_operation(  ).
*    r_put_operation = i_environment->create_mass_put_operation( ).
  ENDMETHOD.


  METHOD get_put_operation_for_devc.
    "on prem interface of environment does not offer "for-devc"
    r_put_operation = i_environment->for-devc->create_put_operation( ).
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


  METHOD set_bdef_extensible_options.
    "valid as of 2023
    io_specification->set_extensible_options(
                        VALUE #(
                        ( xco_cp_behavior_definition=>extensible_option->with_additional_save  )
                        ( xco_cp_behavior_definition=>extensible_option->with_determinations_on_modify  )
                        ( xco_cp_behavior_definition=>extensible_option->with_determinations_on_save  )
                        ( xco_cp_behavior_definition=>extensible_option->with_validations_on_save  )
                        )
                         ).
  ENDMETHOD.


  METHOD set_extensible_for_mapping.
    "valid as of 2023
    io_mapping->set_extensible(  )->set_corresponding(  ).
  ENDMETHOD.


  METHOD set_service_definition_annos.
    "valid as of 2023
    IF io_rap_bo_node->is_extensible(  ) = abap_true.
      "add @AbapCatalog.extensibility.extensible: true
      io_specification->add_annotation( 'AbapCatalog.extensibility.extensible' )->value->build( )->add_boolean( abap_true ).
    ENDIF.

    "check if custom entities will be generated.
    "if yes the leading entity is an r-view rather than a p-view
    IF io_rap_bo_node->data_source_type = zdmo_cl_rap_node=>data_source_types-abstract_entity OR
       io_rap_bo_node->data_source_type = zdmo_cl_rap_node=>data_source_types-abap_type .
      io_specification->add_annotation( 'ObjectModel.leadingEntity.name' )->value->build( )->add_string( CONV #( io_rap_bo_node->rap_node_objects-cds_view_r ) ).
    ELSE.
      io_specification->add_annotation( 'ObjectModel.leadingEntity.name' )->value->build( )->add_string( CONV #( io_rap_bo_node->rap_node_objects-cds_view_p ) ).
    ENDIF.

  ENDMETHOD.


  METHOD set_struct_enhancement_cat_any.
    "valid as of 2402
    io_specification->set_enhancement_category( xco_cp_table=>enhancement_category->extensible_any ).
  ENDMETHOD.


  METHOD set_table_enhancement_cat_any.
    "valid as of 2402
    io_specification->set_enhancement_category( xco_cp_table=>enhancement_category->extensible_any ).
  ENDMETHOD.
ENDCLASS.
