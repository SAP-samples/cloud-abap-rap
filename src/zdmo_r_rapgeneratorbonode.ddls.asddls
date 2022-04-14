@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forRAPGeneratorBONode'
define view entity ZDMO_R_RapGeneratorBONode
  as select from zdmo_rapgen_node
  association        to parent ZDMO_R_RapGeneratorBO as _RAPGeneratorBO on $projection.HeaderUUID = _RAPGeneratorBO.RapNodeUUID
  association [1..1] to ZDMO_R_RapGeneratorBONode    as _Parent         on $projection.NodeUUID = _Parent.NodeUUID
  association [0..*] to ZDMO_R_RapGeneratorBONode    as _Child          on $projection.NodeUUID = _Child.ParentUUID
{
  key node_uuid                      as NodeUUID,
      header_uuid                    as HeaderUUID,
      parent_uuid                    as ParentUUID,
      root_uuid                      as RootUUID,
      node_number                    as NodeNumber,
      is_root_node                   as IsRootNode,
      entity_name                    as EntityName,
      parent_entity_name             as ParentEntityName,
      //  data_source_type as DataSourceType,
      data_source                    as DataSource,
      parent_data_source             as ParentDataSource,
      view_type_value                as ViewTypeValue,
      //  namespace as Namespace,
      //  implementation_type as ImplementationType,
      //  draft_enabled as DraftEnabled,
      //  suffix as Suffix,
      //  prefix as Prefix,
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
      hierarchy_drill_state          as HierarchyDrillState, // leaf, expanded, collapsed
      hierarchy_preorder_rank        as HierarchyPreorderRank,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at          as LocalLastChangedAt,
      _RAPGeneratorBO,
      _Parent,
      _Child

}
