CLASS lhc_rapgeneratorbonode DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      calculatenodenumber FOR DETERMINE ON MODIFY
        IMPORTING
          keys FOR  rapgeneratorbonode~calculatenodenumber .

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR rapgeneratorbonode RESULT result.

    METHODS setrepositoryobjectnames FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rapgeneratorbonode~setrepositoryobjectnames.




    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR rapgeneratorbonode RESULT result.

*    METHODS addchild2 FOR MODIFY
*      IMPORTING keys FOR ACTION rapgeneratorbonode~addchild2 .

    METHODS addchild2 FOR MODIFY
      IMPORTING keys   FOR ACTION rapgeneratorbonode~addchild2
      RESULT    result
      .
    METHODS setchangedatfieldnames FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rapgeneratorbonode~setchangedatfieldnames.
    METHODS setparentandrootuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rapgeneratorbonode~setparentandrootuuid.
    METHODS setfieldnames FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rapgeneratorbonode~setfieldnames.
    METHODS setrepoobjectnames FOR MODIFY
      IMPORTING keys FOR ACTION rapgeneratorbonode~setrepoobjectnames.
    METHODS setrepofieldnames FOR MODIFY
      IMPORTING keys FOR ACTION rapgeneratorbonode~setrepofieldnames.


ENDCLASS.

CLASS lhc_rapgeneratorbonode IMPLEMENTATION.

  METHOD calculatenodenumber.

    DATA max_nodenumber TYPE ZDMO_rapgen_node-node_number.
    DATA is_root_node TYPE abap_bool.
    DATA hierarchy_distance_from_root  TYPE  ZDMO_rapgen_node-hierarchy_distance_from_root .

    DATA update TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode.
*
    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
    FIELDS ( prefix suffix namespace packagename )
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).



    LOOP AT rapbos INTO DATA(rapbo).


      " read a dummy field
      READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
          FIELDS (  parentuuid rootuuid   )
        WITH VALUE #( ( %tky = rapbo-%tky ) )
        RESULT DATA(rapbo_nodes).

      SORT rapbo_nodes DESCENDING BY isrootnode.

      " find max used nodenumber in all nodes of this rapbo
      max_nodenumber = 0.
      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        IF rapbo_node-nodenumber > max_nodenumber.
          max_nodenumber = rapbo_node-nodenumber.
        ENDIF.
      ENDLOOP.

      DATA(number_of_nodes) = lines( rapbo_nodes ).

*      IF number_of_nodes = 1.
*        is_root_node = abap_true.


      LOOP AT rapbo_nodes INTO rapbo_node .



*        IF max_nodenumber = 0.
*          is_root_node = abap_true.
*        ELSE.
*          is_root_node = abap_false.
*        ENDIF.
        IF is_root_node = abap_true.

          APPEND VALUE #( %tky      = rapbo_node-%tky
                    rootuuid = rapbo_node-rootuuid
                    parentuuid = rapbo_node-parentuuid
                    nodenumber   = max_nodenumber
                    ) TO update.
        ELSE.
          APPEND VALUE #( %tky      = rapbo_node-%tky
                    nodenumber   = max_nodenumber
                    ) TO update.
        ENDIF.
        max_nodenumber += 1.

      ENDLOOP.
*      ENDIF.
    ENDLOOP.



    " Update the Booking ID of all relevant bookings
    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode
      UPDATE FIELDS (
                    "  isRootNode
                      nodenumber
                     " HierarchyDistanceFromRoot
                      ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
      FIELDS (  implementationtype datasourcetype
               namespace prefix suffix draftenabled )
      WITH CORRESPONDING #( keys )
      RESULT DATA(rapbos).
*
    LOOP AT rapbos INTO DATA(rapbo).
      " read a dummy field
      READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
          FIELDS ( entityname isrootnode viewtypevalue hierarchydistancefromroot )
        WITH VALUE #( ( %tky = rapbo-%tky ) )
        RESULT DATA(rapbo_nodes).

      result = VALUE #( FOR rapbo_node IN rapbo_nodes
                            ( %tky                   = rapbo_node-%tky

                              %action-addchild2      = COND #( WHEN rapbo-%is_draft = if_abap_behv=>mk-on
                                                               THEN if_abap_behv=>fc-o-enabled
                                                               ELSE if_abap_behv=>fc-o-disabled )


                              %field-fieldnameuuid         = COND #( WHEN rapbo-implementationtype = ZDMO_cl_rap_node=>implementation_type-managed_uuid
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                              %field-fieldnamerootuuid     = COND #( WHEN ( rapbo-implementationtype = ZDMO_cl_rap_node=>implementation_type-managed_uuid
                                                                      AND rapbo_node-hierarchydistancefromroot > 1 )
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-fieldnameparentuuid    = COND #( WHEN ( rapbo-implementationtype = ZDMO_cl_rap_node=>implementation_type-managed_uuid
                                                                      AND  rapbo_node-hierarchydistancefromroot > 0 )
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-controlstructure       = COND #( WHEN rapbo-implementationtype = ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-drafttablename         = COND #( WHEN rapbo-draftenabled = abap_true
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )


                              %field-queryimplementationclass = COND #( WHEN rapbo_node-viewtypevalue = xco_cp_data_definition=>type->abstract_entity->value OR
                                                                             rapbo_node-viewtypevalue = xco_cp_data_definition=>type->custom_entity->value
                                                                        THEN if_abap_behv=>fc-f-mandatory
                                                                        ELSE if_abap_behv=>fc-f-read_only
                                                                               )

                             %field-fieldnameetagmaster        = COND #( WHEN rapbo_node-isrootnode = abap_true
                                                                         THEN if_abap_behv=>fc-f-mandatory
                                                                         ELSE if_abap_behv=>fc-f-unrestricted )

                             "fields needed for root entities

                             %field-servicebinding          = COND #( WHEN rapbo_node-isrootnode = abap_true
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-servicedefinition      = COND #( WHEN rapbo_node-isrootnode = abap_true
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-fieldnametotaletag      = COND #( WHEN ( rapbo_node-isrootnode = abap_true AND rapbo-draftenabled = abap_true )
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                           "additional administrative fields that can be annotated for a root node

                             %field-fieldnamecreatedat      = COND #( WHEN rapbo_node-isrootnode = abap_true
                                                               THEN if_abap_behv=>fc-f-unrestricted
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-fieldnamecreatedby      = COND #( WHEN rapbo_node-isrootnode = abap_true
                                                               THEN if_abap_behv=>fc-f-unrestricted
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-fieldnamelastchangedby      = COND #( WHEN rapbo_node-isrootnode = abap_true
                                                               THEN if_abap_behv=>fc-f-unrestricted
                                                               ELSE if_abap_behv=>fc-f-read_only )

                            ) ).



    ENDLOOP.


  ENDMETHOD.



  METHOD setrepositoryobjectnames.
    "proposals for repository object names are only set
    "a) when draft is active and
    "b) when the entity name changes.

    DATA draft_keys TYPE TABLE FOR DETERMINATION ZDMO_i_rapgeneratorbo\\rapgeneratorbonode~setrepositoryobjectnames .
    "  if_abap_behv=>mk-on
    draft_keys = VALUE #( FOR draft_key IN keys  WHERE (   %is_draft = if_abap_behv=>mk-on )
    (
      %is_draft  = draft_key-%is_draft
     nodeuuid = draft_key-nodeuuid
     "Component Groups
     %key  = draft_key-%key
     %tky  = draft_key-%tky
     %pky  = draft_key-%pky
     ) ) .

    CHECK draft_keys IS NOT INITIAL.

    " Trigger Re-Calculation of repository object names
    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
      ENTITY rapgeneratorbonode
        EXECUTE setrepoobjectnames
          FROM CORRESPONDING  #( draft_keys ).

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD addchild2.

    DATA all_mapped TYPE RESPONSE FOR MAPPED EARLY ZDMO_i_rapgeneratorbo .

    DATA lt_create TYPE TABLE FOR CREATE ZDMO_i_rapgeneratorbonode.
    DATA update TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode .
    DATA number_of_childs TYPE i.
*    DATA lt_create TYPE TABLE FOR CREATE ZDMO_i_rapgeneratorbo\_RAPGeneratorBONode .
*    DATA ls_create TYPE STRUCTURE FOR CREATE ZDMO_i_rapgeneratorbo\_RAPGeneratorBONode .

*    DATA lt_create TYPE TABLE FOR CREATE ZDMO_i_rapgeneratorboNode .
    CONSTANTS mycid_rapbonode TYPE abp_behv_cid VALUE 'My%CID_rapbonode' ##NO_TEXT.

    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
    FIELDS ( rapnodeuuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).

      READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
         ALL FIELDS
        WITH VALUE #( ( %tky = rapbo-%tky ) )
        RESULT DATA(rapbo_nodes).

*    ENDLOOP.
*
*    LOOP AT keys INTO DATA(ls_key2).



      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        CLEAR update_line.
        CLEAR number_of_childs.
        LOOP AT rapbo_nodes INTO DATA(rapbo_node_2) WHERE parentuuid = rapbo_node-nodeuuid AND isrootnode = abap_false.
          number_of_childs += 1.
        ENDLOOP.

        LOOP AT rapbo_nodes INTO rapbo_node_2 WHERE nodeuuid = rapbo_node-nodeuuid.
          update_line-%tky      = rapbo_node_2-%tky.
          update_line-hierarchydescendantcount = number_of_childs + 1 .
          APPEND update_line TO update.
        ENDLOOP.


      ENDLOOP.


    ENDLOOP.






    LOOP AT keys INTO DATA(ls_key).

      IF line_exists( rapbo_nodes[ nodeuuid = ls_key-nodeuuid ] ).
*        DATA(parent_entity_name) = rapbo_nodes[ NodeUUID = ls_key-NodeUUID ]-EntityName.




        MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE

    ENTITY rapgeneratorbonode
      UPDATE FIELDS (
                      hierarchydescendantcount

                      ) WITH update
*    REPORTED DATA(update_reported)

        ENTITY rapgeneratorbo
          CREATE BY \_rapgeneratorbonode
            SET FIELDS WITH VALUE #( ( %is_draft = ls_key-%is_draft
*                                             %cid_ref  = ls_key-%cid
**                                              %cid  = ls_key-%cid
*                                              %tky     = ls_key-%tky
                                       rapnodeuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-headeruuid

                                       %target   = VALUE #( ( %is_draft = ls_key-%is_draft
                                                              %cid      = ls_key-%cid_ref
                                                              entityname = ls_key-%param-entity_name
                                                              parententityname = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-entityname
                                                              parentdatasource = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-datasource
                                                              parentuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-nodeuuid
                                                              rootuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-rootuuid
                                                              hierarchydistancefromroot = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-hierarchydistancefromroot + 1
                                                               )
                                                             ) ) )
        MAPPED  mapped " DATA(mapped_from_modify)
        FAILED  failed "  DATA(failed_from_modify)
        REPORTED reported." DATA(reported_from_modify).

        CHECK mapped-rapgeneratorbonode[] IS NOT INITIAL.

        APPEND LINES OF mapped-rapgeneratorbonode TO all_mapped-rapgeneratorbonode.
*
*        APPEND VALUE #( %tky = ls_key-%tky
*                        %param = VALUE #(
*                                                              entityname = ls_key-%param-entity_name
*                                                              parententityname = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-entityname
*                                                              parentdatasource = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-DataSource
*                                                              parentuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-nodeuuid
*                                                              rootuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-rootuuid
*                                                              hierarchydistancefromroot = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-hierarchydistancefromroot + 1
*
*                         ) ) TO result.


      ENDIF.

    ENDLOOP.



    CLEAR mapped-rapgeneratorbonode.
    mapped-rapgeneratorbonode = all_mapped-rapgeneratorbonode.


    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode
          ALL FIELDS WITH VALUE #(  FOR m IN all_mapped-rapgeneratorbonode ( %tky = m-%tky  ) )
          RESULT DATA(lt_result).

    result = VALUE #( FOR r IN lt_result (
                                           %tky = r-%tky
                                           %param = CORRESPONDING #( r ) ) ).


  ENDMETHOD.

  METHOD setchangedatfieldnames.


    DATA my_node TYPE REF TO ZDMO_cl_rap_node.
    DATA update TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode .
*
    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
    FIELDS ( prefix suffix namespace packagename implementationtype )
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

*
*    " Process all affected RAPBos. Read respective nodes,
*    " determine the implementation type of the RAP BO
*
    LOOP AT rapbos INTO DATA(rapbo).
      CLEAR update_line.

      " read a dummy field
      READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
          FIELDS ( entityname  cdsiview  cdspview   )
        WITH VALUE #( ( %tky = rapbo-%tky ) )
        RESULT DATA(rapbo_nodes).
      LOOP AT rapbo_nodes INTO DATA(rapbo_node).


        update_line-%tky      = rapbo_node-%tky.
        update_line-fieldnamelastchangedat = rapbo_node-fieldnametotaletag .
        update_line-fieldnameloclastchangedat = rapbo_node-fieldnameetagmaster.
        APPEND update_line TO update.

      ENDLOOP.
    ENDLOOP.


    " Update the Booking ID of all relevant bookings
    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode
      UPDATE FIELDS (
                      fieldnamelastchangedat
                      fieldnameloclastchangedat
                      ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD setparentandrootuuid.


    DATA my_node TYPE REF TO ZDMO_cl_rap_node.
    DATA update TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode .
*
    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
    FIELDS ( rapnodeuuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

*
*    " Process all affected RAPBos. Read respective nodes,
*    " determine the implementation type of the RAP BO
*
    LOOP AT rapbos INTO DATA(rapbo).
      CLEAR update_line.

      " read a dummy field
      READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
          FIELDS ( nodeuuid   )
        WITH VALUE #( ( %tky = rapbo-%tky ) )
        RESULT DATA(rapbo_nodes).
      LOOP AT rapbo_nodes INTO DATA(rapbo_node) WHERE isrootnode = abap_true.
        update_line-%tky      = rapbo_node-%tky.
        update_line-rootuuid = rapbo_node-nodeuuid .
        update_line-parentuuid = rapbo_node-nodeuuid.
        APPEND update_line TO update.

      ENDLOOP.
    ENDLOOP.


    " Update the Booking ID of all relevant bookings
    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode
      UPDATE FIELDS (
                      rootuuid
                      parentuuid
                      ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).




  ENDMETHOD.

  METHOD setfieldnames.

    DATA draft_keys TYPE TABLE FOR DETERMINATION ZDMO_i_rapgeneratorbo\\rapgeneratorbonode~setfieldnames .


    draft_keys = VALUE #( FOR draft_key IN keys  WHERE (   %is_draft = if_abap_behv=>mk-on )
    (
      %is_draft  = draft_key-%is_draft
     nodeuuid = draft_key-nodeuuid
     "Component Groups
     %key  = draft_key-%key
     %tky  = draft_key-%tky
     %pky  = draft_key-%pky
     ) ) .

    CHECK draft_keys IS NOT INITIAL.

    " Trigger Re-Calculation of repository object names
    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
      ENTITY rapgeneratorbonode
        EXECUTE setrepofieldnames
          FROM CORRESPONDING  #( draft_keys ).

*    DATA my_node TYPE REF TO ZDMO_cl_rap_node.
*    DATA my_parent_node TYPE REF TO ZDMO_cl_rap_node.
*    DATA update TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode.
*    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode .
**
*    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
*    ALL FIELDS
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(rapbos).
*
**
**    " Process all affected RAPBos. Read respective nodes,
**    " determine the implementation type of the RAP BO
**
*    LOOP AT rapbos INTO DATA(rapbo).
*
*
*      " read a dummy field
*      READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
*         ALL FIELDS " ( datasource )
*        WITH VALUE #( ( %tky = rapbo-%tky ) )
*        RESULT DATA(rapbo_nodes).
*
*      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
*        CLEAR update_line.
*        update_line-%tky      = rapbo_node-%tky.
*
**        update_line-fieldnameobjectid  = ''.
**        update_line-%control-fieldnameobjectid = if_abap_behv=>mk-on.
*
*        IF rapbo_node-datasource IS NOT INITIAL.
*          TRY.
*              DATA my_xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.
*              IF rapbo-abaplanguageversion = ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development.
*                my_xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
*              ELSE.
*                my_xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib( ) .
*              ENDIF.
*
*              my_node = NEW ZDMO_cl_rap_node(  ).
*              my_node->set_xco_lib( my_xco_lib ).
*              my_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
*              my_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).
*              my_node->set_data_source( CONV #( rapbo_node-datasource ) ).
*
*
*
*
*
**              IF rapbo-DataSourceType = ZDMO_cl_rap_node=>data_source_types-cds_view.
*              update_line-ViewTypeValue = my_node->view_type_value.
*              update_line-%control-ViewTypeValue = if_abap_behv=>mk-on.
**              ENDIF.
*              IF rapbo-implementationtype = 'managed_uuid'.
*                my_node->set_field_name_uuid( ). "CONV string( rapbo_node-FieldNameUUID ) ).
*                update_line-fieldnameuuid  = to_upper( my_node->field_name-uuid ).
*                update_line-%control-fieldnameuuid = if_abap_behv=>mk-on.
*                IF rapbo_node-hierarchydistancefromroot > 0.
*                  my_node->set_field_name_parent_uuid( ). "CONV string( rapbo_node-FieldNameParentUUID ) ).
*                  update_line-fieldnameparentuuid  = to_upper( my_node->field_name-parent_uuid ).
*                  update_line-%control-fieldnameparentuuid = if_abap_behv=>mk-on.
*                ENDIF.
*              ELSE.
*                update_line-fieldnameuuid  = ''.
*                update_line-%control-fieldnameuuid = if_abap_behv=>mk-on.
*                update_line-fieldnameparentuuid  = ''.
*                update_line-%control-fieldnameparentuuid = if_abap_behv=>mk-on.
*                update_line-fieldnamerootuuid  = ''.
*                update_line-%control-fieldnamerootuuid = if_abap_behv=>mk-on.
*              ENDIF.
*
*              my_node->set_field_name_etag_master( CONV string( rapbo_node-FieldNameEtagMaster ) ).
*              update_line-fieldnameetagmaster = to_upper( my_node->field_name-etag_master ).
*              update_line-%control-fieldnameetagmaster = if_abap_behv=>mk-on.
*
*              IF rapbo_node-isrootnode = abap_true.
*                my_node->set_is_root_node(  ).
*                my_node->set_field_name_total_etag( CONV string( rapbo_node-FieldNameTotalEtag )  ).
*                my_node->set_field_name_created_at( CONV string( rapbo_node-FieldNameCreatedAt ) ).
*                my_node->set_field_name_created_by( CONV string( rapbo_node-FieldNameCreatedBy ) ).
*                my_node->set_field_name_last_changed_by( CONV string( rapbo_node-FieldNameLastChangedBy ) ).
*                my_node->set_object_id(  rapbo_node-FieldNameObjectID ).
*                update_line-fieldnamecreatedat = to_upper( my_node->field_name-created_at ).
*                update_line-%control-fieldnamecreatedat = if_abap_behv=>mk-on.
*                update_line-fieldnamecreatedby = to_upper( my_node->field_name-created_by ).
*                update_line-%control-fieldnamecreatedby = if_abap_behv=>mk-on.
*                update_line-fieldnametotaletag = to_upper( my_node->field_name-total_etag ).
*                update_line-%control-fieldnametotaletag = if_abap_behv=>mk-on.
*                update_line-fieldnamelastchangedby = to_upper( my_node->field_name-last_changed_by ).
*                update_line-%control-fieldnamelastchangedby = if_abap_behv=>mk-on.
*                update_line-FieldNameObjectID = to_upper( my_node->object_id ).
*                update_line-%control-FieldNameObjectID = if_abap_behv=>mk-on.
*
*              ELSE.
*
*                my_parent_node = NEW ZDMO_cl_rap_node(  ).
*                my_parent_node->set_xco_lib( my_xco_lib ).
*                my_parent_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
*                my_parent_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).
*                my_parent_node->set_data_source( CONV #( rapbo_node-parentdatasource ) ).
*
*                IF rapbo-implementationtype = 'managed_semantic' OR
*                   rapbo-implementationtype = 'unmanaged_semantic'.
*
*                  LOOP AT my_node->semantic_key INTO DATA(semantic_key_field).
*                    IF NOT line_exists( my_parent_node->semantic_key[ name = semantic_key_field-name ] ).
*                      update_line-fieldnameobjectid = to_upper( semantic_key_field-name ).
*                      update_line-%control-FieldNameObjectID = if_abap_behv=>mk-on.
*
*                      EXIT.
*                    ENDIF.
*                  ENDLOOP.
*
*                ENDIF.
*
*              ENDIF.
*
*            CATCH ZDMO_cx_rap_generator INTO DATA(rap_node_exception).
*              DATA(exception_text) = rap_node_exception->get_text(  ).
*          ENDTRY.
*
*        ENDIF.
*        APPEND update_line TO update.
*      ENDLOOP.

*    ENDLOOP.
*
*
*    " Trigger Re-Calculation of repository object names
*    " setfieldnames is triggered when datasource changes
*    " when an abstract entity is chosen instead of a normal cds view
*    " we need a query implementation class
*    "@todo: When value help only offers cds views that are associations or compositions
*    "no change of cds view type will happen
*
*    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*      ENTITY rapgeneratorbonode
*        EXECUTE setrepoobjectnames
*          FROM CORRESPONDING  #( keys ).
*
*    " Update the fieldnames in all relevant nodes
*    " use the syntax of explicit use of %control fields because
*    " the update structure contains different fields based on type of node
*    " root node, implementation type, ...
*
*    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
*    ENTITY rapgeneratorbonode
*       UPDATE FROM update
*    REPORTED DATA(update_reported).
*
*    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD setrepoobjectnames.




    DATA my_node TYPE REF TO ZDMO_cl_rap_node.
    DATA root_node TYPE REF TO ZDMO_cl_rap_node.


    DATA update_bo TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbo.
    DATA update_bo_line TYPE STRUCTURE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbo .

    DATA update TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode .
*
    DATA draft_keys TYPE TABLE FOR DETERMINATION ZDMO_i_rapgeneratorbo\\rapgeneratorbonode~setrepositoryobjectnames.


    draft_keys = VALUE #( FOR draft_key IN keys  WHERE (   %is_draft = if_abap_behv=>mk-on )
    (
      %is_draft  = draft_key-%is_draft
     nodeuuid = draft_key-nodeuuid
     "Component Groups
     %key  = draft_key-%key
     %tky  = draft_key-%tky
     %pky  = draft_key-%pky
     ) ) .

    CHECK draft_keys IS NOT INITIAL.

    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
    ALL FIELDS "( prefix suffix namespace packagename implementationtype draftenabled )
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

*
*    " Process all affected RAPBos. Read respective nodes,
*    " determine the implementation type of the RAP BO
*
    LOOP AT rapbos INTO DATA(rapbo).

      DATA my_xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.
      IF rapbo-abaplanguageversion = ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development.
        my_xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
      ELSE.
        my_xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib( ) .
      ENDIF.

      CLEAR update_bo_line.

      " read a dummy field
      READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
        ENTITY rapgeneratorbo BY \_rapgeneratorbonode
         ALL FIELDS "( entityname  cdsiview  cdspview   )
        WITH VALUE #( ( %tky = rapbo-%tky ) )
        RESULT DATA(rapbo_nodes).

      update_bo_line-%tky      = rapbo-%tky.

      SORT rapbo_nodes BY hierarchydistancefromroot ASCENDING. "loop will start with the root node

      root_node = NEW ZDMO_cl_rap_node(  ).
      root_node->set_is_root_node(  ).
      root_node->set_xco_lib( my_xco_lib ).
      root_node->set_draft_enabled( rapbo-draftenabled ).
      root_node->set_prefix( rapbo-prefix ).
      root_node->set_suffix( rapbo-suffix ).
      root_node->set_namespace( CONV #( rapbo-namespace ) ).
      root_node->set_binding_type( CONV #( rapbo-bindingtype ) ).
      root_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
      root_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).

        CHECK rapbo_node-entityname IS NOT INITIAL AND
              rapbo-namespace IS NOT INITIAL .
*              AND
*              rapbo_node-hierarchydescendantcount > 0.  "node has child nodes

        CLEAR update_line.
        update_line-%tky      = rapbo_node-%tky.

        IF line_exists( rapbo_nodes[ nodeuuid = rapbo_node-parentuuid ] ).
          update_line-parententityname = rapbo_nodes[ nodeuuid = rapbo_node-parentuuid ]-entityname.
        ENDIF.


        TRY.

            IF rapbo_node-isrootnode = abap_true.

              my_node = root_node.
              my_node->set_entity_name( CONV #( rapbo_node-entityname ) ).

              my_node->set_name_service_definition(  ).
              my_node->set_name_service_binding(  ).

              update_line-servicebinding = my_node->rap_root_node_objects-service_binding.
              update_line-servicedefinition = my_node->rap_root_node_objects-service_definition.



            ELSE.

              "value must be explictly set to ''.
              "Because if fields are initial their content is not updated via EML

              update_line-servicebinding = ''.
              update_line-servicedefinition = ''.

              CASE rapbo_node-hierarchydistancefromroot.
                WHEN 1.
                  my_node = root_node->add_child( ).
                  my_node->set_entity_name( CONV #( rapbo_node-entityname ) ).
                WHEN OTHERS.
                  LOOP AT root_node->all_childnodes INTO DATA(child_node).
                    IF child_node->entityname = update_line-parententityname.
                      my_node = child_node->add_child( ).
                      my_node->set_entity_name( CONV #( rapbo_node-entityname ) ).
                    ENDIF.
                  ENDLOOP.
              ENDCASE.
            ENDIF.

            IF rapbo-draftenabled = abap_true.
              my_node->set_name_draft_table(  ).
              update_line-drafttablename   = my_node->draft_table_name.
            ELSE.
              update_line-drafttablename = ''.
            ENDIF.

            my_node->set_name_cds_i_view(  ).
            my_node->set_name_cds_p_view(  ).
            my_node->set_name_behavior_impl(  ).
            my_node->set_name_mde(  ).

            update_line-cdsiview   = my_node->rap_node_objects-cds_view_i.
            update_line-cdspview   = my_node->rap_node_objects-cds_view_p.
            update_line-mdeview  = my_node->rap_node_objects-meta_data_extension.
            update_line-behaviorimplementationclass  = my_node->rap_node_objects-behavior_implementation.

*            "boname can only be set after name of cds-i-view has been determined
*            IF rapbo_node-isrootnode = abap_true.
*              update_bo_line-boname = my_node->rap_node_objects-cds_view_i.
*            ENDIF.

            IF rapbo-implementationtype = ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
              my_node->set_name_control_structure(  ).
              update_line-controlstructure = my_node->rap_node_objects-control_structure.
            ELSE.
              update_line-controlstructure = ''.
            ENDIF.

            IF rapbo_node-viewtypevalue = xco_cp_data_definition=>type->abstract_entity->value OR
               rapbo_node-viewtypevalue = xco_cp_data_definition=>type->custom_entity->value.

              my_node->set_name_custom_query_impl(  ).
              my_node->set_name_custom_entity(  ).

              update_line-queryimplementationclass = my_node->rap_node_objects-custom_query_impl_class.
            ELSE.
              update_line-queryimplementationclass = ''.
            ENDIF.


          CATCH ZDMO_cx_rap_generator INTO DATA(rap_node_exception).
            DATA(exception_text) = rap_node_exception->get_text(  ).
        ENDTRY.


        APPEND update_line TO update.

      ENDLOOP.

      APPEND update_bo_line TO update_bo.

    ENDLOOP.


    " Update repository object name proposals of all relevant entities
    " Update the parent entity name
    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbo
      UPDATE FIELDS (
                      boname
                     ) WITH update_bo
    ENTITY rapgeneratorbonode
      UPDATE FIELDS (
                      parententityname
                      cdsiview
                      cdspview
                      mdeview
                      behaviorimplementationclass
                      servicedefinition
                      servicebinding
                      controlstructure
                      queryimplementationclass
                      drafttablename
                      ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD setrepofieldnames.

    DATA rapbo TYPE STRUCTURE FOR READ RESULT ZDMO_i_rapgeneratorbo\\rapgeneratorbonode\_rapgeneratorbo .
    DATA my_node TYPE REF TO ZDMO_cl_rap_node.
    DATA my_parent_node TYPE REF TO ZDMO_cl_rap_node.
    DATA update TYPE TABLE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_i_rapgeneratorbo\\rapgeneratorbonode .
*

    DATA draft_keys TYPE TABLE FOR DETERMINATION ZDMO_i_rapgeneratorbo\\rapgeneratorbonode~setfieldnames .


    draft_keys = VALUE #( FOR draft_key IN keys  WHERE (   %is_draft = if_abap_behv=>mk-on )
    (
      %is_draft  = draft_key-%is_draft
     nodeuuid = draft_key-nodeuuid
     "Component Groups
     %key  = draft_key-%key
     %tky  = draft_key-%tky
     %pky  = draft_key-%pky
     ) ) .

    CHECK draft_keys IS NOT INITIAL.

    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode BY \_rapgeneratorbo
    ALL FIELDS
    WITH CORRESPONDING #( draft_keys )
    RESULT DATA(rapbos).
*
**
**    " Process all affected RAPBos. Read respective nodes,
**    " determine the implementation type of the RAP BO
**
*    LOOP AT rapbos INTO DATA(rapbo).
*
*
*      " read a dummy field
    READ ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
      ENTITY rapgeneratorbonode
       ALL FIELDS
      WITH CORRESPONDING #( draft_keys )
      RESULT DATA(rapbo_nodes).



    LOOP AT rapbo_nodes INTO DATA(rapbo_node).

      CLEAR rapbo.

      IF line_exists( rapbos[ rapnodeuuid = rapbo_node-headeruuid ] ).
        rapbo = rapbos[ rapnodeuuid = rapbo_node-headeruuid ].
      ENDIF.

      CHECK rapbo IS NOT INITIAL.

      CLEAR update_line.

      update_line-%tky      = rapbo_node-%tky.

*        update_line-fieldnameobjectid  = ''.
*        update_line-%control-fieldnameobjectid = if_abap_behv=>mk-on.

      "delete all field name proposals
      update_line-fieldnameobjectid = ''.
      update_line-%control-fieldnameobjectid = if_abap_behv=>mk-on.
      update_line-viewtypevalue = ''.
      update_line-%control-viewtypevalue = if_abap_behv=>mk-on.
      update_line-fieldnameuuid  = ''.
      update_line-%control-fieldnameuuid = if_abap_behv=>mk-on.
      update_line-fieldnameparentuuid  = ''.
      update_line-%control-fieldnameparentuuid = if_abap_behv=>mk-on.
      update_line-fieldnamerootuuid  = ''.
      update_line-%control-fieldnamerootuuid = if_abap_behv=>mk-on.
      update_line-fieldnameetagmaster = ''.
      update_line-%control-fieldnameetagmaster = if_abap_behv=>mk-on.
      update_line-fieldnamecreatedat = ''.
      update_line-%control-fieldnamecreatedat = if_abap_behv=>mk-on.
      update_line-fieldnamecreatedby = ''.
      update_line-%control-fieldnamecreatedby = if_abap_behv=>mk-on.
      update_line-fieldnametotaletag = ''.
      update_line-%control-fieldnametotaletag = if_abap_behv=>mk-on.
      update_line-fieldnamelastchangedby = ''.
      update_line-%control-fieldnamelastchangedby = if_abap_behv=>mk-on.
      update_line-fieldnameobjectid = ''.
      update_line-%control-fieldnameobjectid = if_abap_behv=>mk-on.

      IF rapbo_node-datasource IS NOT INITIAL.

        TRY.
            DATA my_xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.
            IF rapbo-abaplanguageversion = ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development.
              my_xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
            ELSE.
              my_xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib( ) .
            ENDIF.

            my_node = NEW ZDMO_cl_rap_node(  ).
            my_node->set_xco_lib( my_xco_lib ).
            my_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
            my_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).
            my_node->set_data_source( CONV #( rapbo_node-datasource ) ).

*              IF rapbo-DataSourceType = ZDMO_cl_rap_node=>data_source_types-cds_view.
            update_line-viewtypevalue = my_node->view_type_value.
            update_line-%control-viewtypevalue = if_abap_behv=>mk-on.
*              ENDIF.
            IF rapbo-implementationtype = 'managed_uuid'.
              my_node->set_field_name_uuid( ). "CONV string( rapbo_node-FieldNameUUID ) ).
              update_line-fieldnameuuid  = to_upper( my_node->field_name-uuid ).
              update_line-%control-fieldnameuuid = if_abap_behv=>mk-on.
              IF rapbo_node-hierarchydistancefromroot > 0.
                my_node->set_field_name_parent_uuid( ). "CONV string( rapbo_node-FieldNameParentUUID ) ).
                update_line-fieldnameparentuuid  = to_upper( my_node->field_name-parent_uuid ).
                update_line-%control-fieldnameparentuuid = if_abap_behv=>mk-on.
              ENDIF.
            ELSE.
              update_line-fieldnameuuid  = ''.
              update_line-%control-fieldnameuuid = if_abap_behv=>mk-on.
              update_line-fieldnameparentuuid  = ''.
              update_line-%control-fieldnameparentuuid = if_abap_behv=>mk-on.
              update_line-fieldnamerootuuid  = ''.
              update_line-%control-fieldnamerootuuid = if_abap_behv=>mk-on.
            ENDIF.

            my_node->set_field_name_etag_master( CONV string( rapbo_node-fieldnameetagmaster ) ).
            update_line-fieldnameetagmaster = to_upper( my_node->field_name-etag_master ).
            update_line-%control-fieldnameetagmaster = if_abap_behv=>mk-on.

            IF rapbo_node-isrootnode = abap_true.
              my_node->set_is_root_node(  ).
              my_node->set_draft_enabled( rapbo-draftenabled ).
              my_node->set_field_name_total_etag( ). "CONV string( rapbo_node-FieldNameTotalEtag )  ).
              my_node->set_field_name_created_at( ). "CONV string( rapbo_node-FieldNameCreatedAt ) ).
              my_node->set_field_name_created_by( ). "CONV string( rapbo_node-FieldNameCreatedBy ) ).
              my_node->set_field_name_last_changed_by( ). "ONV string( rapbo_node-FieldNameLastChangedBy ) ).
              my_node->set_object_id(  ). " rapbo_node-FieldNameObjectID ).
              update_line-fieldnamecreatedat = to_upper( my_node->field_name-created_at ).
              update_line-%control-fieldnamecreatedat = if_abap_behv=>mk-on.
              update_line-fieldnamecreatedby = to_upper( my_node->field_name-created_by ).
              update_line-%control-fieldnamecreatedby = if_abap_behv=>mk-on.
              update_line-fieldnametotaletag = to_upper( my_node->field_name-total_etag ).
              update_line-%control-fieldnametotaletag = if_abap_behv=>mk-on.
              update_line-fieldnamelastchangedby = to_upper( my_node->field_name-last_changed_by ).
              update_line-%control-fieldnamelastchangedby = if_abap_behv=>mk-on.
              update_line-fieldnameobjectid = to_upper( my_node->object_id ).
              update_line-%control-fieldnameobjectid = if_abap_behv=>mk-on.

            ELSE.

              my_parent_node = NEW ZDMO_cl_rap_node(  ).
              my_parent_node->set_xco_lib( my_xco_lib ).
              my_parent_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
              my_parent_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).
              my_parent_node->set_data_source( CONV #( rapbo_node-parentdatasource ) ).

              IF rapbo-implementationtype = 'managed_semantic' OR
                 rapbo-implementationtype = 'unmanaged_semantic'.

                LOOP AT my_node->semantic_key INTO DATA(semantic_key_field).
                  IF NOT line_exists( my_parent_node->semantic_key[ name = semantic_key_field-name ] ).
                    update_line-fieldnameobjectid = to_upper( semantic_key_field-name ).
                    update_line-%control-fieldnameobjectid = if_abap_behv=>mk-on.

                    EXIT.
                  ENDIF.
                ENDLOOP.

              ENDIF.

            ENDIF.

          CATCH ZDMO_cx_rap_generator INTO DATA(rap_node_exception).
            DATA(exception_text) = rap_node_exception->get_text(  ).
        ENDTRY.

      ENDIF.
      APPEND update_line TO update.
    ENDLOOP.
*    ENDLOOP.


    " Trigger Re-Calculation of repository object names
    " setfieldnames is triggered when datasource changes
    " when an abstract entity is chosen instead of a normal cds view
    " we need a query implementation class
    "@todo: When value help only offers cds views that are associations or compositions
    "no change of cds view type will happen

    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
      ENTITY rapgeneratorbonode
        EXECUTE setrepoobjectnames
          FROM CORRESPONDING  #( keys ).

    " Update the fieldnames in all relevant nodes
    " use the syntax of explicit use of %control fields because
    " the update structure contains different fields based on type of node
    " root node, implementation type, ...

    MODIFY ENTITIES OF ZDMO_i_rapgeneratorbo IN LOCAL MODE
    ENTITY rapgeneratorbonode
       UPDATE FROM update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

ENDCLASS.
