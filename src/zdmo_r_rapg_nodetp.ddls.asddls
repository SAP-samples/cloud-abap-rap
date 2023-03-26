@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forNode'

define view entity ZDMO_R_RAPG_NodeTP
  as select from zdmo_rapgen_node
  association to parent ZDMO_R_RAPG_ProjectTP as _Project on $projection.RapBoUUID = _Project.RapBoUUID
  composition [0..*] of ZDMO_R_RAPG_FieldTP   as _Field
//  association [0..*] to ZDMO_R_RAPG_NodeTP    as _Entity          on $projection.RapBoUUID = _Entity.RapBoUUID
{

  key node_uuid                      as NodeUUID,
      header_uuid                    as RapBoUUID,
      parent_uuid                    as ParentUUID,
      root_uuid                      as RootUUID,
      node_number                    as NodeNumber,
      is_root_node                   as IsRootNode,
      entity_name                    as EntityName,
      parent_entity_name             as ParentEntityName,
      data_source                    as DataSource,
      parent_data_source             as ParentDataSource,
      view_type_value                as ViewTypeValue,
      field_name_object_id           as FieldNameObjectID,
      field_name_etag_master         as FieldNameEtagMaster,
      field_name_total_etag          as FieldNameTotalEtag,
      field_name_uuid                as FieldNameUUID,
      field_name_parent_uuid         as FieldNameParentUUID,
      field_name_root_uuid           as FieldNameRootUUID,
      field_name_created_by          as FieldNameCreatedBy,
      field_name_created_at          as FieldNameCreatedAt,
      field_name_last_changed_by     as FieldNameLastChangedBy,
      field_name_last_changed_at     as FieldNameLastChangedAt,
      field_name_loc_last_changed_at as FieldNameLocLastChangedAt,
      cds_i_view                     as CdsIView,
      cds_r_view                     as CdsRView,
      cds_p_view                     as CdsPView,
      mde_view                       as MdeView,
      behavior_implementation_class  as BehaviorImplementationClass,
      service_definition             as ServiceDefinition,
      service_binding                as ServiceBinding,
      control_structure              as ControlStructure,
      query_implementation_class     as QueryImplementationClass,
      draft_table_name               as DraftTableName,
      hierarchy_distance_from_root   as HierarchyDistanceFromRoot,
      hierarchy_descendant_count     as HierarchyDescendantCount,
      hierarchy_drill_state          as HierarchyDrillState,
      hierarchy_preorder_rank        as HierarchyPreorderRank,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at          as LocalLastChangedAt,
      cast( case
       when is_root_node = 'X' then ' '
       else 'X'
      end         as abap_boolean    ) as isChildNode,
      
      cast( case
       when _Project.DataSourceType = 'table' then 'X'
       else ' '
      end         as abap_boolean    ) as isTable,
       cast( case
       when _Project.DataSourceType = 'cds_view' then 'X'
       else ' '
      end         as abap_boolean    ) as isCDSview,
       cast( case
       when _Project.DataSourceType = 'abstract_entity' then 'X'
       else ' '
      end         as abap_boolean    ) as isAbstractEntity,
      
      _Field,
      _Project
//      ,
//      _Entity 

}
