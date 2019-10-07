/**
 * Created by tescher on 10/8/15.
 */
$(document).ready(function() {

    $('[id*=donation_type_ids]').multiselect();

    $('[id^=dialogDonationSummary]').dialog({
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

    $('[id^=linkDonationSummary]').click(function(evt) {
        var id = $(this).attr("data-id");
        var objectName = $(this).attr("data-object-name");
        var nonMonetary = $(this).attr("data-non-monetary");
        $.ajax({
            url: "/donations/donation_summary?dialog=true&object_name="+objectName+"&id="+id+"&non_monetary="+nonMonetary,
            success: function(data) {
                loadDialog("dialogDonationSummary"+(nonMonetary == "true" ? "NonMonetary" : "Monetary"),data, {
                    my: "center top",
                    at: "center bottom",
                    of: $("header")
                });
                $('[id^=dialogDonationSummary] #tabs-container').tabs();

            },
            async: false,
            cache: false
        });

        return false;
    });

    $('#donation_report_object_organizations').click(function(){
        $('#donation_report_org_types').css('display', ($(this).is(':checked') ? 'block' : 'none'));
    });
    $('#donation_report_object_volunteers').click(function(){
        $('#donation_report_org_types').css('display', ($(this).is(':checked') ? 'none' : 'block'));
    });

    $('#donation_report_org_types').css('display', ($('#donation_report_org').is(':checked') ? 'block' : 'none'));

});

