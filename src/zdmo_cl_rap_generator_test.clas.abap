CLASS zdmo_cl_rap_generator_test DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  PROTECTED SECTION.
    METHODS main REDEFINITION.
    METHODS get_json_string
      RETURNING VALUE(json_string) TYPE string.
  PRIVATE SECTION.

    TYPES : tt_bo_data   TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbo,
            tt_node_data TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbonode.

    TYPES : t_bo_data   TYPE  ZDMO_r_rapgeneratorbo,
            t_node_data TYPE  ZDMO_r_rapgeneratorbonode.
    TYPES t_mapped  TYPE RESPONSE FOR MAPPED EARLY zdmo_r_rapgeneratorbo.
    TYPES t_failed TYPE RESPONSE FOR FAILED EARLY zdmo_r_rapgeneratorbo.
    TYPES t_reported TYPE RESPONSE FOR REPORTED EARLY zdmo_r_rapgeneratorbo.


    DATA: generate_repository_objects TYPE abap_bool VALUE abap_false,
          running_in_test_mode        TYPE abap_bool,
          PackageNameForAllTests      TYPE sxco_package,
          suffixForAllTests           TYPE sxco_ar_object_name.


    DATA mapped TYPE t_mapped.
    DATA failed TYPE t_failed.
    DATA reported TYPE t_reported.

    DATA update_node TYPE TABLE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbonode.
    DATA update_rapbo TYPE TABLE FOR UPDATE ZDMO_R_RapGeneratorBO\\RAPGeneratorBO.

    DATA update_node_line TYPE STRUCTURE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbonode .
    DATA update_rapbo_line TYPE STRUCTURE FOR UPDATE zdmo_r_rapgeneratorbo\\RAPGeneratorBO.

    DATA wait_time_in_seconds TYPE i VALUE 1 .

    DATA  et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val  .




    METHODS: create_managed_uuid ,

      create_managed_semantic ,

      create_unmanaged_semantic ,

      create_unmanaged_abstract,

      create_managed_uuid_O2 ,

      create_three_level_uuid
        IMPORTING i_bo_data   TYPE tt_bo_data
                  i_node_data TYPE tt_node_data,

      create_two_level_semantic
        IMPORTING i_bo_data   TYPE tt_bo_data
                  i_node_data TYPE tt_node_data.



ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_TEST IMPLEMENTATION.


  METHOD create_managed_semantic.


    DATA : bo_data       TYPE tt_bo_data,
           node_data     TYPE tt_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                             PackageName         = packagenameforalltests
                             Prefix              = 'M_'
                             Suffix              = suffixforalltests
                             ImplementationType  = zdmo_cl_rap_node=>implementation_type-managed_semantic
                             BindingType         = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                             DataSourceType      = zdmo_cl_rap_node=>data_source_types-table
                             DraftEnabled        = abap_true
                         )
                         ).

    node_data = VALUE #( (
                          entityname        = |Holiday|
                          DataSource        = 'ZDMO_fcal_holi'
                       )
                       (
                          entityname        = |HolidayText|
                          DataSource        = 'ZDMO_fcal_holi_t'
                       )
                       ).

    create_two_level_semantic(
      i_bo_data   = bo_data
      i_node_data = node_data
    ).

  ENDMETHOD.


  METHOD create_managed_uuid.

    DATA : bo_data       TYPE tt_bo_data,
           node_data     TYPE tt_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                         PackageName         = packagenameforalltests
                         Prefix              = 'UUID_'
                         Suffix              = suffixforalltests
                         ImplementationType  = zdmo_cl_rap_node=>implementation_type-managed_uuid
                         BindingType         = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                         DataSourceType      = zdmo_cl_rap_node=>data_source_types-table
                         DraftEnabled        = abap_true
                         TransportRequest    = ''
                     )
                     ).

    node_data = VALUE #( (
                          entityname        = |Header|
                          DataSource        = to_upper( 'zdmo_uuid_header' )
                          FieldNameObjectID = to_upper( 'salesorder_id' )
                       )
                       (

                          entityname        = |Item|
                          DataSource        = to_upper( 'zdmo_uuid_item' )
                          FieldNameObjectID = to_upper( 'item_id' )
                       )
                        (
                          entityname           = |SubItem|
                          FieldNameRootUUID    = to_upper( 'root_uuid' )
                          FieldNameParentUUID  = to_upper( 'parent_uuid' )
                          DataSource           = to_upper( 'zdmo_uuid_s_item' )
                          FieldNameObjectID    = to_upper( 'schedule_line_id' )
                       )
                       ).

    create_three_level_uuid(
      i_bo_data   = bo_Data
      i_node_data = node_data
    ).


  ENDMETHOD.


  METHOD create_managed_uuid_o2.

    DATA : bo_data       TYPE tt_bo_data,
           node_data     TYPE tt_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                        PackageName         = packagenameforalltests
                        Prefix              = 'O2_'
                        Suffix              = suffixforalltests
                        ImplementationType  = zdmo_cl_rap_node=>implementation_type-managed_uuid
                        BindingType         = zdmo_cl_rap_node=>binding_type_name-odata_v2_ui
                        DataSourceType      = zdmo_cl_rap_node=>data_source_types-table
                        DraftEnabled        = abap_true
                         TransportRequest    = ''
                    )
                    ).

    node_data = VALUE #( (
                          entityname        = |Header|
                          DataSource        = to_upper( 'zdmo_uuid_header' )
                          FieldNameObjectID = to_upper( 'salesorder_id' )
                       )
                       (

                          entityname        = |Item|
                          DataSource        = to_upper( 'zdmo_uuid_item' )
                          FieldNameObjectID = to_upper( 'item_id' )
                       )
                        (
                          entityname           = |SubItem|
                          FieldNameRootUUID    = to_upper( 'root_uuid' )
                          FieldNameParentUUID  = to_upper( 'parent_uuid' )
                          DataSource           = to_upper( 'zdmo_uuid_s_item' )
                          FieldNameObjectID    = to_upper( 'schedule_line_id' )
                       )
                       ).

    create_three_level_uuid(
      i_bo_data   = bo_data
      i_node_data = node_data
    ).


  ENDMETHOD.


  METHOD create_three_level_uuid.

    DATA(bo_data) = i_bo_data.
    DATA(node_data) = i_node_data.

    "create BO and root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbo
        EXECUTE createBOandRootNode
          FROM VALUE #( (
          %cid = 'ROOT1'
          %param-entity_name = node_data[ 1 ]-EntityName
          %param-package_name = bo_data[ 1 ]-PackageName
          ) )
      MAPPED   DATA(mapped)
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    " expect no failures and messages
    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    " expect a newly created record in mapped tables
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbo'  act = mapped-rapgeneratorbo  ).
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).


    DATA(my_rapnodeuuid) = mapped-rapgeneratorbo[ 1 ]-RapNodeUUID.
    DATA(my_rootnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.


    "set fields for RAP BO
    CLEAR update_rapbo_line.
    CLEAR update_rapbo.
    MOVE-CORRESPONDING bo_data[ 1 ] TO update_rapbo_line.
    update_rapbo_line-%tky = VALUE #( %is_draft = if_abap_behv=>mk-on RapNodeUUID = my_rapnodeuuid ).
    APPEND update_rapbo_line TO update_rapbo.

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
          ENTITY RAPGeneratorBO
                UPDATE FIELDS (
                          suffix
                          prefix
                          ImplementationType
                          DataSourceType
                          BindingType
                          DraftEnabled
                           TransportRequest
                         ) WITH update_rapbo
       FAILED   failed
       REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed to set bo header data'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported to set bo header data' act = reported ).


    "set fields for root node
    "first set data source, then set objectID field
    CLEAR update_node_line.
    CLEAR update_node.
    MOVE-CORRESPONDING node_data[ 1 ] TO update_node_line.
    update_node_line-%tky = VALUE #(  %is_draft = if_abap_behv=>mk-on NodeUUID = my_rootnodeuuid ).
    APPEND update_node_line TO update_node.

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE FIELDS (
                               DataSource
                             ) WITH update_node
           FAILED   failed
           REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE FIELDS (
                               FieldNameObjectID
                             ) WITH update_node
           FAILED   failed
           REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "add child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbonode
        EXECUTE addChild2
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_rootnodeuuid )
                              %param-entity_name = node_data[ 2 ]-EntityName
          ) )
      MAPPED   mapped
      FAILED   failed
      REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

    DATA(my_childnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.

    "set fields for child node
    "first set data source, then set objectID field
    CLEAR update_node_line.
    CLEAR update_node.
    MOVE-CORRESPONDING node_data[ 2 ] TO update_node_line.
    update_node_line-%tky = VALUE #(  %is_draft = if_abap_behv=>mk-on NodeUUID = my_childnodeuuid ).
    APPEND update_node_line TO update_node.

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE FIELDS (
                            DataSource
                          ) WITH update_node
        FAILED   failed
        REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE FIELDS (
                               FieldNameObjectID
                             ) WITH update_node
           FAILED   failed
           REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).


    "add grand child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbonode
        EXECUTE addChild2
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_childnodeuuid )
                              %param-entity_name = node_data[ 3 ]-EntityName
          ) )
      MAPPED   mapped
      FAILED   failed
      REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

    DATA(my_grandchildnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.

    "set fields for grand child node
    "first set data source, then set objectID field
    CLEAR update_node_line.
    CLEAR update_node.
    MOVE-CORRESPONDING node_data[ 3 ] TO update_node_line.
    update_node_line-%tky = VALUE #(  %is_draft = if_abap_behv=>mk-on NodeUUID = my_grandchildnodeuuid ).
    APPEND update_node_line TO update_node.

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE FIELDS (
                            DataSource
                          ) WITH update_node
        FAILED   failed
        REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE FIELDS (
                               FieldNameObjectID
                               FieldNameRootUUID
                               FieldNameParentUUID
                             ) WITH update_node
           FAILED   failed
           REPORTED reported.

    "activate instance
    MODIFY ENTITY ZDMO_r_rapgeneratorbo
        EXECUTE
            Activate FROM VALUE #( ( %key-RapNodeUUID = my_rapnodeuuid ) )
        MAPPED DATA(mapped_active)
        FAILED DATA(failed_active)
        REPORTED DATA(reported_active).

    "cl_abap_unit_assert=>assert_initial( msg = 'failed_active'   act = failed_active ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported_active' act = reported_active ).
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbo' act = mapped_active-rapgeneratorbo ).

    "commit data
    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    "cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    "check committed data

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    "cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).

    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).

    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    "cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).
    "cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).

    "generate repository objects
*    MODIFY ENTITY ZDMO_r_rapgeneratorbo
*        EXECUTE
*            createBO FROM VALUE #( (
*                                                %tky = VALUE #(  %is_draft = if_abap_behv=>mk-off
*                                                rapNodeUUID = my_rapnodeuuid )
**             %key-RapNodeUUID = my_rapnodeuuid
*             ) )
*        MAPPED mapped
*        FAILED failed
*        REPORTED reported.
*
*    "cl_abap_unit_assert=>assert_initial( msg = 'failed - generate objects' act = failed ).
*    "cl_abap_unit_assert=>assert_initial( msg = 'reported - generate objects' act = reported ).
*
*    COMMIT ENTITIES RESPONSES
*           FAILED   DATA(commit_failed2)
*           REPORTED DATA(commit_reported2).

    "cl_abap_unit_assert=>assert_initial( msg = 'failed2 - generate objects' act = commit_failed2 ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported2 - generate objects' act = commit_reported2 ).

    et_parameters = VALUE #(
    ( selname = zdmo_cl_rap_node=>job_selection_name
      kind = if_apj_dt_exec_object=>parameter
      sign = 'I'
      option = 'EQ'
      low = rapbo-BoName )
  ).

    TRY.
        DATA rap_job TYPE REF TO zdmo_cl_rap_gen_in_background.

        rap_job = NEW #(  ).


        rap_job->if_apj_rt_exec_object~execute( it_parameters = et_parameters ).
      CATCH cx_apj_rt_content INTO DATA(job_exception).

    ENDTRY.

  ENDMETHOD.


  METHOD create_two_level_semantic.

    DATA(bo_data) = i_bo_data.
    DATA(node_data) = i_node_data.

    "create BO and root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbo
        EXECUTE createBOandRootNode
          FROM VALUE #( (
          %cid = 'ROOT1'
          %param-entity_name = node_data[ 1 ]-EntityName
          %param-package_name = bo_data[ 1 ]-PackageName
          ) )
      MAPPED   DATA(mapped)
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    " expect no failures and messages
    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    " expect a newly created record in mapped tables
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbo'  act = mapped-rapgeneratorbo  ).
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).


    DATA(my_rapnodeuuid) = mapped-rapgeneratorbo[ 1 ]-RapNodeUUID.
    DATA(my_rootnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.


    "set fields for RAP BO
    CLEAR update_rapbo_line.
    CLEAR update_rapbo.
    MOVE-CORRESPONDING bo_data[ 1 ] TO update_rapbo_line.
    update_rapbo_line-%tky = VALUE #( %is_draft = if_abap_behv=>mk-on RapNodeUUID = my_rapnodeuuid ).
    APPEND update_rapbo_line TO update_rapbo.

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
          ENTITY RAPGeneratorBO
                UPDATE FIELDS (
                         Prefix
                         Suffix
                         ImplementationType
                         BindingType
                         DataSourceType
                         DraftEnabled
                           TransportRequest
                         ) WITH update_rapbo
       FAILED   failed
       REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed to set bo header data'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported to set bo header data' act = reported ).


    "set fields for root node
    "first set data source, then set objectID field
    CLEAR update_node_line.
    CLEAR update_node.
    MOVE-CORRESPONDING node_data[ 1 ] TO update_node_line.
    update_node_line-%tky = VALUE #(  %is_draft = if_abap_behv=>mk-on NodeUUID = my_rootnodeuuid ).
    APPEND update_node_line TO update_node.

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE FIELDS (
                               DataSource
                             ) WITH update_node
           FAILED   failed
           REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "add child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbonode
        EXECUTE addChild2
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_rootnodeuuid )
                              %param-entity_name = node_data[ 2 ]-EntityName
          ) )
      MAPPED   mapped
      FAILED   failed
      REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

    DATA(my_childnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.

    "set fields for child node
    "first set data source, then set objectID field
    CLEAR update_node_line.
    CLEAR update_node.
    MOVE-CORRESPONDING node_data[ 2 ] TO update_node_line.
    update_node_line-%tky = VALUE #(  %is_draft = if_abap_behv=>mk-on NodeUUID = my_childnodeuuid ).
    APPEND update_node_line TO update_node.

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE FIELDS (
                            DataSource
                          ) WITH update_node
        FAILED   failed
        REPORTED reported.

    "cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    IF  node_data[ 2 ]-FieldNameEtagMaster IS NOT INITIAL.

      CLEAR update_node_line.
      CLEAR update_node.
      MOVE-CORRESPONDING node_data[ 2 ] TO update_node_line.
      update_node_line-FieldNameEtagMaster =  node_data[ 2 ]-FieldNameEtagMaster.
      update_node_line-%tky = VALUE #(  %is_draft = if_abap_behv=>mk-on NodeUUID = my_childnodeuuid ).
      APPEND update_node_line TO update_node.

      MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
             ENTITY RAPGeneratorBONode
                   UPDATE FIELDS (
                              FieldNameEtagMaster
                            ) WITH update_node
          FAILED   failed
          REPORTED reported.

      "cl_abap_unit_assert=>assert_initial( msg = 'failed to set etag master'   act = failed ).
      "cl_abap_unit_assert=>assert_initial( msg = 'reported to set etag master' act = reported ).

    ENDIF.

    "activate instance
    MODIFY ENTITY ZDMO_r_rapgeneratorbo
        EXECUTE
            Activate FROM VALUE #( ( %key-RapNodeUUID = my_rapnodeuuid ) )
        MAPPED DATA(mapped_active)
        FAILED DATA(failed_active)
        REPORTED DATA(reported_active).

    "cl_abap_unit_assert=>assert_initial( msg = 'failed_active'   act = failed_active ).
    "cl_abap_unit_assert=>assert_initial( msg = 'reported_active' act = reported_active ).
    "cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbo' act = mapped_active-rapgeneratorbo ).

    "commit data
    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    "cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    "cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    "check committed data

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    "cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).

    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).

    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    "cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).
    "cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).

*    "generate repository objects
*    MODIFY ENTITY ZDMO_r_rapgeneratorbo
*        EXECUTE
*            createBO FROM VALUE #( (
*                                                %tky = VALUE #(  %is_draft = if_abap_behv=>mk-off
*                                                rapNodeUUID = my_rapnodeuuid )
**             %key-RapNodeUUID = my_rapnodeuuid
*             ) )
*        MAPPED mapped
*        FAILED failed
*        REPORTED reported.
*
*    "cl_abap_unit_assert=>assert_initial( msg = 'failed - generate objects' act = failed ).
*    "cl_abap_unit_assert=>assert_initial( msg = 'reported - generate objects' act = reported ).
*
*    COMMIT ENTITIES RESPONSES
*           FAILED   DATA(commit_failed2)
*           REPORTED DATA(commit_reported2).
*
*    "cl_abap_unit_assert=>assert_initial( msg = 'failed2 - generate objects' act = commit_failed2 ).
*    "cl_abap_unit_assert=>assert_initial( msg = 'reported2 - generate objects' act = commit_reported2 ).
*
*
*


    et_parameters = VALUE #(
       ( selname = zdmo_cl_rap_node=>job_selection_name
         kind = if_apj_dt_exec_object=>parameter
         sign = 'I'
         option = 'EQ'
         low = rapbo-BoName )
     ).

    TRY.
        DATA rap_job TYPE REF TO zdmo_cl_rap_gen_in_background.

        rap_job = NEW #(  ).


        rap_job->if_apj_rt_exec_object~execute( it_parameters = et_parameters ).
      CATCH cx_apj_rt_content INTO DATA(job_exception).

    ENDTRY.

  ENDMETHOD.


  METHOD create_unmanaged_abstract.


    DATA : bo_data       TYPE tt_bo_data,
           node_data     TYPE tt_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                             PackageName         = packagenameforalltests
                             Prefix              = 'A_'
                             Suffix              = suffixforalltests
                             ImplementationType  = zdmo_cl_rap_node=>implementation_type-unmanaged_semantic
                             BindingType         = zdmo_cl_rap_node=>binding_type_name-odata_v2_ui
                             DataSourceType      = zdmo_cl_rap_node=>data_source_types-abstract_entity
                             DraftEnabled        = abap_FALSE
                              TransportRequest    = ''
                         )
                         ).

    node_data = VALUE #( (
                          entityname        = |SalesOrder|
                          DataSource        = 'ZDMO_TEST_ABSTRACT_ROOT_ENTITY'
                       )
                       (
                          entityname        = |Item|
                          DataSource        = 'ZDMO_TEST_ABSTRACT_CHILDENTITY'
                          FieldNameEtagMaster = 'DELIVERYDATE'
                       )
                       ).

    create_two_level_semantic(
      i_bo_data   = bo_data
      i_node_data = node_data
    ).


  ENDMETHOD.


  METHOD create_unmanaged_semantic.

    DATA : bo_data       TYPE tt_bo_data,
           node_data     TYPE tt_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                             PackageName         = packagenameforalltests
                             Prefix              = 'U_'
                             Suffix              = suffixforalltests
                             ImplementationType  = zdmo_cl_rap_node=>implementation_type-unmanaged_semantic
                             BindingType         = zdmo_cl_rap_node=>binding_type_name-odata_v2_ui
                             DataSourceType      = zdmo_cl_rap_node=>data_source_types-table
                             DraftEnabled        = abap_FALSE
                              TransportRequest    = ''
                         )
                         ).

    node_data = VALUE #( (
                          entityname        = |Holiday|
                          DataSource        = 'ZDMO_fcal_holi'
                       )
                       (
                          entityname        = |HolidayText|
                          DataSource        = 'ZDMO_fcal_holi_t'
                       )
                       ).

    create_two_level_semantic(
      i_bo_data   = bo_data
      i_node_data = node_data
    ).


  ENDMETHOD.


  METHOD get_json_string.
    json_string = '{ "Info" : "to be replaced with your JSON string" }' .
  ENDMETHOD.


  METHOD main.


    out->write( 'start' ).
    wait up to 10 seconds.
    out->write( 'finish' ).
    EXIT.
    PackageNameForAllTests = 'ZDMO_DELETE_TESTS_EML3'.
    suffixForAllTests      = '_35'  .
    running_in_test_mode = abap_false.

    TRY.

        out->write( 'run create_managed_semantic' ).
        create_managed_semantic( ).
        out->write( |waiting { wait_time_in_seconds } seconds| ).
        WAIT UP TO wait_time_in_seconds SECONDS.

        out->write( 'run create_managed_uuid' ).
        create_managed_uuid(  ).
        out->write( |waiting { wait_time_in_seconds } seconds| ).
        WAIT UP TO wait_time_in_seconds SECONDS.

        out->write( 'run create_managed_uuid_o2' ).
        create_managed_uuid_o2(  ).
        out->write( |waiting { wait_time_in_seconds } seconds| ).
        WAIT UP TO wait_time_in_seconds SECONDS.

        out->write( 'run create_unmanaged_abstract' ).
        create_unmanaged_abstract(  ).
        out->write( |waiting { wait_time_in_seconds } seconds| ).
        WAIT UP TO wait_time_in_seconds SECONDS.

        out->write( 'run create_unmanaged_semantic' ).
        create_unmanaged_semantic(  ).


      CATCH ZDMO_cx_rap_generator INTO DATA(rap_generator_exception).
        out->write( 'The following exception has been raised:' ) .
        out->write( rap_generator_exception->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
