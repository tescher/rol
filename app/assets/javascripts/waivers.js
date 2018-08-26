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
            text: "Cancel",
            click: function () {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        open: function () {
            $(this).dialog("option", "title", "New Waiver");
        },

        close: function (event, ui) {
            // RO_DO: Something go here?
        }
    });

    $('[id^="linkNewWaiver"]').click(function (evt) {
        $.ajax({
            url: "/waivers/signed_by?dialog=true",
            success: function (data) {
                loadDialog("dialogSignedBy", data);
            },
            async: false,
            cache: false
        });

        return false;
    });

});
