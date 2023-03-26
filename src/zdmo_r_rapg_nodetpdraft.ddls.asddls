@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for draft entries'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDMO_R_RAPG_NodeTPDraft
  as select from zdmo_rapgnode00d
{
  key nodeuuid                      as Nodeuuid,
      rapbouuid                     as Rapbouuid,
      parentuuid                    as Parentuuid,
      rootuuid                      as Rootuuid,
      nodenumber                    as Nodenumber,
      isrootnode                    as Isrootnode,
      entityname                    as Entityname,
      parententityname              as Parententityname,
      datasource                    as Datasource,
      parentdatasource              as Parentdatasource,
      viewtypevalue                 as Viewtypevalue,
      fieldnameobjectid             as Fieldnameobjectid,
      fieldnameetagmaster           as Fieldnameetagmaster,
      fieldnametotaletag            as Fieldnametotaletag,
      fieldnameuuid                 as Fieldnameuuid,
      fieldnameparentuuid           as Fieldnameparentuuid,
      fieldnamerootuuid             as Fieldnamerootuuid,
      fieldnamecreatedby            as Fieldnamecreatedby,
      fieldnamecreatedat            as Fieldnamecreatedat,
      fieldnamelastchangedby        as Fieldnamelastchangedby,
      fieldnamelastchangedat        as Fieldnamelastchangedat,
      fieldnameloclastchangedat     as Fieldnameloclastchangedat,
      cdsiview                      as Cdsiview,
      cdsrview                      as Cdsrview,
      cdspview                      as Cdspview,
      mdeview                       as Mdeview,
      behaviorimplementationclass   as Behaviorimplementationclass,
      servicedefinition             as Servicedefinition,
      servicebinding                as Servicebinding,
      controlstructure              as Controlstructure,
      queryimplementationclass      as Queryimplementationclass,
      drafttablename                as Drafttablename,
      hierarchydistancefromroot     as Hierarchydistancefromroot,
      hierarchydescendantcount      as Hierarchydescendantcount,
      hierarchydrillstate           as Hierarchydrillstate,
      hierarchypreorderrank         as Hierarchypreorderrank,
      locallastchangedat            as Locallastchangedat,
      ischildnode                   as Ischildnode,
      istable                       as Istable,
      iscdsview                     as Iscdsview,
      isabstractentity              as Isabstractentity,
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
