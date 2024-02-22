@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forLog'
define view entity ZDMO_R_RAPG_LogTP
  as select from zdmo_rapgen_log
  association to parent ZDMO_R_RAPG_ProjectTP as _Project on $projection.RapBoUUID = _Project.RapBoUUID
{
  key log_uuid              as LogUUID,
      rapbo_uuid            as RapBoUUID,
      log_item_number       as LogItemNumber,
      detail_level          as DetailLevel,
      severity              as Severity,
      case
        when severity = 'S' then 3  //successul / green
        when severity = 'I' then 0  //information / grey
        when severity = 'W' then 2  //warning / orange
        when severity = 'E' then 1  //error / red
        when severity = 'A' then 1  //error / red
        else 0  //not specified / grey
      end                   as Criticality,
      text                  as Text,
      time_stamp            as TimeStamp,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Project

}
