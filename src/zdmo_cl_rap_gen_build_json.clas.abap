CLASS zdmo_cl_rap_gen_build_json DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES :  tt_rapgen_node TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbonode WITH EMPTY KEY.
    TYPES :  ty_rapgen_node TYPE ZDMO_r_rapgeneratorbonode.
    TYPES :  tt_rapgen_bo TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbo WITH EMPTY KEY.
    TYPES :  ty_rapgen_bo TYPE  ZDMO_r_rapgeneratorbo.


    TYPES: BEGIN OF entities,

             nodeuuid TYPE sysuuid_x16,


           END OF entities.

    TYPES tt_childentities TYPE STANDARD TABLE OF entities WITH DEFAULT KEY  .
    DATA root_entity  TYPE ZDMO_r_rapgeneratorbonode.
    DATA rapgen_node TYPE tt_rapgen_node.
    DATA rapgen_bo TYPE tt_rapgen_bo.

    METHODS constructor
      IMPORTING iv_bo_uuid     TYPE ZDMO_rapgen_bo-rap_node_uuid OPTIONAL
                it_rapgen_node TYPE tt_rapgen_node OPTIONAL
                it_rapgen_bo   TYPE tt_rapgen_bo OPTIONAL
      RAISING   ZDMO_cx_rap_generator.

    METHODS create_json
      "IMPORTING iv_rapgen_bo_uuid     TYPE ZDMO_rapgen_bo-rap_node_uuid
      RETURNING VALUE(rv_json_string) TYPE string
      RAISING   ZDMO_cx_rap_generator.

    METHODS get_formatted_json_string
      IMPORTING json_string_in         TYPE string
      RETURNING VALUE(json_string_out) TYPE string
      RAISING   cx_sxml_parse_error.


  PROTECTED SECTION.
    METHODS: main REDEFINITION.
  PRIVATE SECTION.


    DATA  json_data_builder TYPE REF TO if_xco_cp_json_data_builder  .
    DATA rap_bo_uuid TYPE ZDMO_rapgen_bo-rap_node_uuid.
*    DATA rap_bo TYPE ZDMO_rapgen_bo.
    DATA rap_bo TYPE ZDMO_r_rapgeneratorbo.

    METHODS get_child_entity_keys
      IMPORTING current_node              TYPE ZDMO_r_rapgeneratorbonode
      RETURNING VALUE(child_csn_entities) TYPE  tt_childentities      .

    METHODS in_order
      IMPORTING current_node TYPE ZDMO_r_rapgeneratorbonode
                "   out          TYPE REF TO if_xco_adt_classrun_out
                io_json      TYPE REF TO if_xco_cp_json_data_builder   .
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_BUILD_JSON IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    rap_bo_uuid = iv_bo_uuid.
    rapgen_bo = it_rapgen_bo.
    rapgen_node = it_rapgen_node.
  ENDMETHOD.


  METHOD create_json.

    DATA json_string  TYPE string .
    DATA formatted_json_string TYPE string.

    DATA(lo_json_data_builder) = xco_cp_json=>data->builder( ).

*    SELECT SINGLE * FROM ZDMO_rapgen_bo INTO @rap_bo
*    WHERE rap_node_uuid = @rap_bo_uuid.

*    SELECT SINGLE namespace , p  FROM @rapgen_bo AS bo
*    WHERE RapNodeUUID = @rap_bo_uuid
*    INTO @rap_bo.

    rap_bo = rapgen_bo[ rapnodeuuid = rap_bo_uuid ].


    IF sy-subrc = 0.

*      SELECT SINGLE * FROM ZDMO_rapgen_node
*                     INTO @DATA(root_node)
*                     WHERE    is_root_node = @abap_true AND
*                     header_uuid = @rap_bo_uuid.
*      SELECT * FROM @rapgen_node AS nodes
*                  WHERE IsRootNode = @abap_true
*                    AND HeaderUUID  = @rap_bo_uuid INTO TABLE @DATA(root_node).


      DATA(root_node)      =   rapgen_node[ isrootnode = abap_true headeruuid  = rap_bo_uuid  ].

      lo_json_data_builder->begin_object( ).

      lo_json_data_builder->add_member( 'namespace' )->add_string( CONV string( rap_bo-namespace ) ).
      lo_json_data_builder->add_member( 'package' )->add_string( CONV string( rap_bo-packagename ) ).
      lo_json_data_builder->add_member( 'dataSourceType' )->add_string( CONV string( rap_bo-datasourcetype ) ).
      lo_json_data_builder->add_member( 'bindingType' )->add_string( CONV string( rap_bo-bindingtype ) ).
      lo_json_data_builder->add_member( 'implementationType' )->add_string( CONV string( rap_bo-implementationtype ) ).
      lo_json_data_builder->add_member( 'prefix' )->add_string( CONV string( rap_bo-prefix ) ).
      lo_json_data_builder->add_member( 'suffix' )->add_string( CONV string( rap_bo-suffix ) ).
      lo_json_data_builder->add_member( 'draftEnabled' )->add_boolean( rap_bo-draftenabled ).
      lo_json_data_builder->add_member( 'multiInlineEdit' )->add_boolean( rap_bo-MultiInlineEdit ).
      lo_json_data_builder->add_member( 'isCustomizingTable' )->add_boolean( rap_bo-CustomizingTable ).
      lo_json_data_builder->add_member( 'addBusinessConfigurationRegistration' )->add_boolean( rap_bo-AddToManageBusinessConfig ).
      lo_json_data_builder->add_member( 'transportRequest' )->add_string( CONV string( rap_bo-TransportRequest ) ).

      lo_json_data_builder->add_member( 'hierarchy' ).

      in_order(
        EXPORTING
          current_node = root_node
          "out          = out
          io_json      = lo_json_data_builder
      ).


      "end object von BO infos
      lo_json_data_builder->end_object( ).

      DATA(lo_json_data) = lo_json_data_builder->get_data( ).

      json_string = lo_json_data->to_string( ).

      rv_json_string = get_formatted_json_string( json_string ).

    ENDIF.

  ENDMETHOD.


  METHOD get_child_entity_keys.

*    SELECT node_uuid FROM ZDMO_rapgen_node WHERE
*                     parent_uuid = @current_node-node_uuid AND
*                     is_root_node = @abap_false
*                     INTO TABLE @child_csn_entities.

    SELECT nodeuuid FROM @rapgen_node AS node
           WHERE parentuuid = @current_node-nodeuuid AND
                 isrootnode = @abap_false
                 INTO TABLE @child_csn_entities.

  ENDMETHOD.


  METHOD get_formatted_json_string.

    "cloud
    DATA(json_xstring) = cl_abap_conv_codepage=>create_out( )->convert( json_string_in ).
    "on_premise
    "DATA(json_xstring) = cl_abap_codepage=>convert_to( json_string_in ).

    "Check and pretty print JSON

    DATA(reader) = cl_sxml_string_reader=>create( json_xstring ).
    DATA(writer) = CAST if_sxml_writer(
                          cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ) ).
    writer->set_option( option = if_sxml_writer=>co_opt_linebreaks ).
    writer->set_option( option = if_sxml_writer=>co_opt_indent ).
    reader->next_node( ).
    reader->skip_node( writer ).

    "cloud
    DATA(json_formatted_string) = cl_abap_conv_codepage=>create_in( )->convert( CAST cl_sxml_string_writer( writer )->get_output( ) ).
    "on premise
    "DATA(json_formatted_string) = cl_abap_codepage=>convert_from( CAST cl_sxml_string_writer( writer )->get_output( ) ).

    json_string_out = escape( val = json_formatted_string format = cl_abap_format=>e_xml_text  ).

  ENDMETHOD.


  METHOD in_order.
    DATA child_entities  TYPE TABLE OF ZDMO_r_rapgeneratorbonode.
    DATA i TYPE i.
    " CLEAR child_entities.

    io_json->begin_object( ).

    io_json->add_member( 'entityname' )->add_string( CONV string( current_node-entityname ) ).
    io_json->add_member( 'dataSource' )->add_string( CONV string( current_node-datasource ) ).
    io_json->add_member( 'objectid' )->add_string( CONV string( current_node-fieldnameobjectid ) ).
    "uuid specific fields
    io_json->add_member( 'uuid' )->add_string( CONV string( current_node-fieldnameuuid ) ).
    io_json->add_member( 'parentUUID' )->add_string( CONV string( current_node-fieldnameparentuuid ) ).
    io_json->add_member( 'rootUUID' )->add_string( CONV string( current_node-fieldnamerootuuid ) ).
    "etag specific fields
    io_json->add_member( 'etagMaster' )->add_string( CONV string( current_node-fieldnameetagmaster ) ).
    io_json->add_member( 'totalEtag' )->add_string( CONV string( current_node-fieldnametotaletag ) ).
    "administrative fields
    io_json->add_member( 'lastChangedAt' )->add_string( CONV string( current_node-fieldnamelastchangedat ) ).
    io_json->add_member( 'lastChangedBy' )->add_string( CONV string( current_node-fieldnamelastchangedby ) ).
    io_json->add_member( 'localInstanceLastChangedAt' )->add_string( CONV string( current_node-fieldnameloclastchangedat ) ).
    io_json->add_member( 'createdAt' )->add_string( CONV string( current_node-fieldnamecreatedat ) ).
    io_json->add_member( 'createdBy' )->add_string( CONV string( current_node-fieldnamecreatedby ) ).
    "repository object names
    io_json->add_member( 'draftTable' )->add_string( CONV string( current_node-drafttablename ) ).
    io_json->add_member( 'cdsInterfaceView' )->add_string( CONV string( current_node-cdsiview ) ).
    io_json->add_member( 'cdsRestrictedReuseView' )->add_string( CONV string( current_node-cdsrview ) ).
    io_json->add_member( 'cdsProjectionView' )->add_string( CONV string( current_node-cdspview ) ).
    io_json->add_member( 'metadataExtensionView' )->add_string( CONV string( current_node-mdeview ) ).
    io_json->add_member( 'behaviorImplementationClass' )->add_string( CONV string( current_node-behaviorimplementationclass ) ).
*    IF current_node-isrootnode = abap_true.
      io_json->add_member( 'serviceDefinition' )->add_string( CONV string( current_node-servicedefinition ) ).
      io_json->add_member( 'serviceBinding' )->add_string( CONV string( current_node-servicebinding ) ).
*    ENDIF.
    io_json->add_member( 'controlStructure' )->add_string( CONV string( current_node-controlstructure ) ).
    io_json->add_member( 'customQueryImplementationClass' )->add_string( CONV string( current_node-queryimplementationclass ) ).



    DATA(child_entity_keys) = get_child_entity_keys( current_node ).

    "CHECK child_entity_keys IS NOT INITIAL.
    IF child_entity_keys IS INITIAL.
      io_json->end_object( ).
    ELSE.
      io_json->add_member( 'Children' )->begin_array( ).

      DATA(number_of_child_entities) = lines( child_entity_keys ).
      LOOP AT child_entity_keys INTO DATA(child_entity_key).

*        SELECT SINGLE * FROM ZDMO_rapgen_node INTO @DATA(child_entity) WHERE
*                    node_uuid = @child_entity_key-node_uuid.

        DATA(child_entity) = rapgen_node[ nodeuuid = child_entity_key-nodeuuid ]  .

        APPEND child_entity TO child_entities.
      ENDLOOP.

      WHILE i < number_of_child_entities - 1.
        i += 1 .

        in_order(
          EXPORTING
            current_node = child_entities[ i ]
           " out        = out
            io_json = io_json
          ).

      ENDWHILE.

      in_order(
        EXPORTING
          current_node = child_entities[ number_of_child_entities ]
         " out        = out
          io_json = io_json
      ).

      io_json->end_array(  ).
      io_json->end_object( ).
    ENDIF.




  ENDMETHOD.


  METHOD main.

    rap_bo_uuid  = '42010AEF3E3F1EDC9782A6BDFB939EFC'.
    DATA(json_string) = create_json(  ).
    out->write( json_string ).

  ENDMETHOD.
ENDCLASS.
