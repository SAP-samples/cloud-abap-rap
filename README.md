[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/cloud-abap-rap)](https://api.reuse.software/info/github.com/SAP-samples/cloud-abap-rap)

# Description

This repository contains sample code that helps you to create boiler plate coding for the ABAP RESTful Application Programming Model (RAP) in SAP BTP, ABAP environment.  

## What's new with 2108

- There are now JSON schemas available that simplyfy the creation of the JSON files that are used as input by the RAP Generator
- Draft tables are now automatically generated without having to specify the table names upfront    
- Support for unmanaged RAP BO's with custom entities for the following data source types  
   - Abstract entities which are for example being generated when a Service Consumption Model is created  
   - DDIC structures  
- Support for Multi-Inline-Edit (see [Blog Post - Generating SAP Fiori table maintenance dialogs using the RAP Generator](https://blogs.sap.com/2021/08/23/generating-sap-fiori-table-maintenance-dialogs-using-the-rap-generator/).
- calling the RAP Generator as an API was made more simple using a static method to accomodate on prem and cloud scenarios. 
  It simply boils down to three lines of code  
  <pre>
     DATA(json_string) = '<your json string>'.
     DATA(rap_generator) = /dmo/cl_rap_generator=>create_for_cloud_development( json_string ).
     DATA(framework_messages) = rap_generator->generate_bo( ).
  </pre>
 
## Motivation

The basic idea behind the *RAP Generator* is to make it easier for the developer to create the complete stack of objects that are needed to implement a RAP business object. The goal is to generate most of the boiler plate coding so that the developer can start more quickly to implement the business logic.  

As an input for the RAP Generator a JSON file is used which als reflects the tree structure of a RAP business object. This way all necessary input data can be entered upfront and can be reused to create similar RAP business objects, for example for testing or training purposes.  

**Datasources**

The first data source which is supported are **tables**. When creating new tables for green field scenarios the use of tables with uuid based keys is recommended, so that a managed scenario can be used where no code needs to be implemented for the CRUD operations and earyl numbering can be used. 
The only thing that is left for the developer is to implement determinations, validations and actions. 

For brownfield scenarios where existing business logic does exist to create, update and delete business data an unmanaged scenario can be generated.

As a second data source the RAP generator supports **CDS views**. This way it will be possible to create RAP business objects based on existing CDS views. 

In addition the generator supports **abstract CDS views** as a third data source. This way you can now easily leverage the abstract entities that are generated when creating a *Service Consumption Model*. In the JSON configuration file both types of CDS views are denoted as **"datasource" : "cds_view"**.  The generator automatically detects which entity type is used and will use the appropriate XCO API.

As a third and fourth data source there is now support for **DDIC structures** and **ABAP types**. Through the support of DDIC structures scenarios can be addressed that so far have been implemented using code based implementation using SEGW and the binding of DDIC structures. The support of ABAP types is so far limited to ABAP types that itself are based on DDIC structures. So for example ABAP type definitions that you may find in the model provider class of a SEGW project where entity types have been created using the binding of a DDIC structure.  

To make the use of the tool as easy as possible the input that is needed by the generator can be provided as a **JSON file**. This JSON file is based on a schema so that there is a input help and validity check when a JSON Editor such as Visual Studio Code is used.  

**JSON schemas**

In this folder [json_schemas](../../tree/master/json_schemas) JSON schemas are provided that can be used when using an appropriate JSON editor such as Visual Studio Code. Right now there is just one schema that contains all properties that can be used for the most common scenarios.
 
It is planned to add additional schemas that make some or more fields and their values mandatory, e.g. a JSON schema for the scenario where a RAP BO shall be generated as a maintenace UI for a customizing table.  

**JSON templates**

 In this folder [json_templates](../../tree/master/json_templates) you will find sample JSON files for different scenarios that should help you to create your own json files that are needed as an input of the RAP Generator.   

## Sample JSON file - managed scenario with semantic keys

A simple sample of such a JSON file that would generate a managed business object based on the two tables **/dmo/a_travel_d** and **/dmo/a_booking_d** would look like follows.

<pre>
{
    "$schema": "https://raw.githubusercontent.com/SAP-samples/cloud-abap-rap/main/json_schemas/RAPGenerator-schema-all.json",
    "namespace": "Z",
    "dataSourceType": "table",
    "implementationtype": "managed_uuid",
    "bindingType": "odata_v4_ui",
    "package": "Z_###_YOUR_PACKAGE",
    "draftenabled": true,
    "prefix": "",
    "suffix": "",
    "hierarchy": {
        "entityName": "Travel",
        "dataSource": "/dmo/a_travel_d",
        "objectId": "travel_id",
        "uuid": "travel_uuid",
        "etagMaster": "local_last_changed_at",
        "lastChangedAt": "last_changed_at",
        "lastChangedBy": "last_changed_by",
        "localInstanceLastChangedAt": "local_last_changed_at",
        "createdAt": "created_at",
        "createdBy": "created_by",
        "children": [
            {
                "entityName": "Booking",
                "dataSource": "/dmo/a_booking_d",
                "objectId": "booking_id",
                "uuid": "booking_uuid",
                "parentUuid": "parent_uuid",
                "etagMaster": "local_last_changed_at",
                "localInstanceLastChangedAt": "local_last_changed_at",
                "children": [
                    {
                        "entityName": "Supplements",
                        "dataSource": "/dmo/a_bksuppl_d",
                        "objectId": "booking_supplement_id",
                        "uuid": "booksuppl_uuid",
                        "parentUuid": "parent_uuid",
                        "etagMaster": "local_last_changed_at",
                        "localInstanceLastChangedAt": "local_last_changed_at"
                       
                    }
                ]
            }
        ]
    }
}
</pre>

## How to use the RAP Generator 

The package **`/DMO/RAP_Generator`** has been imported to all trial systems for your convenience.

This is a short description how the RAP Generator can be used.
1. Make sure you have set the following option **Wrap and escape text when pasting into string literal** for your ABAP source code editor in your ADT preferences as described in my blog [How to wrap long strings automatically in ADT](https://blogs.sap.com/2020/07/29/how-to-wrap-long-strings-automatically-in-adt/)  
2. Create an class **zcl_rap_generator_console_####** in your package using the following code as a template. You can duplicate the class **`/dmo/cl_rap_generator_console`** for that.

<pre>
CLASS zcl_rap_generator_console_## DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  PROTECTED SECTION.
    METHODS main REDEFINITION.
    METHODS get_json_string
      RETURNING VALUE(json_string) TYPE string.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_rap_generator_console_## IMPLEMENTATION.

  METHOD main.
    TRY.
        DATA(json_string) = get_json_string(  ).
        DATA(rap_generator) = /dmo/cl_rap_generator=>create_for_cloud_development( json_string ).
        "DATA(rap_generator) = /dmo/cl_rap_generator=>create_for_S4_2020_development( json_string ).
        DATA(framework_messages) = rap_generator->generate_bo( ).
        IF rap_generator->exception_occured( ).
          out->write( |Caution: Exception occured | ) .
          out->write( |Check repository objects of RAP BO { rap_generator->get_rap_bo_name(  ) }.| ) .
        ELSE.
          out->write( |RAP BO { rap_generator->get_rap_bo_name(  ) }  generated successfully| ) .
        ENDIF.
        out->write( |Messages from framework:| ) .
        LOOP AT framework_messages INTO DATA(framework_message).
          out->write( framework_message ).
        ENDLOOP.
      CATCH /dmo/cx_rap_generator INTO DATA(rap_generator_exception).
        out->write( 'RAP Generator has raised the following exception:' ) .
        out->write( rap_generator_exception->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_json_string.
    json_string = '{ "Info" : "to be replaced with your JSON string" }' .
  ENDMETHOD.

ENDCLASS.
</pre>

4. Copy the json string shown above or one of the json strings for the different scenarios, that you can find in the folder [json_templates](../../tree/master/json_templates)
   between the two single quotes
   <pre>DATA(json_string) = <b>''</b>.</pre>
5. Adapt the value for the parameter "package" : "Z_###_YOUR_PACKAGE" 
   that is used as a placeholder so that it fits to the name of your package. You can choose to use a suffixand the suffix that you want to use.  
6. Run the class using F9

The class inherits from the class **cl_xco_cp_adt_simple_classrun** which is provided by the XCO framework. This class will catch all exceptions that are not chatched by the RAP Generator. The generator provides a list of warnings and messages that you will also see when you check the generated reposiotry objects in ADT. When an exception occurs that is not chatched by the generator the class will show the call stack as you are used to it by ADT.  

A much more detailed description (including screen shots and a video) can be found in my following blog posts:

- [How to use the RAP Generator?](https://blogs.sap.com/2020/09/11/how-to-use-the-rap-generator/)  
- [How to use the RAP Generator in SAP S/4HANA on premise?](https://blogs.sap.com/2021/06/16/how-to-use-the-rap-generator-in-sap-s-4hana-on-premise/)  
   
The description of the technical details of this tool I have moved to this readme.md file instead.

## Supported scenarios

The generator supports various implementation type ("implementationtype")

- "managed_uuid"
- "managed_semantic"
- "unmanaged_semantic"

in combination with the various supported data sources types ("dataSourceType").

- "table"
- "cds_view"
- "structure"
- "abap_type"

Some of them also support draft.


## JSON file parameters

The JSON file contains some mandatory properties that are needed for the generation of the repository objects.
The node has a schema that contains an array called children, each of which are also node instances.
This way we can model a root node including its child and grand child nodes in a way that is readable and reusable by the developer.
Let’s start with the explanation of the (mandatory) properties of the business object itself.  

### Mandatory parameters of the root node

#### "implementationType" 

The generator currently supports three implementation types
-	managed_uuid
-	managed_semantic_key
-	unmanaged_semantic_key

##### "managed_uuid" 

If the implementation type **managed_uuid** is used, the generator will generate a managed business object that uses internal numbering. It is thus required that the key fields of the nodes and therefore also the key fields of the underlying tables are of type raw(16) (UUID). 

<pre>
key client      : abap.clnt not null;
key uuid        : sysuuid_x16 not null;
</pre>

##### "managed_semantic" and "unmanaged_semantic"

If one of the scenarios **"managed_semantic"** or **"unmanaged_semantic"** is used, the generator expects that there is a hierarchy of tables where the header table always contains all key fields of the item table.

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

#### “namespace”
Here you have to specify the namespace of the repository objects. This would typically be the value **“Z”** or your own namespace **"/namespace/"** if you have registered one.

#### "package"
With the parameter **“package”** you have to provide the name of a package where all repository objects of your RAP business object will be generated in.
Please note that in on premise systems the ABAP language version of the package must match static method being used for creating the RAP Generator object.

#### "datasourcetype"
The generator supports tables and CDS views as a data source.
Please note that when starting from tables the generator will be able to also generate a mapping whereas a mapping has to be created manually by the developer when starting with CDS views as data sources. You have to provide one of the following values here:
- table
- cds_view

### Optional parameters of the root node

#### "draftenabled"

Using the boolean parameter **"draftenabled"** you can specify that the generated RAP object supports draft. 

New in the 2108 release is the feature that the generator will automatically generated appropriate draft tables whithout the need to specifiy the names of the draft tables beforehand. Please note that you can nevertheless specifiy the names of the draft tables for each node of the compostion tree using the parameter **"draftTable"**.

#### "transportrequest"

You can now provide the name of a transport request that shall be used for all objects that are being generated. If no transport request is specified the RAP Generator will first search for any modifiable transport that fits to the transport layer of the package which belongs to the developer.

If not such transport is found a new transport request is being created.

#### “suffix” and “prefix”
These are optional parameters that can be used to tweak the names of the repository objects.

The naming convention used by the generator follows the naming conventions propsed by the Virtual Data Model (VDM) used in SAP S/4 HANA.
For example the name of a CDS interface view would be generated from the above mentioned properties as follows:
`DATA(lv_name) = |{ namespace }I_{ prefix }{ entityname }{ suffix }|.`
The name of the entity which is part of the repository object name is set by the property **“entityName”** on node level (see below).

### Mandatory properties of node objects
For each node object must specify the following mandatory properties

#### “entityName”
Here you have to specify the name of your entity (e.g. “Travel” or “Booking”). The name of the entity becomes part of the names of the repository objects that will be generated and it is used as the name of associations (e.g. "_Travel").
Please note, that the value of “entityName” must be unique within a business object.

#### “dataSource” and “dataSourceType”
The generator supports the data source types **“table”**, **"cds_view"** (views, view entities, abstract entities and custom entities), **structure** or **abap_type**
The name of the data source is the name of the underlying table, the name of the underlying cds view, the name of the underlying DDIC structure or the name of the ABAP type. The latter uses the format (myclass_my_type_name=>mytype_name)

#### “objectId”
With **objectId** we denote a semantic key field that is part of the data source (table, cds view, structure or ABAP type). 
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

#### etag support

OData services need to have etags in order to support optimistic locking. In addition the RAP framework supports to update automatically administrative fields that contain the information when an entity has been created, updated and by whom these actions have been performed.  For this appropriate annoations have to be set in the CDS interface views.  
In addition to set these annotions in the CDS views it is required to specify which field plays the role of an etag in the behavior definition of your RAP business object. So we have to provide both informations:   
- fields that contain administrative information (for managed scenarios)   
- fields that act as etag for an entity ("etagMaster")
- field that acts as the etag for the whole business object ("totalEtag") in case you are using a draft scenario   

##### etagMaster

Since eTags are required for each entity when consuming the RAP BO via OData this schema enforces you to specify the field of the datasource that contains a timestamp, a hash value, or any other versioning that precisely identifies the version of the data set.

##### totalEtag  ( only needed for the root entity)

A total etag field is mandatory for the root entity when using draft. It must be different from the field that is defined as the etagMaster.

##### "lastChangedAt",  "lastChangedBy",  "createdAt", "createdBy" and "localInstanceLastChangedAt"

In a managed scenario it is required that the root entity provides fields to store administrative data when an entity was created and changed and by whom these actions have been performed.

Again the generator assumes some default values for these field names, namely:
- “last_changed_at",
- "last_changed_by",
- "created_at" and
- "created_by"

<br>
If the tables that you are using do not follow this naming convention it is possible to tell the generator about the actual field names by setting these optional properties.

A good example is the table which is used in the Flight reference draft scenario where we need the following mapping

<pre>
    "lastChangedAt": "last_changed_at",
    "lastChangedBy": "local_last_changed_by",
    "createdAt": "local_created_at",
    "createdBy": "local_created_by",
    "localInstanceLastChangedAt": "local_last_changed_at",
</pre>

In draft scenarios the fields used as etagMaster and totalEtag will be mapped as follows

### Optional parameters for node

#### drafttable

When you specify that a RAP business object shall support draft using the parameter **"draftenabled" : true** you can specifiy the name of the draft table that is being generated for each node using the following syntax

<pre>
"drafttable": "zd_book_0000",
</pre>

If no name is provided upfront the generator will generate a valid draft table name using the following string template:

`to_upper( namespace ) &&  to_upper( prefix )  && to_upper( lv_entityname ) && hex_number && 'D' && to_upper( suffix  ).`

where the a hexadecimal number is calculated to get a unique repository object name that has not been used so far.

# Changing the repository object names of the generated objects

The names of the repository objects that are generated by the RAP Generator try to follow the naming conventions used in SAP S/4 HANA development and the naming conventions that you are used to when working with ADT.

The generator uses string templates that contain the *namespace*, the *prefix* the *entityname* and the **suffix** together with naming conventions such as "I_" for interface views.

**"draftTable"**  
<pre>|{ namespace }{ prefix }{ lv_entityname }{ unique_hex_number }D{ suffix }|.</pre>  
**"cdsInterfaceView"**  
<pre>|{ namespace }I_{ prefix }{ entityname }{ suffix }|.</pre>    
**"cdsProjectionView"**  
<pre>|{ namespace }C_{ prefix }{ entityname }{ suffix }|.</pre>    
**"metadataExtensionView"**  
<pre>|{ namespace }C_{ prefix }{ entityname }{ suffix }|.</pre>    
**"behaviorImplementationClass"**  
<pre>|{ namespace }BP_I_{ prefix }{ entityname }{ suffix }|.</pre>    
**"serviceDefinition"**  
<pre>|{ namespace }{ prefix }{ entityname }{ suffix }|.</pre>    
**"serviceBinding"**  
<pre>|{ namespace }{ binding }{ prefix }{ entityname }{ suffix }{ protocol_version }|.</pre>    
**"controlStructure"**  
<pre>|{ namespace }S{ prefix }{ entityname }_X{ suffix }|.</pre>    
**"customQueryImplementationClass"**  
<pre>|{ namespace }CL_CE_{ prefix }{ entityname }{ suffix }|.</pre>    

If you are not happy with these proposals you can override these settings by providing appropriate proposals in your JSON configuration file.

So it would be technically possible to set the following names for the repository objects:
<pre>
        "entityName": "Travel",
        "dataSource": "/dmo/a_travel_d",
        "objectId": "travel_id",
        "uuid": "travel_uuid",
        "etagMaster": "local_last_changed_at",
        "lastChangedAt": "last_changed_at",
        "lastChangedBy": "last_changed_by",
        "localInstanceLastChangedAt": "local_last_changed_at",
        "createdAt": "created_at",
        "createdBy": "created_by",
        "draftTable": "ZH34HJ4545",
        "cdsInterfaceView": "ZI_H34HJ4545",
        "cdsProjectionView": "ZP_H34HJ4545",
        "metadataExtensionView": "ZP_H34HJ4545",
        "behaviorImplementationClass": "ZCL_P_H34HJ4545",
        "serviceDefinition": "ZSD_H34HJ4545",
        "serviceBinding": "ZSD_H34HJ4545_O4",
        "controlStructure": "ZX_H34HJ454d",
        "customQueryImplementationClass": "ZCL_CE_H34HJ454d",
</pre>
Please note:
There is no setting available for some repository object names such as the behavior definition since the name of the behavior definition must match the name of the CDS interface view of your root entity. The same is true for the name of the behvarior projection that must match the name of the projection view of your root entity.


# Additional parameters for workshops and enhanced scenarios

The RAP Generator has been used to generate repository objects for various hands-on sessions at SAP TechEd and in the openSAP courses that have been offered recently for the ABAP RESTful Programming Model and for SAP Fiori.  

Here additional requirements had to be met such as creating repository objects with additional fields that are not part of the data source or adding additional value helps and association upfront. These requirements meant to offer the option to add this additional information in the configuration JSON file as well.  

As a result the JSON files used in such scenarios become more complex and it would not be helpful to offer all these options to the developer that just wants to create a RAP business object as a starter object.

So I have decided to provide the information about these advanced features that are quite valuable if you have the need for them in a separate readme file that you can find here:

[Additional parameters for workshops](optional_parameters.md).

# Requirements

This sample code does currently only work in SAP BTP, ABAP environment where the XCO framework has been enabled as of version 2008.

Make sure you have set the following option "Wrap and escape text when pasting into string literal" for your ABAP source code editor in your ADT preferences as described in my blog [How to wrap long strings automatically in ADT](https://blogs.sap.com/2020/07/29/how-to-wrap-long-strings-automatically-in-adt/)

For more detailed information please also check out the following blog post:
https://blogs.sap.com/2020/05/17/the-rap-generator

# Download and Installation

In the trial systems of the ABAP Environment in SAP BTP there is no need to install the RAP Generator since it has been been installed and is updated everytime a new version or fix has been available via GitHub.  

When you want to install this sample code in your own ABAP Environment systems you can simply download it using the abapGIT plugin in ABAP Development Tools in Eclipse when working with SAP BTP, ABAP environment. For this you have to create a package in the /DMO/-namespace (for example /DMO/RAP_GENERATOR) and link it as an abapGit repository.

Please make sure that you use this URL

https://github.com/SAP-samples/cloud-abap-rap/tree/main

so that you have used the "main" branch.

It is also possible to install the RAP Generator in an on-premise system as of SAP S/4HANA 2020. For this you have to set up the namespace `/DMO/`in your on premise system as described in the setup guide for the new [ABAP Flight Reference Scenario for the ABAP RESTful Application Programming Model](https://github.com/SAP-samples/abap-platform-refscen-flight/blob/On-Premise-2020/README.md#set-up-namespace).

And for **on premise** systems you have to use the branch **On-Premise-2020** https://github.com/SAP-samples/cloud-abap-rap/tree/On-Premise-2020

# Known Issues

The sample code is provided "as-is".

It is currently not possible to set the names of the repository objects used by the virtual root node that is implicitly generated by the generator when using customizing tables with multi inline edit capabilities.


# How to obtain support
If you have problems or questions you can [post them in the SAP Community](https://answers.sap.com/questions/ask.html) using either the primary tag "[SAP BTP, ABAP environment](https://answers.sap.com/tags/73555000100800001164)" or "[ABAP RESTful Application Programming Model](https://answers.sap.com/tags/7e44126e-7b27-471d-a379-df205a12b1ff)".

# Contributing
You can add proposals for enhancements as issues. 

# License
Copyright (c) 2020 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSE) file.
