
$(document).ready(function() {

    $('[id*=project_ids]').multiselect();

    $("#dialogWorkdaySummary").dialog({
        modal: true,
        title: "Workday Summary (Non-donated hours only)",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Full Report",
            click: function () {
                objectId = $(this).data("object_id");
                objectName = $(this).data("object_name");
                $.ajax({
                    url: "/workdays/participant_report?dialog=true&object_name="+objectName+"&object_id="+objectId,
                    success: function(data) {
                        loadDialog("dialogParticipantReport",data, {
                            my: "center top",
                            at: "center bottom",
                            of: $("header")
                        });
                    },
                    async: false,
                    cache: false
                });
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        },{
            text: "Close",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        open: function (event, ui ) {
            var wHeight = $(window).height();
            $(this).dialog("option", "height", wHeight * 0.8)
        },

        close: function (event, ui ) {
            $(this).dialog("option", "height", "auto")
        }
    });

    $("#dialogParticipantReport").dialog({
        modal: true,
        title: "Workday Report",
        disabled: true,
        autoOpen: false,
        width: 'auto',
        buttons: [{
            text: "Run",
            click: function () {
                $("#dialogParticipantReportForm").submit();
                $(this).close();
             },
            class: "btn btn-large btn-primary"
        },{
            text: "Cancel",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        open: function (event, ui ) {
            var wHeight = $(window).height();
            $(this).dialog("option", "height", "auto")
            $(this).keydown(function(e) {
                if (e.keyCode === $.ui.keyCode.ENTER) {
                    $(this).parent().find("button:eq(1)").trigger("click");
                }
            });
        },

        close: function (event, ui ) {
            $(this).dialog("option", "height", "auto")
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
                $("#dialogWorkdaySummary #tabs-container").tabs();
                $("#dialogWorkdaySummary").data("object_name", objectName);
                $("#dialogWorkdaySummary").data("object_id", id);

            },
            async: false,
            cache: false
        });

        return false;
    });

    $(document).on('change', '#include_inactive', function(evt) {
        $.ajax({
            url: 'update_projects_select',
            type: 'GET',
            dataType: 'script',
            data: {
                include_inactive: $("#include_inactive").is(':checked')
            }
         });
    });




});