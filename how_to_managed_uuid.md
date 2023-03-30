
# Open the Fiori Elements preview

- In ADT open the repository object `ZDMO_UI_RAPG_PROJECT_O4` which is located in the package `ZDMO_RAP_GENERATOR` (or in `TEST_RAP_GENERATOR`)  

- You can now start the Fiori Elements preview of the RAP Generator business object
  
  1. Select the entity **Project**  
  2. Click on **Preview**   

   ![Start FE preview](/images_how_to_uuid/100_start_FE_preview.png)  

- In the **New Project** dialogue you have to specify parameters for the RAP business object 
   
  | Parameter    | Possible entries    | Explanation |
  |--------------|-----------|------------|
  | Datasource Type | table, cds_view, abstract_entity      |         |
  | Implementation Type | managed, unmanaged  |       |  
  | Binding Type  | odata_v4_ui, odata_v4_api, odata_v2_ui or odata_v2_api |   |
  | Draft enabled | Yes, No |  |   
  | Root Entity Name |  <EntityName> |  Here you should enter a meaningful name for your root entity |  
  | Data Source Name |  <Table Name> | Here you can search (with type ahead support) for an object of the type that you have selected beforehand. |
  | Package | <Package Name>  | Here you can search (with type ahead support) for a package where the repository objects of the RAP BO will be generated   |   
  
  Press **New Project**   
    
  ![new project](/images_how_to_uuid/110_new_project.png)   


   ![enter project details](/images_how_to_uuid/120_the_new_project_dialog.png)  

      ![Choose root entity name](/images_how_to_uuid/130_root_entity_name.png)   

      ![select datasource](/images_how_to_uuid/140_select_table_for_root_entity.png)  

      ![select package](/images_how_to_uuid/150_select_package.png)  


    ![root entity meta data](/images_how_to_uuid/200_select_root_entity_definition.png)   


    ![map field for semantic key](/images_how_to_uuid/300_map_field_for_object_id.png)   


    ![select field for object id](/images_how_to_uuid/310_select_object_id_field.png)   

    ![other automatically mapped fields](/images_how_to_uuid/320_show_other_mapped_fields.png)   

    ![proposed repository object names and field names](/images_how_to_uuid/330_show_proposed_repo_obj_names_and_field_names.png)   

    ![add child entity](/images_how_to_uuid/400_add_child_entity.png)   

    ![add child entity 2](/images_how_to_uuid/500_add_child_entity.png)   

    ![maintain fields for child entity](/images_how_to_uuid/530_maintain_fields_for_child.png)   

    ![other item specific fields](/images_how_to_uuid/540_rest_of_item_specifc_settings.png)   

    ![generate_repo_objects](/images_how_to_uuid/550_generate_repo_objects.png)  

    ![save business object](/images_how_to_uuid/600_create_save_bo.png)

    ![Press Generate button](/images_how_to_uuid/600_generate_objects.png)  

    ![in process](/images_how_to_uuid/610_in_process.png)   

     
    ![finished](/images_how_to_uuid/620_finished.png)


    ![check log](/images_how_to_uuid/650_check_log.png)  


    ![navigate back](/images_how_to_uuid/700_navigate_back_1.png)

    ![result](/images_how_to_uuid/800%20Result.png)









