"! @testing BDEF:ZDMO_I_RAPGENERATORBO
CLASS zdmo_tc_rap_gen_bo_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC

  FOR TESTING
   RISK LEVEL HARMLESS
   DURATION LONG.

  PUBLIC SECTION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA:
      generate_repository_objects TYPE abap_bool VALUE abap_false,
      running_in_test_mode        TYPE abap_bool,
      cds_test_environment        TYPE REF TO if_cds_test_environment,
      sql_test_environment        TYPE REF TO if_osql_test_environment,
      PackageNameForAllTests      TYPE sxco_package,
      suffixForAllTests           TYPE sxco_ar_object_name.

*      ,
*      running_in_test_mode TYPE abap_bool VALUE abap_false
*     ,
*      <test>_mock_data     TYPE STANDARD TABLE OF <test>

    .
    CLASS-METHODS:
*      running_in_test_mode RETURNING VALUE(r_running_in_test_mode) TYPE abap_bool,
      " setup test double framework
      class_setup,
      " stop test doubles
      class_teardown.

    TYPES : tt_bo_data   TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbo,
            tt_node_data TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbonode.

    TYPES : t_bo_data   TYPE  ZDMO_r_rapgeneratorbo,
            t_node_data TYPE  ZDMO_r_rapgeneratorbonode.

    TYPES t_mapped  TYPE RESPONSE FOR MAPPED EARLY zdmo_r_rapgeneratorbo.
    TYPES t_failed TYPE RESPONSE FOR FAILED EARLY zdmo_r_rapgeneratorbo.
    TYPES t_reported TYPE RESPONSE FOR REPORTED EARLY zdmo_r_rapgeneratorbo.

    DATA mapped TYPE t_mapped.
    DATA failed TYPE t_failed.
    DATA reported TYPE t_reported.

    DATA update_node TYPE TABLE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbonode.
    DATA update_rapbo TYPE TABLE FOR UPDATE ZDMO_R_RapGeneratorBO\\RAPGeneratorBO.

    DATA update_node_line TYPE STRUCTURE FOR UPDATE zdmo_r_rapgeneratorbo\\rapgeneratorbonode .
    DATA update_rapbo_line TYPE STRUCTURE FOR UPDATE zdmo_r_rapgeneratorbo\\RAPGeneratorBO.

    METHODS:
      " reset test doubles
      setup,
      " rollback any changes
      teardown,
      " CUT: deep create different RAP BOs with action call and commit

      create_managed_uuid FOR TESTING RAISING cx_static_check,

      create_managed_semantic FOR TESTING RAISING cx_static_check,

      create_unmanaged_semantic FOR TESTING RAISING cx_static_check,

      create_unmanaged_abstract FOR TESTING RAISING cx_static_check,

      create_managed_uuid_O2 FOR TESTING RAISING cx_static_check,

      create_three_level_uuid
        IMPORTING i_bo_data   TYPE tt_bo_data
                  i_node_data TYPE tt_node_data,

      create_two_level_semantic
        IMPORTING i_bo_data   TYPE tt_bo_data
                  i_node_data TYPE tt_node_data.




    .

ENDCLASS.



CLASS ZDMO_TC_RAP_GEN_BO_EML IMPLEMENTATION.


  METHOD class_setup.

    PackageNameForAllTests = 'ZDMO_DELETE_TESTS_EML2'.
    suffixForAllTests      = '_25'  .

    running_in_test_mode = abap_false.
    IF running_in_test_mode = abap_true.


      " Create the test doubles for the underlying CDS entities
      cds_test_environment = cl_cds_test_environment=>create_for_multiple_cds(
                        i_for_entities = VALUE #(
                          ( i_for_entity = 'ZDMO_I_RAPGENERATORBO' )
                          ( i_for_entity = 'ZDMO_I_RAPGENERATORBONODE'  ) ) ).
      " create test doubles for additional used (draft) tables.
      sql_test_environment = cl_osql_test_environment=>create(
          i_dependency_list = VALUE #(
          ( 'ZDMO_rapgener00d' )
          ( 'ZDMO_rapgener01d' )  ) ).
      " prepare the test data
*    <test>_mock_data   = VALUE #( ( column1 = 'a' column2 = 'b' ) ).

    ENDIF.

  ENDMETHOD.


  METHOD class_teardown.
    IF running_in_test_mode = abap_true.
      " remove test doubles
      cds_test_environment->destroy(  ).
      sql_test_environment->destroy(  ).
    ENDIF.
  ENDMETHOD.


  METHOD create_managed_semantic.


    DATA : bo_data       TYPE tt_bo_data,
           node_data     TYPE tt_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                             PackageName         = packagenameforalltests
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
    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    " expect a newly created record in mapped tables
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbo'  act = mapped-rapgeneratorbo  ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).


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
                          ImplementationType
                          DataSourceType
                          BindingType
                          DraftEnabled
                           TransportRequest
                         ) WITH update_rapbo
       FAILED   failed
       REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed to set bo header data'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported to set bo header data' act = reported ).


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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE FIELDS (
                               FieldNameObjectID
                             ) WITH update_node
           FAILED   failed
           REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE FIELDS (
                               FieldNameObjectID
                             ) WITH update_node
           FAILED   failed
           REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).


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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

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

    cl_abap_unit_assert=>assert_initial( msg = 'failed_active'   act = failed_active ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported_active' act = reported_active ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbo' act = mapped_active-rapgeneratorbo ).

    "commit data
    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    "check committed data

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).

    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).

    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).
    cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).

    "generate repository objects
    MODIFY ENTITY ZDMO_r_rapgeneratorbo
        EXECUTE
            createBO FROM VALUE #( (
                                                %tky = VALUE #(  %is_draft = if_abap_behv=>mk-off
                                                rapNodeUUID = my_rapnodeuuid )
*             %key-RapNodeUUID = my_rapnodeuuid
             ) )
        MAPPED mapped
        FAILED failed
        REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed - generate objects' act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported - generate objects' act = reported ).

    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed2)
           REPORTED DATA(commit_reported2).

    cl_abap_unit_assert=>assert_initial( msg = 'failed2 - generate objects' act = commit_failed2 ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported2 - generate objects' act = commit_reported2 ).



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
    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    " expect a newly created record in mapped tables
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbo'  act = mapped-rapgeneratorbo  ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).


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

    cl_abap_unit_assert=>assert_initial( msg = 'failed to set bo header data'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported to set bo header data' act = reported ).


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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

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

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

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

      cl_abap_unit_assert=>assert_initial( msg = 'failed to set etag master'   act = failed ).
      cl_abap_unit_assert=>assert_initial( msg = 'reported to set etag master' act = reported ).

    ENDIF.

    "activate instance
    MODIFY ENTITY ZDMO_r_rapgeneratorbo
        EXECUTE
            Activate FROM VALUE #( ( %key-RapNodeUUID = my_rapnodeuuid ) )
        MAPPED DATA(mapped_active)
        FAILED DATA(failed_active)
        REPORTED DATA(reported_active).

    cl_abap_unit_assert=>assert_initial( msg = 'failed_active'   act = failed_active ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported_active' act = reported_active ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbo' act = mapped_active-rapgeneratorbo ).

    "commit data
    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    "check committed data

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).

    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).

    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).
    cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).

    "generate repository objects
    MODIFY ENTITY ZDMO_r_rapgeneratorbo
        EXECUTE
            createBO FROM VALUE #( (
                                                %tky = VALUE #(  %is_draft = if_abap_behv=>mk-off
                                                rapNodeUUID = my_rapnodeuuid )
*             %key-RapNodeUUID = my_rapnodeuuid
             ) )
        MAPPED mapped
        FAILED failed
        REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed - generate objects' act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported - generate objects' act = reported ).

    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed2)
           REPORTED DATA(commit_reported2).

    cl_abap_unit_assert=>assert_initial( msg = 'failed2 - generate objects' act = commit_failed2 ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported2 - generate objects' act = commit_reported2 ).




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


  METHOD setup.

    IF running_in_test_mode = abap_true.

      " clear the test doubles per test
      cds_test_environment->clear_doubles(  ).
      sql_test_environment->clear_doubles(  ).
      " insert test data into test doubles
*    sql_test_environment->insert_test_data( <test>_mock_data   ).

    ENDIF.
  ENDMETHOD.


  METHOD teardown.
    IF running_in_test_mode = abap_true.

      " clean up any involved entity
      ROLLBACK ENTITIES.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
