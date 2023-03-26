@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forProject'
define root view entity ZDMO_R_RAPG_ProjectTP
  as select from zdmo_rapgen_bo
  composition [0..*] of ZDMO_R_RAPG_LogTP  as _Log
  composition [0..*] of ZDMO_R_RAPG_NodeTP as _Node
{
  key rap_node_uuid                    as RapBoUUID,
      bo_name                          as BoName,
      root_entity_name                 as RootEntityName,
      namespace                        as Namespace,
      package_name                     as PackageName,
      transport_request                as TransportRequest,
      skip_activation                  as SkipActivation,
      implementation_type              as ImplementationType,
      abap_language_version            as AbapLanguageVersion,
      package_language_version         as PackageLanguageVersion,
      data_source_type                 as DataSourceType,
      binding_type                     as BindingType,
      draft_enabled                    as DraftEnabled,
      suffix                           as Suffix,
      prefix                           as Prefix,
      multi_inline_edit                as MultiInlineEdit,
      customizing_table                as CustomizingTable,
      add_to_manage_business_config    as AddToManageBusinessConfig,
      business_conf_name               as BusinessConfName,
      business_conf_identifier         as BusinessConfIdentifier,
      business_conf_description        as BusinessConfDescription,
      @Semantics.systemDateTime.createdAt: true
      created_at                       as CreatedAt,
      @Semantics.user.createdBy: true
      created_by                       as CreatedBy,
      @Semantics.user.lastChangedBy: true
      last_changed_by                  as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                  as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at            as LocalLastChangedAt,
      json_string                      as JsonString,
      json_is_valid                    as JsonIsValid,
      bo_is_generated                  as BoIsGenerated,
      bo_is_deleted                    as BoIsDeleted,
      appl_job_log_handle              as ApplJobLogHandle,
      job_count                        as JobCount,
      job_name                         as JobName,
      adt_link                         as ADTLink,
      is_managed                       as  isManaged,
      does_not_use_unmanaged_query     as doesNotUseUnmanagedQuery,
      has_semantic_key                 as hasSematicKey,
      _Log,
      _Node

}
