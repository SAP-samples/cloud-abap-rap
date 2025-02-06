CLASS zdmo_cl_rap_generator_del_asyn DEFINITION
INHERITING FROM zdmo_cl_rap_generator_base
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
        i_boname TYPE ZDMO_R_RAPG_ProjectTP-BoName.


  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES : BEGIN OF t_log_entry,
              DetailLevel TYPE ballevel,
              Severity    TYPE symsgty,
              Text        TYPE  bapi_msg,
              TimeStamp   TYPE timestamp,
            END OF t_log_entry.
    DATA boname TYPE zdmo_rap_gen_entityname.
    METHODS start_deletion.

    METHODS get_root_exception
      IMPORTING !ix_exception  TYPE REF TO cx_root
      RETURNING VALUE(rx_root) TYPE REF TO cx_root .

ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_DEL_ASYN IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    boname = i_boname.
  ENDMETHOD.


  METHOD get_root_exception.
    rx_root = ix_exception.
    WHILE rx_root->previous IS BOUND.
      rx_root ?= rx_root->previous.
    ENDWHILE.
  ENDMETHOD.


  METHOD if_abap_parallel~do.
    start_deletion(  ).
  ENDMETHOD.


  METHOD if_bgmc_op_single_tx_uncontr~execute.
    start_deletion(  ).
  ENDMETHOD.


  METHOD start_deletion.

    SELECT SINGLE rapbouuid FROM ZDMO_R_RAPG_ProjectTP WHERE boname = @boname INTO @DATA(rap_bo_uuid).

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
                                           JobStatusCriticality = '2' "green
                                           JobStatusText = 'Running'
                                                    ) )
     REPORTED DATA(update_reported_finished1).
    COMMIT ENTITIES .
    COMMIT WORK.


    DATA(rap_generator_del) = NEW zdmo_cl_rap_generator_del( boname ).
    rap_generator_del->start_deletion(  ).

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


  ENDMETHOD.
ENDCLASS.
