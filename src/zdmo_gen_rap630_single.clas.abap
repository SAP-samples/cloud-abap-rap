CLASS zDMO_gen_rap630_single DEFINITION

INHERITING FROM zdmo_cl_rap_generator_base
**************************************************************************
**
** Welcome to the RAP110 travel exercise generator!
**
** STAND: 2023-05-08 --> OKAY
** Adjust superpackage and TR
** ...
**************************************************************************

  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    METHODS constructor
      IMPORTING i_unique_suffix TYPE string OPTIONAL.

  PROTECTED SECTION.

  PRIVATE SECTION.


    CONSTANTS:
      co_prefix                     TYPE string           VALUE 'ZRAP630_',
      co_entity_name                TYPE string           VALUE 'Shop',
      co_session_name               TYPE string           VALUE 'RAP630',
      co_software_component_base_bo TYPE sxco_package     VALUE 'ZLOCAL',
      co_software_component_ext_bo  TYPE sxco_package     VALUE 'ZLOCAL',
      co_super_package_base_bo      TYPE sxco_package     VALUE 'ZLOCAL',
      co_super_package_ext_bo       TYPE sxco_package     VALUE 'ZLOCAL'
*      co_super_package_base_bo      TYPE sxco_package     VALUE 'ZRAP630',
*      co_super_package_ext_bo       TYPE sxco_package     VALUE 'ZRAP630_EXT'
      .











    DATA xco_on_prem_library TYPE REF TO zdmo_cl_rap_xco_on_prem_lib.
    DATA xco_lib             TYPE REF TO zdmo_cl_rap_xco_lib.
    DATA package_name           TYPE sxco_package .
    DATA extension_package_name           TYPE sxco_package .
    DATA unique_suffix          TYPE string.
*    DATA mo_environment         TYPE REF TO if_xco_cp_gen_env_dev_system.
    DATA transport              TYPE sxco_transport .
    DATA transport_extensions   TYPE sxco_transport .
    "database tables
    DATA table_name_root        TYPE sxco_dbt_object_name.
    DATA table_name_child       TYPE sxco_dbt_object_name.
    DATA draft_table_name_root  TYPE sxco_dbt_object_name.
    DATA draft_table_name_child TYPE sxco_dbt_object_name.
    DATA data_generator_class_name TYPE sxco_ad_object_name.
    DATA calc_travel_elem_class_name TYPE sxco_ad_object_name.
    DATA calc_booking_elem_class_name TYPE sxco_ad_object_name.
    DATA eml_playground_class_name TYPE sxco_ad_object_name.
    "CDS views
    DATA r_view_name_travel   TYPE sxco_cds_object_name.
    DATA r_view_name_booking  TYPE sxco_cds_object_name.
    DATA c_view_name_travel   TYPE sxco_cds_object_name.
    DATA c_view_name_booking  TYPE sxco_cds_object_name.
    DATA i_view_name_travel   TYPE sxco_cds_object_name.
    DATA i_view_basic_name_travel   TYPE sxco_cds_object_name.
    DATA i_view_name_booking  TYPE sxco_cds_object_name.
    DATA create_mde_files     TYPE abap_bool.
    "Behavior pools
    DATA beh_impl_name_travel   TYPE sxco_ao_object_name.
    DATA beh_impl_name_booking  TYPE sxco_ao_object_name.
    "business service
    DATA srv_definition_name    TYPE sxco_srvd_object_name.
    DATA srv_binding_o4_name    TYPE sxco_srvb_service_name.
    DATA debug_modus            TYPE abap_bool VALUE abap_true.


    TYPES: BEGIN OF t_table_fields,
             field                  TYPE sxco_ad_field_name,
             is_key                 TYPE abap_bool,
             not_null               TYPE abap_bool,
             currencyCode           TYPE sxco_cds_field_name,
             unitOfMeasure          TYPE sxco_cds_field_name,
             data_element           TYPE sxco_ad_object_name,
             built_in_type          TYPE cl_xco_ad_built_in_type=>tv_type,
             built_in_type_length   TYPE cl_xco_ad_built_in_type=>tv_length,
             built_in_type_decimals TYPE cl_xco_ad_built_in_type=>tv_decimals,
           END OF t_table_fields.

    TYPES: tt_fields TYPE STANDARD TABLE OF t_table_fields WITH KEY field.

    METHODS create_rap_bo IMPORTING out          TYPE REF TO if_oo_adt_classrun_out
                          EXPORTING eo_root_node TYPE REF TO zdmo_cl_rap_node .

    METHODS get_unique_suffix     IMPORTING VALUE(s_prefix)     TYPE string RETURNING VALUE(s_unique_suffix) TYPE string.
    METHODS create_transport      RETURNING VALUE(lo_transport) TYPE sxco_transport.
    METHODS create_package        IMPORTING VALUE(lo_transport) TYPE sxco_transport.
    METHODS create_extension_package IMPORTING VALUE(lo_transport) TYPE sxco_transport.

    METHODS get_json_string           RETURNING VALUE(json_string) TYPE string.

    METHODS generate_vh_custom_entity IMPORTING VALUE(lo_transport) TYPE sxco_transport .


ENDCLASS.



CLASS ZDMO_GEN_RAP630_SINGLE IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).

    xco_on_prem_library = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    "check whether being on cloud or on prem
    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.

    IF i_unique_suffix IS INITIAL.
      unique_suffix          = get_unique_suffix( co_prefix ).
    ELSE.
      unique_suffix = i_unique_suffix.
    ENDIF.

  ENDMETHOD.


  METHOD create_extension_package.
    DATA(package_environment) = get_environment( lo_transport ).
    DATA(lo_put_operation) = get_put_operation_for_devc( package_environment ).
    DATA(lo_specification) = lo_put_operation->add_object( extension_package_name )->create_form_specification( ).
    lo_specification->set_short_description( |#Generated { co_session_name }  extension tutorial package| ).
    lo_specification->properties->set_super_package( co_software_component_ext_bo )->set_software_component( co_software_component_ext_bo ).
    DATA(lo_result) = lo_put_operation->execute( ).
  ENDMETHOD.


  METHOD create_package.
    DATA(package_environment) = get_environment( lo_transport ).
    DATA(lo_put_operation) = get_put_operation_for_devc( package_environment ).
    DATA(lo_specification) = lo_put_operation->add_object( package_name )->create_form_specification( ).
    lo_specification->set_short_description( |#Generated { co_session_name }  tutorial package| ).
    lo_specification->properties->set_super_package( co_software_component_base_bo )->set_software_component( co_software_component_base_bo ).
*    lo_specification->properties->set_super_package( 'ZRAP630' )->set_software_component( co_software_component_base_bo ).
    DATA(lo_result) = lo_put_operation->execute( ).
  ENDMETHOD.


  METHOD create_rap_bo.

    DATA(json_string)              = get_json_string(  ).            " get json document

    DATA(abap_language_version_number) = xco_lib->get_abap_language_version( package_name ).

    DATA background_process TYPE REF TO if_bgmc_process_single_op.
    DATA bgpf_operation TYPE REF TO zdmo_cl_rap_generator_asyn .
    bgpf_operation = NEW zdmo_cl_rap_generator_asyn(
      i_json_string              = json_string
      i_package_language_version = abap_language_version_number
*      i_rap_bo_uuid              =
    ).
    TRY.
        background_process = cl_bgmc_process_factory=>get_default(  )->create(  ).
        background_process->set_operation_tx_uncontrolled( bgpf_operation ).
        background_process->set_name( CONV #( |Generate { r_view_name_travel } | ) ).
        background_process->save_for_execution(  ).
      CATCH cx_bgmc INTO DATA(bgmc_exception).
        "handle exception
        out->write( |BGPF error { bgmc_exception->get_text(  ) }| ).
    ENDTRY.
    COMMIT WORK.

  ENDMETHOD.


  METHOD create_transport.
    DATA(ls_package) = xco_lib->get_package( co_software_component_base_bo ).
    IF ls_package->read( )-property-record_object_changes = abap_true.
*    DATA(ls_package) = xco_cp_abap_repository=>package->for( co_zlocal_package )->read( ).
      DATA(lv_transport_layer) = ls_package->read( )-property-transport_layer->value.
      DATA(lv_transport_target) = ls_package->read( )-property-transport_layer->get_transport_target( )->value.
      DATA(lo_transport_request) = xco_cp_cts=>transports->workbench( lv_transport_target )->create_request( '#Generated RAP110 tutorial transport request' ).
      lo_transport = lo_transport_request->value.
    ENDIF.
  ENDMETHOD.


  METHOD generate_vh_custom_entity.
    DATA(vh_environment) = get_environment( lo_transport ).
    DATA(lo_put_operation) = get_put_operation( vh_environment ).             ""ZRAP630I_VH_Product_{ unique_suffix }"
    DATA(lo_interface_specification) = lo_put_operation->for-ddls->add_object( |ZRAP630I_VH_Product_{ unique_suffix }|
        )->set_package( package_name
        )->create_form_specification( ).
    "add entity description
    DATA(lo_custom_entity) = lo_interface_specification->set_short_description( 'Value help for products'
    )->add_custom_entity( ).



    " Annotations can be added to custom entities.
    lo_custom_entity->add_annotation( 'ObjectModel.query.implementedBy' )->value->build( )->add_string( |ABAP:{ to_upper( data_generator_class_name ) }| ).


    "add view annotation
    lo_custom_entity->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Value help for products' ).
    " Add fields.



    DATA(lo_identifier) = lo_custom_entity->add_field( xco_cp_ddl=>field( 'Product' )
    )->set_type( xco_cp_abap_dictionary=>built_in_type->char( 40 ) ).
    lo_identifier->set_key( ).
    lo_identifier = lo_custom_entity->add_field( xco_cp_ddl=>field( 'ProductText' )
    )->set_type( xco_cp_abap_dictionary=>built_in_type->char( 40 )  ).

    lo_identifier = lo_custom_entity->add_field( xco_cp_ddl=>field( 'ProductGroup' )
    )->set_type( xco_cp_abap_dictionary=>built_in_type->char( 40 )  ).
    lo_identifier = lo_custom_entity->add_field( xco_cp_ddl=>field( 'Price' )
    )->set_type( xco_cp_abap_dictionary=>built_in_type->curr(
                   iv_length   = 15
                   iv_decimals = 2
                 )  ).
    lo_identifier->add_annotation( 'Semantics.amount.currencyCode' )->value->build( )->add_string( 'Currency' ).
    lo_identifier = lo_custom_entity->add_field( xco_cp_ddl=>field( 'Currency' )
    )->set_type( xco_cp_abap_dictionary=>built_in_type->cuky ).
    lo_identifier = lo_custom_entity->add_field( xco_cp_ddl=>field( 'BaseUnit' )
       )->set_type( xco_cp_abap_dictionary=>built_in_type->unit( 3 ) ).


*    DATA(package_environment) = get_environment( lo_transport ).
*    DATA(lo_put_operation) = get_put_operation( package_environment ).



    DATA(lo_specification) = lo_put_operation->for-clas->add_object(  data_generator_class_name
                                          )->set_package( package_name
                                          )->create_form_specification( ).
    lo_specification->set_short_description( |This class provide value help data| ).


    DATA(lo_public_section) = lo_specification->definition->section-public.
    lo_public_section->add_type( 't_products'
      )->for_table_type(
        io_row_type = xco_cp_abap_dictionary=>table_type( |ZRAP630I_VH_Product_{ unique_suffix }| )
        io_primary_key = xco_cp_table_type=>primary_key->not_specified( xco_cp_table_type=>key_category->not_specified ) ).

    lo_public_section->add_method( 'get_products'
      )->add_returning_parameter( 'products'
      )->set_type( lo_specification->own->type( 't_products' ) ).

    lo_public_section->add_data( 'producty'
      )->set_type( lo_specification->own->type( 't_products' )
      )->set_read_only( ).

    lo_specification->implementation->add_method( |get_products|
          )->set_source( VALUE #(
         (  |"| )
         ( |  products = VALUE #( | )
  ( |  ( Product = 'ZPRINTER01' ProductText = 'Printer Professional ABC' Price = '500.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  ) | )
  ( |  ( Product = 'ZPRINTER02' ProductText = 'Printer Platinum' Price = '800.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  ) | )
  ( |  ( Product = 'D001' ProductText = 'Mobile Phone' Price = '850.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  )  | )
  ( |  ( Product = 'D002' ProductText = 'Table PC' Price = '900.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  ) | )
  ( |  ( Product = 'D003' ProductText = 'Office Table' Price = '599.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  )  | )
  ( |  ( Product = 'D004' ProductText = 'Office Chair' Price = '449.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  )  | )
  ( |  ( Product = 'D005' ProductText = 'Developer Notebook' Price = '3150.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  ) | )
  ( |  ( Product = 'D006' ProductText = 'Mouse' Price = '79.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  )  | )
  ( |  ( Product = 'D007' ProductText = 'Headset' Price = '159.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  )  | )
  ( |  ( Product = 'D008' ProductText = 'Keyboard' Price = '39.00 ' Currency = 'EUR' ProductGroup = 'L001' BaseUnit = 'ST'  ) | )
  ( |   ). | )



          )
           ) .

    lo_specification->set_short_description( 'Value help for products' ).
    lo_specification->definition->add_interface( 'if_rap_query_provider' ).
    lo_specification->implementation->add_method( |if_rap_query_provider~select|
      )->set_source( VALUE #(

        " business logic to fill both tables with demo data
        ( |  DATA business_data TYPE TABLE OF ZRAP630I_VH_Product_{ unique_suffix }.| )
        ( |  DATA business_data_line TYPE ZRAP630I_VH_Product_{ unique_suffix } .       | )
        ( |  DATA(skip)    = io_request->get_paging( )->get_offset( ). | )
        ( |  DATA(requested_fields)  = io_request->get_requested_elements( ). | )
        ( |  DATA(sort_order)    = io_request->get_sort_elements( ). | )
        ( |  TRY. | )
        ( |    DATA(filter_condition) = io_request->get_filter( )->get_as_sql_string( ). | )
        ( |    business_data = get_products(  ).| )
        ( |    SELECT * FROM @business_data AS implementation_types| )
        ( |       WHERE (filter_condition) INTO TABLE @business_data.| )
        ( |    io_response->set_total_number_of_records( lines( business_data ) ).| )
        ( |    io_response->set_data( business_data ).| )
        ( |    CATCH cx_root INTO DATA(exception).| )
        ( |    DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).| )
        ( |    DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.| )
        ( |    RAISE EXCEPTION TYPE zdmo_cx_rap_gen_custom_entity| )
        ( |        EXPORTING | )
        ( |          textid   = VALUE scx_t100key( msgid = exception_t100_key-msgid | )
        ( |          msgno = exception_t100_key-msgno| )
        ( |          attr1 = exception_t100_key-attr1| )
        ( |          attr2 = exception_t100_key-attr2| )
        ( |          attr3 = exception_t100_key-attr3| )
        ( |          attr4 = exception_t100_key-attr4 )| )
        ( |    previous = exception.| )
        ( |  ENDTRY. | )
        ( |    | )
      ) ).






    DATA(lo_result) = lo_put_operation->execute( ).





  ENDMETHOD.


  METHOD get_json_string.

    " build the json document
    json_string =

|\{\r\n| &
|    "namespace":"Z",\r\n| &
|    "package":"{ package_name }", \r\n| &
|    "bindingType":"odata_v4_ui",    \r\n| &
|    "implementationType":"managed_uuid",\r\n| &
|    "prefix":"{ co_session_name }",\r\n| &
|    "suffix":"_{ unique_suffix }",\r\n| &
|    "datasourcetype": "table",\r\n| &
|    "draftEnabled":true,\r\n| &
**********
|    "createtable":true,\r\n| &
**********
|    "publishservice":true,\r\n| &
|    "isextensible":true,\r\n| &
*|    "extensibilityElementSuffix":"ZAA",\r\n| &

"|     "addbasiciviews":false,\r\n| &
|     "addbasiciviews":true,\r\n| &
|    "multiInlineEdit":false,\r\n| &
|    "isCustomizingTable":false,\r\n| &
|    "addBusinessConfigurationRegistration":false,\r\n| &
|    "transportRequest":"{ transport }",\r\n| &
|\r\n| &
|    "hierarchy":\r\n| &&
|    \{\r\n| &&
|    "entityname":"{ co_entity_name }",\r\n| &&
|    "dataSource":"{ table_name_root }",\r\n| &&
|    "objectid":"ORDER_ID",\r\n| &&
|    "uuid":"ORDER_UUID",\r\n| &&
|    "parentUUID":"",\r\n| &&
|    "rootUUID":"",\r\n| &&
|    "etagMaster":"LOCAL_LAST_CHANGED_AT",\r\n| &&
|    "totalEtag":"LAST_CHANGED_AT",\r\n| &&
|    "lastChangedAt":"LAST_CHANGED_AT",\r\n| &&
|    "lastChangedBy":"LAST_CHANGED_BY",\r\n| &&
|    "localInstanceLastChangedBy":"LOCAL_LAST_CHANGED_BY",\r\n| &&
|    "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",\r\n| &&
|    "createdAt":"CREATED_AT",\r\n| &&
|    "createdBy":"CREATED_BY",\r\n| &&
|    "extensibilityElementSuffix":"ZAA",\r\n| &

|    "valueHelps": [ \r\n| &
|       \{\r\n| &
|           "alias": "Product",\r\n| &
|           "name": "ZRAP630I_VH_Product_{ unique_suffix }",\r\n| &
|           "localElement": "OrderedItem",\r\n| &
|           "element": "Product"\r\n| &
|       \}\r\n| &

|    ], | &&
**********************************************************************

'"fields": [' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CLIENT",' && |\r\n|  &&
'            "dataelement": "MANDT",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "iskey": true,' && |\r\n|  &&
'            "notnull": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "ORDER_UUID",' && |\r\n|  &&
'            "dataelement": "sysuuid_x16",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "iskey": true,' && |\r\n|  &&
'            "notnull": true,' && |\r\n|  &&
'            "cdsviewfieldname": "OrderUUID"' && |\r\n|  &&
'        },' && |\r\n|  &&

'        {' && |\r\n|  &&
'            "abapfieldname": "ORDER_ID",' && |\r\n|  &&
'            "isbuiltintype": true,' && |\r\n|  &&
'            "builtintype": "CHAR",' && |\r\n|  &&
'            "builtintypelength": 10,' && |\r\n|  &&
'            "cdsviewfieldname": "OrderID"' && |\r\n|  &&
'        },' && |\r\n|  &&

'         {' && |\r\n|  &&
'            "abapfieldname": "ORDERED_ITEM",' && |\r\n|  &&
'            "isbuiltintype": true,' && |\r\n|  &&
'            "builtintype": "CHAR",' && |\r\n|  &&
'            "builtintypelength": 40,' && |\r\n|  &&
'            "cdsviewfieldname": "OrderedItem"' && |\r\n|  &&
'        },' && |\r\n|  &&

'        {' && |\r\n|  &&
'            "abapfieldname": "CURRENCY_CODE",' && |\r\n|  &&
'            "isbuiltintype": true,' && |\r\n|  &&
'            "builtintype": "CUKY",' && |\r\n|  &&
'            "builtintypelength": 5,' && |\r\n|  &&
'            "cdsviewfieldname": "CurrencyCode"' && |\r\n|  &&
'        },' && |\r\n|  &&

'        {' && |\r\n|  &&
'            "abapfieldname": "ORDER_ITEM_PRICE",' && |\r\n|  &&
'            "currencycode": "CURRENCY_CODE",' && |\r\n| &&
'            "isbuiltintype": true,' && |\r\n|  &&
'            "builtintype": "CURR",' && |\r\n|  &&
'            "builtintypelength": 11,' && |\r\n|  &&
'            "builtintypedecimals": 2,' && |\r\n|  &&
'            "cdsviewfieldname": "OrderItemPrice"' && |\r\n|  &&
'        },' && |\r\n|  &&



'        {' && |\r\n|  &&
'            "abapfieldname": "DELIVERY_DATE",' && |\r\n|  &&
'            "isbuiltintype": true,' && |\r\n|  &&
'            "builtintype": "DATS",' && |\r\n|  &&
'            "cdsviewfieldname": "DeliveryDate"' && |\r\n|  &&
'        },' && |\r\n|  &&

'        {' && |\r\n|  &&
'            "abapfieldname": "OVERALL_STATUS",' && |\r\n|  &&
'            "isbuiltintype": true,' && |\r\n|  &&
'            "builtintype": "CHAR",' && |\r\n|  &&
'            "builtintypelength": 30,' && |\r\n|  &&
'            "cdsviewfieldname": "OverallStatus"' && |\r\n|  &&
'        },' && |\r\n|  &&

'        {' && |\r\n|  &&
'            "abapfieldname": "NOTES",' && |\r\n|  &&
'            "isbuiltintype": true,' && |\r\n|  &&
'            "builtintype": "CHAR",' && |\r\n|  &&
'            "builtintypelength": 256,' && |\r\n|  &&
'            "cdsviewfieldname": "Notes"' && |\r\n|  &&
'        },' && |\r\n|  &&

'        {' && |\r\n|  &&
'            "abapfieldname": "LAST_CHANGED_AT",' && |\r\n|  &&
'            "dataelement": "ABP_LASTCHANGE_TSTMPL",' && |\r\n|  &&
'            "cdsviewfieldname": "LastChangedAt",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CREATED_BY",' && |\r\n|  &&
'            "dataelement": "abp_creation_user",' && |\r\n|  &&
'            "cdsviewfieldname": "CreatedBy",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CREATED_AT",' && |\r\n|  &&
'            "dataelement": "abp_creation_tstmpl",' && |\r\n|  &&
'            "cdsviewfieldname": "CreatedAt",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "LOCAL_LAST_CHANGED_BY",' && |\r\n|  &&
'            "dataelement": "abp_locinst_lastchange_user",' && |\r\n|  &&
'            "cdsviewfieldname": "LocalLastChangedBy",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "LAST_CHANGED_BY",' && |\r\n|  &&
'            "dataelement": "ABP_LASTCHANGE_USER",' && |\r\n|  &&
'            "cdsviewfieldname": "LastChangedBy",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
'            "dataelement": "abp_locinst_lastchange_tstmpl",' && |\r\n|  &&
'            "cdsviewfieldname": "LocalLastChangedAt",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        }' && |\r\n|  &&
'    ]' &&


**********


*********

|    \}\r\n| &
|    \}|
.

  ENDMETHOD.


  METHOD get_unique_suffix.

    DATA: ls_package_name  TYPE sxco_package,

          is_valid_package TYPE abap_bool,
          step_number      TYPE i.

    DATA: ascii_hex TYPE x LENGTH 3.
    DATA ascii_hex_string TYPE string.
    s_unique_suffix = ''.
    is_valid_package = abap_false.
    ascii_hex = 90.
    ascii_hex_string = ascii_hex.
    ascii_hex_string = substring( val = ascii_hex_string off = strlen( ascii_hex_string ) - 3 len = 3 ).

    WHILE is_valid_package = abap_false.

      "check package name(s)
      ls_package_name = s_prefix && ascii_hex_string.

      DATA(lo_package) = xco_lib->get_package( ls_package_name ). "  xco_cp_abap_repository=>object->devc->for( ls_package_name ).
      DATA(extension_package) = xco_lib->get_package( extension_package_name ). "  xco_cp_abap_repository=>object->devc->for( ls_package_name ).

      IF NOT lo_package->exists( ) AND
         NOT extension_package->exists( ).
        is_valid_package = abap_true.
        s_unique_suffix = ascii_hex_string.
      ELSE.
        ascii_hex += 1.
        ascii_hex_string = ascii_hex.
        ascii_hex_string = substring( val = ascii_hex_string off = strlen( ascii_hex_string ) - 3 len = 3 ).

        step_number += 1.
      ENDIF.

      IF step_number > 10000.
        ASSERT 1 = 2.
      ENDIF.

    ENDWHILE.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    debug_modus = abap_true.

*    transport = 'D23K900976'. " <-- maintain your transport request here
    package_name           = co_prefix && unique_suffix.
    extension_package_name = package_name && '_EXT' .

    DATA(lo_transport_target) = xco_lib->get_package( co_software_component_base_bo
              )->read( )-property-transport_layer->get_transport_target( ).

    DATA(new_transport_object) = xco_cp_cts=>transports->workbench( lo_transport_target->value  )->create_request( |Package name: { package_name } | ).
    transport = new_transport_object->value.


    DATA(lo_transport_target_ext) = xco_lib->get_package( co_software_component_ext_bo
              )->read( )-property-transport_layer->get_transport_target( ).

    DATA(new_transport_object_ext) = xco_cp_cts=>transports->workbench( lo_transport_target_ext->value  )->create_request( |Package name: { extension_package_name } | ).
    transport_extensions = new_transport_object_ext->value.

    out->write( | { co_session_name } exercise generator | ).
    out->write( | ------------------------------------- | ).
    .

    "database tables
    table_name_root               = to_upper( |{ co_prefix }ashop{ unique_suffix }| ).
    draft_table_name_root         = to_upper( |{ co_prefix }dshop{ unique_suffix }| ).
    "CDS views
    r_view_name_travel            = to_upper( |{ co_prefix }R_{ co_entity_name }TP_{ unique_suffix }| ).
    c_view_name_travel            = to_upper( |{ co_prefix }C_{ co_entity_name }TP_{ unique_suffix }| ).
    i_view_name_travel            = |{ co_prefix }I_{ co_entity_name }TP_{ unique_suffix }|.
    i_view_basic_name_travel      = |{ co_prefix }I_{ co_entity_name }_{ unique_suffix }|.
    "behavior pools
    beh_impl_name_travel          = |{ co_prefix }BP_{ co_entity_name }TP_{ unique_suffix }|.
    "business service
    srv_definition_name           = |{ co_prefix }UI_{ co_entity_name }_{ unique_suffix }|.
    srv_binding_o4_name           = |{ co_prefix }UI_{ co_entity_name }_O4_{ unique_suffix }|.


    " to upper
    package_name  = to_upper( package_name ).
    unique_suffix = to_upper( unique_suffix ).

    out->write( | Use transport { transport }| ).

    DATA(my_package) = xco_lib->get_package( package_name ).
    IF my_package->exists( ) = abap_false.
      out->write( | Info: Suffix "{ unique_suffix }" will be used. | ).
    ELSE.
      out->write( | Note: Package "{ package_name }" already exists. | ).
    ENDIF.

    TRY.
        "create package
        create_package( transport ).
        create_extension_package( transport_extensions ).
      CATCH cx_xco_gen_put_exception INTO DATA(put_exception).
        out->write( 'error creating packages' ).
        DATA(lt_findings) = put_exception->findings->get( ).
        LOOP AT lt_findings INTO DATA(finding).
          out->write( finding->message->get_text(  ) ).
        ENDLOOP.
        EXIT.
      CATCH cx_root INTO DATA(package_exception).
        IF debug_modus = abap_true.
          out->write( | Error during create_package( ). | ).
        ENDIF.
        EXIT.
    ENDTRY.

    data_generator_class_name     = |zrap630_cl_vh_product_{ unique_suffix }|.


    TRY.

        generate_vh_custom_entity( transport ).
*        generate_behavior_impl_class( transport ).
      CATCH cx_xco_gen_put_exception INTO DATA(put_vh_exception).
        out->write( 'error creating custom entity' ).
        lt_findings = put_vh_exception->findings->get( ).
        LOOP AT lt_findings INTO finding.
          out->write( finding->message->get_text(  ) ).
        ENDLOOP.
        EXIT.
    ENDTRY.





    mo_environment                 = get_environment( transport ).
    mo_put_operation               = get_put_operation( mo_environment )."->create_put_operation( ).

    TRY.
        create_rap_bo(
          EXPORTING
            out          = out
          IMPORTING
            eo_root_node = DATA(root_node)
        ).
      CATCH cx_xco_gen_put_exception INTO put_exception.
        out->write( 'error creating rap bo' ).
        lt_findings = put_exception->findings->get( ).
        LOOP AT lt_findings INTO finding.
          out->write( | { finding->message->get_type( )->value }: { finding->message->get_text(  ) } | ).
        ENDLOOP.
        EXIT.
    ENDTRY.
    out->write( | The following packages got created for you and will include everything you need: | ).
    out->write( | - "{ package_name }"     and | ).
    out->write( | - "{ extension_package_name }" | ).
    out->write( | In the "Project Explorer" right click on "Favorite Packages" and click on "Add Package...". | ).
    out->write( | Select both (!) packages "{ package_name }" and { extension_package_name } and click OK. | ).
    out->write( | The generation process has been started asynchronously in the backend | ).
    out->write( | and it will take some minutes to complete. | ).
  ENDMETHOD.
ENDCLASS.
