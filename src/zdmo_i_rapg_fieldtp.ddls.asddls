@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forField'
define view entity ZDMO_I_RAPG_FieldTP
  as projection on ZDMO_R_RAPG_FieldTP
{
  key FieldUUID,
  NodeUUID,
  RapboUUID,
  DbtableField,
  CdsViewField,
  LocalLastChangedAt,
  _Node : redirected to parent ZDMO_I_RAPG_NodeTP,
  _Project : redirected to ZDMO_I_RAPG_ProjectTP
  
}
