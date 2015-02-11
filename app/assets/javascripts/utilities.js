/**
 * Created by tescher on 1/27/15.
 */

jQuery(document).ready(function($) {

    add_fields_wire_up_events($(document));

});

// Put all events here that have to be wired again when fields are added
function add_fields_wire_up_events(start_node) {
    $(start_node).find('.remove_fields').click(function() {
        remove_fields(this);
        return false;
    });
    $(start_node).find("[id$='datepicker']").datetimepicker({
        format: 'M/D/YYYY'
    });

    $(start_node).find("[id$='timepicker']").datetimepicker({
        format: 'h:mm A'
    });

    $(start_node).find(".workdayHoursCalc").focusout(function(ev) {
        workday_hours_calc(this);
    });

    $(".row.clickable").click(function() {
        window.document.location = $(this).attr("href");
    });


}


function loadDialog(id, data) {
    id = "#"+id;
    $(id).html(data);
    $(id).dialog("enable");
    $(id).dialog("open");
    add_fields_wire_up_events($(id));

}


// Calculate the workday hours on changes to start or end time. Find the fields from the parent.
function workday_hours_calc(node) {
    var parent_node = $(node).closest("tr");
    var start_string = $(parent_node).find("input[id*='start_time']").val();
    var end_string = $(parent_node).find("input[id*='end_time']").val();
    if (start_string && end_string) {
        var start = moment("2000-01-01 " + start_string, "YYYY-MM-DD h:mm A");
        var end = moment("2000-01-01 " + end_string, "YYYY-MM-DD h:mm A");
        var diff = moment.duration(end.diff(start)).asHours().toFixed(1);
        $(parent_node).find("input[id*='hours']").val(+diff);
    }
}


function remove_fields(link) {
    $(link).prev("input[type=hidden]").val("1");
    $(link).closest(".hide_on_remove").hide();
}

function add_fields(link, association, content, parent_selector) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    $(parent_selector).append(content.replace(regexp, new_id));
    add_fields_wire_up_events($(parent_selector));
    // $(link).parent().before(content.replace(regexp, new_id));
}

function add_fields_and_close(link, association, content, parent_selector) {
    add_fields(link,association, content, parent_selector);
    $(link).closest('.ui-dialog-content').dialog('close');
}

function change_val(selector, value) {
    $(selector).val(value);
}

