CLASS zdmo_cl_rap_generator_console DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  PROTECTED SECTION.
    METHODS main REDEFINITION.
    METHODS get_json_string
      RETURNING VALUE(json_string) TYPE string.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_CONSOLE IMPLEMENTATION.


  METHOD get_json_string.
    json_string = '' .
  ENDMETHOD.


  METHOD main.
    TRY.
        DATA rap_generator_exception_occurd TYPE abap_bool.
        DATA(json_string) = get_json_string(  ).

        DATA(on_prem_xco_lib) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

        IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_true.
          DATA(rap_generator_on_prem) = ZDMO_cl_rap_generator=>create_for_on_prem_development( json_string ).
          DATA(framework_messages) = rap_generator_on_prem->generate_bo( ).
          rap_generator_exception_occurd = rap_generator_on_prem->exception_occured( ).
          IF rap_generator_exception_occurd = abap_true.
            out->write( |Caution: Exception occured | ) .
            out->write( |Check repository objects of RAP BO { rap_generator_on_prem->get_rap_bo_name(  ) }.| ) .
          ELSE.
            out->write( |RAP BO { rap_generator_on_prem->get_rap_bo_name(  ) }  generated successfully| ) .
          ENDIF.
        ELSE.
          DATA(rap_generator) = ZDMO_cl_rap_generator=>create_for_cloud_development( json_string ).
          framework_messages = rap_generator->generate_bo( ).
          rap_generator_exception_occurd = rap_generator->exception_occured( ).
          IF rap_generator_exception_occurd = abap_true.
            out->write( |Caution: Exception occured | ) .
            out->write( |Check repository objects of RAP BO { rap_generator->get_rap_bo_name(  ) }.| ) .
          ELSE.
            out->write( |RAP BO { rap_generator->get_rap_bo_name(  ) }  generated successfully| ) .
          ENDIF.
        ENDIF.
      CATCH ZDMO_cx_rap_generator INTO DATA(rap_generator_exception).
        out->write( 'RAP Generator has raised the following exception:' ) .
        out->write( rap_generator_exception->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
