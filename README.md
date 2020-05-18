# cloud-abap-rap
This repository contains several examples how to develop with the ABAP RESTful Programming Model (RAP) in SAP Cloud Platform, ABAP environment.

## Description

The RAP Generator is a tool that allows you to generate nearly the complete stack of a RAP business object based on one (header) or two (header/item) tables. Lets have a look at the famous flight sample and assume that you have developed two tables

ZRAP_TRAVEL_DEMO
ZRAP:BOOK_DEMO

Based on these two tables the generator will create the repository objects listed below, provided you have named the header entity Travel and the item entity Booking.

CDS views

ZRAP_I_Travel_demo – CDS interface view – Travel
ZRAP_C_Travel_demo – CDS projection view – Travel
ZRAP_I_Booking_demo – CDS interface view – Booking
ZRAP_C_Booking_demo – CDS projection view – BookingIn addition the DDIC views for both interface views are generated as well
ZRAP_VBOOKI_DEMO – DDIC view for Booking entity
ZRAP_VTRAVE_DEMO – DDIC view for Travel entity

Metadata Extensions

ZRAP_C_Travel_demo – for the Travel projection view
ZRAP_C_Booking_demo – for the Booking projection view

Behavior Definition

ZRAP_I_Travel_demo – for the interface view
ZRAP_C_Travel_demo- for the projection view

Behavior implementation

ZRAP_CL_BIL_TRAVEL_#### – for Travel
ZRAP_CL_BIL_BOOKING_#### – for Booking


## Requirements

This sample code does currently only work in SAP Cloud Platform, ABAP Environment where the XCO framework has been enabled via an appropriate feature toggle.
It is not yet available by default in customer systems but can be used in the trial systems of SAP Cloud Platform ABAP Environment. 
For more detailed information please checked out the following blog post:
https://blogs.sap.com/2020/05/17/the-rap-generator

## Download and Installation

The sample code can simply be downloaded using the abapGIT plugin in ABAP Development Tools in Eclispe when working with a trial system of SAP Cloud Platform, ABAP Environment.

## Limitations

There are some limitations that will be fixed once the XCO framework will provide convenient API’s that had to be implemnted via other code for the time being.
The tables are currently being analyzed by creating structures so that I can use RTTI API’s to read the details of the underlying fields.
It is hence not possible to create objects in different software components. You would have thus to create the class in the software component.
Service Definitions and service bindings cannot yet be generated. But these are only a few mouse clicks in ADT.

## Known Issues
The sample code is provided "as-is".

## How to obtain support
If you have problems or questions you can post them in the SAP community https://answers.sap.com/questions/ask.html using the primary tag "SAP Cloud Platform, ABAP Environment" or "ABAP RESTful Programming Model"

