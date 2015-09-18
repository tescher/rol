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



});