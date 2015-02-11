// Use the Bootstrap datepicker

$(document).ready(function() {

    $("#dialogSearchVolunteers").dialog({
        modal: true,
        title: "Search Volunteers",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Search",
            click: function() {
                $("#dialogFormSearchVolunteers").submit()
            },
            class: "btn btn-large btn-primary"
        },{
            text: "Cancel",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    $("#dialogSelectVolunteer").dialog({
        modal: true,
        title: "Select Volunteer",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "New Volunteer",
            click: function() {
                $.ajax({
                    url: "/volunteers/new?dialog=true",
                    success: function(data) {
                        loadDialog("dialogNewVolunteer",data);
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

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    $("#dialogNewVolunteer").dialog({
        modal: true,
        title: "New Volunteer",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Submit",
            click: function() {
                $("#dialogFormNewVolunteer").submit()
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

    $(document.body).on('ajax:success', "form[id*='dialog']", function(evt, data) {
        var dialog = $(this).closest("div[id*='dialog']");
        switch(dialog.attr('id')) {
            case "dialogSearchVolunteers":
                dialog.dialog("close");
                loadDialog("dialogSelectVolunteer", data);
                break;
            case "dialogNewVolunteer":
                if (data.indexOf("dialogFormNewVolunteer") > -1) {  //HACK
                    alert("Error creating volunteer, make sure fields filled correctly");
                    // dialog.dialog("close");
                } else {
                    add_fields("","workday_volunteers", data, ".add_fields");
                    dialog.dialog("close");
                }
                break;
        }
    });

    $('[id*=project_ids]').multiselect();




});