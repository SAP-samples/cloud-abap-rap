[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/cloud-abap-rap)](https://api.reuse.software/info/github.com/SAP-samples/cloud-abap-rap)

# Description

The basic idea behind the *RAP Generator* is to ease the life of the developer since it helps you to create most of the boiler plate coding that is needed to implement a RAP business object using the *ABAP RESTful Application Programming Model (RAP)* so that you as a developer can start more quickly to implement the business logic.  
Though there is an ADT-based generator available for SAP BTP, ABAP environment and for on premise and public cloud systems as of SAP S/4HANA 2022 this generator offers some additional features, and especially supports multiple nodes whereas the ADT-based generator only supports one table. In addition, this generator also supports SAP S/4HANA 2021.  

**RAP generates RAP**  
Technically the RAP Generator consists out of a RAP business object `ZDMO_R_RAPG_ProjectTP` that is used to generate other RAP business objects.  
The RAP Generator works similar like the well known **Key user tools** in SAP S/4HANA and uses a Fiori Elements UI. The Fiori Elements UI can be started from within ADT by opening the service binding `ZDMO_UI_RAPG_PROJECT_O2`. There you have to double-click on the entitiy *Project* which starts the Fiori Elements UI without the need to install any additional tool.     

The SAP Fiori elements preview based UI provides value helps for the data that has to be entered and it provides validations and determinations that provide the heavy lifting of specifying which table field is used for which purpose (for example, a field called *local_last_changed_at* or a field based on the data element *abp_locinst_lastchange_tstmpl* will be proposed by the RAP Generator to be used as the etag of an entity).

Once the repository objects are generated, the UI offers an ADT link that lets you conveniently navigate back into ADT to continue to work on your objects.

## What's New 
- The RAP Generator allows to generate an I-view layer beneath the R-view layer as being used in SAP S/4HANA
- The generation and deletion process now leverages the background processing framework (BGPF)
- You can now generate extensible RAP business objects
   - The generator generates the required additional repository objects (include structure, extension include view, ...)   
   - The generator performs the required C0- and C1-release state
- The generator creates _SAP object types_ and _SAP object node types_

# Requirements

This sample code does currently work in:

- SAP BTP, ABAP environment
- SAP S/4HANA, ABAP environment
- SAP S/4HANA 2023
- SAP S/4HANA 2022
- SAP S/4HANA 2021

# How to Guides

- [How to create a managed RAP BO based on tables with UUID based key fields](how_to_managed_uuid.md).

# Download and Installation

## How to Install the RAP Generator

### SAP BTP ABAP Environment and SAP S/4HANA Cloud ABAP Environment

1. Create a package **'ZDMO_RAP_GENERATOR'**.
2. Link this package with the URL of the RAP Generator repository `https://github.com/SAP-samples/cloud-abap-rap`.
3. Use the branch `abap-environment`.
4. Pull changes.
5. Use mass activation to activate the objects that have been imported in step 3.
6. Publish the service binding `ZDMO_UI_RAPG_PROJECT_O2`.

### SAP S/4HANA 2021, 2022 or 2023

1. Create a package **'TEST_RAP_GENERATOR'**.
2. Start the report `ZABAPGIT_STANDALONE`. You might have to download the [source code](https://raw.githubusercontent.com/abapGit/build/main/zabapgit_standalone.prog.abap) of this open source tool.
3. Create an an online repository with the package and with the URL of the RAP Generator repo
   `https://github.com/SAP-samples/cloud-abap-rap` or create an offline repository and download the source code as a ZIP file from `https://github.com/SAP-samples/cloud-abap-rap`. Make sure that you use the appropriate branch `on-prem-2022`, `on-prem-2021` or `on-prem-2023`.   
4. Pull changes.
5. Use mass activation to activate the objects that have been imported in step 3.
6. Publish Service binding `ZDMO_UI_RAPG_PROJECT_O2`

# Known Issues

The sample code is provided "as-is".

Known issues are listed here: [Issues](../../issues)   

## SAP BTP ABAP Environment, SAP S/4HANA ABAP environment and on premise releases

...

## on_premise_2021

- When using the RAP Generator in on-premise systems, you have to make sure that the latest SAPUI5 libraries are installed. If you don’t have the latest version of the SAPUI5 libraries installed you will get no dialogue when choosing the **New Project** button in the RAP Generator.
If the latest SAPUI5 libraries cannot be installed, you can use an implicit enhancement in method `get_sapui5core_resources_url( )` of class `CL_ADT_ODATAV4_FEAP` as described in the following [blog post](https://blogs.sap.com/2022/04/16/how-to-use-the-latest-sapui5-library-for-the-fiori-elements-preview-in-adt/).

# How to Obtain Support

If you have problems or questions, you can post them in the [SAP Community](https://answers.sap.com/questions/ask.html) using either the primary tag or "[ABAP RESTful Application Programming Model](https://answers.sap.com/tags/7e44126e-7b27-471d-a379-df205a12b1ff)".

# Contributing

You can add proposals for enhancements as issues.

# License
Copyright (c) 2023 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSE) file.
