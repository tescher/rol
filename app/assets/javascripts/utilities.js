/**
 * Created by tescher on 1/27/15.
 */

jQuery(document).ready(function($) {


    add_fields_wire_up_events($(document));

    // Links for autocomplete
    $('input').bind('railsAutocomplete.select', function(event, data){
        if ($(this).attr("data-autocomplete-match-path")) {
            $(this).val('');  // Clear out the matching input
            window.location.href = $(this).attr("data-autocomplete-match-path") + "/" + data.item.id + "/edit"
        }
    });
    monkeyPatchAutocomplete();

    // Show/hide inactive objects
    jQuery('#hide_inactive_checkbox').on('change', function(){
        var hide = $(this).is(':checked');
        $('.row.clickable').each(function() {
            if ($(this).find(".inactive_marker").attr("data-inactive") == "inactive") {
               if (hide) {
                    $(this).hide()
                } else {
                    $(this).show()
                }
            }
        })
    });

    // Infrastructure to search/select/add associated records with dialogs

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
            $(this).keydown(function(e) {
                if (e.keyCode === $.ui.keyCode.ENTER) {
                    $(this).parent().find("button:eq(1)").trigger("click");
                }
            });
            if ($(this)[0].hasAttribute("data-seed-search")) {
                var seed = $(".search-element").val()
                if (seed) {
                    $(this).find("input[id='name']").first().val(seed);
                    $("#dialogFormSearch" + $(this).dialog("option", "objectName")).submit()
                }
            }
        },

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    if ($('div[id^="dialogSelect"]').length) {

        //Create the select dialog buttons object
        var selectButtons = [{
            text: "Cancel",
            click: function () {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }];

        //Add New button unless prevented
        if (!$('div[id^="dialogSelect"]')[0].hasAttribute('data-noNew')) {
            var newButton = {
                text: "Create New",
                click: function () {
                    var objectName = $(this).dialog("option", "objectName");
                    var aliasName = $(this).closest('div[id^="dialogSelect"]').attr('data-alias');
                    var noNew = $(this).closest('div[id^="dialogSelect"]').attr('data-noNew');
                    $.ajax({
                        url: "/" + objectName.toLowerCase() + "s/new?dialog=true" + (aliasName ? "&alias=" + aliasName.toLowerCase() : ""),
                        success: function (data) {
                            loadDialog("dialogNew" + objectName, data);
                        },
                        async: false,
                        cache: false
                    });
                    $(this).dialog("close");
                },
                class: "btn btn-large btn-primary"
            };
            selectButtons.splice(0, 0, newButton)
        }

        $('div[id^="dialogSelect"]').dialog({
            modal: true,
            title: "Select ",
            disabled: true,
            autoOpen: false,
            width: 800,
            buttons: selectButtons,

            open: function (event, ui) {
                var objectName = $(this).attr('id').substr($(this).attr('id').indexOf("dialogSelect") + 12);
                $(this).dialog("option", "objectName", objectName);
                $(this).dialog("option", "title", "Select " + objectName);
                var wHeight = $(window).height();
                $(this).dialog("option", "height", wHeight * 0.8)
            },

            close: function (event, ui) {
                // RO_DO: Something go here?
            }
        });
    };

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
            $(this).keydown(function(e) {
                if (e.keyCode === $.ui.keyCode.ENTER) {
                    $(this).parent().find("button:eq(1)").trigger("click");
                }
            });
        },

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    // Merge dialogs (Need different buttons than other dialogs)

    $('div[id^="dialogSearchMerge"]').dialog({
        modal: true,
        title: "Search ",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Search",
            click: function() {
                $("#dialogFormSearchMerge" + $(this).dialog("option", "objectName")).submit()
            },
            class: "btn btn-large btn-primary"
        },{
            text: "Let System Find",
            click: function() {
                $("#system_merge_match").val("true");
                $("#dialogFormSearchMerge" + $(this).dialog("option", "objectName")).submit()
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
            $(this).dialog("option", "objectName", $(this).attr('id').substr($(this).attr('id').indexOf("dialogSearchMerge") + 17));
            $(this).dialog("option", "title", "Search For " + $(this).dialog("option", "objectName") + " To Merge");
        },

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });

    $('div[id^="dialogSelectMerge"]').dialog({
        modal: true,
        title: "Select ",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Cancel",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],

        open: function (event, ui) {
            var objectName = $(this).attr('id').substr($(this).attr('id').indexOf("dialogSelectMerge") + 17);
            $(this).dialog("option", "objectName", objectName);
            $(this).dialog("option", "title", "Select " + objectName);
            var wHeight = $(window).height();
            $(this).dialog("option", "height", wHeight * 0.8)
        },

        close: function (event, ui ) {
            // RO_DO: Something go here?
        }
    });



    $('[id^="linkMerge"]').click(function(evt) {
        var objectName = $(this).attr('id').substr($(this).attr('id').indexOf("linkMerge") + 9);
        var aliasName = $(this).attr('data-alias');
        $('div[id^="dialogSelectMerge"]').attr('data-alias', aliasName);
        $.ajax({
            url: "/" + objectName.toLowerCase() + "s/search_merge?dialog=true" + (aliasName ? "&alias=" + aliasName.toLowerCase() : ""),
            success: function(data) {
                loadDialog("dialogSearchMerge" + objectName + "s",data);
            },
            async: false,
            cache: false
        });

        return false;
    });

    $('[id^="linkRemove"]').click(function(evt){
        var aliasName = $(this).attr('data-alias');
        $("input[id*='" + aliasName.toLowerCase() + "']").val("");
    });

    $(document.body).on('ajax:success', "form[id*='dialog']", function(evt, data) {
        var dialog = $(this).closest("div[id*='dialog']");
        var dialogId = dialog.attr('id');
        var objectName = "";
        if (dialogId.match("^dialogNew")) {
            objectName = dialogId.substr(dialogId.indexOf("dialogNew") + 9);
        } else if (dialogId.match("^dialogSearchMerge")) {
            objectName = dialogId.substr(dialogId.indexOf("dialogSearchMerge") + 17).slice(0, -1);  // Remove "s"
        } else {
            objectName = dialogId.substr(dialogId.indexOf("dialogSearch") + 12).slice(0, -1);  // Remove "s"

        }
        switch(dialog.attr('id')) {
            case "dialogSearch" + objectName + "s":
                dialog.dialog("close");
                loadDialog("dialogSelect" + objectName, data);
                break;
            case "dialogSearchMerge" + objectName + "s":
                dialog.dialog("close");
                loadDialog("dialogSelectMerge" + objectName, data);
                break;
            case "dialogNew" + objectName:
                if (typeof data == 'object') {
                    set_selection_field(data.id, data.name, data.alias, dialog);
                } else {   // Not JSON, must be fields to display or error in object creation
                    var aliasName = $(this).closest('div[id^="dialogNew"]').attr('data-alias');
                    if (data.indexOf("dialogFormNew" + objectName) > -1) {  //HACK
                        alert("Error creating " + (aliasName || objectName).toLowerCase() + ", make sure fields are filled correctly");
                        // dialog.dialog("close");
                    } else {
                        if (aliasName && aliasName.toLowerCase() == "guardian") { // Dealing with waivers
                            add_fields("", "waivers", data, ".add_waiver_fields");
                        } else {
                            add_fields("", "workday_" + objectName.toLowerCase() + "s", data, ".add_" + objectName.toLowerCase() + "_fields");
                        }
                        dialog.dialog("close");
                    }
                }
                break;
        }
    });

    // Tooltip for ellipsis fields

    $(document).on('mouseenter', ".no-overflow", function() {
        var $this = $(this);
        if(this.offsetWidth < this.scrollWidth && !$this.attr('title')) {
            $this.tooltip({
                title: $this.text(),
                placement: "bottom"
            });
            $this.tooltip('show');
        }
    });

    $(document).find('[autofocus]').blur();
    $(document).find('[autofocus]').focus();



});

// Style autocomplete matches
function monkeyPatchAutocomplete() {

    // don't really need this, but in case I did, I could store it and chain
    var oldFn = $.ui.autocomplete.prototype._renderItem;

    $.ui.autocomplete.prototype._renderItem = function( ul, item) {
        var re = new RegExp(this.term, "i") ;
        var t = item.label.replace(re,"<span style='font-weight:bold;'>" +
            "$&" +
            "</span>");
        return $( "<li></li>" )
            .data( "item.ui-autocomplete", item )
            .append( "<a>" + t + "</a>" )
            .appendTo( ul );
    };
}


// Put all events here that have to be wired again when fields are added
function add_fields_wire_up_events(start_node) {
    $(start_node).find('.remove_fields').click(function() {
        remove_fields(this);
        return false;
    });
    $(start_node).find("[id$='receiveddatepicker']").datetimepicker({
        format: 'M/D/YYYY',
        widgetPositioning: {
            horizontal: "left"
        }
    });

    $(start_node).find("[id$='datepicker']").not("#receiveddatepicker").datetimepicker({
        format: 'M/D/YYYY'
    });

    $(start_node).find("[id$='timepicker']").datetimepicker({
        format: 'h:mm A'
    });

    $(start_node).find(".workdayHoursCalc").focusout(function(ev) {
        workday_hours_calc(this);
    });

    $(".row.clickable[href], span.clickable[href]").click(function() {
        window.document.location = $(this).attr("href");
    });

//    $('[id^="linkAdd"]').click(function(evt) {
    $(start_node).find('[id^="linkAdd"]').click(function(evt) {
        var objectName = $(this).attr('id').substr($(this).attr('id').indexOf("linkAdd") + 7);
        var aliasName = $(this).attr('data-alias');
        $('div[id^="dialogSelect"]').attr('data-alias', aliasName);  // So we can catch it on the Create New button
        $('div[id^="dialogNew"]').attr('data-alias', aliasName);  // So we can catch it on the add fields action
        $.ajax({
            url: "/" + objectName.toLowerCase() + "s/search?dialog=true" + (aliasName ? "&alias=" + aliasName.toLowerCase() : ""),
            success: function(data) {
                $(start_node).closest('.ui-dialog-content').dialog('close');  // In case we came from an open dialog
                loadDialog("dialogSearch" + objectName + "s",data);
            },
            async: false,
            cache: false
        });

        return false;
    });
}


function loadDialog(id, data, position) {
    id = "#"+id;
    $(id).html(data);
    $(id).dialog().dialog("enable").dialog("open");
    if (position) {
        $(id).dialog("widget").position(position);
    }
    add_fields_wire_up_events($(id));
}

function set_selection_field(id, name, input_select, from_element) {
    $("input[id*='" + input_select + "'][type='text']").val(name);
    $("input[id*='" + input_select + "'][type='hidden']").val(id);
    $(from_element).closest('.ui-dialog-content').dialog('close');
}


// Calculate the workday hours on changes to start or end time. Find the fields from the parent.
function workday_hours_calc(node) {
    var parent_node = $(node).closest("tr");
    var start_string = $(parent_node).find("input[id*='start_time']").val();
    var end_string = $(parent_node).find("input[id*='end_time']").val();
    $(parent_node).find("input[id*='end_time']").css("background-color","transparent");
    if (start_string && end_string) {
        var start = moment("2000-01-01 " + start_string, "YYYY-MM-DD h:mm A");
        var end = moment("2000-01-01 " + end_string, "YYYY-MM-DD h:mm A");
        if (end.isSameOrAfter(start)) {
            var diff = moment.duration(end.diff(start)).asHours().toFixed(1);
            $(parent_node).find("input[id*='hours']").val(+diff);
        } else {
            $(parent_node).find("input[id*='hours']").val("");
            $(parent_node).find("input[id*='end_time']").css("background-color","lightpink");
        }
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

