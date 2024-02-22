@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forLog'
@ObjectModel.semanticKey: [ 'LogItemNumber' ]
@Search.searchable: true
define view entity ZDMO_C_RAPG_LogTP
  as projection on ZDMO_R_RAPG_LogTP
{
  key LogUUID,
  RapBoUUID,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  LogItemNumber,
  DetailLevel,
  Severity,
  Criticality,
  Text,
  TimeStamp,
  LocalLastChangedAt,
  _Project : redirected to parent ZDMO_C_RAPG_ProjectTP
  
}
