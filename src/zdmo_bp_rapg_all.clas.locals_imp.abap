CLASS lhc_Project DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Project RESULT result.

    METHODS createProjectAndRootNode FOR MODIFY
      IMPORTING keys FOR ACTION Project~createProjectAndRootNode RESULT result.

    METHODS CalculateBoName FOR DETERMINE ON SAVE
      IMPORTING keys FOR Project~CalculateBoName.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Project RESULT result.

    METHODS copyProject FOR MODIFY
      IMPORTING keys FOR ACTION Project~copyProject RESULT result.

    METHODS deleteProject FOR MODIFY
      IMPORTING keys FOR ACTION Project~deleteProject RESULT result.

    METHODS generateProject FOR MODIFY
      IMPORTING keys FOR ACTION Project~generateProject RESULT result.

    METHODS SetRepositoryObjectNames FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Project~SetRepositoryObjectNames.
    METHODS createJsonString FOR DETERMINE ON SAVE
      IMPORTING keys FOR Project~createJsonString.
    METHODS generated_objects_are_deleted FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~generated_objects_are_deleted.
    METHODS mandatory_fields_check FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~mandatory_fields_check.
    METHODS is_customizing_table FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~is_customizing_table.
    METHODS check_for_allowed_combinations FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~check_for_allowed_combinations.
    METHODS rap_gen_project_objects_exist
      IMPORTING
        i_rap_generator_project           TYPE ZDMO_R_RAPG_ProjectTP
      RETURNING
        VALUE(r_repository_objects_exist) TYPE abap_bool.
ENDCLASS.

CLASS lhc_Project IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createProjectAndRootNode.

    CONSTANTS mycid_rapbonode TYPE abp_behv_cid VALUE 'My%CID_rapbonode' ##NO_TEXT.

    DATA update_rapbo TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP.
    DATA update_rapbonode TYPE TABLE FOR UPDATE ZDMO_R_RAPG_NodeTP.

    DATA create_rapbonode_cba TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Node.
    DATA create_rapbo TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP.

    DATA create_rapbonode_cba_line TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Node.
    DATA create_rapbo_line TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_ProjectTP.

    DATA object_name TYPE if_xco_gen_o_finding=>tv_object_name .
    DATA abap_object_directory_entry  TYPE zdmo_cl_rap_xco_lib=>t_abap_obj_directory_entry  .
    DATA package_name TYPE zdmo_cl_rap_xco_lib=>t_abap_obj_directory_entry-ABAPPackage.
    DATA object_type TYPE zdmo_cl_rap_xco_lib=>t_abap_obj_directory_entry-ABAPObjectType.
    DATA object_category TYPE zdmo_cl_rap_xco_lib=>t_abap_obj_directory_entry-ABAPObjectCategory.

    DATA has_semantic_key TYPE abap_bool.
    DATA is_managed TYPE abap_bool.
    DATA does_not_use_unmanaged_query TYPE abap_bool.

    DATA(xco_lib) = zdmo_cl_rap_xco_lib=>create_xco_lib( ).




*    IF xco_lib->on_premise_branch_is_used(  ) = abap_true.
*      DATA(abap_language_version) = zdmo_cl_rap_node=>abap_language_version-standard.
*    ELSE.
*      abap_language_version = zdmo_cl_rap_node=>abap_language_version-abap_for_cloud_development.
*    ENDIF.

*    DATA xco_lib TYPE REF TO zdmo_cl_rap_xco_lib.
*    DATA(xco_on_prem_library) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
**    DATA(xco_cloud_library) = NEW zdmo_cl_rap_xco_cloud_lib(  ).
*    DATA(node) = NEW ZDMO_cl_rap_node(  ).
*    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
*      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
*      node->set_xco_lib( xco_lib ).
*      DATA(abap_language_version) = zdmo_cl_rap_node=>abap_language_version-standard.
*    ELSE.
*      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
*      node->set_xco_lib( xco_lib ).
*      abap_language_version = zdmo_cl_rap_node=>abap_language_version-abap_for_cloud_development.
*    ENDIF.



    LOOP AT keys INTO DATA(ls_key).

      TRY.
          "dummy fix
          DATA(node) = NEW ZDMO_cl_rap_node( xco_lib ) .

          "get package of datasource

          object_name = ls_key-%param-data_source_name.

          DATA(data_source_type) = ls_key-%param-DataSourceType.

          CASE data_source_type.
            WHEN zdmo_cl_rap_node=>data_source_types-table.
              object_category = 'TABL'.
              object_type = 'R3TR'.
            WHEN zdmo_cl_rap_node=>data_source_types-cds_view.
              object_category = 'DDLS'.
              object_type = 'R3TR'.
            WHEN zdmo_cl_rap_node=>data_source_types-abstract_entity.
              object_category = 'DDLS'.
              object_type = 'R3TR'.
            WHEN OTHERS.
              "@todo raise exception
          ENDCASE.

          xco_lib->get_abap_obj_directory_entry(
                   EXPORTING
                     i_abap_object_type            = object_category
                     i_abap_object_category        = object_type
                     i_abap_object                 = object_name
                   RECEIVING
                     r_abap_object_directory_entry = abap_object_directory_entry
                 ).

*      package_name = abap_object_directory_entry-ABAPPackage.

          package_name = ls_key-%param-package_name.

          "get transport request
          node->set_package( package_name ).
          node->set_namespace(  ).
          node->set_transport_request(  ).
          node->set_data_source_type( CONV #( ls_key-%param-DataSourceType ) ).
          node->set_data_source( CONV #( ls_key-%param-data_source_name ) ).
*

        CATCH zdmo_cx_rap_generator INTO DATA(fill_node_object_exception).
          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-project.
          APPEND VALUE #( %cid = ls_key-%cid
*                        %state_area   = 'VALIDATE_QUANTITY'
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = fill_node_object_exception->get_text( ) )
                        ) TO reported-project.
          RETURN.
      ENDTRY.

      IF ls_key-%param-DataSourceType = zdmo_cl_rap_node=>data_source_types-abstract_entity.
        does_not_use_unmanaged_query = abap_false.
      ELSE.
        does_not_use_unmanaged_query = abap_true.
      ENDIF.

      CASE ls_key-%param-BdefImplementationType.
        WHEN zdmo_cl_rap_node=>bdef_implementation_type-managed.
          is_managed = abap_true.
          IF node->is_uuid_based(  ).         .
            DATA(implementation_type) = zdmo_cl_rap_node=>implementation_type-managed_uuid.
          ELSE.
            implementation_type = zdmo_cl_rap_node=>implementation_type-managed_semantic.
            has_semantic_key = abap_true.
          ENDIF.
        WHEN zdmo_cl_rap_node=>bdef_implementation_type-unmanaged.
          implementation_type = zdmo_cl_rap_node=>implementation_type-unmanaged_semantic.
          has_semantic_key = abap_true.
      ENDCASE.

      "make sure that for abstract entities

*      DATA(fields) = node->lt_all_fields.

      DATA(package) = xco_lib->get_package( package_name ).
      DATA(software_compontent) = package->read(  )-property-software_component.
      DATA(abap_language_version_number) = xco_lib->get_abap_language_version( package_name ).

      CASE abap_language_version_number.
        WHEN zdmo_cl_rap_node=>package_abap_language_version-standard.
          DATA(abap_language_version) = zdmo_cl_rap_node=>abap_language_version-standard.
        WHEN zdmo_cl_rap_node=>package_abap_language_version-abap_for_sap_cloud_platform.
          abap_language_version = zdmo_cl_rap_node=>abap_language_version-abap_for_cloud_development.
        WHEN OTHERS.
          "abap language version of package is not supported
          ASSERT 1 = 2.
      ENDCASE.

      create_rapbo_line = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                %cid      = ls_key-%cid
                                rootentityname   = ls_key-%param-EntityName
                                packagename = package_name
                                Namespace = node->namespace
                                abaplanguageversion = abap_language_version "ls_key-%param-language_version
                                PackageLanguageVersion = abap_language_version_number
                                draftenabled = ls_key-%param-DraftEnabled
                                implementationtype = implementation_type
                                datasourcetype = ls_key-%param-DataSourceType
                                BindingType = ls_key-%param-BindingType
                                TransportRequest = node->transport_request
                                "boolean fields to hide / show fields in the UI
                                hasSematicKey    = has_semantic_key
                                doesNotUseUnmanagedQuery = does_not_use_unmanaged_query
                                isManaged = is_managed
                                            ).


      create_rapbonode_cba_line = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                        %cid_ref  = ls_key-%cid
                                        %target   = VALUE #( (
                                                               %is_draft = if_abap_behv=>mk-on
                                                               %cid      = mycid_rapbonode
                                                               entityname = ls_key-%param-entityname
                                                               isrootnode = abap_true
                                                               DataSource = ls_key-%param-data_source_name
                                                               hierarchydistancefromroot = 0
                                                               ) ) ) .


      APPEND create_rapbo_line TO create_rapbo.
      APPEND create_rapbonode_cba_line TO create_rapbonode_cba.

    ENDLOOP.

    MODIFY ENTITIES OF zdmo_r_rapg_projecttp IN LOCAL MODE
            ENTITY Project
            CREATE FIELDS ( rootentityname packagename Namespace
                            abaplanguageversion PackageLanguageVersion
                            draftenabled implementationtype datasourcetype bindingtype
                            hasSematicKey doesNotUseUnmanagedQuery isManaged
                            TransportRequest )
                  WITH create_rapbo
                  CREATE BY \_Node
                  FIELDS ( entityname isrootnode hierarchydistancefromroot DataSource )
                  WITH create_rapbonode_cba
            MAPPED   mapped
            FAILED   failed
            REPORTED reported.

    CHECK mapped-project[] IS NOT INITIAL.

    DATA test_key TYPE STRUCTURE FOR ACTION IMPORT zdmo_r_rapg_projecttp~check_allowed_combinations_det.
    DATA test_keys TYPE TABLE FOR ACTION IMPORT zdmo_r_rapg_projecttp~check_allowed_combinations_det.


    LOOP AT mapped-project INTO DATA(mapped_project).
      APPEND VALUE #( %cid = ls_key-%cid
                      %param = VALUE #( %is_draft = mapped_project-%is_draft
                                        %key      = mapped_project-%key ) ) TO result.
      test_key-RapBoUUID = mapped_project-RapBoUUID.
      test_key-%is_draft = mapped_project-%is_draft.
      APPEND test_key TO test_keys.

    ENDLOOP.


*    MODIFY ENTITIES OF zdmo_r_rapg_projecttp IN LOCAL MODE
*           ENTITY Project
*           EXECUTE check_allowed_combinations_det
*           FROM test_keys
*              MAPPED   mapped
*              FAILED   failed
*              REPORTED reported.

*"set values for node object in global class
*      zdmo_bp_rapg_all=>rap_bo_nodes[ uuid = mapped-project[ 1 ]-%key-RapBoUUID
*
*    DATA rap_bo_node TYPE zdmo_bp_rapg_all=>t_rap_bo_node.
*    TRY.
*        LOOP AT mapped-project INTO mapped_project.
*          rap_bo_node-uuid = mapped_project-RapBoUUID.
*          rap_bo_node-node = node.
*        ENDLOOP.



  ENDMETHOD.

  METHOD CalculateBoName.
  ENDMETHOD.

  METHOD get_instance_features.

    DATA rap_generator_project TYPE ZDMO_R_RAPG_ProjectTP.
    DATA rap_generator_projects TYPE STANDARD TABLE OF ZDMO_R_RAPG_ProjectTP.
    DATA result_line  LIKE LINE OF result  .
    DATA rap_gen_project_objects_exist TYPE abap_bool.

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Project
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).

      MOVE-CORRESPONDING rapbo TO rap_generator_project.

*      DATA(rap_gen_project_objects_exist) = rap_gen_project_objects_exist( rap_generator_project ).


      result_line-%tky = rapbo-%tky.

      "disable EDIT button when
      " - repository objects have already been generated
      " - a job has been scheduled

      IF rap_gen_project_objects_exist = abap_true .
        result_line-%action-edit  = if_abap_behv=>fc-o-disabled.
      ELSE.
        IF  rapbo-jobname IS NOT INITIAL.
          result_line-%action-edit  = if_abap_behv=>fc-o-disabled.
        ELSE.
          result_line-%action-edit  =  if_abap_behv=>fc-o-enabled.
        ENDIF.
      ENDIF.

      result_line-%action-generateProject      = COND #( WHEN rapbo-%is_draft = if_abap_behv=>mk-off AND
                                           rapbo-jobname IS INITIAL
                                      THEN if_abap_behv=>fc-o-enabled
                                      ELSE if_abap_behv=>fc-o-disabled ).
      result_line-%action-copyProject      = COND #( WHEN rapbo-%is_draft = if_abap_behv=>mk-off
                                         THEN if_abap_behv=>fc-o-enabled
                                         ELSE if_abap_behv=>fc-o-disabled ).

      result_line-%field-MultiInlineEdit  = COND #( WHEN rapbo-ImplementationType = zdmo_cl_rap_node=>implementation_type-managed_semantic
                                         AND rapbo-DataSourceType = zdmo_cl_rap_node=>data_source_types-table
                                         AND rapbo-DraftEnabled = abap_true
                                         AND rapbo-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                                        THEN if_abap_behv=>fc-f-unrestricted
                                        ELSE if_abap_behv=>fc-f-read_only ).
      result_line-%field-CustomizingTable = COND #( WHEN rapbo-ImplementationType = zdmo_cl_rap_node=>implementation_type-managed_semantic
                                         AND rapbo-DataSourceType = zdmo_cl_rap_node=>data_source_types-table
                                         AND rapbo-DraftEnabled = abap_true
                                         AND rapbo-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                                        THEN if_abap_behv=>fc-f-unrestricted
                                        ELSE if_abap_behv=>fc-f-read_only ).
      result_line-%field-AddToManageBusinessConfig  = COND #( WHEN rapbo-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui
                                                  THEN if_abap_behv=>fc-f-unrestricted
                                                  ELSE if_abap_behv=>fc-f-read_only ).

*      result_line-%field-ADTLink  = COND #( WHEN rapbo-BoIsGenerated = abap_true
*                                                 THEN if_abap_behv=>fc-f-read_only
*                                                 ELSE if_abap_behv=>fc-f- ).


      APPEND result_line TO result.
    ENDLOOP.



  ENDMETHOD.

  METHOD copyProject.

*
*    DATA:
*      projects       TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\\Project,
*      Nodes_cba  TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\\Project\_Node,
*      fields_cba TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\\Node\_field.
*
**    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_inital_cid).
**    ASSERT key_with_inital_cid IS INITIAL.
*
*    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
*      ENTITY Project
*       ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(Project_read_result)
*    FAILED failed.
*
*    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
*      ENTITY Project BY \_Node
*       ALL FIELDS WITH CORRESPONDING #( Project_read_result )
*     RESULT DATA(book_read_result).
*
*    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
*      ENTITY Node BY \_field
*       ALL FIELDS WITH CORRESPONDING #( book_read_result )
*    RESULT DATA(booksuppl_read_result).
*
*    LOOP AT Project_read_result ASSIGNING FIELD-SYMBOL(<Project>).
*      "Fill Project container for creating new Project instance
*      APPEND VALUE #(
**      %cid     = keys[ KEY entity %tky = <Project>-%tky ]-%cid
*                      %data    = CORRESPONDING #( <Project> EXCEPT rapbouuid  ) )
*        TO projects ASSIGNING FIELD-SYMBOL(<new_Project>).
*
*      "Fill %cid_ref of Project as instance identifier for cba Node
*      APPEND VALUE #(
*        %cid_ref = keys[ KEY entity %tky = <Project>-%tky ]-%cid )
*        TO Nodes_cba ASSIGNING FIELD-SYMBOL(<Nodes_cba>).
*
**      <new_Project>-begin_date     = cl_abap_context_info=>get_system_date( ).
**      <new_Project>-end_date       = cl_abap_context_info=>get_system_date( ) + 30.
**      <new_Project>-overall_status = 'O'.  "Set to open to allow an editable instance
*
*      LOOP AT book_read_result ASSIGNING FIELD-SYMBOL(<Node>) USING KEY entity WHERE Project_id EQ <Project>-Project_id.
*        "Fill Node container for creating Node with cba
*        APPEND VALUE #( %cid     = keys[ KEY entity %tky = <Project>-%tky ]-%cid && <Node>-Node_id
*                        %data    = CORRESPONDING #(  book_read_result[ KEY entity %tky = <Node>-%tky ] EXCEPT Project_id ) )
*          TO <Nodes_cba>-%target ASSIGNING FIELD-SYMBOL(<new_Node>).
*
*        "Fill %cid_ref of Node as instance identifier for cba booksuppl
*        APPEND VALUE #( %cid_ref = keys[ KEY entity %tky = <Project>-%tky ]-%cid && <Node>-Node_id )
*          TO fields_cba ASSIGNING FIELD-SYMBOL(<fields_cba>).
*
*        <new_Node>-Node_status = 'N'.
*
*        LOOP AT booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl>) USING KEY entity WHERE Project_id  EQ <Project>-Project_id
*                                                                                           AND   Node_id EQ <Node>-Node_id.
*          "Fill booksuppl container for creating supplement with cba
*          APPEND VALUE #( %cid  = keys[ KEY entity %tky = <Project>-%tky ]-%cid  && <Node>-Node_id && <booksuppl>-Node_supplement_id
*                          %data = CORRESPONDING #( <booksuppl> EXCEPT Project_id Node_id ) )
*            TO <fields_cba>-%target.
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.
*
*    "create new BO instance
*    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
*      ENTITY Project
*        CREATE FIELDS (
*                boname
* rootentityname
* namespace
* packagename
* transportrequest
* skipactivation
* implementationtype
* abaplanguageversion
* packagelanguageversion
* datasourcetype
* bindingtype
* draftenabled
* suffix
* prefix
* multiinlineedit
* customizingtable
* addtomanagebusinessconfig
* businessconfname
* businessconfidentifier
* businessconfdescription
*        )
*          WITH projects
*        CREATE BY \_Node FIELDS (
*
*                      FieldNameCreatedAt
*                      FieldNameCreatedby
*                      FieldNameEtagMaster
*                      FieldNameLastChangedAt
*                      FieldNameLastChangedBy
*                      FieldNameLocLastChangedAt
*                      FieldNameObjectID
*                      FieldNameParentUUID
*                      FieldNameRootUUID
*                      FieldNameTotalEtag
*                      FieldNameUUID
*
*
*        )
*          WITH Nodes_cba
*      ENTITY Node
*        CREATE BY \_field FIELDS ( Node_supplement_id supplement_id price currency_code )
*          WITH fields_cba
*      MAPPED DATA(mapped_create).
*
*    mapped-Project   =  mapped_create-Project .

    DATA update_bonodes TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Node.
    DATA update_bonode LIKE LINE OF update_bonodes.
*    DATA targets TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\\node .
*    DATA target LIKE LINE OF targets.
    DATA update_rapbonode TYPE TABLE FOR UPDATE ZDMO_R_RAPG_Nodetp.

    DATA update_fields TYPE TABLE FOR UPDATE ZDMO_R_RAPG_FieldTP.
    DATA update_field TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_FieldTP.

    DATA cid TYPE i.

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
     ENTITY Project
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(rapbos).

    CHECK lines( rapbos ) = 1.
    "only copy projects that are not in draft mode
    CHECK rapbos[ 1 ]-%is_draft = if_abap_behv=>mk-off.

    "Get package name selected by the user
    DATA(selected_packagename) = keys[ 1 ]-%param-packagename.


    DATA xco_lib TYPE REF TO zdmo_cl_rap_xco_lib.
    DATA(xco_on_prem_library) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF xco_on_prem_library->on_premise_branch_is_used(  ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.

    DATA(selected_package_exist) = xco_lib->get_package( selected_packagename )->exists(  ).

    IF selected_package_exist = abap_false.

      APPEND VALUE #( %tky = rapbos[ 1 ]-%tky )
                       TO failed-project.

      "Set message
      APPEND VALUE #( %tky = rapbos[ 1 ]-%tky
                      %element-jsonstring = if_abap_behv=>mk-on
                      %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                          number   = 014
                                          severity = if_abap_behv_message=>severity-error
                                          v1       =  selected_packagename
                                   )
                     )
             TO reported-project.
      RETURN.

    ENDIF.

    LOOP AT rapbos INTO DATA(rapbo).

      " Read all associated nodes
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
              ENTITY Project BY \_Node
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      " Read all associated fields
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Node BY \_Field
          ALL FIELDS
        WITH VALUE #( FOR rba_node IN rapbo_nodes ( %tky = rba_node-%tky ) )
        RESULT DATA(source_fields).

      CHECK line_exists( rapbo_nodes[ IsRootNode = abap_true ] ).

      SORT rapbo_nodes BY HierarchyDistanceFromRoot ASCENDING.

      DATA(root_node) = rapbo_nodes[ IsRootNode = abap_true ].


*DataSourceType   char(30)  Datasource Type
*Column  BdefImplementationType   char(50)  Implementation type
*Column  BindingType   char(30)  Binding type
*Column  DraftEnabled  abap_boolean char(1)  Draft enabled
*Column  EntityName  zdmo_rap_gen_entityname char(40)  Root Entity Name
*Column  data_source_name   char(30)

      IF rapbo-ImplementationType = zdmo_cl_rap_node=>implementation_type-managed_semantic OR
         rapbo-ImplementationType = zdmo_cl_rap_node=>implementation_type-managed_uuid.
        DATA(BdefImplementationType) = zdmo_cl_rap_node=>bdef_implementation_type-managed.
      ELSE.
        BdefImplementationType = zdmo_cl_rap_node=>bdef_implementation_type-unmanaged.
      ENDIF.

      "create BO and root node via action

      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Project
          EXECUTE createProjectAndRootNode  "  createBOandRootNode
            FROM VALUE #( (
            %cid = 'ROOT1'
            %param-BdefImplementationType = BdefImplementationType
            %param-BindingType = rapbo-BindingType
            %param-DraftEnabled = rapbo-DraftEnabled
            %param-entityname = root_node-EntityName
            %param-data_source_name = root_node-DataSource
            %param-DataSourceType = rapbo-DataSourceType
            %param-package_name = selected_packagename
            ) )
               " check result
        MAPPED   mapped
        FAILED   failed
        REPORTED reported.

      CHECK mapped-project[] IS NOT INITIAL.


      "get copied root node
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
                    ENTITY Project BY \_node
                    ALL  FIELDS
                    WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                    RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
                    RESULT DATA(copied_root_nodes).

      CHECK lines( copied_root_nodes ) = 1.

      DATA(copied_root_node) = copied_root_nodes[ 1 ].

      "set fields for copied header and root node

      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Project
      UPDATE FIELDS ( AddToManageBusinessConfig
                      CustomizingTable
                      MultiInlineEdit
                      Suffix
                      Prefix
                      SkipActivation )
      WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on
                      RapboUUID = mapped-project[ 1 ]-RapboUUID

                      AddToManageBusinessConfig = rapbo-AddToManageBusinessConfig
                      CustomizingTable = rapbo-CustomizingTable
                      MultiInlineEdit = rapbo-MultiInlineEdit

                      Suffix = rapbo-Suffix
                      Prefix = rapbo-Prefix
                      SkipActivation = rapbo-SkipActivation
                      ) )

       FAILED   DATA(failed_update_root_bo_node)
       REPORTED DATA(reported_update_root_bo_node).

      "in a second modify we set the field names according to the data from the source project
      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node
      UPDATE FIELDS (
*                      DataSource
                      FieldNameCreatedAt
                      FieldNameCreatedby
                      FieldNameEtagMaster
                      FieldNameLastChangedAt
                      FieldNameLastChangedBy
                      FieldNameLocLastChangedAt
                      FieldNameObjectID
                      FieldNameParentUUID
                      FieldNameRootUUID
                      FieldNameTotalEtag
                      FieldNameUUID
                      )
      WITH VALUE #( (
                      NodeUUID = copied_root_node-NodeUUID
                      %is_draft = if_abap_behv=>mk-on
*                      DataSource = root_node-DataSource
                      "check if the following fields have to be set using a seperate EML call
                      FieldNameCreatedAt = root_node-FieldNameCreatedAt
                      FieldNameCreatedby = root_node-FieldNameCreatedby
                      FieldNameEtagMaster = root_node-FieldNameEtagMaster
                      FieldNameLastChangedAt = root_node-FieldNameLastChangedAt
                      FieldNameLastChangedBy = root_node-FieldNameLastChangedBy
                      FieldNameLocLastChangedAt = root_node-FieldNameLocLastChangedAt
                      FieldNameObjectID = root_node-FieldNameObjectID
                      FieldNameParentUUID = root_node-FieldNameParentUUID
                      FieldNameRootUUID = root_node-FieldNameRootUUID
                      FieldNameTotalEtag = root_node-FieldNameTotalEtag
                      FieldNameUUID = root_node-FieldNameUUID
                      ) )
       FAILED   DATA(failed_update_root_bo_node2)
       REPORTED DATA(reported_update_root_bo_node2).





      "read copied project header data
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Project
      ALL FIELDS
      WITH VALUE #( ( %is_draft        = if_abap_behv=>mk-on
                      RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
      RESULT DATA(copied_rapbos).

      CHECK lines( copied_rapbos ) = 1.


      "get created fields
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
                    ENTITY node
                    BY \_field
                    ALL  FIELDS
                    WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                    NodeUUID    = copied_root_nodes[ 1 ]-NodeUUID  ) )
                    RESULT DATA(new_fields).


*  rapbo_node-EntityName

      LOOP AT new_fields INTO DATA(new_field).

        update_field-FieldUUID = new_field-FieldUUID.
        update_field-%is_draft = if_abap_behv=>mk-on.
        update_field-CdsViewField = source_fields[ DbtableField = new_field-dbtablefield NodeUUID = root_node-NodeUUID  ]-CdsViewField.
        APPEND update_field TO update_fields.

      ENDLOOP.



      " loop at nodes of the source project beside the root node

      LOOP AT rapbo_nodes INTO DATA(rapbo_node) WHERE IsRootNode = abap_false.
        cid += 1.

        "get copied rapbo nodes
        READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
                      ENTITY Project BY \_node
                      ALL  FIELDS
                      WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                      RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
                      RESULT DATA(copied_rapbo_nodes).

        "get uuid of parent node
        DATA(uuid_of_parent_node) = copied_rapbo_nodes[ EntityName = rapbo_node-ParentEntityName ]-NodeUUID.

        MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY node
          EXECUTE addChildNode
            FROM VALUE #( (
                                %tky = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                                  NodeUUID = uuid_of_parent_node )
                                %param-entity_name = rapbo_node-EntityName
                                %param-DataSourceName = rapbo_node-DataSource
                                %param-DataSourceType = rapbo-DataSourceType
            ) )

        MAPPED   DATA(mapped_add_child)
        FAILED   DATA(failed_add_child)
        REPORTED DATA(reported_add_child).

        "in a second modify we set the field names according to the data from the source project
        MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Node
        UPDATE FIELDS (
*                        DataSource
                        FieldNameCreatedAt FieldNameCreatedby FieldNameEtagMaster FieldNameLastChangedAt FieldNameLastChangedBy
                        FieldNameLocLastChangedAt FieldNameObjectID FieldNameParentUUID FieldNameRootUUID FieldNameTotalEtag
                        FieldNameUUID
                        )
        WITH VALUE #( (

                                   NodeUUID = mapped_add_child-node[ 1 ]-NodeUUID
                                   %is_draft = if_abap_behv=>mk-on
*                                   DataSource = rapbo_node-DataSource
                                   "check if the following fields have to be set using a seperate EML call
                                   fieldnamecreatedat = rapbo_node-fieldnamecreatedat
                                   fieldnamecreatedby = rapbo_node-fieldnamecreatedby
                                   fieldnameetagmaster = rapbo_node-fieldnameetagmaster
                                   fieldnamelastchangedat = rapbo_node-fieldnamelastchangedat
                                   fieldnamelastchangedby = rapbo_node-fieldnamelastchangedby
                                   fieldnameloclastchangedat = rapbo_node-fieldnameloclastchangedat
                                   fieldnameobjectid = rapbo_node-fieldnameobjectid
                                   fieldnameparentuuid = rapbo_node-fieldnameparentuuid
                                   fieldnamerootuuid = rapbo_node-fieldnamerootuuid
                                   fieldnametotaletag = rapbo_node-fieldnametotaletag
                                   FieldNameUUID = rapbo_node-FieldNameUUID

                        ) )
         FAILED   DATA(failed_update_child_bo_node2)
         REPORTED DATA(reported_update_child_bo_node2).


*        LOOP AT mapped_add_child-field INTO DATA(mapped_add_child_field).

* ENTITY Project BY \_node
*                      ALL  FIELDS
*                      WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
*                                      RapboUUID = mapped-project[ 1 ]-RapboUUID  ) )
*                      RESULT DATA(copied_rapbo_nodes).

        "get created fields
        READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
                      ENTITY node
                      BY \_field
                      ALL  FIELDS
                      WITH VALUE #( ( %is_draft   = if_abap_behv=>mk-on
                                      NodeUUID    = mapped_add_child-node[ 1 ]-NodeUUID  ) )
                      RESULT new_fields.


*  rapbo_node-EntityName

        LOOP AT new_fields INTO new_field.

          update_field-FieldUUID = new_field-FieldUUID.
          update_field-%is_draft = if_abap_behv=>mk-on.
          update_field-CdsViewField = source_fields[ DbtableField = new_field-dbtablefield NodeUUID = rapbo_node-NodeUUID  ]-CdsViewField.
          APPEND update_field TO update_fields.

        ENDLOOP.

      ENDLOOP.

      MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
              ENTITY Field
              UPDATE FIELDS (
                              CdsViewField
                              )
                            WITH
                        update_fields
                     FAILED   DATA(failed_update_child_bo_node3)
                     REPORTED DATA(reported_update_child_bo_node3).

      APPEND VALUE #(
       "von der quelle hier im Schlüssel
                       rapbouuid  = rapbo-RapboUUID "  mapped-rapgeneratorbo[ 1 ]-RapNodeUUID
                       %is_draft = rapbo-%is_draft "  mapped-rapgeneratorbo[ 1 ]-%is_draft
                       "hier steht was rauskommt
                       "also mapping der alten auf neue keys
                       %param = VALUE #( %is_draft = mapped-project[ 1 ]-%is_draft
                                         %key      = mapped-project[ 1 ]-%key ) ) TO result.


    ENDLOOP.


    DATA(a) = mapped.










  ENDMETHOD.

  METHOD deleteProject.

    TYPES: BEGIN OF ty_longtext,
             msgv1(50),
             msgv2(50),
             msgv3(50),
             msgv4(50),
           END OF ty_longtext.
    DATA update TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project.



    "check json string
    "if this is not valid, raise an exception

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
          ENTITY Project
*            FIELDS ( jsonstring abaplanguageversion boname )
            ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(rapbos).

    "Do check
    LOOP AT rapbos INTO DATA(rapbo).

      SELECT SINGLE *  FROM ZDMO_R_RAPG_ProjectTP WHERE BoName = @rapbo-BoName
                                                      INTO @DATA(raprootnode) .

      SELECT SINGLE * FROM ZDMO_R_RAPG_NodeTP WHERE RapBoUUID = @raprootnode-RapBoUUID
                                                     AND IsRootNode = @abap_true
                                                     INTO @DATA(root_node_information).

*
*      DATA(filter_string) = to_upper( root_node_information-ServiceBinding && '%' ).
*
*      SELECT * FROM I_CustABAPObjDirectoryEntry WHERE ABAPObject LIKE @filter_string
*                                                  AND ABAPObjectType = 'SIA6'
*                                                 INTO TABLE @DATA(published_srvb_entries).

      DATA on_prem_xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.
      DATA xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.

      on_prem_xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

      IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_true.
        xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
      ELSE.
        xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
      ENDIF.

      IF xco_lib->get_service_binding( CONV sxco_srvb_object_name( root_node_information-ServiceBinding ) )->if_xco_ar_object~exists( ) = abap_true.
        "service binding exists
        IF xco_lib->service_binding_is_published( CONV sxco_srvb_object_name( root_node_information-ServiceBinding )  ).
          "Service binding is published

          IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_false
*             OR  raprootnode-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v2_ui
*             OR  raprootnode-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v2_web_api
             .

            "only raise a message if we are in cloud or if odata v2 is used on prem

            APPEND VALUE #( %tky = rapbo-%tky )
                   TO failed-project.

            "Set message
            APPEND VALUE #( %tky = rapbo-%tky
                            %element-jsonstring = if_abap_behv=>mk-on
                            %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                                number   = 073
                                                severity = if_abap_behv_message=>severity-error
                                                v1       =  | { root_node_information-ServiceBinding } |
*                                            v2       =  msg->value-msgv2
*                                            v3       =  msg->value-msgv3
*                                            v4       =  msg->value-msgv4
                                                )
                           )
                   TO reported-project.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.


    LOOP AT rapbos INTO rapbo.
      "set a flag to check in the save sequence that a job is to be scheduled
      update_line-BoIsDeleted = abap_true.
      update_line-ApplJobLogHandle = ''.
      update_line-%tky        = rapbo-%tky.
      APPEND update_line TO update.
    ENDLOOP.


    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Project
      UPDATE FIELDS (
                      BoIsDeleted
                      ApplJobLogHandle
                      ) WITH update
    REPORTED reported
    FAILED failed
    MAPPED mapped.

    IF failed IS INITIAL.
      "Read changed data for action result
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Project
          ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT rapbos.
      result = VALUE #( FOR rapbo2 IN rapbos ( %tky   = rapbo2-%tky
                                               %param = rapbo2 ) ).
    ENDIF.






  ENDMETHOD.

  METHOD generateProject.


    TYPES: BEGIN OF ty_longtext,
             msgv1(50),
             msgv2(50),
             msgv3(50),
             msgv4(50),
           END OF ty_longtext.
    DATA update TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project.
    DATA update_line TYPE STRUCTURE FOR UPDATE zDMO_R_RAPG_ProjectTP\\Project .



    "check json string
    "if this is not valid, raise an exception

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
          ENTITY Project
*            FIELDS ( jsonstring abaplanguageversion boname )
            ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(rapbos).

    "Do check
    LOOP AT rapbos INTO DATA(rapbo).

      TRY.

          IF rapbo-abaplanguageversion = zdmo_cl_rap_node=>abap_language_version-standard.
            DATA(check_rapbo_on_prem) =  zdmo_cl_rap_generator=>create_for_on_prem_development( rapbo-jsonstring ).
          ELSE.
            DATA(check_rapbo_cloud) =  zdmo_cl_rap_generator=>create_for_cloud_development( rapbo-jsonstring ).
          ENDIF.

          "set a flag to check in the save sequence that a job is to be scheduled
          update_line-BoIsGenerated = abap_true.
          update_line-%tky      = rapbo-%tky.
          APPEND update_line TO update.


        CATCH zdmo_cx_rap_generator INTO DATA(rapobo_exception).
          DATA(exception_text) = rapobo_exception->get_text(  ).
          DATA(msg) = rapobo_exception->get_message(  ).

          "Set failed keys
          APPEND VALUE #( %tky = rapbo-%tky )
                 TO failed-project.

          "Set message
          APPEND VALUE #( %tky = rapbo-%tky
                          %element-jsonstring = if_abap_behv=>mk-on
                          %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                              number   = msg->value-msgno
                                              severity = if_abap_behv_message=>severity-error
                                              v1       =  msg->value-msgv1
                                              v2       =  msg->value-msgv2
                                              v3       =  msg->value-msgv3
                                              v4       =  msg->value-msgv4 )
                         )
                 TO reported-project.
          RETURN.
      ENDTRY.
    ENDLOOP.


*    LOOP AT rapbos INTO rapbo.
*      "set a flag to check in the save sequence that a job is to be scheduled
*      update_line-BoIsGenerated = abap_true.
*      update_line-%tky      = rapbo-%tky.
*      APPEND update_line TO update.
*    ENDLOOP.



    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Project
      UPDATE FIELDS (
                      BoIsGenerated
                      ) WITH update
    REPORTED reported
    FAILED failed
    MAPPED mapped.

    IF failed IS INITIAL.
      "Read changed data for action result
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Project
          ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT rapbos.
      result = VALUE #( FOR rapbo2 IN rapbos ( %tky   = rapbo2-%tky
                                               %param = rapbo2 ) ).
    ENDIF.



  ENDMETHOD.

  METHOD SetRepositoryObjectNames.

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Project
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

    LOOP AT rapbos INTO DATA(rapbo).
      CHECK rapbo-packagename IS NOT INITIAL.
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
              ENTITY Project BY \_Node
              ALL  FIELDS
              WITH VALUE #( ( %tky = rapbo-%tky ) )
              RESULT DATA(rapbo_nodes).

      LOOP AT rapbo_nodes INTO DATA(rapbo_node).
        MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
              ENTITY Node
                EXECUTE SetRepositoryObjectNames
                  FROM VALUE #( ( %tky = rapbo_node-%tky ) ).
      ENDLOOP.

    ENDLOOP.



  ENDMETHOD.

  METHOD createJsonString.

    DATA json_string_builder TYPE REF TO zdmo_cl_rap_gen_build_json_2.
    DATA update TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project .

    DATA rapgen_nodes  TYPE zdmo_cl_rap_gen_build_json_2=>tt_rapgen_node .
    DATA rapgen_projects  TYPE zdmo_cl_rap_gen_build_json_2=>tt_rapgen_bo .
    DATA rapgen_fields TYPE zdmo_cl_rap_gen_build_json_2=>tt_rapgen_field.

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
       ENTITY Project
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(Projects).

    LOOP AT projects INTO DATA(project).

      " Read all associated nodes
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Project BY \_Node
          ALL FIELDS
        WITH VALUE #( ( %tky = project-%tky ) )
        RESULT DATA(nodes).

      " Read all associated fields
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Node BY \_Field
          ALL FIELDS
        WITH VALUE #( FOR rba_node IN nodes ( %tky = rba_node-%tky ) )
        RESULT DATA(fields).

      MOVE-CORRESPONDING Projects TO rapgen_projects.
      MOVE-CORRESPONDING Nodes TO rapgen_nodes.
      MOVE-CORRESPONDING Fields TO rapgen_fields.

      json_string_builder = NEW zdmo_cl_rap_gen_build_json_2(
        iv_bo_uuid     = project-%tky-RapBoUUID
        it_rapgen_bo   = rapgen_projects
        it_rapgen_node = rapgen_nodes
        it_rapgen_field = rapgen_fields
      ).

      DATA(root_node)      =   rapgen_nodes[ isrootnode = abap_true RapBoUUID  = project-%tky-rapbouuid  ].

      update_line-jsonstring  = json_string_builder->create_json(  ).
      update_line-%tky      = project-%tky.
      APPEND update_line TO update.

    ENDLOOP.

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
       ENTITY Project
       UPDATE FIELDS (
                jsonstring
                ) WITH update
       REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD generated_objects_are_deleted.

    DATA generated_repository_objects  TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    DATA generated_repository_object TYPE  zdmo_cl_rap_generator=>t_generated_repository_object.
    DATA reported_rapgeneratorbo_line LIKE LINE OF reported-project.
    DATA repository_objects_exist TYPE abap_bool VALUE abap_false.

    DATA rap_generator_project TYPE ZDMO_R_RAPG_ProjectTP.
    DATA rap_generator_projects TYPE STANDARD TABLE OF ZDMO_R_RAPG_ProjectTP.

    LOOP AT keys INTO DATA(key).
      SELECT SINGLE * FROM ZDMO_R_RAPG_ProjectTP WHERE RapBoUUID = @key-RapboUUID
      INTO @rap_generator_project.
      APPEND rap_generator_project TO rap_generator_projects.
    ENDLOOP.

    LOOP AT rap_generator_projects INTO rap_generator_project.

      repository_objects_exist = rap_gen_project_objects_exist( rap_generator_project ).

      IF repository_objects_exist = abap_true.
        APPEND VALUE #(  rapbouuid  = rap_generator_project-RapboUUID )
          TO failed-project.
        APPEND VALUE #( rapbouuid = rap_generator_project-RapboUUID
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 077
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ rap_generator_project-BoName }| ) )
               TO reported-project.
      ENDIF.


    ENDLOOP.


  ENDMETHOD.

  METHOD rap_gen_project_objects_exist.

    "@todo - duplicate code ???

    DATA generated_repository_objects TYPE zdmo_cl_rap_generator=>t_generated_repository_objects.
    DATA generated_repository_object TYPE zdmo_cl_rap_generator=>t_generated_repository_object.

    DATA on_prem_xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.
    DATA xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.

    on_prem_xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.

    SELECT * FROM ZDMO_R_RAPG_NodeTP WHERE rapboUUID = @i_rap_generator_project-RapboUUID
                                                        INTO TABLE @DATA(rapbo_nodes).

    LOOP AT rapbo_nodes INTO DATA(rapbo_node).
      "get repository object names and types

      CLEAR generated_repository_objects.

      IF rapbo_node-ServiceBinding IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-ServiceBinding.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-service_binding.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-ServiceDefinition IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-ServiceDefinition.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-service_definition.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-CdsRView IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-CdsRView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-behavior_definition_r.
        APPEND generated_repository_object TO generated_repository_objects.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_r.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-CdsPView IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-CdsPView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>root_node_object_types-behavior_definition_p.
        APPEND generated_repository_object TO generated_repository_objects.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_p.
        APPEND generated_repository_object TO generated_repository_objects.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-meta_data_extension.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-CdsiView IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-CdsiView.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-cds_view_i.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-ControlStructure IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-ControlStructure.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-control_structure.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-BehaviorImplementationClass IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-BehaviorImplementationClass.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-behavior_implementation.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      IF rapbo_node-DraftTableName IS NOT INITIAL.
        generated_repository_object-object_name = rapbo_node-DraftTableName.
        generated_repository_object-object_type = zdmo_cl_rap_node=>node_object_types-draft_table.
        APPEND generated_repository_object TO generated_repository_objects.
      ENDIF.

      LOOP AT generated_repository_objects INTO generated_repository_object.

        CASE generated_repository_object-object_type.

          WHEN zdmo_cl_rap_node=>root_node_object_types-service_binding.
            IF xco_lib->get_service_binding( CONV sxco_srvb_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>root_node_object_types-service_definition.
            IF xco_lib->get_service_definition( CONV sxco_srvd_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>root_node_object_types-behavior_definition_r. "this checks also for behavior projection 'BDEF'
            IF xco_lib->get_behavior_definition( CONV sxco_cds_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-behavior_implementation. "checks also for query implementation 'CLAS'
            IF xco_lib->get_class( CONV  sxco_ao_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-cds_view_r. "this checks also for i- and p-views as well as for custom entities
            IF xco_lib->get_view( CONV  sxco_cds_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-control_structure.
            IF xco_lib->get_structure( CONV  sxco_ad_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN zdmo_cl_rap_node=>node_object_types-draft_table.
            IF xco_lib->get_database_table( CONV  sxco_dbt_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN  zdmo_cl_rap_node=>node_object_types-meta_data_extension.
            IF xco_lib->get_metadata_extension( CONV  sxco_cds_object_name(  generated_repository_object-object_name ) )->if_xco_ar_object~exists( ) = abap_true.
              r_repository_objects_exist = abap_true.
            ENDIF.
          WHEN OTHERS.
            "do nothing
        ENDCASE.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD mandatory_fields_check.

    DATA permission_request TYPE STRUCTURE FOR PERMISSIONS REQUEST ZDMO_C_RAPG_ProjectTP.
    DATA reported_rapgeneratorbo_line LIKE LINE OF reported-project.

    "check permissions of the following fields
    permission_request-%field-PackageName = if_abap_behv=>mk-on.

    " Get current field values
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Project
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(rap_generator_projects).

    "Do check
    LOOP AT rap_generator_projects INTO DATA(rap_generator_project).

      GET PERMISSIONS ONLY INSTANCE ENTITY ZDMO_C_RAPG_ProjectTP
                FROM VALUE #( ( RapBoUUID = rap_generator_project-RapBoUUID ) )
                REQUEST permission_request
                RESULT DATA(permission_result)
                FAILED DATA(failed_permission_result)
                REPORTED DATA(reported_permission_result).

      IF permission_result-global-%field-PackageName = if_abap_behv=>fc-f-mandatory
               AND rap_generator_project-PackageName IS INITIAL.

        APPEND VALUE #( %tky = rap_generator_project-%tky ) TO failed-project.

        CLEAR reported_rapgeneratorbo_line.
        reported_rapgeneratorbo_line-%tky = rap_generator_project-%tky.
        reported_rapgeneratorbo_line-%element-packagename = if_abap_behv=>mk-on.
        reported_rapgeneratorbo_line-%msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                                         number   = 071
                                                         severity = if_abap_behv_message=>severity-error
                                                         v1       = | Package name |
                                                         v2       = |{ rap_generator_project-BoName }| ).
        APPEND reported_rapgeneratorbo_line  TO reported-project.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD is_customizing_table.

    " check if
    " - all data sources are tables of delievery class C
    " - is of implementation type managed_semantic with
    "   binding_type odata_V4_UI and is draft enabled

    "Get values of fields
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY project
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(projects).

    DATA on_prem_xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.
    DATA xco_lib  TYPE REF TO zdmo_cl_rap_xco_lib.

    on_prem_xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

    IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_true.
      xco_lib = NEW zdmo_cl_rap_xco_on_prem_lib(  ).
    ELSE.
      xco_lib = NEW zdmo_cl_rap_xco_cloud_lib(  ).
    ENDIF.


    LOOP AT projects INTO DATA(project).

      IF project-CustomizingTable = abap_true AND

        ( project-ImplementationType <> zdmo_cl_rap_node=>implementation_type-managed_semantic OR
           project-BindingType <> zdmo_cl_rap_node=>binding_type_name-odata_v4_ui OR
           project-DraftEnabled = abap_false ).

        APPEND VALUE #( %tky = project-%tky )
        TO failed-project.
        APPEND VALUE #( %tky = project-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 059
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ project-BoName }| ) )
               TO reported-project.

        "check if all tables are customizing tables
      ELSEIF project-CustomizingTable = abap_true
      AND
        ( project-ImplementationType = zdmo_cl_rap_node=>implementation_type-managed_semantic OR
          project-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui OR
          project-DraftEnabled = abap_true )
      .

        " Read all associated nodes
        READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
          ENTITY Project BY \_Node
            ALL FIELDS
          WITH VALUE #( ( %tky = project-%tky ) )
          RESULT DATA(nodes).

        LOOP AT nodes INTO DATA(node).

          DATA(table_delivery_class) = xco_lib->get_database_table( CONV #( node-DataSource ) )->content(  )->get(  )-delivery_class->value.

          IF table_delivery_class <> 'C'.

            APPEND VALUE #( %tky = project-%tky )
            TO failed-project.
            APPEND VALUE #( %tky = project-%tky
                            %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                                number   = 060
                                                severity = if_abap_behv_message=>severity-error
                                                v1       = |{ node-DataSource }|
                                                v2       = |{ table_delivery_class }| ) )
                   TO reported-project.

            RETURN.

          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD check_for_allowed_combinations.

    "Get values of fields
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Project
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(projects).

    LOOP AT projects INTO DATA(entity).

      "managed scenarios should use tables as data sources
      "scenarios where CDS views are used as datasources are scenarios
      "where one reads from SAP CDS views and one uses API's such as BAPI's
      "to store the changes


      IF entity-DataSourceType = zdmo_cl_rap_node=>data_source_types-cds_view AND
         entity-ImplementationType <> zdmo_cl_rap_node=>implementation_type-unmanaged_semantic .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 080
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-ImplementationType }|
                                            v2       = |{ zdmo_cl_rap_node=>implementation_type-unmanaged_semantic }|

                                             ) )
               TO reported-project.
      ENDIF.


      "custom entities (that are created when abstract entities are used as a data source) do not support draft
      IF entity-DataSourceType = zdmo_cl_rap_node=>data_source_types-abstract_entity AND
         entity-DraftEnabled = abap_true .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 063
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-project.
      ENDIF.

      "custom entities = unmanaged queries do only support an unmanaged transactional implementation

      IF entity-DataSourceType = zdmo_cl_rap_node=>data_source_types-abstract_entity AND
         entity-ImplementationType <> zdmo_cl_rap_node=>implementation_type-unmanaged_semantic.
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 079
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-ImplementationType }|
                                            v2       = |{ zdmo_cl_rap_node=>implementation_type-unmanaged_semantic }|

                                            ) )
               TO reported-project.
      ENDIF.

      "OData V4 as UI service binding in only allowed when draft is used
      IF   entity-BindingType = zdmo_cl_rap_node=>binding_type_name-odata_v4_ui AND
           entity-DraftEnabled = abap_false .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 078
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-project.
      ENDIF.

      "For customizing tables are required as data source
      "the same is true when multi inline edit shall be used

      IF ( entity-MultiInlineEdit = abap_true OR entity-CustomizingTable = abap_true ) AND
           entity-DataSourceType <> zdmo_cl_rap_node=>data_source_types-table .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 067
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-DataSourceType }| ) )
               TO reported-project.
      ENDIF.

      IF ( entity-MultiInlineEdit = abap_true OR entity-CustomizingTable = abap_true ) AND
           entity-ImplementationType <> zdmo_cl_rap_node=>implementation_type-managed_semantic .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 068
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-ImplementationType }| ) )
               TO reported-project.
      ENDIF.

      IF entity-MultiInlineEdit = abap_true AND
       ( entity-BindingType <> zdmo_cl_rap_node=>binding_type_name-odata_v4_ui OR
         entity-DraftEnabled = abap_false ) .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 058
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-project.
      ENDIF.

      IF entity-CustomizingTable = abap_true AND
         ( entity-BindingType <> zdmo_cl_rap_node=>binding_type_name-odata_v4_ui OR
           entity-DraftEnabled = abap_false ) .
        APPEND VALUE #( %tky = entity-%tky )
               TO failed-project.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                            number   = 059
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = |{ entity-BoName }| ) )
               TO reported-project.
      ENDIF.




    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Log DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CalculateLogItemNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Log~CalculateLogItemNumber.

ENDCLASS.

CLASS lhc_Log IMPLEMENTATION.

  METHOD CalculateLogItemNumber.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Node DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Node RESULT result.

*    METHODS get_global_features FOR GLOBAL FEATURES
*      IMPORTING REQUEST requested_features FOR Node RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Node RESULT result.

*    METHODS addChildNode FOR MODIFY
*      IMPORTING keys FOR ACTION Node~addChildNode RESULT result.

*    METHODS createRootNode FOR MODIFY
*      IMPORTING keys FOR ACTION Node~createRootNode RESULT result.

    METHODS CalculateEntityName FOR DETERMINE ON SAVE
      IMPORTING keys FOR Node~CalculateEntityName.
    METHODS SetRepositoryObjectNames FOR MODIFY
      IMPORTING keys FOR ACTION Node~SetRepositoryObjectNames.

    METHODS SetRepositoryObjectNames_det FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Node~SetRepositoryObjectNames_det.
    METHODS addChildNode FOR MODIFY
      IMPORTING keys   FOR ACTION Node~addChildNode
      RESULT    result.
    METHODS addChildDataSourceAbsEntity FOR MODIFY
      IMPORTING keys   FOR ACTION Node~addChildDataSourceAbsEntity
*      RESULT    result
      .

    METHODS addChildDataSourceCDSview FOR MODIFY
      IMPORTING keys   FOR ACTION Node~addChildDataSourceCDSview
*      RESULT    result
      .

    METHODS addChildDataSourceTable FOR MODIFY
      IMPORTING keys   FOR ACTION Node~addChildDataSourceTable
*      RESULT    result
      .
    METHODS SetFieldNames FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Node~SetFieldNames.
    METHODS mandatory_fields_check FOR VALIDATE ON SAVE
      IMPORTING keys FOR Node~mandatory_fields_check.

*    METHODS SetRepositoryObjectNames FOR MODIFY
*      IMPORTING keys FOR ACTION Node~SetRepositoryObjectNames.

ENDCLASS.

CLASS lhc_Node IMPLEMENTATION.

  METHOD get_instance_features.


    "read all child instances
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node
        FIELDS (  entityname isrootnode viewtypevalue hierarchydistancefromroot )
        WITH CORRESPONDING #( keys )
      RESULT DATA(rapbo_nodes).

    "read all links from child instances to the corresponding parent entity
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node BY \_Project
        FROM CORRESPONDING #( rapbo_nodes )
      LINK DATA(rapbo_nodes_links).

    "read all parent entities of the child entities
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Node BY \_Project
      FIELDS ( implementationtype datasourcetype
               namespace prefix suffix draftenabled )
      WITH CORRESPONDING #( keys )
      RESULT DATA(rapbos).

    LOOP AT rapbo_nodes INTO DATA(rapbo_node).

      "use link data to retrieve the data of the parent entity of the currently selected child entity
      DATA(rapbo) = rapbos[  rapbouuid = rapbo_nodes_links[ source-nodeuuid = rapbo_node-nodeuuid ]-target-rapbouuid ].

      APPEND VALUE #( %tky                   = rapbo_node-%tky

                      %action-addchilddatasourcetable      = COND #( WHEN ( rapbo-%is_draft = if_abap_behv=>mk-on
                                                                      AND rapbo-DataSourceType = zdmo_cl_rap_node=>data_source_types-table )
                                              THEN if_abap_behv=>fc-o-enabled
                                              ELSE if_abap_behv=>fc-o-disabled )

                      %action-addchilddatasourcecdsview      = COND #( WHEN ( rapbo-%is_draft = if_abap_behv=>mk-on
                                                                      AND rapbo-DataSourceType = zdmo_cl_rap_node=>data_source_types-cds_view )
                                              THEN if_abap_behv=>fc-o-enabled
                                              ELSE if_abap_behv=>fc-o-disabled )

                      %action-addchilddatasourceAbsEntity      = COND #( WHEN ( rapbo-%is_draft = if_abap_behv=>mk-on
                                                                      AND rapbo-DataSourceType = zdmo_cl_rap_node=>data_source_types-abstract_entity )
                                              THEN if_abap_behv=>fc-o-enabled
                                              ELSE if_abap_behv=>fc-o-disabled )


*                              %field-fieldnameuuid         = COND #( WHEN rapbo-implementationtype = zdmo_cl_rap_node=>implementation_type-managed_uuid
*                                                               THEN if_abap_behv=>fc-f-mandatory
*                                                               ELSE if_abap_behv=>fc-f-read_only )

                              %field-fieldnamerootuuid     = COND #( WHEN ( rapbo-implementationtype = zdmo_cl_rap_node=>implementation_type-managed_uuid
                                                                      AND rapbo_node-hierarchydistancefromroot > 1 )
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-fieldnameparentuuid    = COND #( WHEN ( rapbo-implementationtype = zdmo_cl_rap_node=>implementation_type-managed_uuid
                                                                      AND  rapbo_node-hierarchydistancefromroot > 0 )
                                                               THEN if_abap_behv=>fc-f-mandatory
                                                               ELSE if_abap_behv=>fc-f-read_only )

                             %field-controlstructure       = COND #( WHEN rapbo-implementationtype = zdmo_cl_rap_node=>implementation_type-unmanaged_semantic
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

                             %field-fieldnamelastchangedat      = COND #( WHEN rapbo_node-isrootnode = abap_true
                                                               THEN if_abap_behv=>fc-f-unrestricted
                                                               ELSE if_abap_behv=>fc-f-read_only )

                            ) TO result.
    ENDLOOP.

  ENDMETHOD.

*  METHOD get_global_features.
*  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.



  METHOD CalculateEntityName.
  ENDMETHOD.


  METHOD SetRepositoryObjectNames.
    DATA my_node TYPE REF TO ZDMO_cl_rap_node.
    DATA root_node TYPE REF TO ZDMO_cl_rap_node.


    DATA update_bo TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project.
    DATA update_bo_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project .

    DATA update TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Node.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Node .

    DATA draft_keys TYPE TABLE FOR DETERMINATION zDMO_R_RAPG_ProjectTP\\Node~SetRepositoryObjectNames_det."  rapgeneratorbonode~setrepositoryobjectnames.


* todo check why we only use draft keys here
* when the action is not enabled in non draft this would not be necessary

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

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Node BY \_Project
    ALL FIELDS
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
      READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
        ENTITY Project BY \_Node
         ALL FIELDS "( entityname  cdsiview  cdspview   )
        WITH VALUE #( ( %tky = rapbo-%tky ) )
        RESULT DATA(rapbo_nodes).

      update_bo_line-%tky      = rapbo-%tky.

      "loop will start with the root node
      SORT rapbo_nodes BY hierarchydistancefromroot ASCENDING.

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
            my_node->set_name_cds_r_view(  ).
            my_node->set_name_cds_p_view(  ).
            my_node->set_name_behavior_impl(  ).
            my_node->set_name_mde(  ).

            update_line-cdsiview   = my_node->rap_node_objects-cds_view_i.
            update_line-cdsrview   = my_node->rap_node_objects-cds_view_r.
            update_line-cdspview   = my_node->rap_node_objects-cds_view_p.
            update_line-mdeview  = my_node->rap_node_objects-meta_data_extension.
            update_line-behaviorimplementationclass  = my_node->rap_node_objects-behavior_implementation.

            "boname can only be set after name of cds-i-view has been determined
            IF rapbo_node-isrootnode = abap_true.
              update_bo_line-boname = my_node->rap_node_objects-cds_view_r.
              update_bo_line-adtlink   = | adt://{ sy-sysid }/sap/bc/adt/ddic/ddl/sources/{ my_node->rap_node_objects-cds_view_r } |.
            ENDIF.

            IF rapbo-implementationtype = ZDMO_cl_rap_node=>implementation_type-unmanaged_semantic.
              my_node->set_name_control_structure(  ).
              update_line-controlstructure = my_node->rap_node_objects-control_structure.
            ELSE.
              update_line-controlstructure = ''.
            ENDIF.

            IF rapbo-datasourcetype = ZDMO_cl_rap_node=>data_source_types-abstract_entity.              .

              my_node->set_name_custom_query_impl(  ).
              my_node->set_name_custom_entity(  ).
              "name of custom entity is the same as the name of the cds i(r)-view
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
    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Project
      UPDATE FIELDS (
                      boname
                      ADTLink
                     ) WITH update_bo
    ENTITY Node
      UPDATE FIELDS (
                      parententityname
                      cdsiview
                      cdsrview
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

  METHOD SetRepositoryObjectNames_det.


    "proposals for repository object names are only set
    "a) when draft is active and
    "b) when the entity name changes. (which cannot happen anymore)

    DATA draft_keys TYPE TABLE FOR DETERMINATION ZDMO_R_RAPG_ProjectTP\\Node~SetRepositoryObjectNames_det .
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
    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY node
        EXECUTE SetRepositoryObjectNames
          FROM CORRESPONDING  #( draft_keys ).


  ENDMETHOD.

  METHOD addChildNode.

    DATA update TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Node.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Node .

    DATA create_nodes TYPE TABLE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Node.
    DATA create_node  TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_ProjectTP\_Node.

    DATA number_of_childs TYPE i.
    DATA n TYPE i.

    "get projects
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node BY \_Project
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(projects).

    "get nodes
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
       ENTITY Node "BY \_Project
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(nodes).

    "calculate new number of child nodes
    LOOP AT nodes INTO DATA(node).
      CLEAR update_line.
      CLEAR number_of_childs.
      LOOP AT nodes INTO DATA(node_2) WHERE parentuuid = node-nodeuuid AND isrootnode = abap_false.
        number_of_childs += 1.
      ENDLOOP.
      LOOP AT nodes INTO node_2 WHERE nodeuuid = node-nodeuuid.
        update_line-%tky      = node_2-%tky.
        update_line-hierarchydescendantcount = number_of_childs + 1 .
        APPEND update_line TO update.
      ENDLOOP.
    ENDLOOP.


    LOOP AT nodes INTO node.

      n += 1.

      IF projects[ rapbouuid = node-RapBoUUID ]-AddToManageBusinessConfig = abap_true AND
         node-hierarchydistancefromroot + 1  >= 2.
        APPEND VALUE #( nodeuuid = node-nodeuuid
                        %msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                       number   = 069
                                       severity = if_abap_behv_message=>severity-error
                                       v1       = |{ projects[ rapbouuid = node-RapBoUUID ]-BoName }| ) )
        TO reported-node.

      ELSE.


        create_node = VALUE #(
                                %tky-%is_draft = node-%is_draft
                                %tky-RapBoUUID = node-rapbouuid

                                %target  = VALUE #(  (
                                                      %is_draft = node-%is_draft
                                                      "data from data source specific action
                                                      entityname = keys[ NodeUUID = node-NodeUUID ]-%param-entity_name
                                                      DataSource = keys[ NodeUUID = node-NodeUUID ]-%param-DataSourceName
                                                      "data from selected node
                                                      parententityname = node-EntityName
                                                      parentdatasource = node-DataSource
                                                      parentuuid = node-NodeUUID
                                                      rootuuid = node-RootUUID
                                                      hierarchydistancefromroot = node-hierarchydistancefromroot + 1
                                         ) )
                              ).

        APPEND create_node TO create_nodes.

      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
               ENTITY Node
               UPDATE FIELDS (
                      hierarchydescendantcount
                      ) WITH update
               ENTITY Project
               CREATE BY \_Node
               FIELDS (
                        "set via parameter
                        entityname
                        DataSource
                        "set from selected node
                        parententityname
                        parentdatasource
                        parentuuid
                        rootuuid
                        hierarchydistancefromroot
                      )
               WITH create_nodes
        MAPPED  mapped
        FAILED  failed
        REPORTED reported.



    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY node
            ALL FIELDS WITH VALUE #(  FOR m IN mapped-node ( %tky = m-%tky  ) )
            RESULT DATA(lt_result).

    result = VALUE #( FOR r IN lt_result (
                                           %tky = r-%tky
                                           %param = CORRESPONDING #( r ) ) ).


*        CHECK mapped-rapgeneratorbonode[] IS NOT INITIAL.

*        APPEND LINES OF mapped-rapgeneratorbonode TO all_mapped-rapgeneratorbonode.



* MODIFY ENTITIES OF zdmo_r_rapgeneratorbo IN LOCAL MODE
*               ENTITY rapgeneratorbonode
*               UPDATE FIELDS (
*                      hierarchydescendantcount
*
*                      ) WITH update
**    REPORTED DATA(update_reported)
*
*               ENTITY rapgeneratorbo
*               CREATE BY \_rapgeneratorbonode
*               SET FIELDS WITH VALUE #( ( %is_draft = ls_key-%is_draft
*                                           rapnodeuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-headeruuid
*
*                                           %target   = VALUE #( ( %is_draft = ls_key-%is_draft
*                                                                  %cid = ls_key-%cid_ref
*                                                                  entityname = ls_key-%param-entity_name
*                                                                  parententityname = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-entityname
*                                                                  parentdatasource = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-datasource
*                                                                  parentuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-nodeuuid
*                                                                  rootuuid = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-rootuuid
*                                                                  hierarchydistancefromroot = rapbo_nodes[ nodeuuid = ls_key-nodeuuid ]-hierarchydistancefromroot + 1
*                                                               )
*                                                             ) ) )
*        MAPPED  mapped " DATA(mapped_from_modify)
*        FAILED  failed "  DATA(failed_from_modify)
*        REPORTED reported." DATA(reported_from_modify).
*
*        CHECK mapped-rapgeneratorbonode[] IS NOT INITIAL.
*
*        APPEND LINES OF mapped-rapgeneratorbonode TO all_mapped-rapgeneratorbonode.
*
*


**    value #(
**  ( %is_draft = CONV #( '01' )
**     nodeuuid = CONV #( '22ABBDB515F31EDDB1AF72F1C2D2AFAA' )
**     rapbouuid = CONV #( '22ABBDB515F31EDDB1AF72F1C2D26FAA' )
**     parentuuid = CONV #( '00000000000000000000000000000000' )
**     rootuuid = CONV #( '00000000000000000000000000000000' )
*nodenumber = '0'
*isrootnode = 'X'
*entityname = 'Test55'
*parententityname = ''
*datasource = 'ZDMO_UUID_HEADER'
*parentdatasource = ''
*viewtypevalue = ''
*fieldnameobjectid = ''
*fieldnameetagmaster = ''
*fieldnametotaletag = ''
*fieldnameuuid = ''
*fieldnameparentuuid = ''
*fieldnamerootuuid = ''
*fieldnamecreatedby = ''
*fieldnamecreatedat = ''
*fieldnamelastchangedby = ''
*fieldnamelastchangedat = ''
*fieldnameloclastchangedat = ''
*cdsiview = 'ZI_Test55TP_55'
*cdsrview = 'ZR_Test55TP_55'
*cdspview = 'ZC_Test55TP_55'
*mdeview = 'ZC_Test55TP_55'
*behaviorimplementationclass = 'ZBP_R_Test55TP_55'
*servicedefinition = 'ZUI_Test55_55'
*servicebinding = 'ZUI_Test55_O4_55'
*controlstructure = ''
*queryimplementationclass = ''
*drafttablename = 'ZTEST5500D_55'
**
*  hierarchydistancefromroot = '0'
*  hierarchydescendantcount = '0'
*  hierarchydrillstate = ``
*  hierarchypreorderrank = '0'
*  locallastchangedat = '20230318105741.0634310'
*  ischildnode = ''
*  istable = ''
*  iscdsview = ''
*  isabstractentity = ''
*)
**   )


    DATA(a) = 1.

  ENDMETHOD.

  METHOD addChildDataSourceAbsEntity.
    DATA(a) = 1.

    DATA  keys_for_add_child_node TYPE TABLE FOR ACTION IMPORT zdmo_r_rapg_projecttp\\node~addChildNode  .
    FIELD-SYMBOLS: <fs_key_for_add_child_node> LIKE LINE OF keys_for_add_child_node.

    keys_for_add_child_node = CORRESPONDING #( DEEP keys ).

    "set DataSourceType to table
    LOOP AT keys_for_add_child_node  ASSIGNING <fs_key_for_add_child_node>.
      <fs_key_for_add_child_node>-%param-DataSourceType = zdmo_cl_rap_node=>data_source_types-abstract_entity.
    ENDLOOP.

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node
      EXECUTE addChildNode
        FROM keys_for_add_child_node
      RESULT DATA(result_add_child_node).

*    result = CORRESPONDING #( DEEP result_add_child_node ).

  ENDMETHOD.

  METHOD addChildDataSourceCDSview.
    DATA(a) = 1.

    DATA  keys_for_add_child_node TYPE TABLE FOR ACTION IMPORT zdmo_r_rapg_projecttp\\node~addChildNode  .
    FIELD-SYMBOLS: <fs_key_for_add_child_node> LIKE LINE OF keys_for_add_child_node.

    keys_for_add_child_node = CORRESPONDING #( DEEP keys ).

    "set DataSourceType to table
    LOOP AT keys_for_add_child_node  ASSIGNING <fs_key_for_add_child_node>.
      <fs_key_for_add_child_node>-%param-DataSourceType = zdmo_cl_rap_node=>data_source_types-cds_view.
    ENDLOOP.

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node
      EXECUTE addChildNode
        FROM keys_for_add_child_node
      RESULT DATA(result_add_child_node).

*    result = CORRESPONDING #( DEEP result_add_child_node ).

  ENDMETHOD.

  METHOD addChildDataSourceTable.

    DATA(a) = 1.

    DATA  keys_for_add_child_node TYPE TABLE FOR ACTION IMPORT zdmo_r_rapg_projecttp\\node~addChildNode  .
    FIELD-SYMBOLS: <fs_key_for_add_child_node> LIKE LINE OF keys_for_add_child_node.

    keys_for_add_child_node = CORRESPONDING #( DEEP keys ).

    "set DataSourceType to table
    LOOP AT keys_for_add_child_node  ASSIGNING <fs_key_for_add_child_node>.
      <fs_key_for_add_child_node>-%param-DataSourceType = zdmo_cl_rap_node=>data_source_types-table.
    ENDLOOP.

    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node
      EXECUTE addChildNode
        FROM keys_for_add_child_node
      RESULT DATA(result_add_child_node).

*    result = CORRESPONDING #( DEEP result_add_child_node ).

  ENDMETHOD.

  METHOD SetFieldNames.

    DATA rapbo TYPE STRUCTURE FOR READ RESULT ZDMO_R_RAPG_ProjectTP\\node\_Project .


    DATA my_node TYPE REF TO ZDMO_cl_rap_node.
    DATA root_node TYPE REF TO ZDMO_cl_rap_node.
    DATA parent_node TYPE REF TO ZDMO_cl_rap_node.


    DATA update_bo TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project.
    DATA update_bo_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Project .

    DATA update TYPE TABLE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Node.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZDMO_R_RAPG_ProjectTP\\Node .

    DATA draft_keys TYPE TABLE FOR DETERMINATION zDMO_R_RAPG_ProjectTP\\Node~SetRepositoryObjectNames_det."  rapgeneratorbonode~setrepositoryobjectnames.

    DATA create_log_cba TYPE TABLE FOR CREATE ZDMO_R_RAPG_NodeTP\_Field.
    DATA create_log_cba_line TYPE STRUCTURE FOR CREATE ZDMO_R_RAPG_NodeTP\_Field.


* todo check why we only use draft keys here
* when the action is not enabled in non draft this would not be necessary

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

    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Node BY \_Project
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(rapbos).

*
*    " Process all affected RAPBos. Read respective nodes,
*    " determine the implementation type of the RAP BO
*
*    LOOP AT rapbos INTO DATA(rapbo).



    " read a dummy field
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
      ENTITY Node
       ALL FIELDS "( entityname  cdsiview  cdspview   )
      WITH CORRESPONDING #( draft_keys )
      RESULT DATA(rapbo_nodes).

*      update_bo_line-%tky      = rapbo-%tky.

    "loop will start with the root node
    SORT rapbo_nodes BY hierarchydistancefromroot ASCENDING.


*      root_node = NEW ZDMO_cl_rap_node(  ).
*      root_node->set_is_root_node(  ).
*      root_node->set_xco_lib( my_xco_lib ).
*      root_node->set_draft_enabled( rapbo-draftenabled ).
*      root_node->set_prefix( rapbo-prefix ).
*      root_node->set_suffix( rapbo-suffix ).
*      root_node->set_namespace( CONV #( rapbo-namespace ) ).
*      root_node->set_binding_type( CONV #( rapbo-bindingtype ) ).
*      root_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
*      root_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).

    LOOP AT rapbo_nodes INTO DATA(rapbo_node).

      CLEAR rapbo.

      IF line_exists( rapbos[ rapbouuid = rapbo_node-rapbouuid ] ).
        rapbo = rapbos[ rapbouuid = rapbo_node-rapbouuid ].
      ENDIF.

      CHECK rapbo IS NOT INITIAL.

      DATA my_xco_lib TYPE REF TO ZDMO_cl_rap_xco_lib.

      IF rapbo-abaplanguageversion = ZDMO_cl_rap_node=>abap_language_version-abap_for_cloud_development.
        my_xco_lib = NEW ZDMO_cl_rap_xco_cloud_lib(  ).
      ELSE.
        my_xco_lib = NEW ZDMO_cl_rap_xco_on_prem_lib( ) .
      ENDIF.

      CLEAR update_bo_line.

      CLEAR update_line.
      update_line-%tky      = rapbo_node-%tky.

      "values must be explictly set to ''.
      "Because if fields are initial their content is not updated via EML

      update_line-fieldnameobjectid = ''.
      update_line-viewtypevalue = ''.
      update_line-fieldnameuuid  = ''.
      update_line-fieldnameparentuuid  = ''.
      update_line-fieldnamerootuuid  = ''.
      update_line-fieldnameetagmaster = ''.
      update_line-fieldnamecreatedat = ''.
      update_line-fieldnamecreatedby = ''.
      update_line-fieldnametotaletag = ''.
      update_line-fieldnamelastchangedby = ''.
*        update_line-fieldnameobjectid = ''.

      CHECK rapbo_node-datasource IS NOT INITIAL.

      IF line_exists( rapbo_nodes[ nodeuuid = rapbo_node-parentuuid ] ).
        update_line-parententityname = rapbo_nodes[ nodeuuid = rapbo_node-parentuuid ]-entityname.
      ENDIF.


      TRY.

          my_node = NEW ZDMO_cl_rap_node(  ).
          my_node->set_xco_lib( my_xco_lib ).
          my_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
          my_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).
          my_node->set_data_source( CONV #( rapbo_node-datasource ) ).

          update_line-viewtypevalue = my_node->view_type_value.

          IF rapbo-implementationtype = 'managed_uuid'.

            my_node->set_field_name_uuid( ). "CONV string( rapbo_node-FieldNameUUID ) ).
            update_line-fieldnameuuid  = to_upper( my_node->field_name-uuid ).

            IF rapbo_node-hierarchydistancefromroot > 0.
              my_node->set_field_name_parent_uuid( ). "CONV string( rapbo_node-FieldNameParentUUID ) ).
              update_line-fieldnameparentuuid  = to_upper( my_node->field_name-parent_uuid ).
            ENDIF.

            IF rapbo_node-hierarchydistancefromroot > 1.
              my_node->set_field_name_root_uuid(  ) .
              update_line-fieldnamerootuuid  = to_upper( my_node->field_name-root_uuid ).
            ENDIF.

          ELSE.
            update_line-fieldnameuuid  = ''.
            update_line-fieldnameparentuuid  = ''.
            update_line-fieldnamerootuuid  = ''.
          ENDIF.

          my_node->set_field_name_etag_master(  ).
          update_line-fieldnameetagmaster = to_upper( my_node->field_name-etag_master ).

          my_node->set_field_name_loc_last_chg_at(  ).
          update_line-FieldNameLocLastChangedAt = to_upper( my_node->field_name-local_instance_last_changed_at ).


          IF rapbo_node-isrootnode = abap_true.

            my_node->set_is_root_node(  ).
            my_node->set_draft_enabled( rapbo-draftenabled ).

            my_node->set_object_id(  ). " rapbo_node-FieldNameObjectID ).
            update_line-fieldnameobjectid = to_upper( my_node->object_id ).


            my_node->set_field_name_total_etag( ).
            update_line-fieldnametotaletag = to_upper( my_node->field_name-total_etag ).

            my_node->set_field_name_created_at( ).
            update_line-fieldnamecreatedat = to_upper( my_node->field_name-created_at ).

            my_node->set_field_name_created_by( ).
            update_line-fieldnamecreatedby = to_upper( my_node->field_name-created_by ).

            my_node->set_field_name_last_changed_by( ).
            update_line-fieldnamelastchangedby = to_upper( my_node->field_name-last_changed_by ).

          ELSE.

            parent_node = NEW ZDMO_cl_rap_node(  ).
            parent_node->set_xco_lib( my_xco_lib ).
            parent_node->set_implementation_type( CONV #( rapbo-implementationtype ) ).
            parent_node->set_data_source_type( CONV #( rapbo-datasourcetype ) ).
            parent_node->set_data_source( CONV #( rapbo_node-parentdatasource ) ).

            IF rapbo-implementationtype = 'managed_semantic' OR
               rapbo-implementationtype = 'unmanaged_semantic'.

              LOOP AT my_node->semantic_key INTO DATA(semantic_key_field).
                IF NOT line_exists( parent_node->semantic_key[ name = semantic_key_field-name ] ).
                  update_line-fieldnameobjectid = to_upper( semantic_key_field-name ).
                  EXIT.
                ENDIF.
              ENDLOOP.

            ENDIF.

          ENDIF.

        CATCH ZDMO_cx_rap_generator INTO DATA(rap_node_exception).
          DATA(exception_text) = rap_node_exception->get_text(  ).
      ENDTRY.

      DATA n TYPE i.
      "get fields

      CLEAR create_log_cba.

      LOOP AT my_node->lt_fields INTO DATA(field)
                                                  WHERE cds_view_field IS NOT INITIAL AND
                                                        name IS NOT INITIAL
            .
        n += 1 .

        create_log_cba_line = VALUE #(  %is_draft = if_abap_behv=>mk-on
                                        %key-NodeUUID = update_line-NodeUUID
                                        %cid_ref  = update_line-%cid_ref
                                        %target   = VALUE #( (
                                                                 %is_draft = if_abap_behv=>mk-on
                                                                 %cid      = |Hugo{ n }| " ggg
                                                                 CdsViewField = field-cds_view_field
                                                                 DbtableField = field-name

                                                                 ) ) ) .
        APPEND create_log_cba_line TO create_log_cba.

      ENDLOOP.


      APPEND update_line TO update.

*    ENDLOOP.

*    APPEND update_bo_line TO update_bo.

    ENDLOOP.


    " Update repository object name proposals of all relevant entities
    " Update the parent entity name
    MODIFY ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
*    ENTITY Project
*      UPDATE FIELDS (
*                      boname
*                      ADTLink
*                     ) WITH update_bo
    ENTITY Node
      UPDATE FIELDS (

        fieldnameobjectid

        viewtypevalue

        fieldnameuuid
        fieldnameparentuuid
        fieldnamerootuuid

        fieldnameetagmaster
        fieldnametotaletag

        fieldnamecreatedat
        fieldnamecreatedby
        FieldNameLastChangedAt
        fieldnamelastchangedby

        FieldNameLocLastChangedAt

                      ) WITH update

        CREATE BY \_Field
                  FIELDS ( CdsViewField DbtableField )
                  WITH create_log_cba


    REPORTED DATA(update_reported)
    FAILED DATA(update_failed)
    MAPPED DATA(update_mapped).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD mandatory_fields_check.

    DATA permission_request TYPE STRUCTURE FOR PERMISSIONS REQUEST ZDMO_C_RAPG_NodeTP.
    DATA reported_node_line LIKE LINE OF reported-node.

    "check permissions of the following fields
    permission_request-%field-FieldNameObjectID = if_abap_behv=>mk-on.

    " Get current field values
    READ ENTITIES OF ZDMO_R_RAPG_ProjectTP IN LOCAL MODE
    ENTITY Node
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(nodes).

    "Do check
    LOOP AT nodes INTO DATA(node).

      GET PERMISSIONS ONLY INSTANCE ENTITY ZDMO_C_RAPG_NodeTP
                FROM VALUE #( ( NodeUUID = node-NodeUUID ) )
                REQUEST permission_request
                RESULT DATA(permission_result)
                FAILED DATA(failed_permission_result)
                REPORTED DATA(reported_permission_result).

      IF permission_result-global-%field-FieldNameObjectID = if_abap_behv=>fc-f-mandatory
               AND node-FieldNameObjectID IS INITIAL.

        APPEND VALUE #( %tky = node-%tky ) TO failed-project.

        CLEAR reported_node_line.
        reported_node_line-%tky = node-%tky.
        reported_node_line-%element-fieldnameobjectid = if_abap_behv=>mk-on.
        reported_node_line-%msg = new_message( id       = 'ZDMO_CM_RAP_GEN_MSG'
                                                         number   = 071
                                                         severity = if_abap_behv_message=>severity-error
                                                         v1       = | object id |
                                                         v2       = |{ node-EntityName }| ).
        APPEND reported_node_line  TO reported-node.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_Field DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CalculateDbtableField FOR DETERMINE ON SAVE
      IMPORTING keys FOR Field~CalculateDbtableField.

ENDCLASS.

CLASS lhc_Field IMPLEMENTATION.

  METHOD CalculateDbtableField.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZDMO_R_RAPG_PROJECTTP DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZDMO_R_RAPG_PROJECTTP IMPLEMENTATION.

  METHOD save_modified.


    DATA ls_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA lt_job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA ls_job_parameters TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA ls_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA lv_jobname TYPE cl_apj_rt_api=>ty_jobname.
    DATA lv_jobcount TYPE cl_apj_rt_api=>ty_jobcount.
    DATA job_text TYPE cl_apj_rt_api=>ty_job_text .

    DATA(xco_lib) = NEW ZDMO_cl_rap_xco_on_prem_lib(  ).

    LOOP AT update-project INTO DATA(update_rapgeneratorbo)
            WHERE ( BoIsGenerated = abap_true AND
                    %control-BoIsGenerated = if_abap_behv=>mk-on ) OR
                  ( BoIsDeleted = abap_true AND
                    %control-BoIsDeleted = if_abap_behv=>mk-on ) .

      " ls_start_info-start_immediately MUST NOT BE USED on premise
      " since it performs a commit work which would cause a dump
      IF xco_lib->on_premise_branch_is_used(  ) = abap_true.
        GET TIME STAMP FIELD DATA(start_time_of_job).
        ls_start_info-timestamp = start_time_of_job.
      ELSE.
        ls_start_info-start_immediately = abap_true.
      ENDIF.
      ls_job_parameters-name = zdmo_cl_rap_node=>job_selection_name.
      ls_value-sign = 'I'.
      ls_value-option = 'EQ'.
      ls_value-low = update_rapgeneratorbo-boname.
      APPEND ls_value TO ls_job_parameters-t_value.
      APPEND ls_job_parameters TO lt_job_parameters.

      IF update_rapgeneratorbo-BoIsGenerated = abap_true.
        DATA(job_template_name) = zdmo_cl_rap_node=>job_template_name.
        job_text = |Generate { update_rapgeneratorbo-boname }|.
      ENDIF.

      IF update_rapgeneratorbo-BoIsDeleted = abap_true.
        job_template_name = zdmo_cl_rap_node=>job_del_template_name.
        job_text = |Delete { update_rapgeneratorbo-boname }|.
      ENDIF.

      TRY.
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = job_template_name
              iv_job_text            = job_text
              is_start_info          = ls_start_info
              it_job_parameter_value = lt_job_parameters
            IMPORTING
              ev_jobname             = lv_jobname
              ev_jobcount            = lv_jobcount
          ).

          UPDATE zdmo_rapgen_bo SET job_count = @lv_jobcount , job_name = @lv_jobname WHERE rap_node_uuid = @update_rapgeneratorbo-rapbouuid.

        CATCH cx_apj_rt INTO DATA(job_scheduling_error).
          "handle exception
          TYPES: BEGIN OF ty_longtext,
                   msgv1(50),
                   msgv2(50),
                   msgv3(50),
                   msgv4(50),
                 END OF ty_longtext.
          DATA: ls_longtext      TYPE ty_longtext.
          ls_longtext = job_scheduling_error->bapimsg-message .

          "reported-rapgeneratorbo
          APPEND VALUE #(  rapbouuid = update_rapgeneratorbo-rapbouuid
*                   %element-%field-(component_request-name) = if_abap_behv=>mk-on
             %msg = new_message(
                      id       = 'ZDMO_CM_RAP_GEN_MSG'
                      number   = 064
                      severity = if_abap_behv_message=>severity-error
                      v1       = |{ ls_longtext-msgv1 }|
                      v2       = |{ ls_longtext-msgv2 }|
                    )
                     )
           TO reported-project.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
