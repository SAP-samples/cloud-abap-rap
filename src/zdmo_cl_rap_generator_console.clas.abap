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
    json_string = '{' && |\r\n|  &&
                  '"namespace":"Z",' && |\r\n|  &&
                  '"package":"Z_PROJ_TEST",' && |\r\n|  &&
                  '"dataSourceType":"table",' && |\r\n|  &&
                  '"bindingType":"odata_v4_ui",' && |\r\n|  &&
                  '"implementationType":"managed_uuid",' && |\r\n|  &&
                  '"prefix":"",' && |\r\n|  &&
                  '"suffix":"_99",' && |\r\n|  &&
                  '"draftEnabled":true,' && |\r\n|  &&
                  '"multiInlineEdit":false,' && |\r\n|  &&
                  '"isCustomizingTable":false,' && |\r\n|  &&
                  '"addBusinessConfigurationRegistration":false,' && |\r\n|  &&
*                  '"transportRequest":"PM1K900006",' && |\r\n|  &&
                  '"publishservice":true,' && |\r\n|  &&
                  '"addbasiciviews":false,' && |\r\n|  &&
                  '"isextensible":false,' && |\r\n|  &&
                  '"hierarchy":' && |\r\n|  &&
                  '{' && |\r\n|  &&
                  ' "entityname":"SalesORder",' && |\r\n|  &&
                  ' "dataSource":"ZDMO_UUID_HEADER",' && |\r\n|  &&
                  ' "objectid":"SALESORDER_ID",' && |\r\n|  &&
                  ' "uuid":"HEADER_UUID",' && |\r\n|  &&
                  ' "parentUUID":"",' && |\r\n|  &&
                  ' "rootUUID":"",' && |\r\n|  &&
                  ' "etagMaster":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "totalEtag":"LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "lastChangedAt":"LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "lastChangedBy":"LAST_CHANGED_BY",' && |\r\n|  &&
                  ' "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "createdAt":"CREATED_AT",' && |\r\n|  &&
                  ' "createdBy":"CREATED_BY",' && |\r\n|  &&



                  ' "Children":' && |\r\n|  &&
                  ' [' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "entityname":"Item",' && |\r\n|  &&
                  '   "dataSource":"ZDMO_UUID_ITEM",' && |\r\n|  &&
                  '   "objectid":"ITEM_ID",' && |\r\n|  &&
                  '   "uuid":"ITEM_UUID",' && |\r\n|  &&
                  '   "parentUUID":"PARENT_UUID",' && |\r\n|  &&
                  '   "rootUUID":"",' && |\r\n|  &&
                  '   "etagMaster":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "totalEtag":"",' && |\r\n|  &&
                  '   "lastChangedAt":"",' && |\r\n|  &&
                  '   "lastChangedBy":"",' && |\r\n|  &&
                  '   "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "createdAt":"",' && |\r\n|  &&
                  '   "createdBy":"",' && |\r\n|  &&


                  '   "Children":' && |\r\n|  &&
                  '   [' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "entityname":"SubItem",' && |\r\n|  &&
                  '     "dataSource":"ZDMO_UUID_S_ITEM",' && |\r\n|  &&
                  '     "objectid":"SCHEDULE_LINE_ID",' && |\r\n|  &&
                  '     "uuid":"SCHED_LINE_UUID",' && |\r\n|  &&
                  '     "parentUUID":"PARENT_UUID",' && |\r\n|  &&
                  '     "rootUUID":"ROOT_UUID",' && |\r\n|  &&
                  '     "etagMaster":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "totalEtag":"",' && |\r\n|  &&
                  '     "lastChangedAt":"",' && |\r\n|  &&
                  '     "lastChangedBy":"",' && |\r\n|  &&
                  '     "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "createdAt":"",' && |\r\n|  &&
                  '     "createdBy":""' && |\r\n|  &&


                  '    }' && |\r\n|  &&
                  '   ]' && |\r\n|  &&
                  '  }' && |\r\n|  &&
                  ' ]' && |\r\n|  &&
                  '}' && |\r\n|  &&
                  '}' .
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
          LOOP AT rap_generator->root_node->lt_fields INTO DATA(field).
            out->write( |field-built_in_type { field-built_in_type }| ).
            out->write( |field-built_in_type_decimals { field-built_in_type_decimals }| ).
            out->write( |field-built_in_type_length { field-built_in_type_length }| ).

          ENDLOOP.
          EXIT.
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
