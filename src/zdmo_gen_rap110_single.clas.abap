CLASS zdmo_gen_rap110_single DEFINITION

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
      co_prefix             TYPE string           VALUE 'ZRAP110_',
      co_zlocal_package     TYPE sxco_package     VALUE 'ZLOCAL',
*      co_zrap110_ex_package TYPE sxco_package     VALUE 'ZRAP110_EXERCISES'.
      co_zrap110_ex_package TYPE sxco_package     VALUE 'ZLOCAL'.
*      co_zrap110_ex_package TYPE sxco_package VALUE 'ZRAP110_DRYRUN'.









    DATA xco_on_prem_library TYPE REF TO zdmo_cl_rap_xco_on_prem_lib.
    DATA xco_lib             TYPE REF TO zdmo_cl_rap_xco_lib.
    DATA package_name           TYPE sxco_package .
    DATA unique_suffix          TYPE string.
*    DATA mo_environment         TYPE REF TO if_xco_cp_gen_env_dev_system.
    DATA transport              TYPE sxco_transport .
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

    METHODS create_tables IMPORTING  io_out TYPE REF TO if_oo_adt_classrun_out .

    METHODS create_rap_bo IMPORTING out          TYPE REF TO if_oo_adt_classrun_out
                          EXPORTING eo_root_node TYPE REF TO zdmo_cl_rap_node .
    METHODS delete_iview_and_mde IMPORTING  out TYPE REF TO if_oo_adt_classrun_out .

    METHODS create_abs_ent_a_create_travel IMPORTING out          TYPE REF TO if_oo_adt_classrun_out .
    METHODS create_abs_ent_a_daystoflight  IMPORTING out          TYPE REF TO if_oo_adt_classrun_out.
    METHODS create_abs_ent_a_travel        IMPORTING out          TYPE REF TO if_oo_adt_classrun_out.

    METHODS create_number_range IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

    METHODS create_additional_objects IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

    METHODS get_unique_suffix     IMPORTING VALUE(s_prefix)     TYPE string RETURNING VALUE(s_unique_suffix) TYPE string.
    METHODS create_transport      RETURNING VALUE(lo_transport) TYPE sxco_transport.
    METHODS create_super_package. "only needed on-prem
    METHODS create_package        IMPORTING VALUE(lo_transport) TYPE sxco_transport.
    METHODS create_package_in_zlocal IMPORTING VALUE(lo_transport) TYPE sxco_transport.


*    METHODS generate_table        IMPORTING io_put_operation        TYPE REF TO if_xco_cp_gen_d_o_put
*                                            table_fields            TYPE tt_fields
*                                            table_name              TYPE sxco_dbt_object_name
*                                            table_short_description TYPE if_xco_cp_gen_tabl_dbt_s_form=>tv_short_description.
*
*    METHODS generate_data_generator_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put .
*    METHODS generate_virt_elem_trav_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put .
*    METHODS generate_virt_elem_book_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put .
*    METHODS generate_eml_playground_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation TYPE REF TO if_xco_cp_gen_d_o_put .

    METHODS generate_table        IMPORTING io_put_operation        LIKE mo_put_operation "  TYPE REF TO if_xco_gen_o_mass_put
                                            table_fields            TYPE tt_fields
                                            table_name              TYPE sxco_dbt_object_name
                                            table_short_description TYPE if_xco_cp_gen_tabl_dbt_s_form=>tv_short_description.

    METHODS generate_data_generator_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation LIKE mo_put_operation .
    METHODS generate_virt_elem_trav_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation LIKE mo_put_operation .
    METHODS generate_virt_elem_book_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation LIKE mo_put_operation .
    METHODS generate_eml_playground_class IMPORTING VALUE(lo_transport) TYPE sxco_transport io_put_operation LIKE mo_put_operation.






*    METHODS generate_data.
    METHODS get_root_table_fields  RETURNING VALUE(root_table_fields) TYPE tt_fields.
    METHODS get_child_table_fields RETURNING VALUE(child_table_fields) TYPE tt_fields.
*
*    METHODS release_data_generator_class  IMPORTING VALUE(lo_transport) TYPE sxco_transport.
    METHODS get_json_string           RETURNING VALUE(json_string) TYPE string.
    METHODS generate_cds_mde    IMPORTING io_out       TYPE REF TO if_oo_adt_classrun_out
                                          io_root_node TYPE REF TO zdmo_cl_rap_node .
ENDCLASS.



CLASS ZDMO_GEN_RAP110_SINGLE IMPLEMENTATION.


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


  METHOD create_abs_ent_a_create_travel.

    TRY.
        DATA(mo_put_operation2) = get_put_operation( mo_environment  ).
        DATA(lo_interface_specification) = mo_put_operation2->for-ddls->add_object( |ZRAP110_A_Create_Travel_{ unique_suffix }|
        )->set_package( package_name
        )->create_form_specification( ).
        "add entity description
        DATA(lo_abstract_entity) = lo_interface_specification->set_short_description( 'Parameter for Creating Travel+Booking'
        )->add_abstract_entity( ).
        "add view annotation
        lo_abstract_entity->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Parameter for Creating Travel+Booking' ).
        " Add fields.
        DATA(lo_identifier) = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'customer_id' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/customer_id' ) ).


        DATA(lo_valuebuilder) = lo_identifier->add_annotation( 'Consumption.valueHelpDefinition' )->value->build( ).
        lo_valuebuilder->begin_array(
                   )->begin_record(
                     )->add_member( 'entity'
                        )->begin_record(
                           )->add_member( 'name' )->add_string( CONV #( '/DMO/I_Customer_StdVH' )
                           )->add_member( 'element' )->add_string( CONV #( 'CustomerID' )
                        )->end_record( ).

*          lo_valuebuilder->add_member( 'additionalBinding'
*            )->begin_array( ).
*            DATA(lo_record) = lo_valuebuilder->begin_record(
*              )->add_member( 'localElement' )->add_string( CONV #( ls_additionalbinding-localelement )
*              )->add_member( 'element' )->add_string( CONV #( ls_additionalbinding-element )
*              ).
*            IF ls_additionalbinding-usage IS NOT INITIAL.
*              lo_record->add_member( 'usage' )->add_enum( CONV #( ls_additionalbinding-usage ) ).
*            ENDIF.
*            lo_valuebuilder->end_record(  ).
*          lo_valuebuilder->end_array( ).
        lo_valuebuilder->end_record( )->end_array( ).

        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'carrier_id' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/carrier_id' ) ).


        lo_valuebuilder = lo_identifier->add_annotation( 'Consumption.valueHelpDefinition' )->value->build( ).
        lo_valuebuilder->begin_array(
                   )->begin_record(
                     )->add_member( 'entity'
                        )->begin_record(
                           )->add_member( 'name' )->add_string( CONV #( '/DMO/I_Flight_StdVH' )
                           )->add_member( 'element' )->add_string( CONV #( 'AirlineID' )
                        )->end_record( ).

        lo_valuebuilder->add_member( 'additionalBinding'
          )->begin_array( ).
        DATA(lo_record) = lo_valuebuilder->begin_record(
          )->add_member( 'localElement' )->add_string( CONV #( 'flight_date' )
          )->add_member( 'element' )->add_string( CONV #( 'FlightDate' )
          ).
        lo_record->add_member( 'usage' )->add_enum( CONV #( 'RESULT' ) ).
        lo_valuebuilder->end_record(  ).

        lo_record = lo_valuebuilder->begin_record(
          )->add_member( 'localElement' )->add_string( CONV #( 'connection_id' )
          )->add_member( 'element' )->add_string( CONV #( 'ConnectionID' )
          ).
        lo_record->add_member( 'usage' )->add_enum( CONV #( 'RESULT' ) ).


        lo_valuebuilder->end_record(  ).
        lo_valuebuilder->end_array( ).
        lo_valuebuilder->end_record( )->end_array( ).

        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'connection_id' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/connection_id' ) ).

        lo_valuebuilder = lo_identifier->add_annotation( 'Consumption.valueHelpDefinition' )->value->build( ).
        lo_valuebuilder->begin_array(
                   )->begin_record(
                     )->add_member( 'entity'
                        )->begin_record(
                           )->add_member( 'name' )->add_string( CONV #( '/DMO/I_Flight_StdVH' )
                           )->add_member( 'element' )->add_string( CONV #( 'AirlineID' )
                        )->end_record( ).

        lo_valuebuilder->add_member( 'additionalBinding'
          )->begin_array( ).

        lo_record = lo_valuebuilder->begin_record(
          )->add_member( 'localElement' )->add_string( CONV #( 'flight_date' )
          )->add_member( 'element' )->add_string( CONV #( 'FlightDate' )
          ).
        lo_record->add_member( 'usage' )->add_enum( CONV #( 'RESULT' ) ).
        lo_valuebuilder->end_record(  ).

        lo_record = lo_valuebuilder->begin_record(
          )->add_member( 'localElement' )->add_string( CONV #( 'carrier_id' )
          )->add_member( 'element' )->add_string( CONV #( 'AirlineID' )
          ).
        lo_record->add_member( 'usage' )->add_enum( CONV #( 'FILTER_AND_RESULT' ) ).
        lo_valuebuilder->end_record(  ).

        lo_valuebuilder->end_array( ).

        lo_valuebuilder->end_record( )->end_array( ).

        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'flight_date' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/flight_date' ) ).

        lo_valuebuilder = lo_identifier->add_annotation( 'Consumption.valueHelpDefinition' )->value->build( ).
        lo_valuebuilder->begin_array(
                   )->begin_record(
                     )->add_member( 'entity'
                        )->begin_record(
                           )->add_member( 'name' )->add_string( CONV #( '/DMO/I_Flight_StdVH' )
                           )->add_member( 'element' )->add_string( CONV #( 'AirlineID' )
                        )->end_record( ).

        lo_valuebuilder->add_member( 'additionalBinding'
          )->begin_array( ).
        lo_record = lo_valuebuilder->begin_record(
          )->add_member( 'localElement' )->add_string( CONV #( 'carrier_id' )
          )->add_member( 'element' )->add_string( CONV #( 'AirlineID' )
          ).
        lo_record->add_member( 'usage' )->add_enum( CONV #( 'FILTER_AND_RESULT' ) ).
        lo_valuebuilder->end_record(  ).

        lo_record = lo_valuebuilder->begin_record(
          )->add_member( 'localElement' )->add_string( CONV #( 'connection_id' )
          )->add_member( 'element' )->add_string( CONV #( 'ConnectionID' )
          ).
        lo_record->add_member( 'usage' )->add_enum( CONV #( 'FILTER_AND_RESULT' ) ).

        lo_valuebuilder->end_record(  ).
        lo_valuebuilder->end_array( ).
        lo_valuebuilder->end_record( )->end_array( ).

        DATA(lo_result) = mo_put_operation2->execute( ).

        " handle findings
        DATA(lo_findings) = lo_result->findings.
        DATA(lt_findings) = lo_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            out->write( lt_findings ).
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(class_gen_exception).
        out->write( cl_message_helper=>get_latest_t100_exception( class_gen_exception )->if_message~get_longtext( ) ).
        DATA(class_gen_findings) = class_gen_exception->findings.
        lt_findings = class_gen_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO DATA(finding).
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.

  ENDMETHOD.


  METHOD create_abs_ent_a_daystoflight.
    TRY.
        DATA(mo_put_operation2) = get_put_operation( mo_environment  ).
        DATA(lo_interface_specification) = mo_put_operation2->for-ddls->add_object( |ZRAP110_A_DaysToFlight_{ unique_suffix }|
        )->set_package( package_name
        )->create_form_specification( ).
        "add entity description
        DATA(lo_abstract_entity) = lo_interface_specification->set_short_description( 'Abstract entity for Days To Flight'
        )->add_abstract_entity( ).
        "add view annotation
        lo_abstract_entity->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Abstract entity for Days To Flight' ).
        " Add fields.
        DATA(lo_identifier) = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'initial_days_to_flight' )
        )->set_type( xco_cp_abap_dictionary=>data_element( 'abap.int4' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'remaining_days_to_flight' )
        )->set_type( xco_cp_abap_dictionary=>data_element( 'abap.int4' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'booking_status_indicator' )
        )->set_type( xco_cp_abap_dictionary=>data_element( 'abap.int4' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'days_to_flight_indicator' )
        )->set_type( xco_cp_abap_dictionary=>data_element( 'abap.int4' ) ).

        DATA(lo_result) = mo_put_operation2->execute( ).

        " handle findings
        DATA(lo_findings) = lo_result->findings.
        DATA(lt_findings) = lo_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            out->write( lt_findings ).
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(class_gen_exception).
        out->write( cl_message_helper=>get_latest_t100_exception( class_gen_exception )->if_message~get_longtext( ) ).
        DATA(class_gen_findings) = class_gen_exception->findings.
        lt_findings = class_gen_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO DATA(finding).
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.

  ENDMETHOD.


  METHOD create_abs_ent_a_travel. "Abstract entity for Travel
    TRY.
        DATA(mo_put_operation2) = get_put_operation( mo_environment  ).
        DATA(lo_interface_specification) = mo_put_operation2->for-ddls->add_object( |ZRAP110_A_TRAVEL_{ unique_suffix }|
        )->set_package( package_name
        )->create_form_specification( ).
        "add entity description
        DATA(lo_abstract_entity) = lo_interface_specification->set_short_description( 'Parameter for Creating Travel+Booking'
        )->add_abstract_entity( ).
        "add view annotation
        lo_abstract_entity->add_annotation( 'EndUserText.label' )->value->build( )->add_string( 'Parameter for Creating Travel+Booking' ).
        " Add fields.
        DATA(lo_identifier) = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'travel_id' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/travel_id' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'agency_id' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/agency_id' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'customer_id' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/customer_id' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'overall_status' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/overall_status' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'description' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/description' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'total_price' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/total_price' ) ).
        lo_identifier->add_annotation( 'Semantics.amount.currencyCode' )->value->build( )->add_string( 'currency_code' ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'currency_code' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/currency_code' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'begin_date' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/begin_date' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'end_date' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/end_date' ) ).
        lo_identifier = lo_abstract_entity->add_field( xco_cp_ddl=>field( 'email_address' )
        )->set_type( xco_cp_abap_dictionary=>data_element( '/dmo/email_address' ) ).

        DATA(lo_result) = mo_put_operation2->execute( ).

        " handle findings
        DATA(lo_findings) = lo_result->findings.
        DATA(lt_findings) = lo_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            out->write( lt_findings ).
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(class_gen_exception).
        out->write( cl_message_helper=>get_latest_t100_exception( class_gen_exception )->if_message~get_longtext( ) ).
        DATA(class_gen_findings) = class_gen_exception->findings.
        lt_findings = class_gen_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO DATA(finding).
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.
  ENDMETHOD.


  METHOD create_additional_objects.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    TRY.
        "generate Travel virtual element class
        IF debug_modus = abap_true.
          out->write( 'generate Travel virtual element class' ).
        ENDIF.
        DATA(mo_put_operation2) = get_put_operation( mo_environment  ).
        generate_virt_elem_trav_class(
          EXPORTING
            io_put_operation       = mo_put_operation2
            lo_transport            = transport
        ).
        DATA(lo_result) = mo_put_operation2->execute( ).

        " handle findings
        DATA(lo_findings) = lo_result->findings.
        DATA(lt_findings) = lo_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            out->write( lt_findings ).
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(class_gen_exception).
        DATA(class_gen_findings) = class_gen_exception->findings.
        lt_findings = class_gen_findings->get( ).
        IF debug_modus = abap_true.
          out->write( cl_message_helper=>get_latest_t100_exception( class_gen_exception )->if_message~get_longtext( ) ).
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO DATA(finding).
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.

    TRY.
        "generate Booking virtual element class
        DATA(mo_put_operation3) = get_put_operation( mo_environment  ).
        generate_virt_elem_book_class(
          EXPORTING
            io_put_operation       = mo_put_operation3
            lo_transport            = transport
        ).

        lo_result = mo_put_operation3->execute( ).

        " handle findings
        lo_findings = lo_result->findings.
        lt_findings = lo_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            out->write( lt_findings ).
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(class_gen_exception_02).
        DATA(class_gen_findings_02) = class_gen_exception_02->findings.
        lt_findings = class_gen_findings_02->get( ).
        IF debug_modus = abap_true.
          out->write( cl_message_helper=>get_latest_t100_exception( class_gen_exception_02 )->if_message~get_longtext( ) ).
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO finding.
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    TRY.
        "generate Booking virtual element class
        DATA(mo_put_operation4) = get_put_operation( mo_environment  ).
        generate_data_generator_class(
          EXPORTING
            io_put_operation       = mo_put_operation4
            lo_transport            = transport
        ).

        lo_result = mo_put_operation4->execute( ).

        " handle findings
        lo_findings = lo_result->findings.
        lt_findings = lo_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            out->write( lt_findings ).
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(class_gen_exception_03).
        out->write( cl_message_helper=>get_latest_t100_exception( class_gen_exception_03 )->if_message~get_longtext( ) ).
        DATA(class_gen_findings_03) = class_gen_exception_03->findings.
        lt_findings = class_gen_findings_03->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO finding.
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    TRY.
        "generate EML playground class class
        DATA(mo_put_operation5) = get_put_operation( mo_environment  ).
        generate_eml_playground_class(
          EXPORTING
            io_put_operation       = mo_put_operation5
            lo_transport            = transport
        ).

        lo_result = mo_put_operation5->execute( ).

        " handle findings
        lo_findings = lo_result->findings.
        lt_findings = lo_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            out->write( lt_findings ).
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(class_gen_exception_05).
        out->write( cl_message_helper=>get_latest_t100_exception( class_gen_exception_05 )->if_message~get_longtext( ) ).
        DATA(class_gen_findings_05) = class_gen_exception_05->findings.
        lt_findings = class_gen_findings_05->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO finding.
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""ENDE
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ENDMETHOD.


  METHOD create_number_range.
    DATA:
      lv_object   TYPE cl_numberrange_objects=>nr_attributes-object,
      lv_devclass TYPE cl_numberrange_objects=>nr_attributes-devclass,
      lv_corrnr   TYPE cl_numberrange_objects=>nr_attributes-corrnr.

    DATA: lt_interval TYPE cl_numberrange_intervals=>nr_interval,
          ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.

    ls_interval-nrrangenr  = '01'.
    ls_interval-fromnumber = '00000001'.
    ls_interval-tonumber   = '99999999'.
    ls_interval-procind    = 'I'.
    APPEND ls_interval TO lt_interval.


    DATA: group_id   TYPE string,
          error_flag TYPE c.

    group_id = unique_suffix.

    CLEAR error_flag.

    lv_object   = |ZRAP110{ group_id }|.
    lv_devclass = |ZRAP110_{ group_id }|.
    lv_corrnr   = transport.

    TRY.
        cl_numberrange_objects=>create(
          EXPORTING
            attributes = VALUE #( object     = lv_object
                                  domlen     = '/DMO/TRAVEL_ID'
                                  percentage = 10
                                  buffer     = abap_false
                                  noivbuffer = 0
                                  devclass   = lv_devclass
                                  corrnr     = lv_corrnr )
            obj_text   = VALUE #( object     = lv_object
                                  langu      = 'E'
                                  txt        = |RAP110 Travel ID group { group_id }|
                                  txtshort   = 'RAP110 Travel ID' )
          IMPORTING
            errors     = DATA(lt_errors)
            returncode = DATA(lv_returncode)
            ).

      CATCH cx_nr_object_not_found INTO DATA(lx_nr_object_not_found).
        ASSERT 1 = 1.  error_flag = '1'.

      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        ASSERT 1 = 1.  error_flag = '2'.

    ENDTRY.


    TRY.

        CALL METHOD cl_numberrange_intervals=>create
          EXPORTING
            interval  = lt_interval
            object    = lv_object
            subobject = ' '
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error)
            error_iv  = DATA(lt_error_iv)
            warning   = DATA(lv_warning).

      CATCH cx_nr_object_not_found INTO lx_nr_object_not_found.
        ASSERT 1 = 1.  error_flag = '3'.

      CATCH cx_number_ranges INTO lx_number_ranges.
        ASSERT 1 = 1.  error_flag = '4'.

    ENDTRY.

    COMMIT WORK.

    IF error_flag > 0.
      out->write( |Number Range Object: { lv_object }   Package: { lv_devclass }   Transport: { lv_corrnr }   Error: { error_flag }| ).
    ELSE.
      out->write( |Number Range Object: { lv_object }   Package: { lv_devclass } created.| ).
    ENDIF.



  ENDMETHOD.


  METHOD create_package.
    DATA(package_environment) = get_environment( lo_transport ).
    DATA(lo_put_operation) = get_put_operation_for_devc( package_environment ).
    DATA(lo_specification) = lo_put_operation->add_object( package_name )->create_form_specification( ).
    lo_specification->set_short_description( '#Generated RAP110  tutorial package' ).
    lo_specification->properties->set_super_package( co_zrap110_ex_package )->set_software_component( co_zlocal_package ).
    DATA(lo_result) = lo_put_operation->execute( ).
  ENDMETHOD.


  METHOD create_package_in_zlocal.
    DATA(package_environment) = get_environment( lo_transport ).
    DATA(lo_put_operation) = get_put_operation_for_devc( package_environment ).
    DATA(lo_specification) = lo_put_operation->add_object( package_name )->create_form_specification( ).
    lo_specification->set_short_description( '#Generated RAP110  tutorial package' ).
    lo_specification->properties->set_super_package( co_zlocal_package )->set_software_component( co_zlocal_package ).
    DATA(lo_result) = lo_put_operation->execute( ).
  ENDMETHOD.


  METHOD create_rap_bo.

    DATA(json_string)              = get_json_string(  ).            " get json document

    "BO generation
    TRY.
        DATA(rap_bo_generator) = zdmo_cl_rap_generator=>create_for_cloud_development( json_string ).
        eo_root_node = rap_bo_generator->root_node.

        DATA(lt_todos)         = rap_bo_generator->generate_bo(  ).
        IF debug_modus = abap_true.
          " handle findings
          out->write( | rap bo generated { rap_bo_generator->root_node->rap_node_objects-cds_view_r }| ).
          LOOP AT lt_todos INTO DATA(ls_todo).
            out->write( ls_todo-message ).
          ENDLOOP.
        ENDIF.
      CATCH cx_xco_gen_put_exception INTO DATA(bo_gen_exception).
        out->write( cl_message_helper=>get_latest_t100_exception( bo_gen_exception )->if_message~get_longtext( ) ).
        DATA(bo_gen_findings) = bo_gen_exception->findings.
        DATA(lt_findings) = bo_gen_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO DATA(finding).
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
      CATCH zdmo_cx_rap_generator INTO DATA(rap_generator_exception).
        IF debug_modus = abap_true.
          out->write( cl_message_helper=>get_latest_t100_exception( rap_generator_exception )->if_message~get_longtext( ) ).
        ENDIF.
        EXIT.
    ENDTRY.

  ENDMETHOD.


  METHOD create_super_package.
    DATA(lo_environment) = get_environment(  ).
    DATA(lo_put_operation) = get_put_operation_for_devc( lo_environment ).
    DATA(lo_specification) = lo_put_operation->add_object( co_zlocal_package )->create_form_specification( ).
    lo_specification->set_short_description( 'RAP110 tutorial super package' ).
    lo_specification->properties->set_software_component( 'LOCAL' ).
    lo_put_operation->execute( ).
  ENDMETHOD.


  METHOD create_tables.

    mo_environment                 = get_environment( transport ).
    mo_put_operation               = get_put_operation( mo_environment )."->create_put_operation( ).
    DATA(lo_objects_put_operation) = get_put_operation( mo_environment ).

    DATA(lo_table_root)            = xco_cp_abap_repository=>object->tabl->for( CONV #( table_name_root ) ).
    DATA(lo_table_child)           = xco_cp_abap_repository=>object->tabl->for( CONV #( table_name_child ) ).

    DATA table_generated TYPE abap_bool.
    DATA table_exists TYPE abap_bool.

    DATA(root_table_fields)        = get_root_table_fields(  ).
    DATA(child_table_fields)       = get_child_table_fields(  ).

    IF lo_table_root->exists(
    io_origin = xco_cp_table=>origin->local(  )
       )   = abap_false AND
       lo_table_child->exists(
       io_origin = xco_cp_table=>origin->local(  )
       ) = abap_false.

      "generate of travel table
      generate_table(
        EXPORTING
          io_put_operation         = lo_objects_put_operation
          table_fields             = root_table_fields
          table_name               = table_name_root
          table_short_description  = 'Travel data'
      ).
      "generate of booking table
      generate_table(
        EXPORTING
          io_put_operation        = lo_objects_put_operation
          table_fields            = child_table_fields
          table_name              = table_name_child
          table_short_description = 'Booking data'
      ).

      TRY.
          "create the tables
          DATA(lo_result) = lo_objects_put_operation->execute( ).
          IF debug_modus = abap_true.
            io_out->write( | - Table { table_name_child } has been created.| ).
            io_out->write( | - Table { table_name_root } has been created.| ).

            " handle findings
            DATA(lo_findings) = lo_result->findings.
            DATA(lt_findings) = lo_findings->get( ).
            IF lt_findings IS NOT INITIAL.
              io_out->write( lt_findings ).
            ENDIF.
          ENDIF.
        CATCH cx_xco_gen_put_exception INTO DATA(table_exception).
          io_out->write( cl_message_helper=>get_latest_t100_exception( table_exception )->if_message~get_longtext( ) ).
          DATA(table_findings) = table_exception->findings.
          lt_findings = table_findings->get( ).
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO DATA(finding).
              io_out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
          EXIT.
      ENDTRY.
    ELSE.
      table_exists = abap_true.
      io_out->write( | - Table { table_name_root } already exists.| ).
    ENDIF.
  ENDMETHOD.


  METHOD create_transport.
    DATA(ls_package) = xco_lib->get_package( co_zlocal_package ).
    IF ls_package->read( )-property-record_object_changes = abap_true.
*    DATA(ls_package) = xco_cp_abap_repository=>package->for( co_zlocal_package )->read( ).
      DATA(lv_transport_layer) = ls_package->read( )-property-transport_layer->value.
      DATA(lv_transport_target) = ls_package->read( )-property-transport_layer->get_transport_target( )->value.
      DATA(lo_transport_request) = xco_cp_cts=>transports->workbench( lv_transport_target )->create_request( '#Generated RAP110 tutorial transport request' ).
      lo_transport = lo_transport_request->value.
    ENDIF.
  ENDMETHOD.


  METHOD delete_iview_and_mde.
    "CDS MDE deletion and generation
    TRY.

        DATA lv_del_transport   TYPE sxco_transport.
        lv_del_transport = transport.
        IF debug_modus = abap_true.
          out->write( |use transport for deletion { lv_del_transport }| ).
        ENDIF.
        IF lv_del_transport IS INITIAL.
          DATA(cts_obj) = xco_cp_abap_repository=>object->for(
          EXPORTING
          iv_type = 'DDLX'
          iv_name = to_upper(   c_view_name_travel )
            )->if_xco_cts_changeable~get_object( ).
          lv_del_transport = cts_obj->get_lock( )->get_transport( ).
          lv_del_transport = xco_cp_cts=>transport->for( lv_del_transport )->get_request( )->value.
        ENDIF.

        DATA(mo_environment2) = get_environment( lv_del_transport ).
*          mo_environment2 = get_environment( lv_del_transport ). "xco_cp_generation=>environment->dev_system( lv_del_transport ).
        DATA(lo_delete_ddlx_operation) = mo_environment2->for-ddlx->create_delete_operation( ).
        lo_delete_ddlx_operation->add_object( c_view_name_travel ).
        lo_delete_ddlx_operation->add_object( c_view_name_booking ).
        DATA(result_del_ddlx) = lo_delete_ddlx_operation->execute( ).

        IF debug_modus = abap_true.
          out->write( |Success: deleting CDS MDE objects| ).
          DATA(lt_findings) = result_del_ddlx->findings->get(  ).
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO DATA(finding).
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.

        DATA(lo_delete_bdef_iview_operation) = mo_environment2->for-bdef->create_delete_operation( ).
        lo_delete_bdef_iview_operation->add_object( i_view_name_travel ).

        IF debug_modus = abap_true.
          out->write( |add object i bdef for deletion { i_view_name_travel  } | ).
        ENDIF.
        DATA(result_del_bdef) = lo_delete_bdef_iview_operation->execute( ).

        IF debug_modus = abap_true.
          out->write( |Success: deleting bdef interface | ).
          lt_findings = result_del_bdef->findings->get(  ).
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO finding.
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.

        DATA(lo_delete_cds_iview_operation) = mo_environment2->for-ddls->create_delete_operation( ).
        lo_delete_cds_iview_operation->add_object( i_view_name_travel ).
        lo_delete_cds_iview_operation->add_object( i_view_name_booking ).
        IF debug_modus = abap_true.
          out->write( |add object i view for deletion { i_view_name_travel  } and { i_view_name_booking  } | ).
        ENDIF.
        DATA(result_del_ddls) = lo_delete_cds_iview_operation->execute( ).

        IF debug_modus = abap_true.
          out->write( |Success: deleting CDS interface objects| ).
          lt_findings = result_del_ddls->findings->get(  ).
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO finding.
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.

      CATCH cx_xco_gen_put_exception INTO DATA(bo_del_exception).
        out->write( 'error occured' ).
        out->write( cl_message_helper=>get_latest_t100_exception( bo_del_exception )->if_message~get_longtext( ) ).
        DATA(bo_del_findings) = bo_del_exception->findings.
        lt_findings = bo_del_findings->get( ).
        IF debug_modus = abap_true.
          IF lt_findings IS NOT INITIAL.
            LOOP AT lt_findings INTO finding.
              out->write( finding->message->get_text(  ) ).
            ENDLOOP.
          ENDIF.
        ENDIF.
    ENDTRY.

  ENDMETHOD.


  METHOD generate_cds_mde.

    DATA: pos              TYPE i VALUE 0,
          lo_field         TYPE REF TO if_xco_gen_ddlx_s_fo_field,
          lv_del_transport TYPE sxco_transport.

*    DATA(json_string)              = get_json_string(  ).            " get json document
*    DATA(rap_bo_generator) = zdmo_cl_rap_generator=>create_for_cloud_development( json_string ).
    DATA(io_rap_bo_node) =  io_root_node  .

    DATA(cts_obj) = xco_cp_abap_repository=>object->for(
    EXPORTING
    iv_type = 'DDLX'
    iv_name = to_upper( c_view_name_travel )
    )->if_xco_cts_changeable~get_object( ).
    lv_del_transport = cts_obj->get_lock( )->get_transport( ).
    lv_del_transport = xco_cp_cts=>transport->for( lv_del_transport )->get_request( )->value.

    DATA(mo_environment)   = xco_cp_generation=>environment->dev_system( lv_del_transport ).
    DATA(mo_put_operation) = mo_environment->create_put_operation( ).
*    DATA(lv_package)       = io_rap_bo_node->root_node->package.



    DATA(lo_specification) = mo_put_operation->for-ddlx->add_object(  io_rap_bo_node->rap_node_objects-meta_data_extension
      )->set_package( package_name
      )->create_form_specification( ).

    lo_specification->set_short_description( |MDE for { io_rap_bo_node->rap_node_objects-alias }|
      )->set_layer( xco_cp_metadata_extension=>layer->customer
      )->set_view( io_rap_bo_node->rap_node_objects-cds_view_p ). .

    lo_specification->add_annotation( 'UI' )->value->build(
    )->begin_record(
        )->add_member( 'headerInfo'
         )->begin_record(
          )->add_member( 'typeName' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
          )->add_member( 'typeNamePlural' )->add_string( io_rap_bo_node->rap_node_objects-alias && 's'
          )->add_member( 'title'
            )->begin_record(
              )->add_member( 'type' )->add_enum( 'STANDARD'
              )->add_member( 'label' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
              )->add_member( 'value' )->add_string( io_rap_bo_node->object_id_cds_field_name && ''
        )->end_record(
        )->end_record(
      "presentationVariant: [ { sortOrder: [{ by: 'TravelID', direction:  #DESC }], visualizations: [{type: #AS_LINEITEM}] }] }
      )->add_member( 'presentationVariant'
        )->begin_array(
          )->begin_record(
          )->add_member( 'sortOrder'
            )->begin_array(
             )->begin_record(
              )->add_member( 'by' )->add_string( 'TravelID'
               )->add_member( 'direction' )->add_enum( 'DESC'
             )->end_record(
            )->end_array(
          )->add_member( 'visualizations'
          )->begin_array(
             )->begin_record(
               )->add_member( 'type' )->add_enum( 'AS_LINEITEM'
             )->end_record(
            )->end_array(
          )->end_record(
          )->end_array(
          )->end_record(  ).


    LOOP AT io_rap_bo_node->lt_fields INTO  DATA(ls_header_fields) WHERE name <> io_rap_bo_node->field_name-client.
      "increase position
      pos += 10.
      lo_field = lo_specification->add_field( ls_header_fields-cds_view_field ).

      "put facet annotation in front of the first
      IF pos = 10.
        IF io_rap_bo_node->is_root(  ) = abap_true.
          IF io_rap_bo_node->has_childs(  ).
            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'COLLECTION'
                  )->add_member( 'label' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idIdentification'
                  )->add_member( 'parentId' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( 'General Information'
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idLineitem'
                  )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
                  )->add_member( 'label' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''
                  )->add_member( 'position' )->add_number( 20
                  )->add_member( 'targetElement' )->add_string( '_' && io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias
                )->end_record(
              )->end_array( ).
          ELSE.
            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'COLLECTION'
                  )->add_member( 'label' )->add_string( io_rap_bo_node->rap_node_objects-alias && ''
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                  )->add_member( 'id' )->add_string( 'idIdentification'
                  )->add_member( 'parentId' )->add_string( 'idCollection'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( 'General Information'
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
              )->end_array( ).
          ENDIF.
        ELSE.
          IF io_rap_bo_node->has_childs(  ).
            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
*                  )->add_member( 'id' )->add_string( CONV #( 'id' && io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'id' )->add_string( 'id' && io_rap_bo_node->rap_node_objects-alias
                  )->add_member( 'purpose' )->add_enum( 'STANDARD'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
                )->begin_record(
                    )->add_member( 'id' )->add_string( 'idLineitem'
                    )->add_member( 'type' )->add_enum( 'LINEITEM_REFERENCE'
                    )->add_member( 'label' )->add_string( io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias && ''
                    )->add_member( 'position' )->add_number( 20
                    )->add_member( 'targetElement' )->add_string( '_' && io_rap_bo_node->childnodes[ 1 ]->rap_node_objects-alias
                  )->end_record(
              )->end_array( ).
          ELSE.
            lo_field->add_annotation( 'UI.facet' )->value->build(
              )->begin_array(
                )->begin_record(
*                  )->add_member( 'id' )->add_string( CONV #( 'id' && io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'id' )->add_string( 'id' && io_rap_bo_node->rap_node_objects-alias
                  )->add_member( 'purpose' )->add_enum( 'STANDARD'
                  )->add_member( 'type' )->add_enum( 'IDENTIFICATION_REFERENCE'
                  )->add_member( 'label' )->add_string( CONV #( io_rap_bo_node->rap_node_objects-alias )
                  )->add_member( 'position' )->add_number( 10
                )->end_record(
              )->end_array( ).
          ENDIF.
        ENDIF.
      ENDIF.

      CASE to_upper( ls_header_fields-name ).
        WHEN io_rap_bo_node->field_name-uuid.
          "hide technical key field (uuid)
          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).

        WHEN io_rap_bo_node->field_name-last_changed_by OR
             io_rap_bo_node->field_name-last_changed_at OR
             io_rap_bo_node->field_name-created_at OR io_rap_bo_node->field_name-created_by OR
             io_rap_bo_node->field_name-local_instance_last_changed_at OR
             io_rap_bo_node->field_name-parent_uuid OR io_rap_bo_node->field_name-root_uuid OR
             'MIME_TYPE' OR 'FILE_NAME'.
          "hide administrative fields and guid-based fields
          lo_field->add_annotation( 'UI.hidden' )->value->build(  )->add_boolean( iv_value =  abap_true ).

*        WHEN 'LAST_CHANGED_AT' OR
*             'CREATED_BY' OR 'LOCAL_CREATED_AT' OR 'LOCAL_LAST_CHANGED_BY'
          .
          "do nothing. Admin fields not needed on the UI.

        WHEN 'CURRENCY_CODE'.
          "do nothing. The currency will be automatically displayed with the associated amount fields

*          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*          "display field only on object page
*          DATA(lo_valuebuilder) = lo_field->add_annotation( 'UI.lineItem' )->value->build( ).
*          DATA(lo_record) = lo_valuebuilder->begin_array(
*          )->begin_record(
*              )->add_member( 'position' )->add_number( pos  ").
*              )->add_member( 'importance' )->add_enum( 'HIGH').
*
*          "label for fields based on a built-in type
*          IF ls_header_fields-is_data_element = abap_false.
*            lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
*          ENDIF.
*          lo_valuebuilder->end_record( )->end_array( ).
*
*          lo_valuebuilder = lo_field->add_annotation( 'UI.identification' )->value->build( ).
*          lo_record = lo_valuebuilder->begin_array(
*          )->begin_record(
*              )->add_member( 'position' )->add_number( pos ).
*          IF ls_header_fields-is_data_element = abap_false.
*            lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
*          ENDIF.
*          lo_valuebuilder->end_record( )->end_array( ).

        WHEN OTHERS.
          "display field
          DATA lo_valuebuilder TYPE REF TO if_xco_gen_cds_s_fo_ann_v_bldr .

          IF ls_header_fields-name <> 'CURRENCY_CODE'  AND ls_header_fields-name <> 'DESCRIPTION'
            AND ls_header_fields-name <> 'TOTAL_PRICE' AND ls_header_fields-name <> 'BOOKING_FEE'
            AND ls_header_fields-name <> 'BEGIN_DATE'  AND ls_header_fields-name <> 'END_DATE'
            AND ls_header_fields-name <> 'ATTACHMENT'.
            " line item page
            lo_valuebuilder = lo_field->add_annotation( 'UI.lineItem' )->value->build( ).
            DATA(lo_record) = lo_valuebuilder->begin_array(
            )->begin_record(
                )->add_member( 'position' )->add_number( pos  ").
                )->add_member( 'importance' )->add_enum( 'HIGH').

            "label for fields based on a built-in type
            IF ls_header_fields-is_data_element = abap_false.
              lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
            ENDIF.
            lo_valuebuilder->end_record( )->end_array( ).
          ENDIF.

          "object page
          lo_valuebuilder = lo_field->add_annotation( 'UI.identification' )->value->build( ).
          lo_record = lo_valuebuilder->begin_array(
          )->begin_record(
              )->add_member( 'position' )->add_number( pos ).
          IF ls_header_fields-is_data_element = abap_false.
            lo_record->add_member( 'label' )->add_string( CONV #( ls_header_fields-cds_view_field ) ).
          ENDIF.
          "add label
          IF ls_header_fields-name = 'ATTACHMENT'.
            lo_record->add_member( 'label' )->add_string( CONV #( 'Upload a File' ) ).
          ENDIF.
          lo_valuebuilder->end_record( )->end_array( ).

          "text alignment
          IF ls_header_fields-name = 'CUSTOMER_ID' .
            lo_field->add_annotation( 'UI.textArrangement' )->value->build(  )->add_enum( iv_value =  'TEXT_FIRST' ).
          ELSEIF ls_header_fields-name = 'OVERALL_STATUS' OR ls_header_fields-name = 'BOOKING_STATUS'.
            lo_field->add_annotation( 'UI.textArrangement' )->value->build(  )->add_enum( iv_value =  'TEXT_ONLY' ).
          ENDIF.

          "selection fields
          IF
             ls_header_fields-name = 'TRAVEL_ID' OR
             ls_header_fields-name = 'CUSTOMER_ID' OR
             ls_header_fields-name = 'AGENCY_ID' .

            lo_field->add_annotation( 'UI.selectionField' )->value->build(
            )->begin_array(
            )->begin_record(
                )->add_member( 'position' )->add_number( pos
              )->end_record(
            )->end_array( ).
          ENDIF.
          IF io_rap_bo_node->is_root(  ) = abap_true AND
             io_rap_bo_node->get_implementation_type( ) = io_rap_bo_node->implementation_type-managed_uuid  AND
             ls_header_fields-name = io_rap_bo_node->object_id.

            lo_field->add_annotation( 'UI.selectionField' )->value->build(
            )->begin_array(
            )->begin_record(
                )->add_member( 'position' )->add_number( pos
              )->end_record(
            )->end_array( ).
          ENDIF.
      ENDCASE.
    ENDLOOP.

    TRY.

        mo_put_operation->execute(  ).

      CATCH cx_xco_gen_put_exception INTO DATA(bo_del_exception).
        IF debug_modus = abap_true.
          io_out->write( 'error occured' ).
          io_out->write( cl_message_helper=>get_latest_t100_exception( bo_del_exception )->if_message~get_longtext( ) ).
          DATA(bo_del_findings) = bo_del_exception->findings.
          DATA(lt_findings) = bo_del_findings->get( ).
          IF lt_findings IS NOT INITIAL.
            IF debug_modus = abap_true.
              LOOP AT lt_findings INTO DATA(finding).
                io_out->write( finding->message->get_text(  ) ).
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDTRY.

  ENDMETHOD.


  METHOD generate_data_generator_class.
    EXIT.  "comment this line out if generation is needed

    DATA(lo_specification) = io_put_operation->for-clas->add_object(  data_generator_class_name
                                      )->set_package( package_name
                                      )->create_form_specification( ).
    lo_specification->set_short_description( |This class generates the test data| ).

    lo_specification->set_short_description( 'Data generator class' ).
    lo_specification->definition->add_interface( 'if_oo_adt_classrun' ).
    lo_specification->implementation->add_method( |if_oo_adt_classrun~main|
      )->set_source( VALUE #(

        " business logic to fill both tables with demo data
        ( |      DELETE FROM ('{ table_name_root }').| )
        ( |     " insert travel demo data | )
        ( |     INSERT ('{ table_name_root }')  FROM ( | )
        ( |         SELECT | )

        ( |           FROM /dmo/travel AS travel | )
        ( |           FIELDS | )
        ( |             travel~travel_id        AS travel_id, | )
        ( |             travel~agency_id        AS agency_id, | )
        ( |             travel~customer_id      AS customer_id, | )
        ( |             travel~begin_date       AS begin_date, | )
        ( |             travel~end_date         AS end_date, | )
        ( |             travel~booking_fee      AS booking_fee, | )
        ( |             travel~total_price      AS total_price, | )
        ( |             travel~currency_code    AS currency_code, | )
        ( |             travel~description      AS description, | )
        ( |             CASE travel~status    "Status [N(New) \| P(Planned) \| B(Booked) \| X(Cancelled)] | )
        ( |               WHEN 'N' THEN 'O' | )
        ( |               WHEN 'P' THEN 'O' | )
        ( |               WHEN 'B' THEN 'A' | )
        ( |               ELSE 'X' | )
        ( |             END                     AS overall_status,  "Travel Status [A(Accepted) \| O(Open) \| X(Cancelled)] | )
        ( |             travel~createdby        AS created_by, | )
        ( |             travel~createdat        AS created_at, | )
        ( |             travel~lastchangedby    AS last_changed_by, | )
        ( |             travel~lastchangedat    AS last_changed_at | )
        ( |             ORDER BY travel_id UP TO 5 ROWS | )
        ( |       ). | )
        ( |     COMMIT WORK. | )

        ( |     " define FROM clause dynamically | )
        ( |     DATA: dyn_table_name TYPE string. | )
        ( |     dyn_table_name = \| /dmo/booking    AS booking  \| | )
        ( |                  && \| JOIN \{ '{ table_name_root }' \} AS z \|  | )
        ( |                  && \| ON   booking~travel_id = z~travel_id \|. | )

        ( |     DELETE FROM ('{ table_name_child }'). | )
        ( |     " insert booking demo data | )
        ( |     INSERT ('{ table_name_child }') FROM ( | )
        ( |         SELECT | )
        ( |           FROM (dyn_table_name) | )
        ( |           FIELDS | )
        ( |             z~travel_id             AS travel_id           , | )
        ( |             booking~booking_id      AS booking_id            , | )
        ( |             booking~booking_date    AS booking_date          ,| )
        ( |             booking~customer_id     AS customer_id           ,| )
        ( |             booking~carrier_id      AS carrier_id            ,| )
        ( |             booking~connection_id   AS connection_id         ,| )
        ( |             booking~flight_date     AS flight_date           ,| )
        ( |             booking~flight_price    AS flight_price          ,| )
        ( |             booking~currency_code   AS currency_code         ,| )
        ( |             CASE z~overall_status    ""Travel Status [A(Accepted) \| O(Open) \| X(Cancelled)]| )
        ( |               WHEN 'O' THEN 'N'| )
        ( |               WHEN 'P' THEN 'N'| )
        ( |               WHEN 'A' THEN 'B'| )
        ( |               ELSE 'X'| )
        ( |             END                     AS booking_status,   "Booking Status [N(New) \| B(Booked) \| X(Cancelled)]| )
        ( |             z~last_changed_at       AS last_changed_at| )
        ( |       ).| )
        ( |     COMMIT WORK.| )

      ) ).

  ENDMETHOD.


  METHOD generate_eml_playground_class.

    eml_playground_class_name = |zrap110_eml_playground_{ unique_suffix }|.

    DATA(lo_specification) = io_put_operation->for-clas->add_object(  eml_playground_class_name
                                      )->set_package( package_name
                                      )->create_form_specification( ).
    lo_specification->set_short_description( | EML Playground Class ({ unique_suffix })| ).
    lo_specification->definition->add_interface( 'if_oo_adt_classrun' ).
    lo_specification->implementation->add_method( |if_oo_adt_classrun~main|
      )->set_source( VALUE #(
      "EML with function
        ( |     "declare internal table using derived type | )
        ( |     DATA travel_keys TYPE TABLE FOR READ IMPORT ZRAP110_R_TravelTP_{ unique_suffix } . | )
        ( |  | )
        ( |     "fill in relevant travel keys for READ request | )
        ( |     travel_keys = VALUE #( ( TravelID = 'xxxxx' ) | )
        ( |                           "( TravelID = '...' ) | )
        ( |                          ).  | )
        ( |  | )
        ( |     "insert your coding here  | )
        ( |     "read _travel_ instances for specified key  | )
        ( |     READ ENTITIES OF ZRAP110_R_TravelTP_{ unique_suffix }  | )
        ( |       ENTITY Travel  | )
        ( |*        ALL FIELDS       | )
        ( |        FIELDS ( TravelID AgencyID CustomerID BeginDate EndDate )       | )
        ( |        WITH travel_keys       | )
        ( |    RESULT DATA(lt_travels_read)       | )
        ( |    FAILED DATA(failed)       | )
        ( |    REPORTED DATA(reported).       | )
        ( |       | )
        ( |    "console output       | )
        ( |    out->write( \| ***Exercise 10: Implement the Base BO Behavior - Functions*** \| ). | )
        ( |*    out->write( lt_travels_read ). | )
        ( |    IF failed IS NOT INITIAL. | )
        ( |      out->write( \|- [ERROR] Cause for failed read: \{ failed-travel[ 1 ]-%fail-cause \} \| ). | )
        ( |    ENDIF.       | )
        ( |       | )
        ( |    "read relevant booking instances | )
        ( |    READ ENTITIES OF ZRAP110_R_TravelTP_{ unique_suffix } | )
        ( |      ENTITY Travel BY \\_Booking    | )
        ( |        FROM CORRESPONDING #( lt_travels_read ) | )
        ( |        RESULT DATA(lt_bookings_read) | )
        ( |    LINK DATA(travels_to_bookings).       | )
        ( |       | )
        ( |*    "execute function getDaysToFlight   | )
        ( |*    READ ENTITIES OF ZRAP110_R_TravelTP_{ unique_suffix }   | )
        ( |*      ENTITY Booking   | )
        ( |*        EXECUTE getDaysToFlight   | )
        ( |*          FROM VALUE #( FOR link IN travels_to_bookings ( %tky = link-target-%tky ) )   | )
        ( |*    RESULT DATA(days_to_flight).       | )
        ( |*       | )
        ( |*    "output result structure   | )
        ( |*    LOOP AT days_to_flight ASSIGNING FIELD-SYMBOL(<days_to_flight>).   | )
        ( |*      out->write( \| TravelID = \{ <days_to_flight>-%tky-TravelID \} \|  ).   | )
        ( |*      out->write( \| BookingID = \{ <days_to_flight>-%tky-BookingID \} \| ).   | )
        ( |*      out->write( \| RemainingDaysToFlight  = \{ <days_to_flight>-%param-remaining_days_to_flight \} \| ).   | )
        ( |*      out->write( \| InitialDaysToFlight = \{ <days_to_flight>-%param-initial_days_to_flight \} \| ).   | )
        ( |*      out->write( \| ---------------           \| ).   | )
        ( |*    ENDLOOP.       | )
        ( |       | )
      ) ).
*
  ENDMETHOD.


  METHOD generate_table.
    DATA(lo_specification) = io_put_operation->for-tabl-for-database_table->add_object( table_name
              )->set_package( package_name
               )->create_form_specification( ).

    lo_specification->set_short_description( table_short_description ).
    lo_specification->set_data_maintenance( xco_cp_database_table=>data_maintenance->allowed_with_restrictions ).
    lo_specification->set_delivery_class( xco_cp_database_table=>delivery_class->c ).

    DATA database_table_field  TYPE REF TO if_xco_gen_tabl_dbt_s_fo_field  .

    LOOP AT table_fields INTO DATA(table_field_line).
      database_table_field = lo_specification->add_field( table_field_line-field  ).

      IF table_field_line-is_key = abap_true.
        database_table_field->set_key_indicator( ).
      ENDIF.
      IF table_field_line-not_null = abap_true.
        database_table_field->set_not_null( ).
      ENDIF.
      IF table_field_line-currencycode IS NOT INITIAL.
        database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( table_name ) ) )->set_reference_field( to_upper( table_field_line-currencycode ) ).
      ENDIF.
      IF table_field_line-unitofmeasure IS NOT INITIAL.
        database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( table_name ) ) )->set_reference_field( to_upper( table_field_line-unitofmeasure ) ).
      ENDIF.
      IF table_field_line-data_element IS NOT INITIAL.
        database_table_field->set_type( xco_cp_abap_dictionary=>data_element( table_field_line-data_element ) ).
      ELSE.
        CASE  to_lower( table_field_line-built_in_type ).
          WHEN 'accp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->accp ).
          WHEN 'clnt'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->clnt ).
          WHEN 'cuky'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->cuky ).
          WHEN 'dats'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dats ).
          WHEN 'df16_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_raw ).
          WHEN 'df34_raw'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_raw ).
          WHEN 'fltp'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->fltp ).
          WHEN 'int1'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int1 ).
          WHEN 'int2'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int2 ).
          WHEN 'int4'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int4 ).
          WHEN 'int8'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->int8 ).
          WHEN 'lang'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lang ).
          WHEN 'tims'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->tims ).
          WHEN 'char'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->char( table_field_line-built_in_type_length  ) ).
          WHEN 'curr'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->curr(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'dec'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'df16_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df16_dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'df34_dec'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->df34_dec(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
          WHEN 'lchr' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lchr( table_field_line-built_in_type_length  ) ).
          WHEN 'lraw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->lraw( table_field_line-built_in_type_length  ) ).
          WHEN 'numc'   .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->numc( table_field_line-built_in_type_length  ) ).
          WHEN 'quan' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->quan(
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                              ) ).
          WHEN 'raw'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->raw( table_field_line-built_in_type_length  ) ).
          WHEN 'rawstring'.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->rawstring( table_field_line-built_in_type_length  ) ).
          WHEN 'sstring' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->sstring( table_field_line-built_in_type_length  ) ).
          WHEN 'string' .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->string( table_field_line-built_in_type_length  ) ).
          WHEN 'unit'  .
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->unit( table_field_line-built_in_type_length  ) ).
          WHEN OTHERS.
            database_table_field->set_type( xco_cp_abap_dictionary=>built_in_type->for(
                                              iv_type     = to_upper( table_field_line-built_in_type )
                                              iv_length   = table_field_line-built_in_type_length
                                              iv_decimals = table_field_line-built_in_type_decimals
                                            ) ).
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_virt_elem_book_class.

    DATA(lo_specification) = io_put_operation->for-clas->add_object(  calc_booking_elem_class_name
                                      )->set_package( package_name
                                      )->create_form_specification( ).

    lo_specification->set_short_description( |Calculate Booking Virtual Elements| ).
*    lo_specification->definition->add_interface( 'if_sadl_exit_calc_element_read' ).
*    lo_specification->implementation->add_method( |if_sadl_exit_calc_element_read~get_calculation_info |
*      )->set_source( VALUE #(
*
*        ( |     IF iv_entity EQ 'ZRAP110_C_BOOKINGTP_{ unique_suffix }'. "Booking BO node | )
*        ( |      LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_booking_calc_element>).  | )
*        ( |        CASE <fs_booking_calc_element>.  | )
*        ( |          WHEN 'INITIALDAYSTOFLIGHT'.  | )
*        ( |            COLLECT `BOOKINGDATE` INTO et_requested_orig_elements.  | )
*        ( |            COLLECT `FLIGHTDATE` INTO et_requested_orig_elements.  | )
*        ( |  | )
*        ( |          WHEN 'REMAININGDAYSTOFLIGHT'.  | )
*        ( |            COLLECT `FLIGHTDATE` INTO et_requested_orig_elements.  | )
*        ( |  | )
*        ( |          WHEN 'DAYSTOFLIGHTINDICATOR'.  | )
*        ( |            COLLECT `FLIGHTDATE` INTO et_requested_orig_elements.  | )
*        ( |  | )
*        ( |          WHEN 'BOOKINGSTATUSINDICATOR'.  | )
*        ( |            COLLECT `BOOKINGSTATUS` INTO et_requested_orig_elements.  | )
*        ( |  | )
*        ( |        ENDCASE.  | )
*        ( |      ENDLOOP.  | )
*        ( |    ENDIF. | )
*        ( |  | )
*      ) ).

*    lo_specification->implementation->add_method( |if_sadl_exit_calc_element_read~calculate |
*    )->set_source( VALUE #(
*    ( |    IF it_requested_calc_elements IS INITIAL. | )
*    ( |      EXIT. | )
*    ( |    ENDIF. | )
*    ( |  | )
*    ( |    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_req_calc_elements>). | )
*    ( |  | )
*    ( |      CASE <fs_req_calc_elements>. | )
*    ( |          "virtual elements from BOOKING entity | )
*    ( |        WHEN 'INITIALDAYSTOFLIGHT'   OR 'REMAININGDAYSTOFLIGHT' | )
*    ( |          OR 'DAYSTOFLIGHTINDICATOR' OR 'BOOKINGSTATUSINDICATOR'. | )
*    ( |  | )
*    ( |          DATA lt_book_original_data TYPE STANDARD TABLE OF ZRAP110_C_BookingTP_{ unique_suffix } WITH DEFAULT KEY. | )
*    ( |          lt_book_original_data = CORRESPONDING #( it_original_data ). | )
*    ( |          LOOP AT lt_book_original_data ASSIGNING FIELD-SYMBOL(<fs_book_original_data>). | )
*    ( |  | )
*    ( |*            <fs_book_original_data> = zrap110_calc_book_elem_{ unique_suffix }=>calculate_days_to_flight( <fs_book_original_data> ). | )
*    ( |  | )
*    ( |          ENDLOOP. | )
*    ( |  | )
*    ( |          ct_calculated_data = CORRESPONDING #( lt_book_original_data ). | )
*    ( |  | )
*    ( |      ENDCASE. | )
*    ( |    ENDLOOP. | )
*    ) ).
*
*    lo_specification->definition->remove_interface( 'if_sadl_exit' ).

  ENDMETHOD.


  METHOD generate_virt_elem_trav_class.

    DATA(lo_specification) = io_put_operation->for-clas->add_object(  calc_travel_elem_class_name
                                      )->set_package( package_name
                                      )->create_form_specification( ).

    lo_specification->set_short_description( |Calculate Travel Virtual Elements| ).
*    lo_specification->definition->add_interface( 'if_sadl_exit_calc_element_read' ).
*    lo_specification->implementation->add_method( |if_sadl_exit_calc_element_read~get_calculation_info |
*      )->set_source( VALUE #(
*
*        ( |     IF iv_entity EQ 'ZRAP110_C_TRAVELTP_{ unique_suffix }'. "Travel BO node | )
*        ( |      LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_travel_calc_element>).  | )
*        ( |        CASE <fs_travel_calc_element>.  | )
*        ( |          WHEN 'OVERALLSTATUSINDICATOR'.  | )
*        ( |            APPEND 'OVERALLSTATUS' TO et_requested_orig_elements.  | )
*        ( |  | )
*        ( |        ENDCASE.  | )
*        ( |      ENDLOOP.  | )
*        ( |    ENDIF. | )
*        ( |  | )
*      ) ).

*    lo_specification->implementation->add_method( |if_sadl_exit_calc_element_read~calculate |
*    )->set_source( VALUE #(
*    ( |    IF it_requested_calc_elements IS INITIAL. | )
*    ( |      EXIT. | )
*    ( |    ENDIF. | )
*    ( |  | )
*    ( |    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_req_calc_elements>). | )
*    ( |      CASE <fs_req_calc_elements>. | )
*    ( |          "virtual elements from TRAVEL entity | )
*    ( |        WHEN 'OVERALLSTATUSINDICATOR'. | )
*    ( |  | )
*    ( |          DATA lt_trav_original_data TYPE STANDARD TABLE OF ZRAP110_C_TravelTP_{ unique_suffix } WITH DEFAULT KEY. | )
*    ( |          lt_trav_original_data = CORRESPONDING #( it_original_data ). | )
*    ( |          LOOP AT lt_trav_original_data ASSIGNING FIELD-SYMBOL(<fs_trav_original_data>). | )
*    ( |  | )
*    ( |*            <fs_trav_original_data> = zrap110_calc_trav_elem_{ unique_suffix }=>calculate_trav_status_ind( <fs_trav_original_data> ). | )
*    ( |  | )
*    ( |          ENDLOOP. | )
*    ( |  | )
*    ( |          ct_calculated_data = CORRESPONDING #( lt_trav_original_data ). | )
*    ( |  | )
*    ( |      ENDCASE. | )
*    ( |    ENDLOOP. | )
*    ) ).
*
*    lo_specification->definition->remove_interface( 'if_sadl_exit' ).

  ENDMETHOD.


  METHOD get_child_table_fields.
    child_table_fields = VALUE tt_fields(
                   ( field         = 'client'
                     data_element  = 'mandt'
                     is_key        = 'X'
                     not_null      = 'X' )
                   ( field         = 'travel_id'
                     data_element  = '/dmo/travel_id'
                     is_key        = 'X'
                     not_null      = 'X' )
                   ( field         = 'booking_id'
                     data_element  = '/dmo/booking_id'
                     is_key        = 'X'
                     not_null      = 'X' )
                   ( field         = 'booking_date'
                     data_element  = '/dmo/booking_date' )
                   ( field         = 'customer_id'
                     data_element  = '/dmo/customer_id' )
                   ( field         = 'carrier_id'
                     data_element  = '/dmo/carrier_id' )
                   ( field         = 'connection_id'
                     data_element  = '/dmo/connection_id' )
                   ( field         = 'flight_date'
                     data_element  = '/dmo/flight_date' )
                   ( field         = 'flight_price'
                     data_element  = '/dmo/flight_price'
                     currencycode  = 'currency_code'  )
                   ( field         = 'currency_code'
                     data_element  = '/dmo/currency_code' )
                   ( field         = 'booking_status'
                     data_element  = '/dmo/booking_status' )
                   ( field         = 'local_last_changed_at'
                     data_element  = 'abp_locinst_lastchange_tstmpl' )
                   ).
  ENDMETHOD.


  METHOD get_json_string.

    " build the json document
    json_string =

|\{\r\n| &
|    "namespace":"Z",\r\n| &
|    "package":"{ package_name }", \r\n| &
|    "bindingType":"odata_v4_ui",    \r\n| &
|    "implementationType":"managed_semantic",\r\n| &
|    "prefix":"RAP110_",\r\n| &
|    "suffix":"_{ unique_suffix }",\r\n| &
|    "datasourcetype": "table",\r\n| &
|    "draftEnabled":true,\r\n| &
**********
|    "createtable":true,\r\n| &
**********


|    "multiInlineEdit":false,\r\n| &
|    "isCustomizingTable":false,\r\n| &
|    "addBusinessConfigurationRegistration":false,\r\n| &
|    "transportRequest":"{ transport }",\r\n| &
|\r\n| &
|    "hierarchy":\r\n| &
|    \{\r\n| &
|    "entityname":"Travel",\r\n| &
|    "dataSource":"{ table_name_root }",\r\n| &
|    "objectid":"TRAVEL_ID",\r\n| &
|    "uuid":"",\r\n| &
|    "parentUUID":"",\r\n| &
|    "rootUUID":"",\r\n| &
|    "etagMaster":"LOCAL_LAST_CHANGED_AT",\r\n| &
|    "totalEtag":"LAST_CHANGED_AT",\r\n| &
|    "lastChangedAt":"LAST_CHANGED_AT",\r\n| &
|    "lastChangedBy":"",\r\n| &
|    "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",\r\n| &
|    "createdAt":"CREATED_AT",\r\n| &
|    "createdBy":"",\r\n| &
|    "draftTable":"{ draft_table_name_root }",\r\n| &
* |    "cdsInterfaceView":"{ i_view_name_travel  }",\r\n| &
|    "cdsRestrictedReuseView":"{ r_view_name_travel  }",\r\n| &
|    "cdsProjectionView":"{ c_view_name_travel  }",\r\n| &
|    "metadataExtensionView":"{ c_view_name_travel  }",\r\n| &
|\r\n| &
|    "behaviorImplementationClass":"{ beh_impl_name_travel }",\r\n| &
|    \r\n| &
|    "serviceDefinition":"{ srv_definition_name }",\r\n| &
|    "serviceBinding":"{ srv_binding_o4_name }",\r\n| &
|    "controlStructure":"",\r\n| &
|    "customQueryImplementationClass":"",\r\n| &
|    "associations": [ \r\n| &
|        \{\r\n| &
|            "name": "_Agency",\r\n| &
|            "target": "/DMO/I_Agency",\r\n| &
|            "cardinality": "zero_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "AgencyID",\r\n| &
|                "associationField": "AgencyID"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_Customer",\r\n| &
|            "target": "/DMO/I_Customer",\r\n| &
|            "cardinality": "zero_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "CustomerID",\r\n| &
|                "associationField": "CustomerID"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_OverallStatus",\r\n| &
|            "target": "/DMO/I_Overall_Status_VH",\r\n| &
|            "cardinality": "one_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "OverallStatus",\r\n| &
|                "associationField": "OverallStatus"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_Currency",\r\n| &
|            "target": "I_Currency",\r\n| &
|            "cardinality": "zero_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "CurrencyCode",\r\n| &
|                "associationField": "Currency"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \}\r\n| &
|    ], | &
|    "valueHelps": [ \r\n| &
|       \{\r\n| &
|           "alias": "Agency",\r\n| &
|           "name": "/DMO/I_Agency_StdVH",\r\n| &
|           "localElement": "AgencyID",\r\n| &
|           "element": "AgencyID"\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "CustomerVh",\r\n| &
|           "name": "/DMO/I_Customer_StdVH",\r\n| &
|           "localElement": "CustomerID",\r\n| &
|           "element": "CustomerID"\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "CurrencyVh",\r\n| &
|           "name": "I_CurrencyStdVH",\r\n| &
|           "localElement": "CurrencyCode",\r\n| &
|           "element": "Currency"\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "OverallStatusVh",\r\n| &
|           "name": "/DMO/I_Overall_Status_VH",\r\n| &
|           "localElement": "OverallStatus",\r\n| &
|           "element": "OverallStatus"\r\n| &
|       \}\r\n| &
|    ], | &&
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*|        "objectswithadditionalfields": [| && |\r\n|  &&
*'            {' && |\r\n|  &&
*'                "object": "cds_projection_view",' && |\r\n|  &&
*'                "additionalfields": [' && |\r\n|  &&
*'                    {' && |\r\n|  &&
*'                        "fieldname": "_Agency.Name",' && |\r\n|  &&
*'                        "alias": "AgencyName"' && |\r\n|  &&
*'                    },' && |\r\n|  &&
*'                    {' && |\r\n|  &&
*'                        "fieldname": "_Customer.LastName",' && |\r\n|  &&
*'                        "alias": "CustomerName"' && |\r\n|  &&
*'                    }' && |\r\n|  &&
*'                ]' && |\r\n|  &&
*'            }' && |\r\n|  &&
*'        ],' && |\r\n|  &&


*|         \{\r\n| &
*|           "fieldname": "_OverallStatus._Text.Text",\r\n| &
*|           "alias": "OverallStatusText",\r\n| &
*|           "localized": "true"\r\n| &
*|         \}\r\n| &

*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*|    "mapping":\r\n| &
*|    [\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CLIENT",\r\n| &
*|    "cds_view_field":"Client"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"TRAVEL_ID",\r\n| &
*|    "cds_view_field":"TravelID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"AGENCY_ID",\r\n| &
*|    "cds_view_field":"AgencyID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CUSTOMER_ID",\r\n| &
*|    "cds_view_field":"CustomerID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"BEGIN_DATE",\r\n| &
*|    "cds_view_field":"BeginDate"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"END_DATE",\r\n| &
*|    "cds_view_field":"EndDate"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"BOOKING_FEE",\r\n| &
*|    "cds_view_field":"BookingFee"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"TOTAL_PRICE",\r\n| &
*|    "cds_view_field":"TotalPrice"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CURRENCY_CODE",\r\n| &
*|    "cds_view_field":"CurrencyCode"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"DESCRIPTION",\r\n| &
*|    "cds_view_field":"Description"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"ATTACHMENT",\r\n| &
*|    "cds_view_field":"Attachment"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"MIME_TYPE",\r\n| &
*|    "cds_view_field":"MimeType"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"FILE_NAME",\r\n| &
*|    "cds_view_field":"FileName"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"OVERALL_STATUS",\r\n| &
*|    "cds_view_field":"OverallStatus"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CREATED_BY",\r\n| &
*|    "cds_view_field":"CreatedBy"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"LOCAL_CREATED_AT",\r\n| &
*|    "cds_view_field":"LocalCreatedAt"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"LOCAL_LAST_CHANGED_BY",\r\n| &
*|    "cds_view_field":"LocalLastChangedBy"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"LOCAL_LAST_CHANGED_AT",\r\n| &
*|    "cds_view_field":"LocalLastChangedAt"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"LAST_CHANGED_AT",\r\n| &
*|    "cds_view_field":"LastChangedAt"\r\n| &
*|    \}\r\n| &
*|    ],\r\n| &&

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
'            "abapfieldname": "TRAVEL_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/travel_id",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "iskey": true,' && |\r\n|  &&
'            "notnull": true,' && |\r\n|  &&
'            "cdsviewfieldname": "TravelID"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "AGENCY_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/agency_id",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "AgencyID"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CUSTOMER_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/customer_id",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "CustomerID"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "BEGIN_DATE",' && |\r\n|  &&
'            "dataelement": "/dmo/begin_date",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "BeginDate"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "END_DATE",' && |\r\n|  &&
'            "dataelement": "/dmo/end_date",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "EndDate"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "BOOKING_FEE",' && |\r\n|  &&
'            "dataelement": "/dmo/booking_fee",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "currencycode": "CURRENCY_CODE",' && |\r\n|  &&
'            "cdsviewfieldname": "BookingFee"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "TOTAL_PRICE",' && |\r\n|  &&
'            "dataelement": "/dmo/total_price",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "currencycode": "CURRENCY_CODE",' && |\r\n|  &&
'            "cdsviewfieldname": "TotalPrice"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CURRENCY_CODE",' && |\r\n|  &&
'            "dataelement": "/dmo/currency_code",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "CurrencyCode"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "DESCRIPTION",' && |\r\n|  &&
'            "dataelement": "/dmo/description",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "Description"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "OVERALL_STATUS",' && |\r\n|  &&
'            "dataelement": "/dmo/overall_status",' && |\r\n|  &&
'            "cdsviewfieldname": "OverallStatus",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "ATTACHMENT",' && |\r\n|  &&
'            "dataelement": "/dmo/attachment",' && |\r\n|  &&
'            "cdsviewfieldname": "Attachment",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "MIME_TYPE",' && |\r\n|  &&
'            "dataelement": "/dmo/mime_type",' && |\r\n|  &&
'            "cdsviewfieldname": "MimeType",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "FILE_NAME",' && |\r\n|  &&
'            "dataelement": "/dmo/filename",' && |\r\n|  &&
'            "cdsviewfieldname": "FileName",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
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
'            "abapfieldname": "LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
'            "dataelement": "abp_locinst_lastchange_tstmpl",' && |\r\n|  &&
'            "cdsviewfieldname": "LocalLastChangedAt",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        }' && |\r\n|  &&
'    ],' &&


**********

|    "Children":\r\n| &
|    [\r\n| &
|    \{\r\n| &
|    "entityname":"Booking",\r\n| &
|    "dataSource":"{ table_name_child }",\r\n| &
|    "objectid":"BOOKING_ID",\r\n| &
|    "uuid":"",\r\n| &
|    "parentUUID":"",\r\n| &
|    "rootUUID":"",\r\n| &
|    "etagMaster":"LOCAL_LAST_CHANGED_AT",\r\n| &
|    "totalEtag":"",\r\n| &
|    "lastChangedAt":"",\r\n| &
|    "lastChangedBy":"",\r\n| &
|    "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",\r\n| &
|    "createdAt":"",\r\n| &
|    "createdBy":"",\r\n| &
|    "draftTable":"{ draft_table_name_child }",\r\n| &
* |    "cdsInterfaceView":"{ i_view_name_booking }",\r\n| &
|    "cdsRestrictedReuseView":"{ r_view_name_booking }",\r\n| &
|    "cdsProjectionView":"{ c_view_name_booking }",\r\n| &
|    "metadataExtensionView":"{ c_view_name_booking }",\r\n| &
|    "behaviorImplementationClass":"{ beh_impl_name_booking }",\r\n| &
|    "serviceDefinition":"",\r\n| &
|    "serviceBinding":"",\r\n| &
|    "controlStructure":"",\r\n| &
|    "customQueryImplementationClass":"",\r\n| &
|    "associations": [ \r\n| &
|        \{\r\n| &
|            "name": "_Customer",\r\n| &
|            "target": "/DMO/I_Customer",\r\n| &
|            "cardinality": "one_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "CustomerID",\r\n| &
|                "associationField": "CustomerID"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_Carrier",\r\n| &
|            "target": "/DMO/I_Carrier",\r\n| &
|            "cardinality": "one_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "CarrierID",\r\n| &
|                "associationField": "AirlineID"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_Connection",\r\n| &
|            "target": "/DMO/I_Connection",\r\n| &
|            "cardinality": "one_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "CarrierID",\r\n| &
|                "associationField": "AirlineID"    \r\n| &
|            \},\r\n| &
|            \{\r\n| &
|                "projectionField": "ConnectionID",\r\n| &
|                "associationField": "ConnectionID"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_Flight",\r\n| &
|            "target": "/DMO/I_Flight",\r\n| &
|            "cardinality": "one_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "CarrierID",\r\n| &
|                "associationField": "AirlineID"    \r\n| &
|            \},\r\n| &
|            \{\r\n| &
|                "projectionField": "ConnectionID",\r\n| &
|                "associationField": "ConnectionID"    \r\n| &
|            \},\r\n| &
|            \{\r\n| &
|                "projectionField": "FlightDate",\r\n| &
|                "associationField": "FlightDate"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_BookingStatus",\r\n| &
|            "target": "/DMO/I_Booking_Status_VH",\r\n| &
|            "cardinality": "one_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "BookingStatus",\r\n| &
|                "associationField": "BookingStatus"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \},\r\n| &
|        \{\r\n| &
|            "name": "_Currency",\r\n| &
|            "target": "I_Currency",\r\n| &
|            "cardinality": "zero_to_one",\r\n| &
|            "conditions": [\r\n| &
|            \{\r\n| &
|                "projectionField": "CurrencyCode",\r\n| &
|                "associationField": "Currency"    \r\n| &
|            \}\r\n| &
|            ]\r\n| &
|        \}\r\n| &
|    ], | &
|    "valueHelps": [ \r\n| &
|       \{\r\n| &
|           "alias": "CustomerVh",\r\n| &
|           "name": "/DMO/I_Customer_StdVH",\r\n| &
|           "localElement": "CustomerID",\r\n| &
|           "element": "CustomerID"\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "Airline",\r\n| &
|           "name": "/DMO/I_Flight",\r\n| &
|           "localElement": "CarrierID",\r\n| &
|           "element": "AirlineID",\r\n| &
|           "additionalBinding": [ \r\n| &
|              \{\r\n| &
|                  "localElement": "FlightDate",\r\n| &
|                  "element": "FlightDate"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \},\r\n| &
|              \{\r\n| &
|                  "localElement": "ConnectionID",\r\n| &
|                  "element": "ConnectionID"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \}, \r\n| &
|              \{\r\n| &
|                  "localElement": "FlightPrice",\r\n| &
|                  "element": "Price"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \},  \r\n| &
|              \{\r\n| &
|                  "localElement": "CurrencyCode",\r\n| &
|                  "element": "CurrencyCode"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \}  \r\n| &
|           ]\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "Flight",\r\n| &
|           "name": "/DMO/I_Flight",\r\n| &
|           "localElement": "ConnectionID",\r\n| &
|           "element": "ConnectionID",\r\n| &
|           "additionalBinding": [ \r\n| &
|              \{\r\n| &
|                  "localElement": "FlightDate",\r\n| &
|                  "element": "FlightDate"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \},\r\n| &
|              \{\r\n| &
|                  "localElement": "CarrierID",\r\n| &
|                  "element": "AirlineID"\r\n| &
|                 ,"usage": "FILTER_AND_RESULT"\r\n| &
|              \}, \r\n| &
|              \{\r\n| &
|                  "localElement": "FlightPrice",\r\n| &
|                  "element": "Price"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \},  \r\n| &
|              \{\r\n| &
|                  "localElement": "CurrencyCode",\r\n| &
|                  "element": "CurrencyCode"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \}  \r\n| &
|           ]\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "Date",\r\n| &
|           "name": "/DMO/I_Flight",\r\n| &
|           "localElement": "FlightDate",\r\n| &
|           "element": "FlightDate",\r\n| &
|           "additionalBinding": [ \r\n| &
|              \{\r\n| &
|                  "localElement": "CarrierID",\r\n| &
|                  "element": "AirlineID"\r\n| &
|                 ,"usage": "FILTER_AND_RESULT"\r\n| &
|              \}, \r\n| &
|              \{\r\n| &
|                  "localElement": "ConnectionID",\r\n| &
|                  "element": "ConnectionID"\r\n| &
|                 ,"usage": "FILTER_AND_RESULT"\r\n| &
|              \},\r\n| &
|              \{\r\n| &
|                  "localElement": "FlightPrice",\r\n| &
|                  "element": "Price"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \},  \r\n| &
|              \{\r\n| &
|                  "localElement": "CurrencyCode",\r\n| &
|                  "element": "CurrencyCode"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \}  \r\n| &
|           ]\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "Date",\r\n| &
|           "name": "/DMO/I_Flight",\r\n| &
|           "localElement": "FlightPrice",\r\n| &
|           "element": "Price",\r\n| &
|           "additionalBinding": [ \r\n| &
|              \{\r\n| &
|                  "localElement": "CarrierID",\r\n| &
|                  "element": "AirlineID"\r\n| &
|                 ,"usage": "FILTER_AND_RESULT"\r\n| &
|              \}, \r\n| &
|              \{\r\n| &
|                  "localElement": "ConnectionID",\r\n| &
|                  "element": "ConnectionID"\r\n| &
|                 ,"usage": "FILTER_AND_RESULT"\r\n| &
|              \},\r\n| &
|              \{\r\n| &
|                  "localElement": "FlightDate",\r\n| &
|                  "element": "FlightDate"\r\n| &
|                 ,"usage": "FILTER_AND_RESULT"\r\n| &
|              \},  \r\n| &
|              \{\r\n| &
|                  "localElement": "CurrencyCode",\r\n| &
|                  "element": "CurrencyCode"\r\n| &
|                 ,"usage": "RESULT"\r\n| &
|              \}  \r\n| &
|           ]\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "Currencyvh2",\r\n| &
|           "name": "I_CurrencyStdVH",\r\n| &
|           "localElement": "CurrencyCode",\r\n| &
|           "element": "Currency"\r\n| &
|       \},\r\n| &
|       \{\r\n| &
|           "alias": "BookingStatus",\r\n| &
|           "name": "/DMO/I_Booking_Status_VH",\r\n| &
|           "localElement": "BookingStatus",\r\n| &
|           "element": "BookingStatus"\r\n| &
|       \}\r\n| &
|    ], | &&
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*| "objectswithadditionalfields": [ | && |\r\n|  &&
*'                    {' && |\r\n|  &&
*'                        "object": "cds_projection_view",' && |\r\n|  &&
*'                        "additionalfields": [' && |\r\n|  &&
*'                            {' && |\r\n|  &&
*'                                "fieldname": "_Customer.LastName",' && |\r\n|  &&
*'                                "alias": "CustomerName"' && |\r\n|  &&
*'                            },' && |\r\n|  &&
*'                            {' && |\r\n|  &&
*'                                "fieldname": "_Carrier.LastName",' && |\r\n|  &&
*'                                "alias": "CarrierName"' && |\r\n|  &&
*'                            }' && |\r\n|  &&
*'                        ]' && |\r\n|  &&
*'                    }' && |\r\n|  &&
*'                ],' && |\r\n|  &&

*|         \{\r\n| &
*|           "fieldname": "_BookingStatus._Text.Text",\r\n| &
*|           "alias": "BookingStatusText",\r\n| &
*|           "localized": "true" \r\n| &
*|         \}\r\n| &

*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*|    "mapping":\r\n| &
*|    [\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CLIENT",\r\n| &
*|    "cds_view_field":"Client"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"TRAVEL_ID",\r\n| &
*|    "cds_view_field":"TravelID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"BOOKING_ID",\r\n| &
*|    "cds_view_field":"BookingID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"BOOKING_DATE",\r\n| &
*|    "cds_view_field":"BookingDate"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CUSTOMER_ID",\r\n| &
*|    "cds_view_field":"CustomerID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CARRIER_ID",\r\n| &
*|    "cds_view_field":"CarrierID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CONNECTION_ID",\r\n| &
*|    "cds_view_field":"ConnectionID"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"FLIGHT_DATE",\r\n| &
*|    "cds_view_field":"FlightDate"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"FLIGHT_PRICE",\r\n| &
*|    "cds_view_field":"FlightPrice"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"CURRENCY_CODE",\r\n| &
*|    "cds_view_field":"CurrencyCode"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"BOOKING_STATUS",\r\n| &
*|    "cds_view_field":"BookingStatus"\r\n| &
*|    \},\r\n| &
*|    \{\r\n| &
*|    "dbtable_field":"LOCAL_LAST_CHANGED_AT",\r\n| &
*|    "cds_view_field":"LocalLastChangedAt"\r\n| &
*|    \}\r\n| &
*|    ],\r\n| &&

************
'"fields": [' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CLIENT",' && |\r\n|  &&
'            "dataelement": "MANDT",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "iskey": true,' && |\r\n|  &&
'            "notnull": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "TRAVEL_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/travel_id",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "TravelID",' && |\r\n|  &&
'            "iskey": true,' && |\r\n|  &&
'            "notnull": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "BOOKING_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/booking_id",' && |\r\n|  &&
'            "cdsviewfieldname": "BookingID",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "iskey": true,' && |\r\n|  &&
'            "notnull": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "BOOKING_DATE",' && |\r\n|  &&
'            "dataelement": "/dmo/booking_date",' && |\r\n|  &&
'            "cdsviewfieldname": "BookingDate",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CUSTOMER_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/customer_id",' && |\r\n|  &&
'            "cdsviewfieldname": "CustomerID",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CARRIER_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/carrier_id",' && |\r\n|  &&
'            "cdsviewfieldname": "CarrierID",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CONNECTION_ID",' && |\r\n|  &&
'            "dataelement": "/dmo/connection_id",' && |\r\n|  &&
'            "cdsviewfieldname": "ConnectionID",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "FLIGHT_DATE",' && |\r\n|  &&
'            "dataelement": "/dmo/flight_date",' && |\r\n|  &&
'            "cdsviewfieldname": "FlightDate",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "BOOKING_STATUS",' && |\r\n|  &&
'            "dataelement": "/dmo/booking_status",' && |\r\n|  &&
'            "cdsviewfieldname": "BookingStatus",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "FLIGHT_PRICE",' && |\r\n|  &&
'            "dataelement": "/dmo/flight_price",' && |\r\n|  &&
'            "isdataelement": true,' && |\r\n|  &&
'            "cdsviewfieldname": "FlightPrice",' && |\r\n|  &&
'            "currencycode": "CURRENCY_CODE"' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "CURRENCY_CODE",' && |\r\n|  &&
'            "dataelement": "/dmo/currency_code",' && |\r\n|  &&
'            "cdsviewfieldname": "CurrencyCode",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        },' && |\r\n|  &&
'        {' && |\r\n|  &&
'            "abapfieldname": "LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
'            "dataelement": "abp_locinst_lastchange_tstmpl",' && |\r\n|  &&
'            "cdsviewfieldname": "LocalLastChangedAt",' && |\r\n|  &&
'            "isdataelement": true' && |\r\n|  &&
'        }' && |\r\n|  &&
'    ]' &&

*********

|    \}\r\n| &
|    ]\r\n| &
|    \}\r\n| &
|    \}|
.

  ENDMETHOD.


  METHOD get_root_table_fields.
    root_table_fields = VALUE tt_fields(
                  ( field         = 'client'
                    data_element  = 'mandt'
                    is_key        = 'X'
                    not_null      = 'X' )
                  ( field         = 'travel_id'
                    data_element  = '/dmo/travel_id'
                    is_key        = 'X'
                    not_null      = 'X' )
                  ( field         = 'agency_id'
                    data_element  = '/dmo/agency_id' )
                  ( field         = 'customer_id'
                    data_element  = '/dmo/customer_id' )
                  ( field         = 'begin_date'
                    data_element  = '/dmo/begin_date' )
                  ( field         = 'end_date'
                    data_element  = '/dmo/end_date' )
                  ( field         = 'booking_fee'
                    data_element  = '/dmo/booking_fee'
                    currencycode  = 'currency_code' )
                  ( field         = 'total_price'
                    data_element  = '/dmo/total_price'
                    currencycode  = 'currency_code' )
                  ( field         = 'currency_code'
                    data_element  = '/dmo/currency_code' )
                  ( field         = 'description'
                    data_element  = '/dmo/description' )
                  ( field         = 'overall_status'
                    data_element  = '/dmo/overall_status' )
                  ( field         = 'attachment'
                    data_element  = '/dmo/attachment' )
                  ( field         = 'mime_type'
                    data_element  = '/dmo/mime_type' )
                  ( field         = 'file_name'
                    data_element  = '/dmo/filename' )
                  ( field         = 'created_by'
                    data_element  = 'abp_creation_user' )
                  ( field         = 'local_created_at'
                    data_element  = 'abp_creation_tstmpl' )
                  ( field         = 'local_last_changed_by'
                    data_element  = 'abp_locinst_lastchange_user' )
                  ( field         = 'local_last_changed_at'
                    data_element  = 'abp_locinst_lastchange_tstmpl' )
                  ( field         = 'last_changed_at'
                    data_element  = 'abp_lastchange_tstmpl' )
                    ).
  ENDMETHOD.


  METHOD get_unique_suffix.

    DATA: ls_package_name  TYPE sxco_package,
          is_valid_package TYPE abap_bool,
          step_number      TYPE i.

    DATA: ascii_hex TYPE x LENGTH 3.
    DATA ascii_hex_string TYPE string.
    s_unique_suffix = ''.
    is_valid_package = abap_false.
    ascii_hex = 1.
    ascii_hex_string = ascii_hex.
    ascii_hex_string = substring( val = ascii_hex_string off = strlen( ascii_hex_string ) - 3 len = 3 ).

    WHILE is_valid_package = abap_false.

      "check package name
      ls_package_name = s_prefix && ascii_hex_string.
      DATA(lo_package) = xco_lib->get_package( ls_package_name ). "  xco_cp_abap_repository=>object->devc->for( ls_package_name ).
      IF NOT lo_package->exists( ).
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
    package_name           = 'ZRAP110_' && unique_suffix.


    DATA(lo_transport_target) = xco_lib->get_package( co_zrap110_ex_package
              )->read( )-property-transport_layer->get_transport_target( ).

    DATA(new_transport_object) = xco_cp_cts=>transports->workbench( lo_transport_target->value  )->create_request( |Package name: { package_name } | ).
    transport = new_transport_object->value.

    out->write( | RAP110 exercise generator | ).
    out->write( | ------------------------------------- | ).
    .

    "database tables
    table_name_root               = to_upper( |zrap110_atrav{ unique_suffix }| ).
    table_name_child              = to_upper( |zrap110_abook{ unique_suffix }| ).
    draft_table_name_root         = to_upper( |zrap110_dtrav{ unique_suffix }| ).
    draft_table_name_child        = to_upper( |zrap110_dbook{ unique_suffix }| ).
    data_generator_class_name     = |zrap110_data_generator_{ unique_suffix }|.
    "CDS views
    r_view_name_travel            = to_upper( |zrap110_R_TravelTP_{ unique_suffix }| ).
    r_view_name_booking           = to_upper( |zrap110_R_BookingTP_{ unique_suffix }| ).
    c_view_name_travel            = to_upper( |zrap110_C_TravelTP_{ unique_suffix }| ).
    c_view_name_booking           = to_upper( |zrap110_C_BookingTP_{ unique_suffix }| ) .
    i_view_name_travel            = |zrap110_I_TravelTP_{ unique_suffix }|.
    i_view_name_booking           = |zrap110_I_BookingTP_{ unique_suffix }|.
    calc_travel_elem_class_name   = |zrap110_calc_trav_elem_{ unique_suffix }|.
    calc_booking_elem_class_name  = |zrap110_calc_book_elem_{ unique_suffix }|.
    eml_playground_class_name     = |zrap110_eml_playground_{ unique_suffix }|.
    create_mde_files              = abap_true.
    "behavior pools
    beh_impl_name_travel          = |zrap110_BP_TravelTP_{ unique_suffix }|.
    beh_impl_name_booking         = |zrap110_BP_BookingTP_{ unique_suffix }|.
    "business service
    srv_definition_name           = |zrap110_UI_Travel_{ unique_suffix }|.
    srv_binding_o4_name           = |zrap110_UI_Travel_O4_{ unique_suffix }|.


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
      CATCH cx_root INTO DATA(package_exception).
        IF debug_modus = abap_true.
          out->write( | Error during create_package( ). | ).
        ENDIF.
    ENDTRY.

*    create_tables( out ).

    mo_environment                 = get_environment( transport ).
    mo_put_operation               = get_put_operation( mo_environment )."->create_put_operation( ).

    "create abstract entities
    create_abs_ent_a_create_travel( out ).
    create_abs_ent_a_daystoflight( out ).
    create_abs_ent_a_travel( out ).

    DATA(lo_table_root)  = xco_cp_abap_repository=>object->tabl->for( CONV #( table_name_root ) ).
    DATA(lo_table_child) = xco_cp_abap_repository=>object->tabl->for( CONV #( table_name_child ) ).


*    IF lo_table_root->exists(  )  = abap_true AND
*       lo_table_child->exists(  ) = abap_true.

    create_rap_bo(
      EXPORTING
        out          = out
      IMPORTING
        eo_root_node = DATA(root_node)
    )..

    delete_iview_and_mde( out = out ).

*    ENDIF.

    DATA(lo_travel_bdef) = xco_cp_abap_repository=>object->bdef->for( CONV #( r_view_name_travel  ) ).
*      DATA(lo_travel_bdef) = xco_cp_abap_repository=>object->bdef->for( r_view_name_travel  ).

    IF lo_travel_bdef->exists(  ).
      generate_cds_mde(
        io_out       = out
        io_root_node = root_node
      ).
      generate_cds_mde(
        io_out       = out
        io_root_node = root_node->all_childnodes[ 1 ]
      ).
      create_additional_objects( out = out ).
    ENDIF.

    create_number_range(  out = out ).

    out->write( | The following package got created for you and includes everything you need: { package_name } | ).
    out->write( | In the "Project Explorer" right click on "Favorite Packages" and click on "Add Package...". | ).
    out->write( | Enter "{ package_name }" and click OK. | ).



  ENDMETHOD.
ENDCLASS.
