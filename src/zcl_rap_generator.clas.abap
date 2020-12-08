CLASS zcl_rap_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA filename TYPE string.
    DATA fileext TYPE string.
    DATA filedata TYPE string.
    DATA json_string TYPE string.
    METHODS: get_html RETURNING VALUE(ui_html) TYPE string.
ENDCLASS.



CLASS ZCL_RAP_GENERATOR IMPLEMENTATION.


  METHOD get_html.
    ui_html =
    |<!DOCTYPE HTML> \n| &&
     |<html> \n| &&
     |<head> \n| &&
     |    <meta http-equiv="X-UA-Compatible" content="IE=edge"> \n| &&
     |    <meta http-equiv='Content-Type' content='text/html;charset=UTF-8' /> \n| &&
     |    <title>ABAP File Uploader</title> \n| &&
     |    <script id="sap-ui-bootstrap" src="https://sapui5.hana.ondemand.com/resources/sap-ui-core.js" \n| &&
     |        data-sap-ui-theme="sap_fiori_3_dark" data-sap-ui-xx-bindingSyntax="complex" data-sap-ui-compatVersion="edge" \n| &&
     |        data-sap-ui-async="true"> \n| &&
     |    </script> \n| &&
     |    <script> \n| &&
     |        sap.ui.require(['sap/ui/core/Core'], (oCore, ) => \{ \n| &&
     | \n| &&
     |            sap.ui.getCore().loadLibrary("sap.f", \{ \n| &&
     |                async: true \n| &&
     |            \}).then(() => \{ \n| &&
     |                let shell = new sap.f.ShellBar("shell") \n| &&
     |                shell.setTitle("RAP Generator - JSON File Uploader") \n| &&
     |                shell.setShowCopilot(true) \n| &&
     |                shell.setShowSearch(true) \n| &&
     |                shell.setShowNotifications(true) \n| &&
     |                shell.setShowProductSwitcher(true) \n| &&
     |                shell.placeAt("uiArea") \n| &&
     |                sap.ui.getCore().loadLibrary("sap.ui.layout", \{ \n| &&
     |                    async: true \n| &&
     |                \}).then(() => \{ \n| &&
     |                    let layout = new sap.ui.layout.VerticalLayout("layout") \n| &&
     |                    layout.placeAt("uiArea") \n| &&
     |                    let line2 = new sap.ui.layout.HorizontalLayout("line2") \n| &&
     |                    let line3 = new sap.ui.layout.HorizontalLayout("line3") \n| &&
     |                    let line4 = new sap.ui.layout.HorizontalLayout("line4") \n| &&
     |                    sap.ui.getCore().loadLibrary("sap.m", \{ \n| &&
     |                        async: true \n| &&
     |                    \}).then(() => \{\}) \n| &&
     |                    let button = new sap.m.Button("button") \n| &&
     |                    button.setText("Upload File and generate BO") \n| &&
     |                    button.attachPress(function () \{ \n| &&
     |                        let oFileUploader = oCore.byId("fileToUpload") \n| &&
     |                        if (!oFileUploader.getValue()) \{ \n| &&
     |                            sap.m.MessageToast.show("Choose a file first") \n| &&
     |                            return \n| &&
     |                        \} \n| &&
     |                       oFileUploader.upload() \n| &&
     |                    \}) \n| &&
     |                    line2.placeAt("layout") \n| &&
     |                    line3.placeAt("layout") \n| &&
     |                    line4.placeAt("layout") \n| &&
     |                    sap.ui.getCore().loadLibrary("sap.ui.unified", \{ \n| &&
     |                        async: true \n| &&
     |                    \}).then(() => \{ \n| &&
     |                        var fileUploader = new sap.ui.unified.FileUploader( \n| &&
     |                            "fileToUpload") \n| &&
     |                        fileUploader.setFileType("json") \n| &&
     |                        fileUploader.setWidth("400px") \n| &&
     |                        fileUploader.placeAt("line2") \n| &&
     |                        button.placeAt("line2") \n| &&
     |                        fileUploader.setPlaceholder( \n| &&
     |                            "Choose File for Upload...") \n| &&
     |                        fileUploader.attachUploadComplete(function (oEvent) \{ \n| &&
     |                           alert(oEvent.getParameters().response)  \n| &&
     |                       \})   \n| &&
     | \n| &&
     |                    \}) \n| &&
     |                \}) \n| &&
     |            \}) \n| &&
     |        \}) \n| &&
     |    </script> \n| &&
     |</head> \n| &&
     |<body class="sapUiBody"> \n| &&
     |    <div id="uiArea"></div> \n| &&
     |</body> \n| &&
     | \n| &&
     |</html> |.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    DATA text_line TYPE string.
    DATA text_table TYPE TABLE OF string.

    CASE request->get_method(  ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html(   ) ).

      WHEN CONV string( if_web_http_client=>post ).
        TRY.
* the request comes in with metadata around the actual file data,
* extract the filename and fileext from this metadata as well as the raw file data.
            SPLIT request->get_text(  )  AT cl_abap_char_utilities=>cr_lf INTO TABLE DATA(content).
            READ TABLE content REFERENCE INTO DATA(content_item) INDEX 2.
            IF sy-subrc = 0.

              SPLIT content_item->* AT ';' INTO TABLE DATA(content_dis).
              READ TABLE content_dis REFERENCE INTO DATA(content_dis_item) INDEX 3.
              IF sy-subrc = 0.
                SPLIT content_dis_item->* AT '=' INTO DATA(fn) filename.
                REPLACE ALL OCCURRENCES OF `"` IN filename WITH space.
                CONDENSE filename NO-GAPS.
                SPLIT filename AT '.' INTO filename fileext.
              ENDIF.

            ENDIF.


            DELETE content FROM 1 TO 4.  " Get rid of the first 4 lines

            CLEAR json_string.
            CLEAR text_table.

            LOOP AT content REFERENCE INTO content_item.  " put it all back together again humpdy dumpdy....
              text_line = content_item->*.
              FIND 'WebKitFormBoundary' IN text_line. " get rid of the last lines
              IF sy-subrc = 0.
                EXIT .
              ENDIF.
              APPEND text_line TO text_table. "add text to a table that it is easier to check when debugging than a long string.
              json_string = json_string && text_line.
            ENDLOOP.

            DATA(xco_api) = NEW zcl_rap_xco_cloud_lib( ).
            "DATA(xco_api) = NEW zcl_rap_xco_on_prem_lib(  ).

            DATA(root_node) = NEW zcl_rap_node(  ).
            root_node->set_is_root_node( ).
            root_node->set_xco_lib( xco_api ).

            DATA(rap_bo_visitor) = NEW zcl_rap_xco_json_visitor( root_node ).
            DATA(json_data) = xco_cp_json=>data->from_string( json_string ).
            json_data->traverse( rap_bo_visitor ).

            DATA(rap_bo_generator) = NEW zcl_rap_bo_generator( root_node ).
            DATA(lt_todos) = rap_bo_generator->generate_bo(  ).

            response->set_status( i_code = if_web_http_status=>ok
                                  i_reason = | RAP BO { root_node->rap_root_node_objects-behavior_definition_i  } generated successfully | ).
            response->set_text( | RAP BO { root_node->rap_root_node_objects-behavior_definition_i  } generated successfully | ).

          CATCH cx_root INTO DATA(lx_root).
            response->set_status( i_code = if_web_http_status=>bad_request
                                  i_reason = cl_message_helper=>get_latest_t100_exception( lx_root )->if_message~get_text( ) ).
            response->set_text( cl_message_helper=>get_latest_t100_exception( lx_root )->if_message~get_text( )  ).
            RETURN.
        ENDTRY.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
