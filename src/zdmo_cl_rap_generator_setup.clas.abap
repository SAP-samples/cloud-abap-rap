CLASS zdmo_cl_rap_generator_setup DEFINITION
  PUBLIC
   INHERITING FROM zdmo_cl_rap_generator_base
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    DATA package_name_of_rap_generator TYPE sxco_package READ-ONLY.

    METHODS constructor RAISING zdmo_cx_rap_generator.
    METHODS create_application_log_entry RETURNING VALUE(r_application_log_object_name) TYPE string RAISING zdmo_cx_rap_generator. "if_bali_object_handler=>ty_object RAISING zdmo_cx_rap_generator.
    METHODS create_job_catalog_entry
       IMPORTING  i_catalog_name  TYPE cl_apj_dt_create_content=>ty_catalog_name
                  i_class_name  TYPE cl_apj_dt_create_content=>ty_class_name
                  i_text  TYPE cl_apj_dt_create_content=>ty_text
       RETURNING VALUE(r_job_catalog_name) TYPE string RAISING zdmo_cx_rap_generator. "TYPE cl_apj_dt_create_content=>ty_catalog_name RAISING zdmo_cx_rap_generator.
    METHODS create_job_template_entry
        IMPORTING i_template_name  TYPE cl_apj_dt_create_content=>ty_template_name
                  i_catalog_name  TYPE cl_apj_dt_create_content=>ty_catalog_name
                  i_text  TYPE cl_apj_dt_create_content=>ty_text
        RETURNING VALUE(r_job_template_name) TYPE string RAISING zdmo_cx_rap_generator. " TYPE cl_apj_dt_create_content=>ty_template_name RAISING zdmo_cx_rap_generator.
    METHODS create_service_binding RETURNING VALUE(r_service_binding_mame) TYPE string RAISING zdmo_cx_rap_generator. " TYPE  sxco_ao_object_name RAISING zdmo_cx_rap_generator.


  PROTECTED SECTION.
*    METHODS: main REDEFINITION.
  PRIVATE SECTION.

    TYPES: BEGIN OF t_longtext,
             msgv1(50),
             msgv2(50),
             msgv3(50),
             msgv4(50),
           END OF t_longtext.

    DATA transport_request TYPE sxco_transport .
    DATA xco_on_prem_library TYPE REF TO zdmo_cl_rap_xco_on_prem_lib  .
    DATA package_of_rap_generator TYPE REF TO if_xco_package.
    DATA xco_lib TYPE REF TO zdmo_cl_rap_xco_lib.

    METHODS create_transport RETURNING VALUE(r_transport_request) TYPE sxco_transport.



ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_SETUP IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    xco_on_prem_library = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    "check whether being on cloud or on prem
    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.

    package_of_rap_generator = xco_lib->get_class( 'ZDMO_CL_RAP_NODE' )->if_xco_ar_object~get_package(  ).
    package_name_of_rap_generator = package_of_rap_generator->name.

    IF xco_lib->get_package( package_name_of_rap_generator  )->read( )-property-record_object_changes = abap_true.
      transport_request = create_transport(  ).
    ELSE.
      CLEAR transport_request.
    ENDIF.

**    transport_request = create_transport(  ).



  ENDMETHOD.


  METHOD create_application_log_entry.
*    DATA longtext      TYPE t_longtext.
*
*    CLEAR  r_application_log_object_name.
*
*    IF xco_on_prem_library->on_premise_branch_is_used(  ).
*
*      "use xco sample application log object
*      r_application_log_object_name =  'Application log object XCO_DEMO will be used'.
*
*    ELSE.
*
*      DATA(application_log_sub_objects) = VALUE if_bali_object_handler=>ty_tab_subobject(
*                                              ( subobject = zdmo_cl_rap_node=>application_log_sub_obj1_name
*                                                subobject_text = zdmo_cl_rap_node=>application_log_sub_obj1_text )
*                                             "( subobject = '' subobject_text = '' )
*                                              ).
*
*      DATA(lo_log_object) = cl_bali_object_handler=>get_instance( ).
*
*      TRY.
*          lo_log_object->create_object( EXPORTING iv_object = zdmo_cl_rap_node=>application_log_object_name
*                                                  iv_object_text = zdmo_cl_rap_node=>application_log_object_text
*                                                  it_subobjects = application_log_sub_objects
*                                                  iv_package = package_of_rap_generator->name
*                                                  iv_transport_request = transport_request ).
*
*          r_application_log_object_name = zdmo_cl_rap_node=>application_log_object_name.
*
*        CATCH cx_bali_objects INTO DATA(lx_bali_objects).
*
*          IF  NOT ( lx_bali_objects->if_t100_message~t100key-msgno = '602' AND
*                    lx_bali_objects->if_t100_message~t100key-msgid = 'BL' ).
*            "MSGID   BL  SYMSGID C   20
*            "MSGNO   602 SYMSGNO N   3
*            longtext = lx_bali_objects->get_text( ).
*            RAISE EXCEPTION NEW zdmo_cx_rap_generator( textid     = zdmo_cx_rap_generator=>job_scheduling_error
*                                                       mv_value   = CONV #( longtext-msgv1 )
*                                                       mv_value_2 = CONV #( longtext-msgv2 )
*                                                       previous   = lx_bali_objects
*                                                       ).
*
*          ELSE.
*            r_application_log_object_name = |Application log object { zdmo_cl_rap_node=>application_log_object_name } already exists|.
*          ENDIF.
*      ENDTRY.
*
*    ENDIF.
  ENDMETHOD.


  METHOD create_job_catalog_entry.

    DATA longtext      TYPE t_longtext.
    DATA(lo_dt) = cl_apj_dt_create_content=>get_instance( ).

    CLEAR r_job_catalog_name.

    " Create job catalog entry (corresponds to the former report incl. selection parameters)
    " Provided implementation class iv_class_name shall implement two interfaces:
    " - if_apj_dt_exec_object to provide the definition of all supported selection parameters of the job
    "   (corresponds to the former report selection parameters) and to provide the actual default values
    " - if_apj_rt_exec_object to implement the job execution

    TRY.
        lo_dt->create_job_cat_entry(
            iv_catalog_name       = i_catalog_name
            iv_class_name         = i_class_name
            iv_text               = i_text
            iv_catalog_entry_type = cl_apj_dt_create_content=>class_based
            iv_transport_request  = transport_request
            iv_package            = package_of_rap_generator->name
        ).

        r_job_catalog_name = |Job catalog { zdmo_cl_rap_node=>job_catalog_name } created succesfully|. " zdmo_cl_rap_node=>job_catalog_name.

      CATCH cx_apj_dt_content INTO DATA(lx_apj_dt_content).

        IF NOT ( lx_apj_dt_content->if_t100_message~t100key-msgno = cx_apj_dt_content=>cx_object_already_exists-msgno AND
                 lx_apj_dt_content->if_t100_message~t100key-msgid = cx_apj_dt_content=>cx_object_already_exists-msgid AND
                 lx_apj_dt_content->object = 'ZDMO_RAP_GEN_CATATALOG_ENTRY' ).
          longtext = lx_apj_dt_content->get_text( ).
          RAISE EXCEPTION NEW zdmo_cx_rap_generator( textid     = zdmo_cx_rap_generator=>job_scheduling_error
                                                     mv_value   = CONV #( longtext-msgv1 )
                                                     mv_value_2 = CONV #( longtext-msgv2 )
                                                     previous   = lx_apj_dt_content
                                                     ).
        ELSE.
          r_job_catalog_name = lx_apj_dt_content->get_text(  ).
        ENDIF.
    ENDTRY.
  ENDMETHOD.


  METHOD create_job_template_entry.

    " Create job template (corresponds to the former system selection variant) which is mandatory
    " to select the job later on in the Fiori app to schedule the job
    DATA lt_parameters TYPE if_apj_dt_exec_object=>tt_templ_val.

    DATA longtext      TYPE t_longtext.

    CLEAR r_job_template_name.

    DATA(lo_dt) = cl_apj_dt_create_content=>get_instance( ).
    TRY.
        lo_dt->create_job_template_entry(
            iv_template_name     = i_template_name
            iv_catalog_name      = i_catalog_name
            iv_text              = i_text
            it_parameters        = lt_parameters
            iv_transport_request = transport_request
            iv_package           = package_of_rap_generator->name
        ).

        r_job_template_name = |Job template { zdmo_cl_rap_node=>job_template_name } generated successfully|."zdmo_cl_rap_node=>job_template_name.

      CATCH cx_apj_dt_content INTO DATA(lx_apj_dt_content).
        IF  NOT ( lx_apj_dt_content->if_t100_message~t100key-msgno = cx_apj_dt_content=>cx_object_already_exists-msgno AND
                 lx_apj_dt_content->if_t100_message~t100key-msgid = cx_apj_dt_content=>cx_object_already_exists-msgid AND
                 lx_apj_dt_content->object = 'ZDMO_RAP_GEN_JOB_TEMPLATE' ).
          longtext = lx_apj_dt_content->get_text( ).
          RAISE EXCEPTION NEW zdmo_cx_rap_generator( textid     = zdmo_cx_rap_generator=>job_scheduling_error
                                                     mv_value   = CONV #( longtext-msgv1 )
                                                     mv_value_2 = CONV #( longtext-msgv2 )
                                                     previous   = lx_apj_dt_content
                                                     ).
        ELSE.
          r_job_template_name = lx_apj_dt_content->get_text(  ).
        ENDIF.
    ENDTRY.
  ENDMETHOD.


  METHOD create_service_binding.

    DATA service_binding_name TYPE sxco_srvb_object_name  VALUE 'ZDMO_UI_RAPG_PROJECT_O2'." 'ZDMO_UI_RAPG_PROJECT_O4'.
    DATA service_definition_name TYPE  sxco_srvd_object_name  VALUE 'ZDMO_RAPG_PROJECT01'.
    DATA longtext      TYPE t_longtext.


********************************************************************************
    "cloud
*    DATA mo_environment TYPE REF TO if_xco_cp_gen_env_dev_system.
*    DATA mo_srvb_put_operation    TYPE REF TO if_xco_cp_gen_d_o_put .
********************************************************************************
    "onpremise
*    data mo_environment           type ref to if_xco_gen_environment .
*    data mo_srvb_put_operation    type ref to if_xco_gen_o_mass_put.
********************************************************************************

    DATA(service_definition) = xco_lib->get_service_definition( service_definition_name ).

    IF service_definition IS INITIAL.
      RAISE EXCEPTION NEW zdmo_cx_rap_generator( textid     = zdmo_cx_rap_generator=>job_scheduling_error
                                                 mv_value   = CONV #( service_definition_name )
                                                 mv_value_2 = CONV #( 'does not exist' )
                                                 ).
    ENDIF.

    DATA(service_binding) = xco_lib->get_service_binding( service_binding_name ).

    IF service_binding->if_xco_ar_object~exists(  ) = abap_true.
      r_service_binding_mame = |Service binding { service_binding_name } does already exist|.
      EXIT.
    ENDIF.

    TRY.


**********************************************************************
        "cloud
*        mo_environment = get_environment( transport_request ).
*        mo_srvb_put_operation = get_put_operation( mo_environment ).
**********************************************************************
        "on premise
        if transport_request is not initial.
          mo_environment = xco_generation=>environment->transported( transport_request ).
        else.
          mo_environment = xco_generation=>environment->local.
        endif.

        mo_srvb_put_operation = mo_environment->create_mass_put_operation( ).

**********************************************************************

        DATA(specification_srvb) = mo_srvb_put_operation->for-srvb->add_object(   service_binding_name
                                        )->set_package( package_name_of_rap_generator
                                        )->create_form_specification( ).

        specification_srvb->set_short_description( |Service binding for RAP Generator| ) ##no_text.

        specification_srvb->set_binding_type( xco_cp_service_binding=>binding_type->odata_v2_ui ). " odata_v4_ui ).

        specification_srvb->add_service( )->add_version( '0001' )->set_service_definition( service_definition_name ).

        DATA(result) = mo_srvb_put_operation->execute(  ).


        r_service_binding_mame = |Service binding { service_binding_name } generated successfully|.
*        DATA(findings) = result->findings.
*        DATA(findings_list) = findings->get( ).
      CATCH cx_xco_gen_put_exception INTO DATA(cx_root).

        longtext = cx_root->get_message( )->get_text( ).

        RAISE EXCEPTION NEW zdmo_cx_rap_generator( textid     = zdmo_cx_rap_generator=>root_cause_exception
                                                   mv_value   = CONV #( longtext-msgv1 )
                                                   mv_value_2 = CONV #( longtext-msgv2 )
                                                   previous   = cx_root
                                                   ).
    ENDTRY.


    TRY.
        xco_lib->publish_service_binding( service_binding_name ).
        IF xco_lib->service_binding_is_published( service_binding_name  ).
          r_service_binding_mame = |Service binding { service_binding_name } generated and published successfully|.
        ENDIF.
      CATCH zdmo_cx_rap_generator   INTO DATA(cx_publish_service_binding).
    ENDTRY.

  ENDMETHOD.


  METHOD create_transport.

    DATA longtext      TYPE t_longtext.
    DATA transport_request_description TYPE sxco_ar_short_description VALUE 'RAP Generator Application Job Catalog Entry and Job Template'.
    DATA package_name_to_check TYPE sxco_package  .


    package_name_to_check = package_of_rap_generator->name.
    TRY.
        WHILE xco_lib->get_package( package_name_to_check )->read( )-property-transport_layer->value = '$SPL'.
          package_name_to_check = xco_lib->get_package( package_name_to_check )->read( )-property-super_package->name.
        ENDWHILE.
        DATA(transport_target) = xco_lib->get_package( package_name_to_check
          )->read( )-property-transport_layer->get_transport_target( ).
        DATA(transport_target_name) = transport_target->value.
        r_transport_request = xco_cp_cts=>transports->workbench( transport_target_name )->create_request( transport_request_description )->value.
      CATCH cx_root INTO DATA(exc_getting_transport_target).
        CLEAR r_transport_request.
        longtext = exc_getting_transport_target->get_text( ).
        RAISE EXCEPTION NEW zdmo_cx_rap_generator( textid     = zdmo_cx_rap_generator=>job_scheduling_error
                                                   mv_value   = CONV #( longtext-msgv1 )
                                                   mv_value_2 = CONV #( longtext-msgv2 )
                                                   previous   = exc_getting_transport_target
                                                   ).
    ENDTRY.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    DATA job_del_class_name TYPE cl_apj_dt_create_content=>ty_class_name.

    TRY.
        DATA(application_log_object_name) = create_application_log_entry(  ).
        out->write( |{ application_log_object_name } | ).  ##NO_TEXT
      CATCH zdmo_cx_rap_generator INTO DATA(rap_generator_setup_exception).
        out->write( rap_generator_setup_exception->get_text(  ) ).
    ENDTRY.
    TRY.

        DATA(job_catalog_name) = create_job_catalog_entry(
                                   i_catalog_name = zdmo_cl_rap_node=>job_catalog_name
                                   i_class_name   = zdmo_cl_rap_node=>job_class_name
                                   i_text         = zdmo_cl_rap_node=>job_catalog_text
                                 ).
        out->write( |{ job_catalog_name } | ).  ##NO_TEXT
      CATCH zdmo_cx_rap_generator INTO rap_generator_setup_exception.
        out->write( rap_generator_setup_exception->get_text(  ) ).
    ENDTRY.
    TRY.

        IF  xco_lib->on_premise_branch_is_used(  ) = abap_true.
          job_del_class_name = zdmo_cl_rap_node=>job_del_class_name_op.
        ELSE.
          job_del_class_name = zdmo_cl_rap_node=>job_del_class_name.
        ENDIF.

        DATA(job_del_catalog_name) = create_job_catalog_entry(
                                        i_catalog_name = zdmo_cl_rap_node=>job_del_catalog_name
                                        i_class_name   = job_del_class_name
                                        i_text         = zdmo_cl_rap_node=>job_catalog_text
                                 ).
        out->write( |{ job_del_catalog_name } | ).  ##NO_TEXT
      CATCH zdmo_cx_rap_generator INTO rap_generator_setup_exception.
        out->write( rap_generator_setup_exception->get_text(  ) ).
    ENDTRY.
    TRY.
        DATA(job_template_name) = create_job_template_entry(
                                    i_template_name = zdmo_cl_rap_node=>job_template_name
                                    i_catalog_name  = zdmo_cl_rap_node=>job_catalog_name
                                    i_text          = zdmo_cl_rap_node=>job_catalog_text
                                  ).
        out->write( |{ job_template_name } | ).  ##NO_TEXT
      CATCH zdmo_cx_rap_generator INTO rap_generator_setup_exception.
        out->write( rap_generator_setup_exception->get_text(  ) ).
    ENDTRY.
    TRY.
        DATA(job_del_template_name) = create_job_template_entry(
                                        i_template_name = zdmo_cl_rap_node=>job_del_template_name
                                        i_catalog_name  = zdmo_cl_rap_node=>job_del_catalog_name
                                        i_text          = zdmo_cl_rap_node=>job_catalog_text
                                  ).
        out->write( |{ job_del_template_name } | ).  ##NO_TEXT
      CATCH zdmo_cx_rap_generator INTO rap_generator_setup_exception.
        out->write( rap_generator_setup_exception->get_text(  ) ).
    ENDTRY.
    TRY.
        DATA(service_binding_name) = create_service_binding(  ).
        out->write( |{ service_binding_name } | ).
      CATCH zdmo_cx_rap_generator INTO rap_generator_setup_exception.
        out->write( rap_generator_setup_exception->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
