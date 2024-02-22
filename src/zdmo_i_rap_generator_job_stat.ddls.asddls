@EndUserText.label: 'Job status of jobs scheduled by the RAP Generator UI'
@ObjectModel.query.implementedBy: 'ABAP:ZDMO_CL_RAP_GEN_GET_JOB_STATUS'
define custom entity ZDMO_I_RAP_GENERATOR_JOB_STAT
{

  key job_name    : abap.char(32);
  key job_count   : abap.char(8);
      job_status  : abap.char(1);
      status_text : abap.char(60);

}
