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
                  '  "suffix": "_####",' && |\r\n|  &&
                  '  "prefix": "RAP",' && |\r\n|  &&
                  '  "package": "ZRAP_####",' && |\r\n|  &&
                  '  "datasourcetype": "table",' && |\r\n|  &&
                  '  "hierarchy": {' && |\r\n|  &&
                  '    "entityName": "Travel",' && |\r\n|  &&
                  '    "dataSource": "zrap_travel_demo",' && |\r\n|  &&
                  '    "objectId": "travel_id",    ' && |\r\n|  &&
                  '    "children": [' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '        "entityName": "Booking",' && |\r\n|  &&
                  '        "dataSource": "zrap_book_demo",' && |\r\n|  &&
                  '        "objectId": "booking_id"               ' && |\r\n|  &&
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
