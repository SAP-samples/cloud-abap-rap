CLASS zdmo_cl_rap_generator_strtbgpf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
                i_bgpf_del_operation TYPE REF TO zdmo_cl_rap_generator_del_asyn OPTIONAL
                i_bgpf_operation     TYPE REF TO zdmo_cl_rap_generator_asyn OPTIONAL
                i_operation_text     TYPE string OPTIONAL
      RAISING   ZDMO_cx_rap_generator.

    CLASS-METHODS create_for_del_bgpf
      IMPORTING
        i_bgpf_del_operation TYPE REF TO zdmo_cl_rap_generator_del_asyn
        i_operation_text     TYPE string
      RETURNING
        VALUE(result)        TYPE REF TO zdmo_cl_rap_generator_strtbgpf.

    CLASS-METHODS create_for_bgpf
      IMPORTING
        i_bgpf_operation TYPE REF TO zdmo_cl_rap_generator_asyn
        i_operation_text TYPE string
      RETURNING
        VALUE(result)    TYPE REF TO zdmo_cl_rap_generator_strtbgpf.

    METHODS start_execution.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA bgpf_operation TYPE REF TO zdmo_cl_rap_generator_asyn .
    DATA bgpf_del_operation TYPE REF TO zdmo_cl_rap_generator_del_asyn .
    DATA async_process_name TYPE string.
ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_STRTBGPF IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    IF i_bgpf_del_operation IS NOT INITIAL.
      bgpf_del_operation = i_bgpf_del_operation.
    ELSEIF i_bgpf_operation IS NOT INITIAL.
      bgpf_operation = i_bgpf_operation.
    ENDIF.
    async_process_name = i_operation_text.

  ENDMETHOD.


  METHOD create_for_bgpf.
    result = NEW #( i_bgpf_operation =  i_bgpf_operation
                    i_operation_text = i_operation_text ).
  ENDMETHOD.


  METHOD create_for_del_bgpf.
    result = NEW #( i_bgpf_del_operation =  i_bgpf_del_operation
                    i_operation_text = i_operation_text ).
  ENDMETHOD.


  METHOD start_execution.
    TRY.
        DATA(background_process) = cl_bgmc_process_factory=>get_default(  )->create(  ).

        IF bgpf_del_operation IS NOT INITIAL.
          background_process->set_operation_tx_uncontrolled( bgpf_del_operation ).
          background_process->set_name( CONV #( async_process_name ) ).
        ELSEIF bgpf_operation IS NOT INITIAL.
          background_process->set_operation_tx_uncontrolled( bgpf_operation ).
          background_process->set_name( CONV #( async_process_name ) ).
        ENDIF.
        background_process->save_for_execution(  ).
      CATCH cx_bgmc.
        "handle exception
        assert 1 = 2.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
