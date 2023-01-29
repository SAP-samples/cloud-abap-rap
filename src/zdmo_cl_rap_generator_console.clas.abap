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
                  '    "namespace": "Z",' && |\r\n|  &&
                  '    "package": "ZDMO_DELETE_TESTS_EML",' && |\r\n|  &&
                  '    "dataSourceType": "table",' && |\r\n|  &&
                  '    "bindingType": "odata_v4_ui",' && |\r\n|  &&
                  '    "implementationType": "managed_uuid",' && |\r\n|  &&
                  '    "prefix": "",' && |\r\n|  &&
                  '    "suffix": "_AF10",' && |\r\n|  &&
                  '    "draftEnabled": true,' && |\r\n|  &&
                  '    "multiInlineEdit": false,' && |\r\n|  &&
                  '    "isCustomizingTable": false,' && |\r\n|  &&
                  '    "addBusinessConfigurationRegistration": false,' && |\r\n|  &&
                  '    "transportRequest": "PMDK900273",' && |\r\n|  &&
                  '    "hierarchy": {' && |\r\n|  &&
                  '        "entityname": "SalesOrder",' && |\r\n|  &&
                  '        "dataSource": "ZDMO_UUID_HEADER",' && |\r\n|  &&
                  '        "objectid": "SALESORDER_ID",' && |\r\n|  &&
                  '        "uuid": "HEADER_UUID",' && |\r\n|  &&
                  '        "parentUUID": "",' && |\r\n|  &&
                  '        "rootUUID": "",' && |\r\n|  &&
                  '        "etagMaster": "LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '        "totalEtag": "LAST_CHANGED_AT",' && |\r\n|  &&
                  '        "lastChangedAt": "LAST_CHANGED_AT",' && |\r\n|  &&
                  '        "lastChangedBy": "LAST_CHANGED_BY",' && |\r\n|  &&
                  '        "localInstanceLastChangedAt": "LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '        "createdAt": "CREATED_AT",' && |\r\n|  &&
                  '        "createdBy": "CREATED_BY",' && |\r\n|  &&
                  '        "draftTable": "ZSALESOR00D_AF10",' && |\r\n|  &&
                  '        "cdsInterfaceView": "ZI_SalesOrderTP_AF10",' && |\r\n|  &&
                  '        "cdsRestrictedReuseView": "ZR_SalesOrderTP_AF10",' && |\r\n|  &&
                  '        "cdsProjectionView": "ZC_SalesOrderTP_AF10",' && |\r\n|  &&
                  '        "metadataExtensionView": "ZC_SalesOrder_AF10",' && |\r\n|  &&
                  '        "behaviorImplementationClass": "ZBP_R_SalesOrder_AF10",' && |\r\n|  &&
                  '        "serviceDefinition": "ZSalesOrder_AF10",' && |\r\n|  &&
                  '        "serviceBinding": "ZUI_SalesOrder_O4_AF10",' && |\r\n|  &&
                  '        "controlStructure": "",' && |\r\n|  &&
                  '        "customQueryImplementationClass": "",' && |\r\n|  &&
                  '        "Children": [' && |\r\n|  &&
                  '            {' && |\r\n|  &&
                  '                "entityname": "Item",' && |\r\n|  &&
                  '                "dataSource": "ZDMO_UUID_ITEM",' && |\r\n|  &&
                  '                "objectid": "ITEM_ID",' && |\r\n|  &&
                  '                "uuid": "ITEM_UUID",' && |\r\n|  &&
                  '                "parentUUID": "PARENT_UUID",' && |\r\n|  &&
                  '                "rootUUID": "",' && |\r\n|  &&
                  '                "etagMaster": "LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '                "totalEtag": "",' && |\r\n|  &&
                  '                "lastChangedAt": "",' && |\r\n|  &&
                  '                "lastChangedBy": "",' && |\r\n|  &&
                  '                "localInstanceLastChangedAt": "LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '                "createdAt": "",' && |\r\n|  &&
                  '                "createdBy": "",' && |\r\n|  &&
                  '                "draftTable": "ZITEM00D_AF10",' && |\r\n|  &&
                  '                "cdsInterfaceView": "ZI_ItemTP_AF10",' && |\r\n|  &&
                  '                "cdsRestrictedReuseView": "ZR_ItemTP_AF10",' && |\r\n|  &&
                  '                "cdsProjectionView": "ZC_ItemTP_AF10",' && |\r\n|  &&
                  '                "metadataExtensionView": "ZC_Item_AF10",' && |\r\n|  &&
                  '                "behaviorImplementationClass": "ZBP_R_Item_AF10",' && |\r\n|  &&
                  '                "serviceDefinition": "",' && |\r\n|  &&
                  '                "serviceBinding": "",' && |\r\n|  &&
                  '                "controlStructure": "",' && |\r\n|  &&
                  '                "customQueryImplementationClass": ""' && |\r\n|  &&
                  '            }' && |\r\n|  &&
                  '        ]' && |\r\n|  &&
                  '    }' && |\r\n|  &&
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
