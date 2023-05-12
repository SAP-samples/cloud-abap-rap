@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forField'
define view entity ZDMO_R_RAPG_FieldTP
  as select from zdmo_rapgen_flds
  association     to parent ZDMO_R_RAPG_NodeTP as _Node    on $projection.NodeUUID = _Node.NodeUUID
  association [1] to ZDMO_R_RAPG_ProjectTP     as _Project on $projection.RapboUUID = _Project.RapBoUUID
{
  key field_uuid            as FieldUUID,
      node_uuid             as NodeUUID,
      rapbo_uuid            as RapboUUID,
      dbtable_field         as DbtableField,
      cds_view_field        as CdsViewField,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Node,
      _Project

}
