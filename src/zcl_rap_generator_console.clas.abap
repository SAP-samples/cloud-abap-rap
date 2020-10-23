CLASS zcl_rap_generator_console DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS main REDEFINITION.
  PRIVATE SECTION.
    DATA filename TYPE string.
    DATA fileext TYPE string.
    DATA filedata TYPE string.
    DATA json_string TYPE string.

ENDCLASS.



CLASS zcl_rap_generator_console IMPLEMENTATION.

  METHOD main.

    DATA text_line TYPE string.
    DATA text_table TYPE TABLE OF string.

    json_String = '{' && |\r\n|  &&
                  '  "implementationType": "managed_uuid",' && |\r\n|  &&
                  '  "namespace": "Z",' && |\r\n|  &&
                  '  "suffix": "_5682",' && |\r\n|  &&
                  '  "prefix": "RAP_",' && |\r\n|  &&
                  '  "package": "ZRAP_TRAVEL_5678",' && |\r\n|  &&
                  '  "datasourcetype": "table",' && |\r\n|  &&
                  '  "hierarchy": {' && |\r\n|  &&
                  '    "entityName": "Travel",' && |\r\n|  &&
                  '    "dataSource": "zrap_atrav_1234",' && |\r\n|  &&
                  '    "objectId": "travel_id",' && |\r\n|  &&
                  '    "uuid": "travel_uuid",' && |\r\n|  &&
                  '    "valueHelps": [' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "alias": "Agency",' && |\r\n|  &&
                  '        "name": "/DMO/I_Agency",' && |\r\n|  &&
                  '        "localElement": "AgencyID",' && |\r\n|  &&
                  '        "element": "AgencyID"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "alias": "Customer",' && |\r\n|  &&
                  '        "name": "/DMO/I_Customer",' && |\r\n|  &&
                  '        "localElement": "CustomerID",' && |\r\n|  &&
                  '        "element": "CustomerID"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "alias": "Currency",' && |\r\n|  &&
                  '        "name": "I_Currency",' && |\r\n|  &&
                  '        "localElement": "CurrencyCode",' && |\r\n|  &&
                  '        "element": "Currency"' && |\r\n|  &&
                  '      }' && |\r\n|  &&
                  '    ],' && |\r\n|  &&
                  '    "associations": [' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "name": "_Agency",' && |\r\n|  &&
                  '        "target": "/DMO/I_Agency",' && |\r\n|  &&
                  '        "cardinality": "zero_to_one",' && |\r\n|  &&
                  '        "conditions": [' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "projectionField": "AgencyID",' && |\r\n|  &&
                  '            "associationField": "AgencyID"' && |\r\n|  &&
                  '          }' && |\r\n|  &&
                  '        ]' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "name": "_Currency",' && |\r\n|  &&
                  '        "target": "I_Currency",' && |\r\n|  &&
                  '        "cardinality": "zero_to_one",' && |\r\n|  &&
                  '        "conditions": [' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "projectionField": "CurrencyCode",' && |\r\n|  &&
                  '            "associationField": "Currency"' && |\r\n|  &&
                  '          }' && |\r\n|  &&
                  '        ]' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "name": "_Customer",' && |\r\n|  &&
                  '        "target": "/DMO/I_Customer",' && |\r\n|  &&
                  '        "cardinality": "zero_to_one",' && |\r\n|  &&
                  '        "conditions": [' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "projectionField": "CustomerID",' && |\r\n|  &&
                  '            "associationField": "CustomerID"' && |\r\n|  &&
                  '          }' && |\r\n|  &&
                  '        ]' && |\r\n|  &&
                  '      }' && |\r\n|  &&
                  '    ],' && |\r\n|  &&
                  '    "children": [' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "entityName": "Booking",' && |\r\n|  &&
                  '        "dataSource": "zrap_abook_1234",' && |\r\n|  &&
                  '        "objectId": "booking_id",' && |\r\n|  &&
                  '        "uuid": "booking_uuid",' && |\r\n|  &&
                  '        "parentUuid": "travel_uuid",' && |\r\n|  &&
                  '        "valueHelps": [' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "alias": "Flight",' && |\r\n|  &&
                  '            "name": "/DMO/I_Flight",' && |\r\n|  &&
                  '            "localElement": "ConnectionID",' && |\r\n|  &&
                  '            "element": "ConnectionID",' && |\r\n|  &&
                  '            "additionalBinding": [' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "localElement": "FlightDate",' && |\r\n|  &&
                  '                "element": "FlightDate"' && |\r\n|  &&
                  '              },' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "localElement": "CarrierID",' && |\r\n|  &&
                  '                "element": "AirlineID"' && |\r\n|  &&
                  '              },' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "localElement": "FlightPrice",' && |\r\n|  &&
                  '                "element": "Price"' && |\r\n|  &&
                  '              },' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "localElement": "CurrencyCode",' && |\r\n|  &&
                  '                "element": "CurrencyCode"' && |\r\n|  &&
                  '              }' && |\r\n|  &&
                  '            ]' && |\r\n|  &&
                  '          },' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "alias": "Currency",' && |\r\n|  &&
                  '            "name": "I_Currency",' && |\r\n|  &&
                  '            "localElement": "CurrencyCode",' && |\r\n|  &&
                  '            "element": "Currency"' && |\r\n|  &&
                  '          },' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "alias": "Airline",' && |\r\n|  &&
                  '            "name": "/DMO/I_Carrier",' && |\r\n|  &&
                  '            "localElement": "CarrierID",' && |\r\n|  &&
                  '            "element": "AirlineID"' && |\r\n|  &&
                  '          },' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "alias": "Customer",' && |\r\n|  &&
                  '            "name": "/DMO/I_Customer",' && |\r\n|  &&
                  '            "localElement": "CustomerID",' && |\r\n|  &&
                  '            "element": "CustomerID"' && |\r\n|  &&
                  '          }' && |\r\n|  &&
                  '        ],' && |\r\n|  &&
                  '        "associations": [' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "name": "_Connection",' && |\r\n|  &&
                  '            "target": "/DMO/I_Connection",' && |\r\n|  &&
                  '            "cardinality": "one_to_one",' && |\r\n|  &&
                  '            "conditions": [' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "CarrierID",' && |\r\n|  &&
                  '                "associationField": "AirlineID"' && |\r\n|  &&
                  '              },' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "ConnectionID",' && |\r\n|  &&
                  '                "associationField": "ConnectionID"' && |\r\n|  &&
                  '              }' && |\r\n|  &&
                  '            ]' && |\r\n|  &&
                  '          },' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "name": "_Flight",' && |\r\n|  &&
                  '            "target": "/DMO/I_Flight",' && |\r\n|  &&
                  '            "cardinality": "one_to_one",' && |\r\n|  &&
                  '            "conditions": [' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "CarrierID",' && |\r\n|  &&
                  '                "associationField": "AirlineID"' && |\r\n|  &&
                  '              },' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "ConnectionID",' && |\r\n|  &&
                  '                "associationField": "ConnectionID"' && |\r\n|  &&
                  '              },' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "FlightDate",' && |\r\n|  &&
                  '                "associationField": "FlightDate"' && |\r\n|  &&
                  '              }' && |\r\n|  &&
                  '            ]' && |\r\n|  &&
                  '          },' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "name": "_Carrier",' && |\r\n|  &&
                  '            "target": "/DMO/I_Carrier",' && |\r\n|  &&
                  '            "cardinality": "one_to_one",' && |\r\n|  &&
                  '            "conditions": [' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "CarrierID",' && |\r\n|  &&
                  '                "associationField": "AirlineID"' && |\r\n|  &&
                  '              }' && |\r\n|  &&
                  '            ]' && |\r\n|  &&
                  '          },' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "name": "_Currency",' && |\r\n|  &&
                  '            "target": "I_Currency",' && |\r\n|  &&
                  '            "cardinality": "zero_to_one",' && |\r\n|  &&
                  '            "conditions": [' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "CurrencyCode",' && |\r\n|  &&
                  '                "associationField": "Currency"' && |\r\n|  &&
                  '              }' && |\r\n|  &&
                  '            ]' && |\r\n|  &&
                  '          },' && |\r\n|  &&
                  '          {' && |\r\n|  &&
                  '            "name": "_Customer",' && |\r\n|  &&
                  '            "target": "/DMO/I_Customer",' && |\r\n|  &&
                  '            "cardinality": "one_to_one",' && |\r\n|  &&
                  '            "conditions": [' && |\r\n|  &&
                  '              {' && |\r\n|  &&
                  '                "projectionField": "CustomerID",' && |\r\n|  &&
                  '                "associationField": "CustomerID"' && |\r\n|  &&
                  '              }' && |\r\n|  &&
                  '            ]' && |\r\n|  &&
                  '          }' && |\r\n|  &&
                  '        ]' && |\r\n|  &&
                  '      }' && |\r\n|  &&
                  '    ]' && |\r\n|  &&
                  '  }' && |\r\n|  &&
                  '}'.
    TRY.

        DATA(xco_api) = NEW zcl_rap_xco_cloud_lib( ).
        "DATA(xco_api) = NEW zcl_rap_xco_on_prem_lib(  ).

        DATA(root_node) = NEW zcl_rap_node(  ).
        root_node->set_is_root_node( ).
        root_node->set_xco_lib( xco_api ).

        DATA(rap_bo_visitor) = NEW zcl_rap_xco_json_visitor( root_node ).
        DATA(json_data) = xco_cp_json=>data->from_string( json_string ).
        json_data->traverse( rap_bo_visitor ).

        DATA(rap_bo_generator) = NEW zcl_rap_bo_generator( root_node ).
        DATA(lt_todos) = rap_bo_generator->generate_bo(  ).


        out->write( | RAP BO { root_node->rap_root_node_objects-behavior_definition_i  } generated successfully | ).

      CATCH cx_root INTO DATA(lx_root).
        out->write( | exception {   cl_message_helper=>get_latest_t100_exception( lx_root )->if_message~get_text( )  } | ) .
    ENDTRY.



  ENDMETHOD.

ENDCLASS.
