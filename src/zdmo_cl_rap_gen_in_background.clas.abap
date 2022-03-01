CLASS zdmo_cl_rap_gen_in_background DEFINITION
  PUBLIC

  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.
    METHODS create_job_template IMPORTING i_package_name TYPE sxco_package RAISING ZDMO_cx_rap_generator .
  PROTECTED SECTION.
    METHODS create_transport RETURNING VALUE(lo_transport) TYPE sxco_transport.
  PRIVATE SECTION.

    CONSTANTS:
      co_rap_generator_package TYPE sxco_package VALUE 'ZDMO_RAP_GENERATOR'.

    DATA package_name TYPE sxco_package.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_IN_BACKGROUND IMPLEMENTATION.


  METHOD create_transport.

    "transport creation checks whether being on cloud or on prem

    DATA xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.

    DATA(xco_on_prem_library) = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).

    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
      xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
    ENDIF.


*    DATA(ls_package) = xco_cp_abap_repository=>package->for( co_rap_generator_package )->read( ).

    DATA(ls_package) = xco_lib->get_package( package_name )->read(  ).

    "  DATA(ls_package) = xco_cp_abap_repository=>package->for( co_rap_generator_package )->read( ).
    DATA(lv_transport_layer) = ls_package-property-transport_layer->value.
    DATA(lv_transport_target) = ls_package-property-transport_layer->get_transport_target( )->value.
    DATA(lo_transport_request) = xco_cp_cts=>transports->workbench( lv_transport_target )->create_request( |RAP Generator Application Job Catalog Entry and Job Template| ).



* IF lo_transport_request->get_status( ) = xco_cp_transport=>filter->status( xco_cp_transport=>status->modifiable ).
* DATA(lo_transport_modifiable) = abap_true.
* ENDIF.



    lo_transport = lo_transport_request->value.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA json_string TYPE string.
    DATA messages TYPE string_table.
    DATA(on_prem_xco_lib) = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).



    TRY.
        IF on_prem_xco_lib->on_premise_branch_is_used(  ).
          DATA(application_log) = cl_bali_log=>create_with_header(
                          header = cl_bali_header_setter=>create( object = 'XCO_DEMO'
                                                                  subobject = 'DEMO'
                                                                  external_id = 'External ID' ) )..
        ELSE.
          application_log = cl_bali_log=>create_with_header(
                          header = cl_bali_header_setter=>create( object = zdmo_cl_rap_node=>application_log_object_name
                                                                  subobject = zdmo_cl_rap_node=>application_log_sub_obj1_name
                                                                  external_id = 'External ID' ) ).
        ENDIF.

      CATCH cx_bali_runtime INTO DATA(application_log_exception).

        DATA(bali_log_exception) = application_log_exception->get_text(  ).

        RAISE EXCEPTION TYPE cx_apj_rt_content
          EXPORTING
            previous = application_log_exception.

    ENDTRY.

    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'I_VIEW'.

          SELECT SINGLE * FROM ZDMO_i_rapgeneratorbo  WHERE boname = @ls_parameter-low
          INTO @DATA(rap_generator_bo).

          IF sy-subrc = 0.
            json_string = rap_generator_bo-jsonstring.
          ELSE.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>root_cause_exception
                mv_value = |BO name { ls_parameter-low } not found in ZDMO_i_rapgeneratorbo |.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    DATA(xco_on_prem_library) = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).

    DATA(todo) = NEW ZDMO_cl_rap_node(  ).
    TRY.
        CASE rap_generator_bo-packagelanguageversion.

          WHEN ZDMO_cl_rap_node=>package_abap_language_version-standard.
            DATA(rap_generator_on_prem) = ZDMO_cl_rap_generator_on_prem=>create_for_on_prem_development( json_string ).
            DATA(framework_messages) = rap_generator_on_prem->generate_bo( ).
            APPEND |RAP BO { rap_generator_on_prem->get_rap_bo_name(  ) }  generated successfully| TO messages.

          WHEN ZDMO_cl_rap_node=>package_abap_language_version-abap_for_sap_cloud_platform.

            "If in on premise systems packages with the language version abap_for_sap_cloud_platform are used
            "we have to use the xco_cp libraries for generation and
            "we have to use the xco on prem libraries for reading

            IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
              DATA(rap_generator) = ZDMO_cl_rap_generator=>create_for_on_prem_development( json_string ).
            ELSE.
              rap_generator = ZDMO_cl_rap_generator=>create_for_cloud_development( json_string ).
            ENDIF.

            framework_messages = rap_generator->generate_bo( ).
            APPEND |RAP BO { rap_generator->get_rap_bo_name(  ) }  generated successfully| TO messages.

          WHEN OTHERS.
            RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
              EXPORTING
                textid   = ZDMO_cx_rap_generator=>root_cause_exception
                mv_value = |abap language version '{ rap_generator_bo-packagelanguageversion }' is not supported |.

        ENDCASE.



        APPEND |Messages from framework:| TO messages.
        LOOP AT framework_messages INTO DATA(framework_message).
          APPEND framework_message-message TO messages.

          DATA(application_log_free_text) = cl_bali_free_text_setter=>create(
                            severity = if_bali_constants=>c_severity_status
                            text = CONV #( framework_message-message ) ).
          application_log_free_text->set_detail_level( detail_level = '1' ).
          application_log->add_item( item = application_log_free_text ).

        ENDLOOP.
        cl_bali_log_db=>get_instance( )->save_log( log = application_log assign_to_current_appl_job = abap_true ).
      CATCH ZDMO_cx_rap_generator INTO DATA(rap_generator_exception).

        application_log->add_item( item = cl_bali_exception_setter=>create(
                                     severity = if_bali_constants=>c_severity_error
                                     exception = rap_generator_exception ) ).

        cl_bali_log_db=>get_instance( )->save_log( log = application_log assign_to_current_appl_job = abap_true ).

        RAISE EXCEPTION TYPE cx_apj_rt_content
          EXPORTING
            previous = rap_generator_exception.

    ENDTRY.


  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'I_VIEW' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length =  40 param_text = 'I_VIEW' changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'I_VIEW' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'ZI_###' )
    ).

  ENDMETHOD.


  METHOD create_job_template.

    TYPES: BEGIN OF ty_longtext,
             msgv1(50),
             msgv2(50),
             msgv3(50),
             msgv4(50),
           END OF ty_longtext.
    DATA: ls_longtext      TYPE ty_longtext.

    DATA lv_transport_request TYPE cl_apj_dt_create_content=>ty_transport_request .

    package_name = i_package_name.

    lv_transport_request = create_transport(  ).

    DATA(lo_dt) = cl_apj_dt_create_content=>get_instance( ).

    " Create job catalog entry (corresponds to the former report incl. selection parameters)
    " Provided implementation class iv_class_name shall implement two interfaces:
    " - if_apj_dt_exec_object to provide the definition of all supported selection parameters of the job
    "   (corresponds to the former report selection parameters) and to provide the actual default values
    " - if_apj_rt_exec_object to implement the job execution

    TRY.
        lo_dt->create_job_cat_entry(
            iv_catalog_name       = ZDMO_cl_rap_node=>job_catalog_name
            iv_class_name         = ZDMO_cl_rap_node=>job_class_name
            iv_text               = ZDMO_cl_rap_node=>job_catalog_text
            iv_catalog_entry_type = cl_apj_dt_create_content=>class_based
            iv_transport_request  = lv_transport_request
            iv_package            = co_rap_generator_package
        ).
        "out->write( |Job catalog entry created successfully| ).

      CATCH cx_apj_dt_content INTO DATA(lx_apj_dt_content).

        IF NOT ( lx_apj_dt_content->if_t100_message~t100key-msgno = cx_apj_dt_content=>cx_object_already_exists-msgno AND
                 lx_apj_dt_content->if_t100_message~t100key-msgid = cx_apj_dt_content=>cx_object_already_exists-msgid AND
                 lx_apj_dt_content->object = 'ZDMO_RAP_GEN_CATATALOG_ENTRY' ).
          ls_longtext = lx_apj_dt_content->get_text( ).
          RAISE EXCEPTION NEW ZDMO_cx_rap_generator( textid     = ZDMO_cx_rap_generator=>job_scheduling_error
                                                     mv_value   = CONV #( ls_longtext-msgv1 )
                                                     mv_value_2 = CONV #( ls_longtext-msgv2 )
                                                     previous   = lx_apj_dt_content
                                                     ).
        ENDIF.
    ENDTRY.

    " Create job template (corresponds to the former system selection variant) which is mandatory
    " to select the job later on in the Fiori app to schedule the job
    DATA lt_parameters TYPE if_apj_dt_exec_object=>tt_templ_val.

    NEW zdmo_cl_rap_gen_in_background( )->if_apj_dt_exec_object~get_parameters(
      IMPORTING
        et_parameter_val = lt_parameters
    ).

    TRY.
        lo_dt->create_job_template_entry(
            iv_template_name     = ZDMO_cl_rap_node=>job_template_name
            iv_catalog_name      = ZDMO_cl_rap_node=>job_catalog_name
            iv_text              = ZDMO_cl_rap_node=>job_template_text
            it_parameters        = lt_parameters
            iv_transport_request = lv_transport_request
            iv_package           = co_rap_generator_package
        ).
      CATCH cx_apj_dt_content INTO lx_apj_dt_content.
        IF  NOT ( lx_apj_dt_content->if_t100_message~t100key-msgno = cx_apj_dt_content=>cx_object_already_exists-msgno AND
                 lx_apj_dt_content->if_t100_message~t100key-msgid = cx_apj_dt_content=>cx_object_already_exists-msgid AND
                 lx_apj_dt_content->object = 'ZDMO_RAP_GEN_JOB_TEMPLATE' ).
          ls_longtext = lx_apj_dt_content->get_text( ).
          RAISE EXCEPTION NEW ZDMO_cx_rap_generator( textid     = ZDMO_cx_rap_generator=>job_scheduling_error
                                                     mv_value   = CONV #( ls_longtext-msgv1 )
                                                     mv_value_2 = CONV #( ls_longtext-msgv2 )
                                                     previous   = lx_apj_dt_content
                                                     ).
        ENDIF.
    ENDTRY.



  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    "test run of application job
    "since application job cannot be debugged we test it via F

    DATA  et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val  .

    et_parameters = VALUE #(
        ( selname = 'I_VIEW' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'ZI_Test_AF01' )
      ).

    TRY.
        if_apj_rt_exec_object~execute( it_parameters = et_parameters ).
        out->write( |Finished| ).
      CATCH cx_apj_rt_content INTO DATA(job_scheduling_exception).
        out->write( |Exception has occured: { job_scheduling_exception->get_text(  ) }| ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
