CLASS zcl_call_rap_generator DEFINITION
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



CLASS zcl_call_rap_generator IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.

        DATA(root_bo) = NEW zcl_rap_node_m_uuid_root( 'Travel' ).

        "optional settings
        root_bo->set_prefix( 'RAP_' ).
        root_bo->set_suffix( CONV #( '_054' ) ).
        "mandatory settings
        root_bo->set_namespace( 'Z' ).
        root_bo->set_table( iv_table = 'ZRAP_TRAVEL_DEMO' ).
        root_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'TRAVEL_ID' ) ) ).
        root_bo->finalize( ).

        DATA(child1_bo) = root_bo->add_child( 'Booking' ).
        child1_bo->set_table( iv_table = 'zrap_book_demo' ).
        child1_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_ID' ) ) ).

        DATA(child2_bo) = root_bo->add_child( 'Booking2' ).
        child2_bo->set_table( iv_table = 'zrap_book_demo' ).
        child2_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_ID' ) ) ).

        DATA(child11_bo) = child1_bo->add_child( 'BookingSuppl' ).
        child11_bo->set_table( iv_table = 'zrap_books_demo' ).
        child11_bo->set_semantic_key_fields( it_semantic_key = VALUE #( ( 'BOOKING_SUPPL_ID' ) ) ).

        DATA(my_bo_generator) = NEW zcl_rap_bo_generator(
          iv_package          = 'ZRAP_GENERATED_OBJECTS_AF'
          io_rap_bo_root_node = root_bo
        ).

        DATA(lt_todos) = my_bo_generator->generate_bo(  ).
        out->write( lt_todos ).

      CATCH cx_xco_gen_put_exception  INTO DATA(lx_put_exception).
        out->write( 'XCO Generation: PUT exception:' ).
        DATA(lo_findings) = lx_put_exception->findings.
        DATA(lt_findings) = lo_findings->get( ).
        LOOP AT lt_findings INTO DATA(ls_findings).
          out->write( ls_findings->message->get_text(  ) ).
        ENDLOOP.
        EXIT.
      CATCH zcx_rap_generator  INTO DATA(lx_rap_generator).
        out->write( 'RAP Generator: Exception occured' ).
        out->write( lx_rap_generator->get_text(  ) ).
        IF root_bo->lt_messages IS NOT INITIAL.
          out->write( 'Additional messages:' ).
          out->write( root_bo->lt_messages ).
        ENDIF.
        EXIT.
      CATCH cx_root INTO DATA(lx_root).
        out->write( 'Other exception:' ).
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
