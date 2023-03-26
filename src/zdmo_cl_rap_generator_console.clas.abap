CLASS zdmo_cl_rap_generator_console DEFINITION
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
ENDCLASS.



CLASS ZDMO_CL_RAP_GENERATOR_CONSOLE IMPLEMENTATION.


  METHOD get_json_string.
    json_string = '{' && |\r\n|  &&
                  '"namespace":"Z",' && |\r\n|  &&
                  '"package":"ZDMO_RAP_GENERATOR_3",' && |\r\n|  &&
                  '"dataSourceType":"table",' && |\r\n|  &&
                  '"bindingType":"odata_v4_ui",' && |\r\n|  &&
                  '"implementationType":"managed_uuid",' && |\r\n|  &&
                  '"prefix":"DMO_",' && |\r\n|  &&
                  '"suffix":"",' && |\r\n|  &&
                  '"draftEnabled":true,' && |\r\n|  &&
                  '"multiInlineEdit":false,' && |\r\n|  &&
                  '"isCustomizingTable":false,' && |\r\n|  &&
                  '"addBusinessConfigurationRegistration":false,' && |\r\n|  &&
                  '"transportRequest":"T22K900006",' && |\r\n|  &&
                  '"hierarchy":' && |\r\n|  &&
                  '{' && |\r\n|  &&
                  ' "entityname":"RAP_Gen_Projects",' && |\r\n|  &&
                  ' "dataSource":"ZDMO_RAPGEN_BO",' && |\r\n|  &&
                  ' "objectid":"BO_NAME",' && |\r\n|  &&
                  ' "uuid":"RAP_NODE_UUID",' && |\r\n|  &&
                  ' "parentUUID":"",' && |\r\n|  &&
                  ' "rootUUID":"",' && |\r\n|  &&
                  ' "etagMaster":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "totalEtag":"LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "lastChangedAt":"LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "lastChangedBy":"LAST_CHANGED_BY",' && |\r\n|  &&
                  ' "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  ' "createdAt":"CREATED_AT",' && |\r\n|  &&
                  ' "createdBy":"CREATED_BY",' && |\r\n|  &&
                  ' "draftTable":"ZDMORAP_GEN_P00D",' && |\r\n|  &&
                  ' "cdsInterfaceView":"ZDMO_I_RAP_Gen_ProjectsTP",' && |\r\n|  &&
                  ' "cdsRestrictedReuseView":"ZDMO_R_RAP_Gen_ProjectsTP",' && |\r\n|  &&
                  ' "cdsProjectionView":"ZDMO_C_RAP_Gen_ProjectsTP",' && |\r\n|  &&
                  ' "metadataExtensionView":"ZDMO_C_RAP_Gen_ProjectsTP",' && |\r\n|  &&
                  ' "behaviorImplementationClass":"ZDMO_BP_R_RAP_Gen_ProjectsTP",' && |\r\n|  &&
                  ' "serviceDefinition":"ZDMO_UI_RAP_Gen_Projects",' && |\r\n|  &&
                  ' "serviceBinding":"ZDMO_UI_RAP_Gen_Proj_O4",' && |\r\n|  &&
                  ' "controlStructure":"",' && |\r\n|  &&
                  ' "customQueryImplementationClass":"",' && |\r\n|  &&
                  ' "mapping":' && |\r\n|  &&
                  ' [' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"CLIENT",' && |\r\n|  &&
                  '   "cds_view_field":"Client"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"RAP_NODE_UUID",' && |\r\n|  &&
                  '   "cds_view_field":"ProjectUUID"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"BO_NAME",' && |\r\n|  &&
                  '   "cds_view_field":"BoName"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"ROOT_ENTITY_NAME",' && |\r\n|  &&
                  '   "cds_view_field":"RootEntityName"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"NAMESPACE",' && |\r\n|  &&
                  '   "cds_view_field":"Namespace"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"PACKAGE_NAME",' && |\r\n|  &&
                  '   "cds_view_field":"PackageName"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"TRANSPORT_REQUEST",' && |\r\n|  &&
                  '   "cds_view_field":"TransportRequest"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"SKIP_ACTIVATION",' && |\r\n|  &&
                  '   "cds_view_field":"SkipActivation"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"IMPLEMENTATION_TYPE",' && |\r\n|  &&
                  '   "cds_view_field":"ImplementationType"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"ABAP_LANGUAGE_VERSION",' && |\r\n|  &&
                  '   "cds_view_field":"AbapLanguageVersion"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"PACKAGE_LANGUAGE_VERSION",' && |\r\n|  &&
                  '   "cds_view_field":"PackageLanguageVersion"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"DATA_SOURCE_TYPE",' && |\r\n|  &&
                  '   "cds_view_field":"DataSourceType"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"BINDING_TYPE",' && |\r\n|  &&
                  '   "cds_view_field":"BindingType"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"DRAFT_ENABLED",' && |\r\n|  &&
                  '   "cds_view_field":"DraftEnabled"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"SUFFIX",' && |\r\n|  &&
                  '   "cds_view_field":"Suffix"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"PREFIX",' && |\r\n|  &&
                  '   "cds_view_field":"Prefix"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"MULTI_INLINE_EDIT",' && |\r\n|  &&
                  '   "cds_view_field":"MultiInlineEdit"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"CUSTOMIZING_TABLE",' && |\r\n|  &&
                  '   "cds_view_field":"CustomizingTable"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"ADD_TO_MANAGE_BUSINESS_CONFIG",' && |\r\n|  &&
                  '   "cds_view_field":"AddToManageBusinessConfig"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"BUSINESS_CONF_NAME",' && |\r\n|  &&
                  '   "cds_view_field":"BusinessConfName"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"BUSINESS_CONF_IDENTIFIER",' && |\r\n|  &&
                  '   "cds_view_field":"BusinessConfIdentifier"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"BUSINESS_CONF_DESCRIPTION",' && |\r\n|  &&
                  '   "cds_view_field":"BusinessConfDescription"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"CREATED_AT",' && |\r\n|  &&
                  '   "cds_view_field":"CreatedAt"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"CREATED_BY",' && |\r\n|  &&
                  '   "cds_view_field":"CreatedBy"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"LAST_CHANGED_BY",' && |\r\n|  &&
                  '   "cds_view_field":"LastChangedBy"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "cds_view_field":"LastChangedAt"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "cds_view_field":"LocalLastChangedAt"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"JSON_STRING",' && |\r\n|  &&
                  '   "cds_view_field":"JsonString"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"JSON_IS_VALID",' && |\r\n|  &&
                  '   "cds_view_field":"JsonIsValID"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"BO_IS_GENERATED",' && |\r\n|  &&
                  '   "cds_view_field":"BoIsGenerated"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"BO_IS_DELETED",' && |\r\n|  &&
                  '   "cds_view_field":"BoIsDeleted"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"APPL_JOB_LOG_HANDLE",' && |\r\n|  &&
                  '   "cds_view_field":"ApplJobLogHandle"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"JOB_COUNT",' && |\r\n|  &&
                  '   "cds_view_field":"JobCount"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"JOB_NAME",' && |\r\n|  &&
                  '   "cds_view_field":"JobName"' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "dbtable_field":"ADT_LINK",' && |\r\n|  &&
                  '   "cds_view_field":"AdtLink"' && |\r\n|  &&
                  '  }' && |\r\n|  &&
                  ' ],' && |\r\n|  &&
                  ' "Children":' && |\r\n|  &&
                  ' [' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "entityname":"RAP_Gen_Nodes",' && |\r\n|  &&
                  '   "dataSource":"ZDMO_RAPGEN_NODE",' && |\r\n|  &&
                  '   "objectid":"ENTITY_NAME",' && |\r\n|  &&
                  '   "uuid":"NODE_UUID",' && |\r\n|  &&
                  '   "parentUUID":"HEADER_UUID",' && |\r\n|  &&
                  '   "rootUUID":"",' && |\r\n|  &&
                  '   "etagMaster":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "totalEtag":"",' && |\r\n|  &&
                  '   "lastChangedAt":"",' && |\r\n|  &&
                  '   "lastChangedBy":"",' && |\r\n|  &&
                  '   "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "createdAt":"",' && |\r\n|  &&
                  '   "createdBy":"",' && |\r\n|  &&
                  '   "draftTable":"ZDMORAP_GEN_N00D",' && |\r\n|  &&
                  '   "cdsInterfaceView":"ZDMO_I_RAP_Gen_NodesTP",' && |\r\n|  &&
                  '   "cdsRestrictedReuseView":"ZDMO_R_RAP_Gen_NodesTP",' && |\r\n|  &&
                  '   "cdsProjectionView":"ZDMO_C_RAP_Gen_NodesTP",' && |\r\n|  &&
                  '   "metadataExtensionView":"ZDMO_C_RAP_Gen_NodesTP",' && |\r\n|  &&
                  '   "behaviorImplementationClass":"ZDMO_BP_R_RAP_Gen_NodesTP",' && |\r\n|  &&
                  '   "serviceDefinition":"",' && |\r\n|  &&
                  '   "serviceBinding":"",' && |\r\n|  &&
                  '   "controlStructure":"",' && |\r\n|  &&
                  '   "customQueryImplementationClass":"",' && |\r\n|  &&
                  '   "mapping":' && |\r\n|  &&
                  '   [' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"CLIENT",' && |\r\n|  &&
                  '     "cds_view_field":"Client"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"NODE_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"NodeUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"HEADER_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"ProjectUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"PARENT_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"ParentUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"ROOT_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"RootUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"NODE_NUMBER",' && |\r\n|  &&
                  '     "cds_view_field":"NodeNumber"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"IS_ROOT_NODE",' && |\r\n|  &&
                  '     "cds_view_field":"IsRootNode"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"ENTITY_NAME",' && |\r\n|  &&
                  '     "cds_view_field":"EntityName"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"PARENT_ENTITY_NAME",' && |\r\n|  &&
                  '     "cds_view_field":"ParentEntityName"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"DATA_SOURCE",' && |\r\n|  &&
                  '     "cds_view_field":"DataSource"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"PARENT_DATA_SOURCE",' && |\r\n|  &&
                  '     "cds_view_field":"ParentDataSource"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"VIEW_TYPE_VALUE",' && |\r\n|  &&
                  '     "cds_view_field":"ViewTypeValue"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_OBJECT_ID",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameObjectID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_ETAG_MASTER",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameEtagMaster"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_TOTAL_ETAG",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameTotalEtag"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_PARENT_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameParentUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_ROOT_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameRootUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_CREATED_BY",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameCreatedBy"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_CREATED_AT",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameCreatedAt"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_LAST_CHANGED_BY",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameLastChangedBy"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameLastChangedAt"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"FIELD_NAME_LOC_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "cds_view_field":"FieldNameLocLastChangedAt"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"CDS_I_VIEW",' && |\r\n|  &&
                  '     "cds_view_field":"CdsIView"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"CDS_R_VIEW",' && |\r\n|  &&
                  '     "cds_view_field":"CdsRView"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"CDS_P_VIEW",' && |\r\n|  &&
                  '     "cds_view_field":"CdsPView"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"MDE_VIEW",' && |\r\n|  &&
                  '     "cds_view_field":"MdeView"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"BEHAVIOR_IMPLEMENTATION_CLASS",' && |\r\n|  &&
                  '     "cds_view_field":"BehaviorImplementationClass"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"SERVICE_DEFINITION",' && |\r\n|  &&
                  '     "cds_view_field":"ServiceDefinition"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"SERVICE_BINDING",' && |\r\n|  &&
                  '     "cds_view_field":"ServiceBinding"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"CONTROL_STRUCTURE",' && |\r\n|  &&
                  '     "cds_view_field":"ControlStructure"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"QUERY_IMPLEMENTATION_CLASS",' && |\r\n|  &&
                  '     "cds_view_field":"QueryImplementationClass"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"DRAFT_TABLE_NAME",' && |\r\n|  &&
                  '     "cds_view_field":"DraftTableName"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"HIERARCHY_DISTANCE_FROM_ROOT",' && |\r\n|  &&
                  '     "cds_view_field":"HierarchyDistanceFromRoot"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"HIERARCHY_DESCENDANT_COUNT",' && |\r\n|  &&
                  '     "cds_view_field":"HierarchyDescendantCount"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"HIERARCHY_DRILL_STATE",' && |\r\n|  &&
                  '     "cds_view_field":"HierarchyDrillState"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"HIERARCHY_PREORDER_RANK",' && |\r\n|  &&
                  '     "cds_view_field":"HierarchyPreorderRank"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "cds_view_field":"LocalLastChangedAt"' && |\r\n|  &&
                  '    }' && |\r\n|  &&
                  '   ],' && |\r\n|  &&
                  '   "Children":' && |\r\n|  &&
                  '   [' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "entityname":"RAP_Gen_Fields",' && |\r\n|  &&
                  '     "dataSource":"ZDMO_RAPGEN_FLDS",' && |\r\n|  &&
                  '     "objectid":"DBTABLE_FIELD",' && |\r\n|  &&
                  '     "uuid":"FIELD_UUID",' && |\r\n|  &&
                  '     "parentUUID":"NODE_UUID",' && |\r\n|  &&
                  '     "rootUUID":"RAPBO_UUID",' && |\r\n|  &&
                  '     "etagMaster":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "totalEtag":"",' && |\r\n|  &&
                  '     "lastChangedAt":"",' && |\r\n|  &&
                  '     "lastChangedBy":"",' && |\r\n|  &&
                  '     "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "createdAt":"",' && |\r\n|  &&
                  '     "createdBy":"",' && |\r\n|  &&
                  '     "draftTable":"ZDMORAP_GEN_F00D",' && |\r\n|  &&
                  '     "cdsInterfaceView":"ZDMO_I_RAP_Gen_FieldsTP",' && |\r\n|  &&
                  '     "cdsRestrictedReuseView":"ZDMO_R_RAP_Gen_FieldsTP",' && |\r\n|  &&
                  '     "cdsProjectionView":"ZDMO_C_RAP_Gen_FieldsTP",' && |\r\n|  &&
                  '     "metadataExtensionView":"ZDMO_C_RAP_Gen_FieldsTP",' && |\r\n|  &&
                  '     "behaviorImplementationClass":"ZDMO_BP_R_RAP_Gen_FieldsTP",' && |\r\n|  &&
                  '     "serviceDefinition":"",' && |\r\n|  &&
                  '     "serviceBinding":"",' && |\r\n|  &&
                  '     "controlStructure":"",' && |\r\n|  &&
                  '     "customQueryImplementationClass":"",' && |\r\n|  &&
                  '     "mapping":' && |\r\n|  &&
                  '     [' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '       "dbtable_field":"CLIENT",' && |\r\n|  &&
                  '       "cds_view_field":"Client"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '       "dbtable_field":"FIELD_UUID",' && |\r\n|  &&
                  '       "cds_view_field":"FieldUUID"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '       "dbtable_field":"NODE_UUID",' && |\r\n|  &&
                  '       "cds_view_field":"NodeUUID"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '       "dbtable_field":"RAPBO_UUID",' && |\r\n|  &&
                  '       "cds_view_field":"ProjectUUID"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '       "dbtable_field":"DBTABLE_FIELD",' && |\r\n|  &&
                  '       "cds_view_field":"DbtableField"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '       "dbtable_field":"CDS_VIEW_FIELD",' && |\r\n|  &&
                  '       "cds_view_field":"CdsViewField"' && |\r\n|  &&
                  '      },' && |\r\n|  &&
                  '      {' && |\r\n|  &&
                  '       "dbtable_field":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '       "cds_view_field":"LocalLastChangedAt"' && |\r\n|  &&
                  '      }' && |\r\n|  &&
                  '     ]' && |\r\n|  &&
                  '    }' && |\r\n|  &&
                  '   ]' && |\r\n|  &&
                  '  },' && |\r\n|  &&
                  '  {' && |\r\n|  &&
                  '   "entityname":"RAP_Gen_Log",' && |\r\n|  &&
                  '   "dataSource":"ZDMO_RAPGEN_LOG",' && |\r\n|  &&
                  '   "objectid":"LOG_ITEM_NUMBER",' && |\r\n|  &&
                  '   "uuid":"LOG_UUID",' && |\r\n|  &&
                  '   "parentUUID":"RAPBO_UUID",' && |\r\n|  &&
                  '   "rootUUID":"",' && |\r\n|  &&
                  '   "etagMaster":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "totalEtag":"",' && |\r\n|  &&
                  '   "lastChangedAt":"",' && |\r\n|  &&
                  '   "lastChangedBy":"",' && |\r\n|  &&
                  '   "localInstanceLastChangedAt":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '   "createdAt":"",' && |\r\n|  &&
                  '   "createdBy":"",' && |\r\n|  &&
                  '   "draftTable":"ZDMORAP_GEN_L00D",' && |\r\n|  &&
                  '   "cdsInterfaceView":"ZDMO_I_RAP_Gen_LogTP",' && |\r\n|  &&
                  '   "cdsRestrictedReuseView":"ZDMO_R_RAP_Gen_LogTP",' && |\r\n|  &&
                  '   "cdsProjectionView":"ZDMO_C_RAP_Gen_LogTP",' && |\r\n|  &&
                  '   "metadataExtensionView":"ZDMO_C_RAP_Gen_LogTP",' && |\r\n|  &&
                  '   "behaviorImplementationClass":"ZDMO_BP_R_RAP_Gen_LogTP",' && |\r\n|  &&
                  '   "serviceDefinition":"",' && |\r\n|  &&
                  '   "serviceBinding":"",' && |\r\n|  &&
                  '   "controlStructure":"",' && |\r\n|  &&
                  '   "customQueryImplementationClass":"",' && |\r\n|  &&
                  '   "mapping":' && |\r\n|  &&
                  '   [' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"CLIENT",' && |\r\n|  &&
                  '     "cds_view_field":"Client"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"LOG_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"LogUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"RAPBO_UUID",' && |\r\n|  &&
                  '     "cds_view_field":"ProjectUUID"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"LOG_ITEM_NUMBER",' && |\r\n|  &&
                  '     "cds_view_field":"LogItemNumber"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"DETAIL_LEVEL",' && |\r\n|  &&
                  '     "cds_view_field":"DetailLevel"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"SEVERITY",' && |\r\n|  &&
                  '     "cds_view_field":"Severity"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"TEXT",' && |\r\n|  &&
                  '     "cds_view_field":"Text"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"TIME_STAMP",' && |\r\n|  &&
                  '     "cds_view_field":"TimeStamp"' && |\r\n|  &&
                  '    },' && |\r\n|  &&
                  '    {' && |\r\n|  &&
                  '     "dbtable_field":"LOCAL_LAST_CHANGED_AT",' && |\r\n|  &&
                  '     "cds_view_field":"LocalLastChangedAt"' && |\r\n|  &&
                  '    }' && |\r\n|  &&
                  '   ]' && |\r\n|  &&
                  '  }' && |\r\n|  &&
                  ' ]' && |\r\n|  &&
                  '}' && |\r\n|  &&
                  '}' .
  ENDMETHOD.


  METHOD main.
    TRY.
        DATA rap_generator_exception_occurd TYPE abap_bool.
        DATA(json_string) = get_json_string(  ).

        DATA(on_prem_xco_lib) = NEW zdmo_cl_rap_xco_on_prem_lib(  ).

        IF on_prem_xco_lib->on_premise_branch_is_used( ) = abap_true.
          DATA(rap_generator_on_prem) = ZDMO_cl_rap_generator=>create_for_on_prem_development( json_string ).
          DATA(framework_messages) = rap_generator_on_prem->generate_bo( ).
          rap_generator_exception_occurd = rap_generator_on_prem->exception_occured( ).
          IF rap_generator_exception_occurd = abap_true.
            out->write( |Caution: Exception occured | ) .
            out->write( |Check repository objects of RAP BO { rap_generator_on_prem->get_rap_bo_name(  ) }.| ) .
          ELSE.
            out->write( |RAP BO { rap_generator_on_prem->get_rap_bo_name(  ) }  generated successfully| ) .
          ENDIF.
        ELSE.
          DATA(rap_generator) = ZDMO_cl_rap_generator=>create_for_cloud_development( json_string ).
          framework_messages = rap_generator->generate_bo( ).
          rap_generator_exception_occurd = rap_generator->exception_occured( ).
          IF rap_generator_exception_occurd = abap_true.
            out->write( |Caution: Exception occured | ) .
            out->write( |Check repository objects of RAP BO { rap_generator->get_rap_bo_name(  ) }.| ) .
          ELSE.
            out->write( |RAP BO { rap_generator->get_rap_bo_name(  ) }  generated successfully| ) .
          ENDIF.
        ENDIF.
      CATCH ZDMO_cx_rap_generator INTO DATA(rap_generator_exception).
        out->write( 'RAP Generator has raised the following exception:' ) .
        out->write( rap_generator_exception->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
