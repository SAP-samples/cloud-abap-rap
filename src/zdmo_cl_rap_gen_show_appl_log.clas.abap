CLASS zdmo_cl_rap_gen_show_appl_log DEFINITION
   PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS is_key_filter
      IMPORTING it_filter_cond          TYPE if_rap_query_filter=>tt_name_range_pairs
      EXPORTING unique_filter_cond      TYPE if_rap_query_filter=>tt_name_range_pairs
      RETURNING VALUE(rv_is_key_filter) TYPE abap_bool.

ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_SHOW_APPL_LOG IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    DATA l_handle TYPE if_bali_log=>ty_handle.

    l_handle = 'vp3Ggk4J7ksZt3pexkwCdW'.
*    l_handle = 'eOy9ubWZ7jsZlQLeIxSCGm'.


    TRY.
        DATA(l_log) = cl_bali_log_db=>get_instance( )->load_log( handle = l_handle
                                                                 read_only_header = abap_true ).

        DATA(log_items) = l_log->get_all_items( )    .

        LOOP AT log_items INTO DATA(log_item).
          DATA(output) = |number { log_item-log_item_number } Category { log_item-item->category }  Severity { log_item-item->severity } log item number { log_item-item->log_item_number } detail level { log_item-item->detail_level } | .
          output = output &&  |time stamp { log_item-item->timestamp } msg_text: { log_item-item->get_message_text(  ) }| .
          out->write( output ).
        ENDLOOP.




      CATCH cx_bali_runtime INTO DATA(l_exception).
        out->write( l_exception->get_text( ) ).
    ENDTRY.


  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA business_data TYPE TABLE OF Zdmo_I_rap_generator_appl_log .
    DATA business_data_line TYPE Zdmo_I_rap_generator_appl_log .
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).
    DATA total_number_of_records TYPE int8.

    DATA log_item_number  TYPE if_bali_log=>ty_log_item_number  .

    TRY.
        DATA(filter_condition_string) = io_request->get_filter( )->get_as_sql_string( ).
        DATA(filter_condition_ranges) = io_request->get_filter( )->get_as_ranges( ).

        is_key_filter(
          EXPORTING
            it_filter_cond     = filter_condition_ranges
          IMPORTING
            unique_filter_cond = DATA(unique_filter_cond)
          RECEIVING
            rv_is_key_filter   = DATA(is_single_read)
        ).

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zdmo_cx_rap_generator
          EXPORTING
            textid   = VALUE scx_t100key( msgid = exception_t100_key-msgid
                                          msgno = exception_t100_key-msgno
                                          attr1 = exception_t100_key-attr1
                                          attr2 = exception_t100_key-attr2
                                          attr3 = exception_t100_key-attr3
                                          attr4 = exception_t100_key-attr4 )
            previous = exception.

*        ELSE.
*        ENDIF.
    ENDTRY.

    READ TABLE filter_condition_ranges WITH KEY name = 'LOG_HANDLE'
    INTO DATA(filter_condition_log_handle).

    READ TABLE filter_condition_ranges WITH KEY name = 'LOG_ITEM_NUMBER'
    INTO DATA(filter_condition_log_item_num).

    IF filter_condition_log_handle IS NOT INITIAL.

      DATA l_handle TYPE if_bali_log=>ty_handle.

      l_handle = filter_condition_log_handle-range[ 1 ]-low.

      IF l_handle IS NOT INITIAL.
        TRY.
            DATA(l_log) = cl_bali_log_db=>get_instance( )->load_log( handle = l_handle
                                                                     read_only_header = abap_true ).

            IF is_single_read = abap_true.

              total_number_of_records = 1.

              log_item_number =  filter_condition_log_item_num-range[ 1 ]-low .

              DATA(single_log_item) = l_log->get_item( log_item_number ).
              APPEND INITIAL LINE TO business_data.
              business_data[ 1 ]-Log_handle = l_handle.
              business_data[ 1 ]-Log_item_number = single_log_item->log_item_number.
              business_data[ 1 ]-category = single_log_item->category.
              business_data[ 1 ]-detail_level = single_log_item->detail_level.
              business_data[ 1 ]-message_text = single_log_item->get_message_text( ).
              business_data[ 1 ]-severity = single_log_item->severity.
              business_data[ 1 ]-timestamp = single_log_item->timestamp.

              CASE single_log_item->severity.
                WHEN 'S' OR 'I'. "Status, Information
                  business_data[ 1 ]-Criticality = 3.
                WHEN 'E' OR 'A'. "Error, Termination
                  business_data[ 1 ]-Criticality = 1.
                WHEN 'W' OR 'X'. "Warning, Exit
                  business_data[ 1 ]-Criticality = 2.
                WHEN OTHERS.
                  business_data[ 1 ]-Criticality = 0.
              ENDCASE.

              io_response->set_total_number_of_records( total_number_of_records ).
              io_response->set_data( business_data ).

              RETURN.
            ELSE.

              DATA(log_items) = l_log->get_all_items( )    .

            ENDIF.

            LOOP AT log_items INTO DATA(log_item).

              "fill key fields
              business_data_line-Log_handle = l_handle.
              business_data_line-Log_item_number = log_item-log_item_number.
              "fill properties
              business_data_line-category = log_item-item->category.
              business_data_line-severity = log_item-item->severity.
              business_data_line-detail_level = log_item-item->detail_level.
              business_data_line-timestamp = log_item-item->timestamp.

              business_data_line-message_text = log_item-item->get_message_text(  ).
              APPEND business_data_line TO business_Data.
            ENDLOOP.




          CATCH cx_bali_runtime INTO DATA(l_exception).
            DATA(l_exception_t100_key) = cl_message_helper=>get_latest_t100_exception( l_exception )->t100key.
            RAISE EXCEPTION TYPE zdmo_cx_rap_generator
              EXPORTING
                textid   = VALUE scx_t100key( msgid = l_exception_t100_key-msgid
                                              msgno = l_exception_t100_key-msgno
                                              attr1 = l_exception_t100_key-attr1
                                              attr2 = l_exception_t100_key-attr2
                                              attr3 = l_exception_t100_key-attr3
                                              attr4 = l_exception_t100_key-attr4 )
                previous = l_exception.
        ENDTRY.
      ENDIF.


    ENDIF.

    total_number_of_records = lines( business_data ).

    IF sort_order IS NOT INITIAL.

      DATA order_by_string TYPE string.

      CLEAR order_by_string.
      LOOP AT sort_order INTO DATA(ls_orderby_property).
        IF ls_orderby_property-descending = abap_true.
          CONCATENATE order_by_string ls_orderby_property-element_name 'DESCENDING' INTO order_by_string SEPARATED BY space.
        ELSE.
          CONCATENATE order_by_string ls_orderby_property-element_name 'ASCENDING' INTO order_by_string SEPARATED BY space.
        ENDIF.
      ENDLOOP.


    ENDIF.

    IF top IS NOT INITIAL AND top > 0.
      DATA(max_index) = top + skip.
    ELSE.
      max_index = 0.
    ENDIF.

    SELECT  Log_item_number FROM @business_data AS data_source_fields
       WHERE (filter_condition_string)
       ORDER BY (order_by_string)
       INTO TABLE @DATA(log_item_number_table)
       UP TO @max_index ROWS.

    DATA s_log_item_number_table TYPE RANGE OF Zdmo_I_rap_generator_appl_log-Log_item_number.
    DATA s_log_item_number_table_line LIKE LINE OF s_log_item_number_table.

    LOOP AT log_item_number_table INTO DATA(log_item_number_line).
      s_log_item_number_table_line-sign = 'I'.
      s_log_item_number_table_line-option = 'EQ'.
      s_log_item_number_table_line-low = log_item_number_line-Log_item_number.
      APPEND s_log_item_number_table_line TO s_log_item_number_table.
    ENDLOOP.

    DELETE business_data WHERE Log_item_number NOT IN s_log_item_number_table.

    IF skip IS NOT INITIAL.
      DELETE business_data TO skip.
    ENDIF.

*public static constant  c_severity_error  type if_bali_constants=>ty_severity value 'E'
*public static constant  c_severity_exit  type if_bali_constants=>ty_severity value 'X'
*public static constant  c_severity_information  type if_bali_constants=>ty_severity value 'I'
*public static constant  c_severity_status  type if_bali_constants=>ty_severity value 'S'
*public static constant  c_severity_termination  type if_bali_constants=>ty_severity value 'A'
*public static constant  c_severity_warning  type if_bali_constants=>ty_severity value 'W'

    LOOP AT business_data ASSIGNING FIELD-SYMBOL(<business_data>).
      CASE <business_data>-severity.
        WHEN 'S' OR 'I'. "Status, Information
          <business_data>-Criticality = 3.
        WHEN 'E' OR 'A'. "Error, Termination
          <business_data>-Criticality = 1.
        WHEN 'W' OR 'X'. "Warning, Exit
          <business_data>-Criticality = 2.
        WHEN OTHERS.
          <business_data>-Criticality = 0.
      ENDCASE.
    ENDLOOP.

    io_response->set_total_number_of_records( total_number_of_records ).
    io_response->set_data( business_data ).

  ENDMETHOD.


  METHOD is_key_filter.

    DATA filter_condition_by_name TYPE if_rap_query_filter=>ty_name_range_pairs .
    DATA key_name TYPE string.
    DATA range_option TYPE if_rap_query_filter=>ty_range_option .

    "check if the request is a single read

    key_name = 'LOG_HANDLE'.
    CLEAR filter_condition_by_name.
    CLEAR range_option.

    READ TABLE it_filter_cond WITH KEY name = key_name INTO filter_condition_by_name.
    IF sy-subrc = 0 AND lines( filter_condition_by_name-range ) = 1.
      READ TABLE filter_condition_by_name-range INTO range_option INDEX 1.
      IF sy-subrc = 0 AND range_option-sign = 'I' AND range_option-option = 'EQ' AND range_option-low IS NOT INITIAL.
        "read details for single record in list
        rv_is_key_filter = abap_true.
        APPEND filter_condition_by_name TO unique_filter_cond.
      ELSE.
        rv_is_key_filter = abap_false.
        CLEAR unique_filter_cond.
      ENDIF.
    ENDIF.

    CHECK rv_is_key_filter = abap_true.

    key_name = 'LOG_ITEM_NUMBER' .
    CLEAR filter_condition_by_name.
    CLEAR range_option.

    READ TABLE it_filter_cond WITH KEY name = key_name INTO filter_condition_by_name.
    IF sy-subrc = 0 AND lines( filter_condition_by_name-range ) = 1.
      READ TABLE filter_condition_by_name-range INTO range_option INDEX 1.
      IF sy-subrc = 0 AND range_option-sign = 'I' AND range_option-option = 'EQ' AND range_option-low IS NOT INITIAL.
        "read details for single record in list
        rv_is_key_filter = abap_true.
        APPEND filter_condition_by_name TO unique_filter_cond.
      ELSE.
        rv_is_key_filter = abap_false.
        CLEAR unique_filter_cond.
      ENDIF.
    ELSE.
      rv_is_key_filter = abap_false.
      CLEAR unique_filter_cond.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
