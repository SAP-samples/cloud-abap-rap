@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for draft entries'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDMO_R_RAPG_ProjectTPDraft
  as select from zdmo_rapgproj00d
{
  key rapbouuid                     as Rapbouuid,
      boname                        as Boname,
      rootentityname                as Rootentityname,
      namespace                     as Namespace,
      packagename                   as Packagename,
      transportrequest              as Transportrequest,
      skipactivation                as Skipactivation,
      implementationtype            as Implementationtype,
      abaplanguageversion           as Abaplanguageversion,
      packagelanguageversion        as Packagelanguageversion,
      datasourcetype                as Datasourcetype,
      bindingtype                   as Bindingtype,
      draftenabled                  as Draftenabled,
      suffix                        as Suffix,
      prefix                        as Prefix,
      multiinlineedit               as Multiinlineedit,
      customizingtable              as Customizingtable,
      addtomanagebusinessconfig     as Addtomanagebusinessconfig,
      businessconfname              as Businessconfname,
      businessconfidentifier        as Businessconfidentifier,
      businessconfdescription       as Businessconfdescription,
      createdat                     as Createdat,
      createdby                     as Createdby,
      lastchangedby                 as Lastchangedby,
      lastchangedat                 as Lastchangedat,
      locallastchangedat            as Locallastchangedat,
      jsonstring                    as Jsonstring,
      jsonisvalid                   as Jsonisvalid,
      boisgenerated                 as Boisgenerated,
      boisdeleted                   as Boisdeleted,
      appljobloghandle              as Appljobloghandle,
      jobcount                      as Jobcount,
      jobname                       as Jobname,
      adtlink                       as Adtlink,
      ismanaged                     as Ismanaged,
      doesnotuseunmanagedquery      as Doesnotuseunmanagedquery,
      hassematickey                 as Hassematickey,
      draftentitycreationdatetime   as Draftentitycreationdatetime,
      draftentitylastchangedatetime as Draftentitylastchangedatetime,
      draftadministrativedatauuid   as Draftadministrativedatauuid,
      draftentityoperationcode      as Draftentityoperationcode,
      hasactiveentity               as Hasactiveentity,
      draftfieldchanges             as Draftfieldchanges
}
where
      draftentityoperationcode <> 'D' // IF_DRAFT_CONSTANTS=>co_operation_code-deleted
  and draftentityoperationcode <> 'L' // IF_DRAFT_CONSTANTS=>co_operation_code-redeleted
