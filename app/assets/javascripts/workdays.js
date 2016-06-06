
$(document).ready(function() {

    $('[id*=project_ids]').multiselect();

    $("#dialogWorkdaySummary").dialog({
        modal: true,
        title: "Workday Summary",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Printable Report",
            click: function () {
                $(this).dialog("close");
                $.ajax({
                    url: "/workdays/participant_report?dialog=true&object_name="+objectName+"&id="+id,
                    success: function(data) {
                        loadDialog("dialogParticipantReportForm",data, {
                            my: "center top",
                            at: "center bottom",
                            of: $("header")
                        });
                    },
                    async: false,
                    cache: false
                });
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

    $("#dialogParticipantReportForm").dialog({
        modal: true,
        title: "Workday Report",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Run",
            click: function () {
                $(this).submit();
                $(this).dialog("close");
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
            $(this).dialog("option", "height", wHeight * 0.8)
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

            },
            async: false,
            cache: false
        });

        return false;
    });




});