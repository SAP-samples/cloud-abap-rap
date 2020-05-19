CLASS zrap_cl_call_bo_generator_demo DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_root_exception
      IMPORTING
        !ix_exception  TYPE REF TO cx_root
      RETURNING
        VALUE(rx_root) TYPE REF TO cx_root .
ENDCLASS.



CLASS zrap_cl_call_bo_generator_demo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    TRY.

        out->write( 'start' ).

*        DATA(rap_bo_generator) = NEW zrap_cl_bo_generator(
*          iv_package            =  'ZRAP_FLIGHT_M_####'
*          iv_namespace = 'ZRAP_'
*          iv_header_table       = 'ZRAP_TRAVEL_####'
*          iv_header_entity_name = 'Travel'
*          iv_header_semantic_key = 'TRAVEL_ID'
*          iv_suffix = '_####'
*          iv_item_table         = 'ZRAP_BOOK_DEMO'
*          iv_item_entity_name   = 'Booking'
*          iv_item_semantic_key = 'BOOKING_ID'
*        ).


        DATA(rap_bo_generator) = NEW zrap_cl_bo_generator(
          iv_package            =  'ZRAP_INVENTORY_M_###'
          iv_namespace = 'ZRAP_'
          iv_header_table       = 'ZRAP_INVEN_####'
          iv_header_entity_name = 'Inventory'
          iv_header_semantic_key = 'INVENTORY_ID'
          iv_suffix = '_####'
          "iv_item_table         = '<item table>'
          "iv_item_entity_name   = 'Items'
          " iv_item_semantic_key = '<semantic key for items>'
        ).


        data(lt_todos) = rap_bo_generator->generate_managed_bo(  ).

        out->write( lt_todos ).

      CATCH cx_xco_gen_put_exception  INTO DATA(lx_put_exception).
        out->write( 'XCO Generation: PUT exception:' ).
        DATA(lo_findings) = lx_put_exception->findings.
        DATA(lt_findings) = lo_findings->get( ).
        LOOP AT lt_findings INTO DATA(ls_findings).
          out->write( ls_findings->message->get_text(  ) ).
        ENDLOOP.
        EXIT.
      CATCH cx_abap_invalid_name  INTO DATA(lx_abap_invalid_name).
        out->write( lx_abap_invalid_name->name ).
        EXIT.  
      CATCH cx_root INTO DATA(lx_root).
        out->write( 'other exception:' ).
        out->write( get_root_exception( lx_root )->get_longtext( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_root_exception.
    rx_root = ix_exception.
    WHILE rx_root->previous IS BOUND.
      rx_root ?= rx_root->previous.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
