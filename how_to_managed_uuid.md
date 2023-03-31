
# How to generate a RAP BO using table with UUID based key fields 

  For green field scenarios tables with UUID based key fields are very convenient since the RAP framework can easily generate unique values for the key fields so that there is no need to implement a numbering as you would need it when using a semantic key layout.  
  
  In the following the use of the RAP generator is shown.

- In ADT open the repository object `ZDMO_UI_RAPG_PROJECT_O4` which is located in the package `ZDMO_RAP_GENERATOR` (or in `TEST_RAP_GENERATOR`)  

- You can now start the Fiori Elements preview of the RAP Generator business object
  
  1. Select the entity **Project**  
  2. Click on **Preview**   

   ![Start FE preview](/images_how_to_uuid/100_start_FE_preview.png)  

- Press **New Project**   
    
  ![new project](/images_how_to_uuid/110_new_project.png)  

- In the **New Project** dialogue you have to specify parameters for the RAP business object 
   
  | Parameter    | Possible entries    | Explanation |
  |--------------|-----------|------------|
  | Datasource Type | table, cds_view, abstract_entity      |         |
  | Implementation Type | managed, unmanaged  |       |  
  | Binding Type  | odata_v4_ui, odata_v4_api, odata_v2_ui or odata_v2_api |   |
  | Draft enabled | Yes, No |  |   
  | (1) Root Entity Name |  &lt;EntityName&gt; |  Here you should enter a meaningful name for your root entity   |  
  | (2) Data Source Name | &lt;Table Name&gt; | Here you can search (with type ahead support) for an object of the type that you have selected beforehand.    |
  | (3) Package | &lt;Package Name&gt;  | Here you can search (with type ahead support) for a package where the repository objects  will be generated     |   
  
  ![enter project details](/images_how_to_uuid/120_the_new_project_dialog.png)  

- Enter the name of the root entity   

  ![Choose root entity name](/images_how_to_uuid/130_root_entity_name.png)   
  
- Search for the data source ( start to search with the string *UUID*  )
  
  ![select datasource](/images_how_to_uuid/140_select_table_for_root_entity.png)  
  
- Search for the package (here: enter *demo_of* )
  
  ![select package](/images_how_to_uuid/150_select_package.png)  

- Press **New Project**   

- Based on the information that you have entered a new Project will be created that contains the information for the root entity as a starting point. 

  The object page will be opened and you now have to maintain information that the generator needs to know in order to generate the RAP business object. 

  Therefore you have to click on the entry of the root entity (here: **SalesOrder**) in the tab **Entities**  

  ![root entity meta data](/images_how_to_uuid/200_select_root_entity_definition.png)   

- On this page you have to map the fields of your data source to their function in your RAP business object. That means you have to specify which field of your data source is used as an etag or which field is used to store the information who has created or who has changed the business object. 
The generator will try to suggest appropriate mappings based on information such as the underlying data elements and / or field names.
Since the table that we are using in this example uses appropriate data elements for the administrative fields the generator was able to map all fields beside the semantic key automatically. 
When using tables with UUID based keys you have at least to specify one field that contains the semantic key. Since this cannot be retrieved automatically we have to navigate to the tab **Map fields for meta data extension**. 

  ![map field for semantic key](/images_how_to_uuid/300_map_field_for_object_id.png)   


- Here you can select the field that is used as the semantic key via a drop down box (in this case the field SALESORDER_ID). 
 

  ![select field for object id](/images_how_to_uuid/310_select_object_id_field.png)   

- You can now check the mapping of the field names and you can change this mapping if needed.   

  ![other automatically mapped fields](/images_how_to_uuid/320_show_other_mapped_fields.png)   
  
- As a new feature the RAP Generator now allows you to maintain the values of the aliases for the field names of your entity. The generator will propose aliases by creating CamelCase values from the underlying ABAP field names by removing the underscores that are usually used for table field names. That means it will suggest SalesOrderID when the ABAP field name is called SALES_ORDER_ID.  

When you are finished with your changes you have to press the **Apply** button to save your changes. 

  ![proposed repository object names and field names](/images_how_to_uuid/330_show_proposed_repo_obj_names_and_field_names.png)   

- Now we can add a child entity to our RAP generator project. To do so select the root entity **SalesOrder** and then press the button **Add Child based on tables**.     

  ![add child entity](/images_how_to_uuid/400_add_child_entity.png)   

- In the dialogue that opens you have to specify the name of the child entity and you have to select the datasource that is used by the child entity. By selecting the datasource the generator can run determinations for the field mappings before the object page opens.    

  ![add child entity 2](/images_how_to_uuid/500_add_child_entity.png)   

- Since we are using tables with UUID based key fields as the data source we again have to provide a mapping which field of the table is used to store the semantic key field of our child entity.    

  ![maintain fields for child entity](/images_how_to_uuid/530_maintain_fields_for_child.png)   

- Since we have added a child entity the fields for root entity specific repository objects such as the service definition are read only. 
The names that are suggested by the generator follow the VDM naming convention, e.g. "Z" & "R_" & "EntityName" & "TP".  
If objects that have this name already exist in your system the generator will add a suffix (here "01") to the entity name. 
To avoid duplicates it is also possible to add a suffix or prefix to all repository object names on the header level of the rap generator project.    

 ![other item specific fields](/images_how_to_uuid/540_rest_of_item_specifc_settings.png)   


- test  
  
  ![generate_repo_objects](/images_how_to_uuid/550_generate_repo_objects.png)  

- save bo  

  ![save business object](/images_how_to_uuid/600_create_save_bo.png)

- geneate  

  ![Press Generate button](/images_how_to_uuid/600_generate_objects.png)  
  
  
    ![in process](/images_how_to_uuid/610_in_process.png)   

     
    ![finished](/images_how_to_uuid/620_finished.png)


    ![check log](/images_how_to_uuid/650_check_log.png)  


    ![navigate back](/images_how_to_uuid/700_navigate_back_1.png)

    ![result](/images_how_to_uuid/800%20Result.png)









