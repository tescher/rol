
$(document).ready(function() {

    $('div[id^="dialogSearch"]').dialog({
        modal: true,
        title: "Search ",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Search",
            click: function() {
                $("#dialogFormSearch" + $(this).dialog("option", "objectName")).submit()
            },
            class: "btn btn-large btn-primary"
        },{
            text: "Cancel",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        open: function (event, ui) {
            $(this).dialog("option", "objectName", $(this).attr('id').substr($(this).attr('id').indexOf("dialogSearch") + 12));
            $(this).dialog("option", "title", "Search " + $(this).dialog("option", "objectName"));
        },

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    $('div[id^="dialogSelect"]').dialog({
        modal: true,
        title: "Select ",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Create New",
            click: function() {
                var objectName = $(this).dialog("option", "objectName");
                $.ajax({
                    url: "/" + objectName.toLowerCase() + "s/new?dialog=true",
                    success: function(data) {
                        loadDialog("dialogNew" + objectName, data);
                    },
                    async: false,
                    cache: false
                });
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

        open: function (event, ui) {
            var objectName = $(this).attr('id').substr($(this).attr('id').indexOf("dialogSelect") + 12);
            $(this).dialog("option", "objectName", objectName);
            $(this).dialog("option", "title", "Select " + objectName);
        },

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    $('div[id^="dialogNew"]').dialog({
        modal: true,
        title: "New ",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Submit",
            click: function() {
                var objectName = $(this).dialog("option", "objectName");
                $("#dialogFormNew" + objectName).submit()
            },
            class: "btn btn-large btn-primary"
        },{
            text: "Cancel",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        open: function() {
            var objectName = $(this).attr('id').substr($(this).attr('id').indexOf("dialogNew") + 9);
            $(this).dialog("option", "objectName", objectName);
            $(this).dialog("option", "title", "New " + objectName);
            $(this).keypress(function(e) {
                if (e.keyCode == $.ui.keyCode.ENTER) {
                    $(this).parent().find("button:eq(0)").trigger("click");
                }
            });
        },

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    $("#linkAddVolunteer").click(function(evt) {
        $.ajax({
            url: "/volunteers/search?dialog=true",
            success: function(data) {
                loadDialog("dialogSearchVolunteers",data);
            },
            async: false,
            cache: false
        });

        return false;
    });

    $("#linkAddOrganization").click(function(evt) {
        $.ajax({
            url: "/organizations/search?dialog=true",
            success: function(data) {
                loadDialog("dialogSearchOrganizations",data);
            },
            async: false,
            cache: false
        });

        return false;
    });

    $(document.body).on('ajax:success', "form[id*='dialog']", function(evt, data) {
        var dialog = $(this).closest("div[id*='dialog']");
        var dialogId = dialog.attr('id');
        var objectName = "";
        if (dialogId.match("^dialogNew")) {
            objectName = dialogId.substr(dialogId.indexOf("dialogNew") + 9);
        } else {
            objectName = dialogId.substr(dialogId.indexOf("dialogSearch") + 12).slice(0, -1);  // Remove "s"
        }
        switch(dialog.attr('id')) {
            case "dialogSearch" + objectName + "s":
                dialog.dialog("close");
                loadDialog("dialogSelect" + objectName, data);
                break;
            case "dialogNew" + objectName:
                if (data.indexOf("dialogFormNew" + objectName) > -1) {  //HACK
                    alert("Error creating " + objectName.toLowerCase() + ", make sure fields are filled correctly");
                    // dialog.dialog("close");
                } else {
                    add_fields("","workday_" + objectName.toLowerCase() + "s", data, ".add_" + objectName.toLowerCase() + "_fields");
                    dialog.dialog("close");
                }
                break;
        }
    });

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
                loadDialog("dialogWorkdaySummary",data);
                $("#tabs-container").tabs();

            },
            async: false,
            cache: false
        });

        return false;
    });




});