CLASS zdmo_cl_rap_gen_calc_json_adt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_CALC_JSON_ADT IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA jobname  TYPE cl_apj_rt_api=>ty_jobname .
    DATA jobcount   TYPE cl_apj_rt_api=>ty_jobcount  .
    DATA jobstatus  TYPE cl_apj_rt_api=>ty_job_status  .
    DATA jobstatustext  TYPE cl_apj_rt_api=>ty_job_status_text .

    DATA lt_original_data TYPE STANDARD TABLE OF ZDMO_c_rapgeneratorbo WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).

      TRY.

          <fs_original_data>-HideADTLink = abap_true.

          IF <fs_original_data>-jobname IS NOT INITIAL AND <fs_original_data>-jobcount IS NOT INITIAL.

            cl_apj_rt_api=>get_job_status(
              EXPORTING
                iv_jobname  = <fs_original_data>-JobName
                iv_jobcount = <fs_original_data>-JobCount
              IMPORTING
                ev_job_status = JobStatus
                ev_job_status_text = jobstatustext
              ).

            <fs_original_data>-JobStatus = jobstatus.
            <fs_original_data>-JobStatusText = jobstatustext.

            CASE jobstatus.
              WHEN 'F'. "Finished
                <fs_original_data>-JobStatusCriticality = 3.
                <fs_original_data>-HideADTLink = abap_false.
              WHEN 'A'. "Aborted
                <fs_original_data>-JobStatusCriticality = 1.
              WHEN 'R'. "Running
                <fs_original_data>-JobStatusCriticality = 2.
              WHEN OTHERS.
                <fs_original_data>-JobStatusCriticality = 0.
            ENDCASE.

          ENDIF.



        CATCH cx_apj_rt INTO DATA(exception).

          DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

          <fs_original_data>-JobStatus = ''.
          <fs_original_data>-JobStatusText = exception->get_text(  ).
          <fs_original_data>-JobStatusCriticality = 0.

        CATCH cx_root INTO DATA(root_exception).

          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            EXPORTING
              previous = root_exception.

      ENDTRY.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.


    CONSTANTS field_name_rap_node_uuid TYPE string VALUE 'RAP_NODE_UUID'.

    IF iv_entity <> 'ZDMO_C_RAPGENERATORBO'.
      RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
        EXPORTING
          textid   = ZDMO_cx_rap_generator=>root_cause_exception
          mv_value = |{ iv_entity } has no virtual elements|.
    ENDIF.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'RAP_NODE_UUID' .
          COLLECT field_name_rap_node_uuid INTO et_requested_orig_elements.
        WHEN OTHERS.
          RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
            EXPORTING
              textid   = ZDMO_cx_rap_generator=>root_cause_exception
              mv_value = |Virtual element { <fs_calc_element> } not known|.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
