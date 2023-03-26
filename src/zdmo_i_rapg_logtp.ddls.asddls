@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forLog'
define view entity ZDMO_I_RAPG_LogTP
  as projection on ZDMO_R_RAPG_LogTP
{
  key LogUUID,
  RapBoUUID,
  LogItemNumber,
  DetailLevel,
  Severity,
  Text,
  TimeStamp,
  LocalLastChangedAt,
  _Project : redirected to parent ZDMO_I_RAPG_ProjectTP
  
}
