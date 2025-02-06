CLASS zdmo_cl_rap_generator_asyn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_serializable_object .
    INTERFACES if_bgmc_operation .
    INTERFACES if_bgmc_op_single_tx_uncontr .
    INTERFACES if_abap_parallel.

    METHODS constructor
      IMPORTING
        i_json_string              TYPE ZDMO_R_RAPG_ProjectTP-JsonString
        i_package_language_version TYPE ZDMO_R_RAPG_ProjectTP-PackageLanguageVersion
        i_rap_bo_uuid              TYPE  ZDMO_R_RAPG_ProjectTP-RapBoUUID OPTIONAL.


  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA json_string TYPE ZDMO_R_RAPG_ProjectTP-JsonString.
    DATA package_language_version TYPE ZDMO_R_RAPG_ProjectTP-PackageLanguageVersion.
    DATA rap_bo_uuid TYPE  ZDMO_R_RAPG_ProjectTP-RapBoUUID.
    METHODS start_generator.
ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_ASYN IMPLEMENTATION.


  METHOD constructor.
    json_string = i_json_string.
    package_language_version = i_package_language_version.
    rap_bo_uuid              = i_rap_bo_uuid.
  ENDMETHOD.


  METHOD if_abap_parallel~do.
    start_generator(  ).
  ENDMETHOD.


  METHOD if_bgmc_op_single_tx_uncontr~execute.
    start_generator(  ).
  ENDMETHOD.


  METHOD start_generator.
    DATA(xco_on_prem_library) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF rap_bo_uuid IS NOT INITIAL.

      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP
        ENTITY Project
            ALL FIELDS WITH VALUE #( ( %key-RapBoUUID = rap_bo_uuid
                                 ) )
        RESULT DATA(items)
        FAILED DATA(read_failed).

      "Fill job status fields
      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
       ENTITY Project
           UPDATE FIELDS ( JobStatus JobStatusCriticality JobStatusText )
           WITH VALUE #( FOR item IN items ( %key = item-%key
                                             JobStatus = 'R'
                                             JobStatusCriticality = '2' "orange
                                             JobStatusText = 'Running'
                                                      ) )
       REPORTED DATA(update_reported).

      COMMIT ENTITIES .
      COMMIT WORK.
    ENDIF.

    CASE package_language_version.

      WHEN zdmo_cl_rap_node=>package_abap_language_version-standard.
        DATA(rap_generator_on_prem) = zdmo_cl_rap_generator=>create_for_on_prem_development( json_string ).
        DATA(framework_messages) = rap_generator_on_prem->generate_bo( ).


      WHEN zdmo_cl_rap_node=>package_abap_language_version-abap_for_sap_cloud_platform.

        "If in on premise systems packages with the language version abap_for_sap_cloud_platform are used
        "we have to use the xco_cp libraries for generation and
        "we have to use the xco on prem libraries for reading

        IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
          DATA(rap_generator) = zdmo_cl_rap_generator=>create_for_on_prem_development( json_string ).
        ELSE.
          rap_generator = zdmo_cl_rap_generator=>create_for_cloud_development( json_string ).
        ENDIF.

        framework_messages = rap_generator->generate_bo( ).

      WHEN OTHERS.

        IF rap_bo_uuid IS NOT INITIAL.
          "Fill job status fields
          MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
           ENTITY Project
               UPDATE FIELDS ( JobStatus JobStatusCriticality JobStatusText )
               WITH VALUE #( FOR item IN items ( %key = item-%key
                                                 JobStatus = 'A'
                                                 JobStatusCriticality = '1' "orange
                                                 JobStatusText = 'Aborted'
                                                          ) )
           REPORTED DATA(update_reported_aborted).
          COMMIT ENTITIES .
          COMMIT WORK.
        ENDIF.

        RAISE EXCEPTION TYPE zdmo_cx_rap_generator
          EXPORTING
            textid = zdmo_cx_rap_generator=>root_cause_exception.


    ENDCASE.

    IF rap_bo_uuid IS NOT INITIAL.

      "Fill job status fields
      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP
       ENTITY Project
           UPDATE FIELDS ( JobStatus JobStatusCriticality JobStatusText )
           WITH VALUE #( FOR item IN items ( %key = item-%key
                                             JobStatus = 'F'
                                             JobStatusCriticality = '3' "green
                                             JobStatusText = 'Finished'
                                                      ) )
       REPORTED DATA(update_reported_finished).
      COMMIT ENTITIES .
      COMMIT WORK.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
