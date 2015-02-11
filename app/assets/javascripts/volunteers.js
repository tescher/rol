// Use the Bootstrap multiselect

    $(document).ready(function() {
        $('[id*=interest_ids]').multiselect();

        $(".multiselect-container").find("label.checkbox").contents().filter(function() { return this.nodeType === 3 }).each(function() {
            var name=$(this).text();
            if (name.substring(0,2) == " *") {
                $(this).replaceWith("<b> "+name.substring(2)+"</b>")
            }
            if (name.substring(0,2) == " /") {
                $(this).replaceWith("<s> "+name.substring(2)+"</s>")
            }
        });


        $("#linkWorkdaySummary").click(function(evt) {
            var volunteer_id = $(this).attr("data-volunteerid");
            $.ajax({
                url: "/workdays/workday_summary?dialog=true&volunteer_id="+volunteer_id,
                success: function(data) {
                    loadDialog("dialogWorkdaySummary",data);
                    $("#tabs-container").tabs();

                },
                async: false,
                cache: false
            });

            return false;
        });

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


    });