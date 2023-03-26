@EndUserText.label: 'Test entity - abstract - child'
@OData.entitySet.name: 'SalesOrderLineItemSet'
@OData.entityType.name: 'SalesOrderLineItem'
define abstract entity ZDMO_TEST_ABSTRACT_CHILDENTITY
{
  key SalesOrderID    : abap.char( 10 );
  key ItemPosition    : abap.char( 10 );
      ProductID       : abap.char( 10 );
      @OData.property.valueControl: 'Note_vc'
      Note            : abap.char( 255 );
      Note_vc         : rap_cp_odata_value_control;
      @OData.property.valueControl: 'NoteLanguage_vc'
      NoteLanguage    : abap.char( 2 );
      NoteLanguage_vc : rap_cp_odata_value_control;
      @OData.property.valueControl: 'CurrencyCode_vc'
      @Semantics.currencyCode: true
      CurrencyCode    : abap.cuky( 5 );
      CurrencyCode_vc : rap_cp_odata_value_control;
      @OData.property.valueControl: 'GrossAmount_vc'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      GrossAmount     : abap.curr( 16, 2 );
      GrossAmount_vc  : rap_cp_odata_value_control;
      @OData.property.valueControl: 'NetAmount_vc'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      NetAmount       : abap.curr( 16, 2 );
      NetAmount_vc    : rap_cp_odata_value_control;
      @OData.property.valueControl: 'TaxAmount_vc'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TaxAmount       : abap.curr( 16, 2 );
      TaxAmount_vc    : rap_cp_odata_value_control;
      DeliveryDate    : rap_cp_odata_v2_edm_datetime;
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      Quantity        : abap.dec( 13, 2 );
      @OData.property.valueControl: 'QuantityUnit_vc'
      @Semantics.unitOfMeasure: true
      QuantityUnit    : abap.unit( 3 );
      QuantityUnit_vc : rap_cp_odata_value_control;

      @OData.property.name: 'ToHeader'
      //A dummy on-condition is required for associations in abstract entities
      //On-condition is not relevant for runtime
      _ToHeader       : association [1] to ZDMO_TEST_ABSTRACT_ROOT_ENTITY on 1 = 1;

}
