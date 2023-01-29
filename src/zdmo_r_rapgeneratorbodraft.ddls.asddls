@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS view for draft entities'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDMO_R_RAPGENERATORBODraft
  as select from zdmo_rapgener01d
{
  key rapnodeuuid                   as Rapnodeuuid,
      boname                        as Boname,
      rootentityname                as Rootentityname,
      namespace                     as Namespace,
      packagename                   as Packagename,
      transportrequest              as Transportrequest,
      skipactivation                as Skipactivation,
      implementationtype            as Implementationtype,
      datasourcetype                as Datasourcetype,
      abaplanguageversion           as Abaplanguageversion,
      packagelanguageversion        as Packagelanguageversion,
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
      createdby                     as Createdby,
      createdat                     as Createdat,
      lastchangedby                 as Lastchangedby,
      lastchangedat                 as Lastchangedat,
      locallastchangedat            as Locallastchangedat,
      jsonstring                    as Jsonstring,
      jsonisvalid                   as Jsonisvalid,
      boisgenerated                 as Boisgenerated,
      jobname                       as Jobname,
      jobcount                      as Jobcount,
      adtlink                       as Adtlink,
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
