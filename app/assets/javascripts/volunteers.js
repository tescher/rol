// Use the Bootstrap multiselect

$(document).ready(function() {

    // Extend JQuery with presence function
    $.fn.presence = function () {
        return this.length !== 0 && this;
    };


    $('[id*=interest_ids], [id*=volunteer_category_ids]').multiselect();

    $('[id*=interest_ids].read-only, [id*=volunteer_category_ids].read-only').next('.btn-group').find('input').each(function(){
        $(this).prop('disabled', true);
    });

    $(".multiselect-container").find("label.checkbox").contents().filter(function() { return this.nodeType === 3 }).each(function() {
        var name=$(this).text();
        if (name.substring(0,2) == " *") {
            $(this).replaceWith("<b> "+name.substring(2)+"</b>")
        }
        if (name.substring(0,2) == " /") {
            $(this).replaceWith("<s> "+name.substring(2)+"</s>")
        }
    });

    // Address checker

    $("#linkAddressCheck").click(function(evt) {
        $.ajax({
            url: "address_check",
            success: function(data) {
                loadDialog("dialogAddressCheck",data);
            },
            async: false,
            cache: false
        });

        return false;
    });

    $("#linkWorkdaySummary").click(function(evt) {
        var id = $(this).attr("data-id");
        var objectName = $(this).attr("data-object-name");
        $.ajax({
            url: "/workdays/workday_summary?dialog=true&object_name="+objectName+"&id="+id,
            success: function(data) {
                loadDialog("dialogWorkdaySummary", data, {
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


    $("#dialogAddressCheck").dialog({
        modal: true,
        title: "Address Check",
        width: 450,
        disabled: true,
        autoOpen: false,
        open: function() {

            $(".ui-dialog-buttonpane button:contains('Use this address')").attr("disabled", true).addClass("ui-state-disabled");

            /* Get the data to use for the check */
            var address = $("input[id*=address]").val();
            var city = $("input[id*=city]").val();
            var state = $("input[id*=state]").val();
            var zip =$("input[id*=zip]").val();

            if (!address.length || (!zip.length && (!city.length || !state.length))) {
                $("#addrchk_msg").html("Incomplete address, can't check.");
                $("#addrchk_ok_container").css("display","block");
                return;
            }

            $("#addrchk_msg").html("Checking address with FedEx...");


            /* Build the query and send it */
            var json = new Object;
            json.street = address;
            json.city = city;
            json.state = state;
            json.postal_code = zip;

            $.ajax({
                url: "address_check.json",
                dataType: 'json',
                data: { address: JSON.stringify(json) },
                success: function(data) {
                    // var result = JSON.parse(data)
                    if (!data.available) {
                        $("#addrchk_msg").html("Address check failed or address not found");
                        $(".ui-dialog-buttonpane button:contains('Use this address')").attr("disabled", true).addClass("ui-state-disabled");
                    } else {
                        $("#addrchk_table").append("<tr><td id=\"addrchk_address\">" + data.street_lines + "</td></tr>");
                        $("#addrchk_table").append("<tr><td id=\"addrchk_city\">" + data.city + "</td></tr>");
                        $("#addrchk_table").append("<tr><td id=\"addrchk_state\">" + data.state + "</td></tr>");
                        $("#addrchk_table").append("<tr><td id=\"addrchk_zip\">" + data.postal_code + "</td></tr>");
                        $("#addrchk_table").css("display","block");
                        $("#addrchk_msg").html("Matching address found:");
                        $(".ui-dialog-buttonpane button:contains('Use this address')").attr("disabled", false).removeClass("ui-state-disabled");
                    }


                }
            });

        },
        close: function() {
            /* Clear out any previous address, message and buttons */
            $("#addrchk_table").html("");
            $("#addrchk_ask_container").css("display","none");
            $("#addrchk_ok_container").css("display","none");
            $("#addrchk_msg").html("");
        },
        buttons: [{
            text: "Use this address",
            click: function() {
                // Stuff the values back into the record
                $("input[id*=address]").val($("#addrchk_address").html());
                $("input[id*=city]").val($("#addrchk_city").html());
                $("input[id*=state]").val($("#addrchk_state").html());
                $("input[id*=zip]").val($("#addrchk_zip").html());
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        },{
            text: "Cancel",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"

        }]



    });

    var buttons = $("#addrchk_ask_container button").click(function(e) {

        // get user input
        var yes = buttons.index(this) === 0;

        if (yes) {
            // Stuff the values back into the record
            $("input[id*=address]").val($("#addrchk_address").html());
            $("input[id*=city]").val($("#addrchk_city").html());
            $("input[id*=state]").val($("#addrchk_state").html());
            $("input[id*=zip]").val($("#addrchk_zip").html());
        }
    });

    // Check boxes on (Pending/Merge) Volunteer

    function set_field_validity_color($checkbox) {
        var field_name = $checkbox.attr("id").split("use_")[1];
        var $field = $("input[id^=volunteer_"+field_name+"]").presence() || $("span[id^=source_volunteer_"+field_name+"]").presence();
        var $other_field = $("span[id^=volunteer_"+field_name+"]");
        if ($checkbox.prop("checked")) {
            $other_field.removeClass("background-valid");
            if ($field.is("input")) {
                switch (field_name) {
                    case "first_name":
                    case "last_name":
                        if ($field.val()) {
                            $field.removeClass("background-invalid");
                            $field.addClass("background-valid")
                        } else {
                            $field.removeClass("background-valid");
                            $field.addClass("background-invalid")
                        }
                        break;
                    case "email":
                        var r = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
                        if ($field.val() && !(r.test($field.val()))) {
                            $field.removeClass("background-valid");
                            $field.addClass("background-invalid")
                        } else {
                            $field.removeClass("background-invalid");
                            $field.addClass("background-valid")
                        }
                        break;
                    default:
                        $field.removeClass("background-invalid");
                        $field.addClass("background-valid");
                        break;
                }
            } else {
                $field.removeClass("background-invalid");
                $field.addClass("background-valid");
            }
        } else {
            $field.removeClass("background-valid");
            $field.removeClass("background-invalid");
            $other_field.addClass("background-valid");
        }
    }

    $(":checkbox[id^=use_]").change(function() {
        set_field_validity_color($(this))
    }).trigger("change");

    ["first_name", "last_name", "email"].forEach(function(field_name) {
        $("input:not(:checkbox)[id$="+field_name+"]").change(function() {
            if ($(":checkbox[id=use_"+field_name+"]").presence()) {
                set_field_validity_color($(":checkbox[id=use_"+field_name+"]"));
            }
        })
    });

    ["notes", "limitations", "medical_conditions", "interests", "categories"].forEach(function(field_name) {
        $("select[id*=" + field_name + "]").change(function () {
            var action = $("select[id*=" + field_name + "] option:selected").text();
            var $field = "";
            var $other_field = "";
            if ((field_name == "notes") || (field_name == "limitations") || (field_name == "medical_conditions")) {
                $field = $("textarea[id^=volunteer_" + field_name + "][disabled!='disabled']").presence() || $("textarea[id^=source_volunteer_" + field_name + "]").presence();
                $other_field = $("textarea[id^=volunteer_" + field_name + "][disabled='disabled']");
            } else if (field_name == "interests") {
                $field = ($("select[id^=volunteer_interest_ids]").not("[class*='read-only']").presence() || $("select[id^=source_volunteer_interest_ids]").presence()).next("div.btn-group").children(":button");
                $other_field = ($("select[id^=volunteer_interest_ids][class*='read-only']").presence() || $("select[id^=volunteer_interest_ids]").presence()).next("div.btn-group").children(":button");
            } else {
                $field = ($("select[id^=volunteer_category_ids]").not("[class*='read-only']").presence() || $("select[id^=source_volunteer_category_ids]").presence()).next("div.btn-group").children(":button");
                $other_field = ($("select[id^=volunteer_category_ids][class*='read-only']").presence() || $("select[id^=volunteer_category_ids]").presence()).next("div.btn-group").children(":button");
            }
            if (action.toLowerCase() != "ignore") {
                $field.addClass("background-valid");
                if (action.toLowerCase() != "replace") {
                    $other_field.addClass("background-valid")
                } else {
                    $other_field.removeClass("background-valid")
                }
            } else {
                $field.removeClass("background-valid");
                $other_field.addClass("background-valid")
            }
        }).trigger("change")
    })
});
