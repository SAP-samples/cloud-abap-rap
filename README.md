[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/cloud-abap-rap)](https://api.reuse.software/info/github.com/SAP-samples/cloud-abap-rap)

# Description

This repository contains sample code that helps you to create boiler plate coding for the ABAP RESTful Application Programming Model (RAP) in SAP Cloud Platform, ABAP environment.

## Motivation

The basic idea behind the *RAP Generator* is to make it easier for the developer to create the complete stack of objects that are needed to implement a RAP business object. The goal is to generate most of the boiler plate coding so that the developer can start more quickly to implement the business logic.

The first data source which is supported are tables. When creating new tables for green field scenarios the use of tables with uuid based keys is recommended, so that a managed scenario can be used where no code needs to be implemented for the CRUD operations and earyl numbering can be used. 
The only thing that is left for the developer is to implement determinations, validations and actions. 

For brownfield scenarios where existing business logic does exist to create, update and delete business data an unmanaged scenario can be generated.

As a second data source the RAP generator now also supports CDS views. This way it will be possible to create RAP business objects based on existing CDS views.  

To make the use of the tool as easy as possible the input that is needed by the generator can be provided as a JSON file.
A simple sample of such a JSON file that would generate a managed business object based on the two tables ZRAP_TRAVEL_DEMO and ZRAP_BOOK_DEMO would look like follows.

<pre>
{
  "implementationType": "managed_uuid",
  "namespace": "Z",
  "suffix": "_####",
  "prefix": "RAP",
  "package": "ZRAP_####",
  "datasourcetype": "table",
  "hierarchy": {
    "entityName": "Travel",
    "dataSource": "zrap_travel_demo",
    "objectId": "travel_id",    
    "children": [
      {
        "entityName": "Booking",
        "dataSource": "zrap_book_demo",
        "objectId": "booking_id"               
      }
    ]
  }
}
</pre>

## How to use the RAP Generator (short version)

This is a short description how the RAP Generator can be used.
1. Download this repository into a package e.g. ZRAP_Generator. (in a trial system it might be that somebody else has already downloaded the package) 
2. Duplicate the class zcl_rap_generator.
3. Make sure you have set the following option "Wrap and escape text when pasting into string literal" for your ABAP source code editor in your ADT preferences as described in my blog [How to wrap long strings automatically in ADT](https://blogs.sap.com/2020/07/29/how-to-wrap-long-strings-automatically-in-adt/)
4. Copy one of the json strings for the different scenarios, that you can find in the folder [json_templates](../../tree/master/json_templates)
   between the two single quotes
   <pre>DATA(json_string) = <b>''</b>.</pre>
5. Replace the hastags <b>####</b> that are used as a placeholder by appropriate strings so that they fit to the name of your package and the suffix that you want to use.  
6. Run the class using F9

The class inherits from the class **cl_xco_cp_adt_simple_classrun** which is provided by the XCO framework. This class will catch all exceptions that are thrown by the RAP Generator and it will show the call stack as you are used to it by ADT.

A much more detailed description (including screen shots) can be found in my following blog [The RAP Generator](https://blogs.sap.com/2020/05/17/the-rap-generator/).
   
The description of the technical details of this tool I have moved to this readme.md file instead.

## Supported scenarios

The generator supports various scenarios that are listed in this table

<table style="width:100%">
  <tr>
    <th>implementation type</th>
    <th>key type</th>
    <th>datasource types</th>
    <th>Comment</th>
  </tr>
  <tr>
    <td>managed</td>
    <td>uuid</td>
    <td>table</td>
    <td>Green field scenario with simple data structure</td>
  </tr>
  <tr>
    <td>managed</td>
    <td>semantic key</td>
    <td>table</td>
    <td>Requires external numbering</td>
  </tr>
  <tr>
    <td>unmanaged</td>
    <td>semantic key</td>
    <td>table</td>
    <td>Requires external numbering</td>
  </tr>
   <tr>
    <td>managed</td>
    <td>uuid</td>
    <td>cds view</td>
    <td>no mapping can be generated</td>
  </tr>
  <tr>
    <td>managed</td>
    <td>semantic key</td>
    <td>cds view</td>
    <td>no mapping can be generated</td>
  </tr>
  <tr>
    <td>unmanaged</td>
    <td>semantic key</td>
    <td>cds view</td>
    <td>no mapping can be generated</td>
  </tr>
</table>

## JSON file parameters

The JSON file contains some mandatory properties that are needed for the generation of the repository objects.
The node has a schema that contains an array called children, each of which are also node instances.
This way we can model a root node including its child and grand child nodes in a way that is readable and reusable by the developer.
Let’s start with the explanation of the (mandatory) properties of the business object itself.  

### Mandatory parameters of the root node

#### "implementationType" 
The generator currently supports three implementation types
-	managed_uuid
-	managed_semantic
-	unmanaged_semantic

##### managed_uuid
If the implementation type **managed_uuid** is used, the generator will generate a managed business object that uses internal numbering. It is thus required that the key fields of the nodes and therefore also the key fields of the underlying tables are of type raw(16) (UUID). 

<pre>
key client      : abap.clnt not null;
key uuid        : sysuuid_x16 not null;
</pre>

##### managed_semantic or unmanaged_semantic
If one of the scenarios **managed_semantic** or **unmanaged_semantic** is used, the generator expects that there is a hierarchy of tables where the header table always contains all key fields of the item table.

- Travel
<pre>
key client                : abap.clnt not null;
key travel_id             : /dmo/travel_id not null;
</pre>
- Booking
<pre>
key client                : abap.clnt not null;
key travel_id             : /dmo/travel_id not null;
key booking_id            : /dmo/booking_id not null;
</pre>
- BookingSupplements
<pre>
key client                : abap.clnt not null;
key travel_id             : /dmo/travel_id not null;
key booking_id            : /dmo/booking_id not null;
key booking_supplement_id : /dmo/booking_supplement_id not null;
</pre>

When the implementation type **managed_semantic** is chosen, the generator will generate a business object that uses a managed implementation that requires external numbering whereas **unmanaged_semantic** will generate a business object that uses an unmanaged implementation.

### "bindingtype"

The generator now supports the generation of services of all four binding types that are available as of 2011.

- odata_v4_ui  
- odata_v2_ui  
- odata_v4_web_api   
- odata_v2_web_api   

If no binding type is specified in the JSON file the binding type **OData V4 UI** is used.

To specify another binding type you have to specify it in the JSON configuration file as follows

<pre>
{
  "implementationType": "managed_uuid",
  "namespace": "Z",
  "suffix": "_####",
  "prefix": "",
  "package": "Z_TEST_####",
  "datasourcetype": "table",
  "draftenabled": true,
  <b>"bindingtype": "odata_v4_ui",</b>
  ...
</pre>

### "draftenabled"

The generator now supports the generation of a draft enabled RAP business objects.
It can be set as follows:
<pre>
 "draftenabled": true
</pre>
 The default value is **false**.
 
 When setting this value to **true** you also have to specify the name of draft tables for all nodes using the parameter **"drafttable""** for each node member.
 
 <pre>
{
  "implementationType": "managed_uuid",
  "namespace": "Z",
  "suffix": "_####",
  "prefix": "",
  "package": "Z_TEST_####",
  "datasourcetype": "table",
  <b>"draftenabled": true,</b>
  "bindingtype": "odata_v4_ui",
  "hierarchy": {
    "entityName": "SalesOrder",
    "dataSource": "ZFET_SO_{ unique_number }",
    <b>"drafttable": "ZFET_D_SO_{ unique_number }",</b>
    "objectId": "sales_order",
    "uuid": "sales_order_uuid",

 
 "hierarchy": {
    "entityName": "SalesOrder",
    "dataSource": "Z_SO_####",
    <b>"drafttable": "Z_D_SO_####",</b>
    "objectId": "sales_order",
    "uuid": "sales_order_uuid",

 </pre>
 
 

#### “namespace”
Here you have to specify the namespace of the repository objects. This would typically be the value “Z” or your own namespace if you have registered one.

#### "package"
With the parameter “package” you have to provide the name of a package where all repository objects of your RAP business object will be generated in.

#### "datasourcetype"
The generator supports tables and CDS views as a data source.
Please note that when starting from tables the generator will be able to also generate a mapping whereas a mapping has to be created manually by the developer when starting with CDS views as data sources. You have to provide one of the following values here:
- table
- cds_view

#### “suffix” and “prefix”
These are optional parameters that can be used to tweak the names of the repository objects.

The naming convention used by the generator follows the naming conventions propsed by the Virtual Data Model (VDM) used in SAP S/4 HANA.
For example the name of a CDS interface view would be generated from the above mentioned properties as follows:
`DATA(lv_name) = |{ namespace }I_{ prefix }{ entityname }{ suffix }|.`
The name of the entity which is part of the repository object name is set by the property **“entityName”** on node level (see below).

### Properties of node objects
For each node object you have to specify the following mandatory properties

#### “entityName”
Here you have to specify the name of your entity (e.g. “Travel” or “Booking”). The name of the entity becomes part of the names of the repository objects that will be generated and it is used as the name of associations (e.g. "_Travel").
Please note, that the value of “entityName” must be unique within a business object.

#### “dataSource” and “dataSourceType”
The generator supports the data source types “table” and "cds_view".
The name of the data source is the name of the underlying table or the name of the underlying cds view.

#### “objectId”
With **objectId** we denote a semantic key field that is part of the data source (table or cds view). 
In our travel/booking scenario this would be the field **travel_id** for the Travel entity and **booking_id** for the Booking entity if the data source are tables and it would be **travelid** and **bookingid** if the CDS views of flight demo scenario are used.
For managed scenarios the generator will generate a determination for each objectid.
You also have to specify an **objectid** for semantic scenarios.

#### “uuid”, “parent_uuid”, “root_uuid”
In a managed scenario that uses keys of type **uuid** the tables of a child node must contain a field where the key of the parent entity is stored.
Grandchild nodes and their children must in addition store the values of the key fields of the parent and the root entity.
This is needed amongst others for the locking mechanism.
The generator by default expects the following naming conventions for those fields
- uuid
- parent_uuid
- root_uuid
<br>
If you don’t want to use the same field names in all tables and prefer more descriptive names, such as
<pre>
key travel_uuid       : <b>sysuuid_x16</b> not null;
</pre>
and
<pre>
key booking_uuid      : <b>sysuuid_x16</b> not null;
    travel_uuid       : <b>sysuuid_x16</b> not null;
</pre>
you have to specify these field names in the definition of the node by providing values for `uuid` and `parentUuid` in the definition of the child entity and for `uuid` in the definition of the root entity.

<pre>
...
  "node": {
    "entityName": "Travel",
    "dataSource": "zrap_atrav_0002",
    "dataSourceType" : "table",
    "objectId": "TRAVEL_ID",
    <b>"uuid": "travel_uuid",</b>
    "children": [
      {
        "entityName": "Booking",
        "dataSource": "zrap_abook_0002",
        "dataSourceType" : "table",
        "objectId": "BOOKING_ID",
        <b>"uuid": "booking_uuid",
        "parentUuid": "travel_uuid"</b>
      }
    ]
  }
...
</pre>

#### "lastChangedAt",  "lastChangedBy",  "createdAt" and  "createdBy" 
In a managed scenario it is required that the root entity provides fields to store administrative data when an entity was created and changed and by whom these actions have been performed.
Again the generator assumes some default values for these field names, namely:
- “last_changed_at",
- "last_changed_by",
- "created_at" and
- "created_by"
<br>
If the tables that you are using do not follow this naming convention it is possible to tell the generator about the actual field names by setting these optional properties.

### Optional parameters that can be used for workshop or for templates

The follwoing parameters have been implemented so that it is possible to create RAP business objects including a mapping (if CDS views are used as a data source) and including assocations and value helps.

When using these parameters the json files will become more complicated. As a result the use of these parameters is not recommended if you want to develop a single RAP object.

They will be used in workshops such as TechEd sessions, CodeJams or OpenSAP courses where there is the need to provide participants with complete RAP business objects as a starting point.

#### transactionalbehavior and publishservice

The following parameters have been implemented so that workshop participants should be able to start just with working *read-only* project and can then continue with publishing the service and/or with adding the *transactional* behavior.

##### transactionalbehavior

If <pre> "transactionalbehavior" : false </pre> is set no behavior definition is created.

##### publishservice

If <pre> "publishservice" : false </pre> is set no service definition and no service binding is created.

#### mapping

Using this parameter you can provide the mapping between the field names of the CDS view and the field names used by the legacy business logic if CDS views are used as a data source.
When using tables as data sources this mapping is generated by the generator.
When CDS views are used as a data source such a mapping has be created manually by the developer if it has not been set.

<pre>
{
  "implementationType": "unmanaged_semantic",
  "namespace": "Z",
  "suffix": "_####",
  "prefix": "RAP_",
  "package": "ZRAP_####",
  "datasourcetype": "cds_view",
  "hierarchy": {
    "entityName": "Travel",
    "dataSource": "/DMO/I_Travel_U",
    "objectId": "TravelID",
    "persistenttable": "/dmo/travel",    
    "lastchangedat": "lastchangedat", 
    <b>"mapping": [
      {
        "dbtable_field": "TRAVEL_ID",
        "cds_view_field": "TravelID"
      },
      {
        "dbtable_field": "AGENCY_ID",
        "cds_view_field": "AgencyID"
      },
      {
        "dbtable_field": "CUSTOMER_ID",
        "cds_view_field": "CustomerID"
      },
      {
        "dbtable_field": "BEGIN_DATE",
        "cds_view_field": "BeginDate"
      },
      {
        "dbtable_field": "BOOKING_FEE",
        "cds_view_field": "BookingFee"
      },
      {
        "dbtable_field": "TOTAL_PRICE",
        "cds_view_field": "TotalPrice"
      },
      {
        "dbtable_field": "CURRENCY_CODE",
        "cds_view_field": "CurrencyCode"
      },
      {
        "dbtable_field": "DESCRIPTION",
        "cds_view_field": "Description"
      },
      {
        "dbtable_field": "STATUS",
        "cds_view_field": "Status"
      },
      {
        "dbtable_field": "LASTCHANGEDAT",
        "cds_view_field": "Lastchangedat"
      }
    ],</b>   
    "children": [
      {
        "entityName": "Booking",
        "dataSource": "/DMO/I_Booking_U",
        "objectId": "BookingID",
        "persistenttable": "/dmo/booking"      
      }
    ]
  }
}
</pre>

#### “associations” and “valuehelps”

On node level it is also possible to set information to generate valuehelps and associations.
These properties have been introduced mainly for setups in courses where one would like to be able that participants can generate a business object that contain exactly those associations and value help definitions that are required for the course.
Though it might also be useful for other scenarios as well, you see that the complexity of your JSON file will grow and it might be simpler to code this manually in the CDS views that are generated by the RAP generator.

##### “associations”

Associations is an array of objects where each object represents one association. 
An association needs the several properties
- "name" is the name of the association and its name must start with an underscore '_'.
- "target" is the name of the CDS view that is the target of your associaton
- "cardinality" here you can enter one of the following values
  - "zero_to_one" [0..1]
  - "one" [1]
  - "zero_to_n" [0..n]
  - "one_to_n" [1..n]
  - "one_to_one" [1..1]
- "conditions" is again an array of objects with two properties
  - "projectionField" this is the field ´"$projection.*AgencyID* = _Agency.AgencyID"´
  - "associationField" this is the field ´"$projection.AgencyID = _Agency.*AgencyID*"´
 

```
    "associations": [
      {
        "name": "_Agency",
        "target": "/DMO/I_Agency",
        "cardinality": "zero_to_n",
        "conditions": [
          {
            "projectionField": "AgencyID",
            "associationField": "AgencyID"
          }
        ]
      },
      {
        "name": "_Customer",
        "target": "/DMO/I_Customer",
        "cardinality": "zero_to_n",
        "conditions": [
          {
            "projectionField": "CustomerID",
            "associationField": "CustomerID"
          }
        ]
      }
    ]

```

##### valueHelps

Valuehelps is also an array of objects where each object represents a value help. Each object may contain an addiitional array that contains the information for the additional binding.

- "alias" is the alias of the value help used in the service definition.
- "name" is the name of the CDS view used as a value help
- "localelement" this denotes the field name in your projection view. Since this is already the CDS field name you have to be aware about the naming convertions that are used by the generator when it creates cds fields from the underlying ABAP field names, namely by using the conversion into camelCase notation.

<pre>
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID'  } }]
      <b>AgencyID</b>,
</pre>

- "element" this is the field name in the CDS view that is used as a value help. 

<pre>
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: '<b>AgencyID</b>'  } }]
      AgencyID,
</pre>

- "additionalBinding" is again an array of objects with two properties
- "localElement" these are the following fields 
 
 <pre>
      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                                                 additionalBinding: [ { localElement: '<b>FlightDate</b>',   element: 'FlightDate'},
                                                                      { localElement: '<b>AirlineID</b>',    element: 'AirlineID'},
                                                                      { localElement: '<b>FlightPrice</b>',  element: 'Price', usage: #RESULT},
                                                                      { localElement: '<b>CurrencyCode</b>', element: 'CurrencyCode' } ] } ]
</pre>                                                                                                                                        
                                                                   
 - "element" these are the following fields
 
<pre>
      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                                                 additionalBinding: [ { localElement: 'FlightDate',   element: '<b>FlightDate</b>'},
                                                                      { localElement: 'AirlineID',    element: '<b>AirlineID</b>'},
                                                                      { localElement: 'FlightPrice',  element: '<b>Price</b>', usage: #RESULT},
                                                                      { localElement: 'CurrencyCode', element: '<b>CurrencyCode</b>' } ] } ]
                                                                      
</pre>                                                                  

 - "usage" these are the following (optinonal) fields in a valuehelp
 
<pre>
      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                                                 additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                                                      { localElement: 'AirlineID',    element: 'AirlineID'},
                                                                      { localElement: 'FlightPrice',  element: 'Price', usage: <b>#RESULT</b>},
                                                                      { localElement: 'CurrencyCode', element: 'CurrencyCode' } ] } ]
                                                                      
</pre> 

In order to generate a value help as mentioned above the following entry would have to be added to a node object, here the booking entity.

<pre>      
    "valueHelps": [
          {
            "alias": "Flight",
            "name": "/DMO/I_Flight",
            "localElement": "ConnectionID",
            "element": "ConnectionID",
            "additionalBinding": [
              {
                "localElement": "ConnectionID",
                "element": "ConnectionID"
              },
              {
                "localElement": "CarrierID",
                "element": "AirlineID"
              },
              {
                "localElement": "ConnectionID",
                "element": "ConnectionID"
              }
            ]
          },
          {
            "alias": "Currency",
            "name": "I_Currency",
            "localElement": "CurrencyCode",
            "element": "Currency"
          }
        ]
      }
    ]

</pre>

# Requirements

This sample code does work in 

- SAP Cloud Platform, ABAP Environment where the XCO framework has been enabled as of version 2008.
- SAP S/4HANA 2020

The RAP Generator can not be used in an SAP S/4HANA 1909 system since the XCO libraries are not available in this on premise release. It would however be possible to generate an unmanged RAP business object in one of the supported platforms mentioned above and transport the generated repository objects via abapGit into your 1909 on premise system.

Make sure you have set the following option "Wrap and escape text when pasting into string literal" for your ABAP source code editor in your ADT preferences as described in my blog [How to wrap long strings automatically in ADT](https://blogs.sap.com/2020/07/29/how-to-wrap-long-strings-automatically-in-adt/)

For more detailed information please also check out the following blog post:
https://blogs.sap.com/2020/05/17/the-rap-generator

# Download and Installation

## SAP Cloud Platform ABAP Environment

The sample code can simply be downloaded using the abapGIT plugin in ABAP Development Tools in Eclipse when working with SAP Cloud Platform, ABAP Environment.
For this you have to create a package in the Z-namespace (for example ZRAP_GENERATOR) and link it as an abapGit repository.

## SAP S/4HANA 2020

The sample code can be imported into an on premise system using the abapGit report https://docs.abapgit.org/ .

# Known Issues

The sample code is provided "as-is".

# How to obtain support
If you have problems or questions you can [post them in the SAP Community](https://answers.sap.com/questions/ask.html) using either the primary tag "[SAP Cloud Platform, ABAP environment](https://answers.sap.com/tags/73555000100800001164)" or "[ABAP RESTful Application Programming Model](https://answers.sap.com/tags/7e44126e-7b27-471d-a379-df205a12b1ff)".

# Contributing
This project is only updated by SAP employees.

# License
Copyright (c) 2020 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSES/Apache-2.0.txt) file.
