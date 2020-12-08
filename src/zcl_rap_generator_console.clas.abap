CLASS zcl_rap_generator_console DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  PROTECTED SECTION.
    METHODS main REDEFINITION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_RAP_GENERATOR_CONSOLE IMPLEMENTATION.


  METHOD main.

    DATA json_string TYPE string.

    json_string = ' {' && |\r\n|  &&
                  '  "implementationType": "managed_uuid",' && |\r\n|  &&
                  |  "namespace": "Z",| && |\r\n|  &&
                  '  "suffix": "_002",' && |\r\n|  &&
                  |  "prefix": "RAP_",| && |\r\n|  &&
                  |  "package": "Z_TEST_AFI",| && |\r\n|  &&
                  '  "datasourcetype": "table",' && |\r\n|  &&
                  '  "draftenabled": true ,' && |\r\n|  &&
                  '  "bindingtype": "odata_v4_ui" ,' && |\r\n|  &&
                  '  "hierarchy": {' && |\r\n|  &&
                  '    "uuid" : "travel_uuid",' && |\r\n|  &&
                  |    "drafttable": "ZRAP_TRAVEL_D",| && |\r\n|  &&
                  |    "entityName": "Travel",| && |\r\n|  &&
                  |    "dataSource": "/DMO/A_TRAVEL_D",| && |\r\n|  &&
                  '    "objectId": "travel_id"' && |\r\n|  &&
                  '  }' && |\r\n|  &&
                  '}'.



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

    DATA(rap_bo_name) = root_node->rap_root_node_objects-service_binding.

    out->write( |RAP BO { rap_bo_name }  generated successfully| ).

  ENDMETHOD.
ENDCLASS.
