/**
 * Created by tescher on 1/27/15.
 */

jQuery(document).ready(function($) {


    $('div[id^="dialogSignedBy"]').dialog({
        modal: true,
        title: "New ",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Submit",
            click: function () {
                var objectName = $(this).dialog("option", "objectName");
                $("#dialogFormNew" + objectName).submit()
            },
            class: "btn btn-large btn-primary"
        }, {
            text: "Cancel",
            click: function () {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        open: function () {
            var objectName = $(this).attr('id').substr($(this).attr('id').indexOf("dialogNew") + 9);
            $(this).dialog("option", "objectName", objectName);
            $(this).dialog("option", "title", "New " + objectName);
            $(this).keydown(function (e) {
                if (e.keyCode === $.ui.keyCode.ENTER) {
                    $(this).parent().find("button:eq(1)").trigger("click");
                }
            });
        },

        close: function (event, ui) {
            // RO_DO: Something go here?
        }
    });

    $('[id^="linkNewWaiver"]').click(function (evt) {
        $.ajax({
            url: "/waivers/signed_by?dialog=true&",
            success: function (data) {
                loadDialog("dialogSignedBy", data);
            },
            async: false,
            cache: false
        });

        return false;
    });

});
