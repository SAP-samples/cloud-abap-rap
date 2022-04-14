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
      running_in_test_mode   TYPE abap_bool,
      cds_test_environment   TYPE REF TO if_cds_test_environment,
      sql_test_environment   TYPE REF TO if_osql_test_environment,
      PackageNameForAllTests TYPE sxco_package,
      suffixForAllTests      TYPE sxco_ar_object_name.
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

    TYPES : t_bo_data   TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbo,
            t_node_data TYPE STANDARD TABLE OF ZDMO_r_rapgeneratorbonode.

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

      create_business_configuration FOR TESTING RAISING cx_static_check.

ENDCLASS.



CLASS ZDMO_TC_RAP_GEN_BO_EML IMPLEMENTATION.


  METHOD class_setup.

    PackageNameForAllTests = 'Z_D041615'.
    suffixForAllTests      = ''  .

    running_in_test_mode = abap_false.
    IF running_in_test_mode = abap_false.
      EXIT.
    ENDIF.
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


  ENDMETHOD.


  METHOD class_teardown.
    IF running_in_test_mode = abap_false.
      EXIT.
    ENDIF.
    " remove test doubles
    cds_test_environment->destroy(  ).
    sql_test_environment->destroy(  ).
  ENDMETHOD.


  METHOD setup.

    IF running_in_test_mode = abap_false.
      EXIT.
    ENDIF.
    " clear the test doubles per test
    cds_test_environment->clear_doubles(  ).
    sql_test_environment->clear_doubles(  ).
    " insert test data into test doubles
*    sql_test_environment->insert_test_data( <test>_mock_data   ).

  ENDMETHOD.


  METHOD teardown.
    IF running_in_test_mode = abap_false.
      EXIT.
    ENDIF.
    " clean up any involved entity
    ROLLBACK ENTITIES.
  ENDMETHOD.


  METHOD create_managed_semantic.


    DATA : bo_data       TYPE t_bo_data,
           node_data     TYPE t_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                             ABAPLanguageVersion = 'abap_for_cloud_development'
                             ImplementationType = 'managed_semantic'
                             PackageName         = packagenameforalltests
                             Suffix              = suffixforalltests
                         )
                         ).

    node_data = VALUE #( (
                          entityname        = |HolidayText123456789|
                          DataSource        = 'ZDMO_fcal_holi'
                       )
                       (
                          entityname        = |HolidayText123456789|
                          parententityname        = |Holiday|
                          DataSource        = 'ZDMO_fcal_holi_t'
                       )
                       ).

    "create BO and root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbo
        EXECUTE createBOandRootNode
          FROM VALUE #( (

          %cid = 'ROOT1'
          %param-entity_name = node_data[ 1 ]-EntityName
*          %param-language_version = bo_data[ 1 ]-ABAPLanguageVersion
          %param-package_name = bo_data[ 1 ]-PackageName

          ) )
             " check result
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

    "add suffix and set datasource for root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY RAPGeneratorBO
    UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            RapNodeUUID = my_rapnodeuuid )
                          Suffix = bo_data[ 1 ]-Suffix
                          ImplementationType = bo_data[ 1 ]-ImplementationType
                     ) )
       ENTITY RAPGeneratorBONode
             UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            NodeUUID = my_rootnodeuuid )
                          DataSource = node_data[ 1 ]-DataSource
                     ) )
      " check result
          FAILED   failed
          REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "add child node Holiday Text
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbonode
        EXECUTE addChild2
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_rootnodeuuid )
                              %param-entity_name = node_data[ 2 ]-EntityName
          ) )
             " check result
      MAPPED   mapped
      FAILED   failed
      REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

    DATA(my_childnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.

    "Set data source for child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE SET FIELDS WITH
                  VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_childnodeuuid )
                              DataSource = node_data[ 2 ]-DataSource
                         ) )
          " check result
              FAILED   failed
              REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed - Set data source for child node'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported - Set data source for child node' act = reported ).



*    READ ENTITIES OF ZDMO_r_rapgeneratorbo
*    ENTITY rapgeneratorbo
*    ALL FIELDS WITH  VALUE #( ( RapNodeUUID = my_rapnodeuuid %is_draft = if_abap_behv=>mk-on ) )
*    RESULT DATA(rapbos)
*      FAILED DATA(failed_read)
*      REPORTED DATA(reported_read).

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


    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).


    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).

    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).

    cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).



  ENDMETHOD.


  METHOD create_managed_uuid.

    DATA : bo_data       TYPE t_bo_data,
           node_data     TYPE t_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                         ABAPLanguageVersion = 'abap_for_cloud_development'
                         PackageName         = packagenameforalltests
                         Suffix              = suffixforalltests
                     )
                     ).

    node_data = VALUE #( (
                          entityname        = |TEST123456789SW1234567821|
                          DataSource        = '/DMO/A_TRAVEL_D'
                          FieldNameObjectID = 'TRAVEL_ID'
                       )
                       (

                          entityname        = |TEST123456789SW1234567821i|
                          parententityname        = |Travel|
                          DataSource        = '/DMO/A_BOOKING_D'
                          FieldNameObjectID = 'BOOKING_ID'
                       )
                        (
                          entityname        = |TEST123456789SW1234567821k|
                          parententityname        = |Travel|
                          DataSource        = '/DMO/A_BOOKING_D'
                          FieldNameObjectID = 'BOOKING_ID'
                       )
                       ).

    DATA(add_child) = abap_false.

    "create BO and root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbo
        EXECUTE createBOandRootNode
          FROM VALUE #( (

          %cid = 'ROOT1'
          %param-entity_name = node_data[ 1 ]-EntityName
*          %param-language_version = bo_data[ 1 ]-ABAPLanguageVersion
          %param-package_name = bo_data[ 1 ]-PackageName

          ) )
             " check result
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

    "add suffix and set datasource for root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY RAPGeneratorBO
    UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            RapNodeUUID = my_rapnodeuuid )
                          Suffix = bo_data[ 1 ]-Suffix
                     ) )
       ENTITY RAPGeneratorBONode
             UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            NodeUUID = my_rootnodeuuid )
                          DataSource = node_data[ 1 ]-DataSource
                     ) )
      " check result
          FAILED   failed
          REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "add semantic key for root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE SET FIELDS WITH
                  VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_rootnodeuuid )
                              FieldNameObjectID = node_data[ 1 ]-FieldNameObjectID
                         ) )
              FAILED   failed
              REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "add child node Booking
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbonode
        EXECUTE addChild2
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_rootnodeuuid )
                              %param-entity_name = node_data[ 2 ]-EntityName
          ) )
             " check result
      MAPPED   mapped
      FAILED   failed
      REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

    DATA(my_childnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.

    "Set data source for child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE SET FIELDS WITH
                  VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_childnodeuuid )
                              DataSource = node_data[ 2 ]-DataSource
                         ) )
          " check result
              FAILED   failed
              REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed - Set data source for child node'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported - Set data source for child node' act = reported ).


    "set semantic key for child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
              ENTITY RAPGeneratorBONode
                    UPDATE SET FIELDS WITH
                     VALUE #( (
                                 %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                   NodeUUID = my_childnodeuuid )
                                 FieldNameObjectID = node_data[ 2 ]-FieldNameObjectID
                            ) )
                 FAILED   failed
                 REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed - set semantic key for child node'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported - set semantic key for child node' act = reported ).


    READ ENTITIES OF ZDMO_r_rapgeneratorbo
    ENTITY rapgeneratorbo
    ALL FIELDS WITH  VALUE #( ( RapNodeUUID = my_rapnodeuuid %is_draft = if_abap_behv=>mk-on ) )
    RESULT DATA(rapbos)
      FAILED DATA(failed_read)
      REPORTED DATA(reported_read).

    "activate instance
    MODIFY ENTITY ZDMO_r_rapgeneratorbo
        EXECUTE
            Activate FROM VALUE #( ( %key-RapNodeUUID = my_rapnodeuuid ) )
        MAPPED DATA(mapped_active)
        FAILED DATA(failed_active)
        REPORTED DATA(reported_active).

    cl_abap_unit_assert=>assert_initial( msg = 'failed_active'   act = failed_active ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported_active' act = reported_active ).

*    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbonode' act = mapped_active-rapgeneratorbonode ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbo' act = mapped_active-rapgeneratorbo ).


    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).

    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).

    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).

    cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).


  ENDMETHOD.


  METHOD create_unmanaged_abstract.

  ENDMETHOD.


  METHOD create_unmanaged_semantic.

    DATA : bo_data       TYPE t_bo_data,
           node_data     TYPE t_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                             ABAPLanguageVersion = 'abap_for_cloud_development'
                             ImplementationType = 'unmanaged_semantic'
                             PackageName         = packagenameforalltests
                             Suffix              = suffixforalltests
                         )
                         ).

    node_data = VALUE #( (
                          entityname        = |Travel|
                          DataSource        = 'ZDMO_travel'
                       )
                       (
                          entityname        = |Booking|
                          parententityname        = |Travel|
                          DataSource        = 'ZDMO_booking'
                       )
                       ).

    "create BO and root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbo
        EXECUTE createBOandRootNode
          FROM VALUE #( (

          %cid = 'ROOT1'
          %param-entity_name = node_data[ 1 ]-EntityName
*          %param-language_version = bo_data[ 1 ]-ABAPLanguageVersion
          %param-package_name = bo_data[ 1 ]-PackageName

          ) )
             " check result
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

    "add suffix and set datasource for root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY RAPGeneratorBO
    UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            RapNodeUUID = my_rapnodeuuid )
                          Suffix = bo_data[ 1 ]-Suffix
                          ImplementationType = bo_data[ 1 ]-ImplementationType
                     ) )
       ENTITY RAPGeneratorBONode
             UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            NodeUUID = my_rootnodeuuid )
                          DataSource = node_data[ 1 ]-DataSource
                     ) )
      " check result
          FAILED   failed
          REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "add child node Holiday Text
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbonode
        EXECUTE addChild2
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_rootnodeuuid )
                              %param-entity_name = node_data[ 2 ]-EntityName
          ) )
             " check result
      MAPPED   mapped
      FAILED   failed
      REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

    DATA(my_childnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.

    "Set data source for child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE SET FIELDS WITH
                  VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_childnodeuuid )
                              DataSource = node_data[ 2 ]-DataSource
                         ) )
          " check result
              FAILED   failed
              REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed - Set data source for child node'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported - Set data source for child node' act = reported ).



*    READ ENTITIES OF ZDMO_r_rapgeneratorbo
*    ENTITY rapgeneratorbo
*    ALL FIELDS WITH  VALUE #( ( RapNodeUUID = my_rapnodeuuid %is_draft = if_abap_behv=>mk-on ) )
*    RESULT DATA(rapbos)
*      FAILED DATA(failed_read)
*      REPORTED DATA(reported_read).

    "activate instance
    MODIFY ENTITY ZDMO_r_rapgeneratorbo
        EXECUTE
            Activate FROM VALUE #( ( %key-RapNodeUUID = my_rapnodeuuid ) )
        MAPPED DATA(mapped_active)
        FAILED DATA(failed_active)
        REPORTED DATA(reported_active).

    cl_abap_unit_assert=>assert_initial( msg = 'failed_active'   act = failed_active ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported_active' act = reported_active ).

*    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbonode' act = mapped_active-rapgeneratorbonode ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped_active-rapgeneratorbo' act = mapped_active-rapgeneratorbo ).


    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).

    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).


    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).

    cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).


  ENDMETHOD.


  METHOD create_business_configuration.

    DATA : bo_data       TYPE t_bo_data,
           node_data     TYPE t_node_data,
           unique_string TYPE string VALUE 'f7nkQ'.

    bo_data = VALUE #( (
                             ABAPLanguageVersion = 'abap_for_cloud_development'
                             ImplementationType = 'managed_semantic'
                             PackageName         = packagenameforalltests
                             Suffix              = suffixforalltests
                             MultiInlineEdit  = abap_true
                             CustomizingTable =  abap_true
                             AddToManageBusinessConfig =  abap_true

                         )
                         ).

    node_data = VALUE #( (
                          entityname        = |Holiday|
                          DataSource        = 'ZDMO_fcal_holi'
                       )
                       (
                          entityname        = |HolidayText|
                          parententityname        = |Holiday|
                          DataSource        = 'ZDMO_fcal_holi_t'
                       )
                       ).

    "create BO and root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbo
        EXECUTE createBOandRootNode
          FROM VALUE #( (

          %cid = 'ROOT1'
          %param-entity_name = node_data[ 1 ]-EntityName
*          %param-language_version = bo_data[ 1 ]-ABAPLanguageVersion
          %param-package_name = bo_data[ 1 ]-PackageName

          ) )
             " check result
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

    "add suffix and set datasource for root node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY RAPGeneratorBO
    UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            RapNodeUUID = my_rapnodeuuid )
                          Suffix = bo_data[ 1 ]-Suffix
                          ImplementationType = bo_data[ 1 ]-ImplementationType
                          MultiInlineEdit = bo_data[ 1 ]-MultiInlineEdit
                          CustomizingTable =  bo_data[ 1 ]-CustomizingTable
                          AddToManageBusinessConfig =  bo_data[ 1 ]-AddToManageBusinessConfig
                     ) )
       ENTITY RAPGeneratorBONode
             UPDATE SET FIELDS WITH
              VALUE #( (
                          %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                            NodeUUID = my_rootnodeuuid )
                          DataSource = node_data[ 1 ]-DataSource
                     ) )
      " check result
          FAILED   failed
          REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    "add child node Holiday Text
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
      ENTITY rapgeneratorbonode
        EXECUTE addChild2
          FROM VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_rootnodeuuid )
                              %param-entity_name = node_data[ 2 ]-EntityName
          ) )
             " check result
      MAPPED   mapped
      FAILED   failed
      REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported' act = reported ).

    cl_abap_unit_assert=>assert_not_initial( msg = 'mapped-rapgeneratorbonode' act = mapped-rapgeneratorbonode ).

    DATA(my_childnodeuuid) = mapped-rapgeneratorbonode[ 1 ]-NodeUUID.

    "Set data source for child node
    MODIFY ENTITIES OF ZDMO_r_rapgeneratorbo
           ENTITY RAPGeneratorBONode
                 UPDATE SET FIELDS WITH
                  VALUE #( (
                              %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                NodeUUID = my_childnodeuuid )
                              DataSource = node_data[ 2 ]-DataSource
                         ) )
          " check result
              FAILED   failed
              REPORTED reported.

    cl_abap_unit_assert=>assert_initial( msg = 'failed - Set data source for child node'   act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'reported - Set data source for child node' act = reported ).



*    READ ENTITIES OF ZDMO_r_rapgeneratorbo
*    ENTITY rapgeneratorbo
*    ALL FIELDS WITH  VALUE #( ( RapNodeUUID = my_rapnodeuuid %is_draft = if_abap_behv=>mk-on ) )
*    RESULT DATA(rapbos)
*      FAILED DATA(failed_read)
*      REPORTED DATA(reported_read).

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


    COMMIT ENTITIES RESPONSES
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'   act = commit_failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'commit_reported' act = commit_reported ).

    SELECT SINGLE * FROM ZDMO_r_rapgeneratorbo WHERE RapNodeUUID = @my_rapnodeuuid INTO @DATA(rapbo).

    cl_abap_unit_assert=>assert_not_initial( msg = 'No RAP BO found' act = rapbo ).


    SELECT * FROM ZDMO_r_rapgeneratorbonode  WHERE HeaderUUID = @rapbo-RapNodeUUID INTO TABLE @DATA(rapbonodes).

    DATA(number_of_entities) = lines( rapbonodes ).
    DATA(expected_number_of_entities) = lines( node_data ).

    cl_abap_unit_assert=>assert_equals( act = rapbonodes[ 1 ]-HeaderUUID exp = rapbo-RapNodeUUID ).

    cl_abap_unit_assert=>assert_equals( act = number_of_entities exp = expected_number_of_entities ).


  ENDMETHOD.
ENDCLASS.
