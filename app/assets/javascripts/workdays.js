// Use the Bootstrap datepicker

    $(document).ready(function() {
        $(function () {
            $("[id$='datepicker']").datetimepicker({
                format: 'M/D/YYYY'
            });
        });

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
                            loadDialog("dialogAddVolunteer",data);
                        },
                        async: false,
                        cache: false
                    });
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
                    if (data.length < 2) {
                        dialog.dialog("close");
                    } else {
                        dialog.html(data);
                    }
            }
        });

        function loadDialog(id, data) {
            id = "#"+id;
            $(id).html(data);
            $(id).dialog("enable");
            $(id).dialog("open");
        }


    });