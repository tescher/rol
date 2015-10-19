/**
 * Created by tescher on 10/8/15.
 */
$(document).ready(function() {

    $("#dialogDonationSummary").dialog({
        modal: true,
        title: "Donation Summary",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Ok",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    $("#linkDonationSummary").click(function(evt) {
        var id = $(this).attr("data-id");
        var objectName = $(this).attr("data-object-name");
        $.ajax({
            url: "/donations/donation_summary?dialog=true&object_name="+objectName+"&id="+id,
            success: function(data) {
                loadDialog("dialogDonationSummary",data, {
                    my: "center top",
                    at: "center bottom",
                    of: $("header")
                });
                $("#dialogDonationSummary #tabs-container").tabs();

            },
            async: false,
            cache: false
        });

        return false;
    });

    $('#donation_report_org').click(function(){
        $('#donation_report_org_types').css('display', ($(this).is(':checked') ? 'block' : 'none'));
    });

    $('#donation_report_org_types').css('display', ($('#donation_report_org').is(':checked') ? 'block' : 'none'));

});

