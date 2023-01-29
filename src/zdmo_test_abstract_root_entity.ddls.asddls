@EndUserText.label: 'Test entity - abstract - root'
 @OData.entitySet.name: 'SalesOrderSet' 
 @OData.entityType.name: 'SalesOrder'
define abstract entity ZDMO_TEST_ABSTRACT_ROOT_ENTITY 
{
 key SalesOrderID : abap.char( 10 ) ; 
 @OData.property.valueControl: 'Note_vc' 
 Note : abap.char( 255 ) ; 
 Note_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'NoteLanguage_vc' 
 NoteLanguage : abap.char( 2 ) ; 
 NoteLanguage_vc : rap_cp_odata_value_control ; 
 CustomerID : abap.char( 10 ) ; 
 @OData.property.valueControl: 'CustomerName_vc' 
 CustomerName : abap.char( 80 ) ; 
 CustomerName_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'CurrencyCode_vc' 
 @Semantics.currencyCode: true 
 CurrencyCode : abap.cuky( 5 ) ; 
 CurrencyCode_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'GrossAmount_vc' 
 @Semantics.amount.currencyCode: 'CurrencyCode' 
 GrossAmount : abap.curr( 16, 2 ) ; 
 GrossAmount_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'NetAmount_vc' 
 @Semantics.amount.currencyCode: 'CurrencyCode' 
 NetAmount : abap.curr( 16, 2 ) ; 
 NetAmount_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'TaxAmount_vc' 
 @Semantics.amount.currencyCode: 'CurrencyCode' 
 TaxAmount : abap.curr( 16, 2 ) ; 
 TaxAmount_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'LifecycleStatus_vc' 
 LifecycleStatus : abap.char( 1 ) ; 
 LifecycleStatus_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'LifecycleStatusDescription_vc' 
 LifecycleStatusDescription : abap.char( 60 ) ; 
 LifecycleStatusDescription_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'BillingStatus_vc' 
 BillingStatus : abap.char( 1 ) ; 
 BillingStatus_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'BillingStatusDescription_vc' 
 BillingStatusDescription : abap.char( 60 ) ; 
 BillingStatusDescription_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'DeliveryStatus_vc' 
 DeliveryStatus : abap.char( 1 ) ; 
 DeliveryStatus_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'DeliveryStatusDescription_vc' 
 DeliveryStatusDescription : abap.char( 60 ) ; 
 DeliveryStatusDescription_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'CreatedAt_vc' 
 CreatedAt : rap_cp_odata_v2_edm_datetime ; 
 CreatedAt_vc : rap_cp_odata_value_control ; 
 @OData.property.valueControl: 'ChangedAt_vc' 
 ChangedAt : rap_cp_odata_v2_edm_datetime ; 
 ChangedAt_vc : rap_cp_odata_value_control ; 
 
 @OData.property.name: 'ToLineItems' 
//A dummy on-condition is required for associations in abstract entities 
//On-condition is not relevant for runtime 
 _ToLineItems : association [0..*] to ZDMO_TEST_ABSTRACT_CHILDENTITY on 1 = 1; 
    
}
