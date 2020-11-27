CLASS zcl_rap_generator_console DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS generate_bo
      IMPORTING
                prefix             TYPE string
                table_name         TYPE sxco_dbt_object_name
                entity_name        TYPE string
                package            TYPE sxco_package
      RETURNING VALUE(rap_bo_name) TYPE string
      RAISING
                cx_xco_gen_put_exception
                zcx_rap_generator .



  PROTECTED SECTION.
    METHODS main REDEFINITION.
  PRIVATE SECTION.
    DATA json_string TYPE string.

ENDCLASS.



CLASS zcl_rap_generator_console IMPLEMENTATION.

  METHOD main.

    DATA prefix TYPE string.
    DATA table_name TYPE sxco_dbt_object_name .
    DATA entity_name TYPE string.
    DATA package TYPE sxco_package .

    prefix      = '054'.
    table_name  = '/dmo/a_travel_d'.
    entity_name = 'Travel'.
    package     = 'ZRAP_0001'.


    DATA(rap_bo_name) = generate_bo(
      EXPORTING
        prefix      = prefix
        table_name  = table_name
        entity_name = entity_name
        package       = package
    ).


    out->write( |RAP BO { rap_bo_name } for table { table_name } generated successfully| ).

  ENDMETHOD.

  METHOD generate_bo.

    DATA(table_name_upper) = to_upper( table_name ).

    "SELECT SINGLE devclass FROM tadir WHERE obj_name = @table_name_upper AND object = 'TABL' INTO @DATA(package).

    IF package IS INITIAL.
      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid            = zcx_rap_generator=>parameter_is_initial
          mv_parameter_name = |Package of table { table_name_upper } |.
    ENDIF.

    json_string = ' {' && |\r\n|  &&
                  '  "implementationType": "managed_uuid",' && |\r\n|  &&
                  |  "namespace": "Z",| && |\r\n|  &&
                  '  "suffix": "",' && |\r\n|  &&
                  |  "prefix": "{ prefix }",| && |\r\n|  &&
                  |  "package": "{ package }",| && |\r\n|  &&
                  '  "datasourcetype": "table",' && |\r\n|  &&
                  '  "draftenabled": true ,' && |\r\n|  &&
                  '  "bindingtype": "odata_v4_ui" ,' && |\r\n|  &&
                  '  "hierarchy": {' && |\r\n|  &&
                  '    "uuid" : "travel_uuid",' && |\r\n|  &&
                  |    "drafttable": "Z{ prefix }{ entity_name }_D",| && |\r\n|  &&
                  |    "entityName": "{ entity_name }",| && |\r\n|  &&
                  |    "dataSource": "{ table_name }",| && |\r\n|  &&
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

    rap_bo_name = root_node->rap_root_node_objects-service_binding.

  ENDMETHOD.

ENDCLASS.
