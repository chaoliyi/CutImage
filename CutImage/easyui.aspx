<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="easyui.aspx.cs" Inherits="CutImage.easyui" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="css/themes/default/easyui.css" rel="stylesheet" />
    <script src="js/jquery.min.js"></script>
    <script src="js/jquery.easyui.min.js"></script>
    <script src="js/easyui-lang-zh_CN.js"></script>
    <script src="SWFUpload/swfupload.js"></script>
    <script src="SWFUpload/handlers.js"></script>
   
    <script type="text/javascript">
        $(function () {
            var swfu = new SWFUpload({
                // Backend Settings
                upload_url: "/ashx/upload.ashx?action=upload",
                post_params: {
                    "ASPSESSID": "<%=Session.SessionID %>"
                },

			    // File Upload Settings
			    file_size_limit: "10 MB",
			    file_types: "*.jpg;*.gif",
			    file_types_description: "JPG Images",
			    file_upload_limit: 0,    // Zero means unlimited

			    // Event Handler Settings - these functions as defined in Handlers.js
			    //  The handlers are not part of SWFUpload but are part of my website and control how
			    //  my website reacts to the SWFUpload events.
			    swfupload_preload_handler: preLoad,
			    swfupload_load_failed_handler: loadFailed,
			    file_queue_error_handler: fileQueueError,
			    file_dialog_complete_handler: fileDialogComplete,
			    upload_progress_handler: uploadProgress,
			    upload_error_handler: uploadError,
			    upload_success_handler: showImage,//uploadSuccess,
			    upload_complete_handler: uploadComplete,

			    // Button settings
			    button_image_url: "/SWFUpload/images/btnbg.png",//设置按钮样式
			    button_placeholder_id: "spanButtonPlaceholder",
			    button_width: 137,
			    button_height: 35,
			    button_text: '<span class="button">选择图片<span class="buttonSmall">(2 MB Max)</span></span>',
			    button_text_style: '.button { font-family: Helvetica, Arial, sans-serif; font-size: 14pt;color:white; } .buttonSmall { font-size: 10pt; }',
			    button_text_top_padding: 6,
			    button_text_left_padding: 6,

			    // Flash Settings
			    flash_url: "/SWFUpload/swfupload.swf",	// Relative to this file
			    flash9_url: "/SWFUpload/swfupload_FP9.swf",	// Relative to this file

			    custom_settings: {
			        upload_target: "divFileProgressContainer"
			    },

			    // Debug Settings
			    debug: false
            });
            //图片截取框拖动和调整大小
            $("#divCutImage").draggable({
                onDrag:onDrag
            }).resizable({
                maxHeight: 200,
                maxWidth: 200,
                minHeight: 100,
                minWidth:100
            });
            //保存头像
            $("#btnCut").click(function () {
                cutImage();
            });
        });
        //Draggable函数
        function onDrag(e) {
            var d = e.data;
            if (d.left < 0) { d.left = 0 }
            if (d.top < 0) { d.top = 0 }
            if (d.left + $(d.target).outerWidth() > $(d.parent).width()) {
                d.left = $(d.parent).width() - $(d.target).outerWidth();
            }
            if (d.top + $(d.target).outerHeight() > $(d.parent).height()) {
                d.top = $(d.parent).height() - $(d.target).outerHeight();
            }
        }
        //图片上传完毕处理函数
        function showImage(file, serverData) {
            //动态调整div大小
            //var data = $.parseJSON(serverData);
            //$("#divShowImage").css("background", "url('" + data.url + "') no-repeat").css("height",data.h).css("width",data.w);
            //显示图片缩略图
            $("#imgPaht").val(serverData);
            $("#divShowImage").css("background", "url('" + serverData + "') no-repeat");
        }
        function cutImage() {
            /*计算截取头像的范围*/
            var x = $("#divCutImage").offset().left - $("#divShowImage").offset().left;
            var y = $("#divCutImage").offset().top - $("#divShowImage").offset().top;
            var width = $("#divCutImage").width();
            var height = $("#divCutImage").height();
            var pars = {
                "x": x,
                "y": y,
                "w": width,
                "h": height,
                "action": "cut",
                "path": $("#imgPaht").val()
            }
            $.post("/ashx/upload.ashx", pars, function (data) {
                var serverData=$.parseJSON(data);
                if (serverData.msg=="ok") {
                    $("#divShowCutImage").html("<img src='"+serverData.path+"'/>")
                } else {
                    alert(serverData.msg);
                }
                
            });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="content">
            <div id="swfu_container" style="margin: 0px 10px;">
                <div>                   
                    <span id="spanButtonPlaceholder"></span>
                    <div id="divFileProgressContainer"></div>
                </div>
                <div id="divShowImage" class="easyui-panel" style="position:relative;overflow:hidden;width:300px;height:300px;">
                    <div id="divCutImage"  style="width:100px;height:100px;border:1px solid red;"></div>
                </div>
                <div id="divShowCutImage"></div>
                <input type="hidden" id="imgPaht" name="imgPaht" value="" />
                <input type="button" id="btnCut" name="btnCut" value="保存截图" />
            </div>
        </div>
    </form>
</body>
</html>
