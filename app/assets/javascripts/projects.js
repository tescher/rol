
jQuery(document).ready(function($) {

    $("input[id='homeowner_search']").keydown(function (e) {
        if (e.keyCode === $.ui.keyCode.ENTER) {
            $("#linkAddVolunteer").trigger("click");
        }
    });
});