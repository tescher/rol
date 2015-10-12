
$(document).ready(function() {

    $('[id*=project_ids]').multiselect();

    $("#dialogWorkdaySummary").dialog({
        modal: true,
        title: "Workday Summary",
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

    $("#linkWorkdaySummary").click(function(evt) {
        var id = $(this).attr("data-id");
        var objectName = $(this).attr("data-object-name");
        $.ajax({
            url: "/workdays/workday_summary?dialog=true&object_name="+objectName+"&id="+id,
            success: function(data) {
                loadDialog("dialogWorkdaySummary",data, {
                    my: "center top",
                    at: "center bottom",
                    of: $("header")
                });
                $("#tabs-container").tabs();

            },
            async: false,
            cache: false
        });

        return false;
    });




});