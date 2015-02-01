/**
 * Created by tescher on 1/27/15.
 */

jQuery(document).ready(function($) {
    $(".row.clickable").click(function() {
        window.document.location = $(this).attr("href");
    });

    $('.remove_fields').click(function() {
        remove_fields(this);
        return false;
    });


});

function remove_fields(link) {
    $(link).prev("input[type=hidden]").val("1");
    $(link).closest(".fields").hide();
}

function add_fields(link, association, content, parent_selector) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    $(parent_selector).append(content.replace(regexp, new_id));
    // $(link).parent().before(content.replace(regexp, new_id));
}

