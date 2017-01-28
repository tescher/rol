function showVolunteerSearch(volunteerSearchUrl) {
    $.get(volunteerSearchUrl, function(data) {
        $("#modalVolunteerSearch").html(data);
        $("#modalVolunteerSearch").modal();
        $("form").on("ajax:complete ajaxSuccess", formPostedSuccessfully);
    });
    return false;
};

function formPostedSuccessfully(e, data, status, xhr) {
  $("#modalVolunteerSearch").html(data.responseText);
  $("form").on("ajax:complete ajaxSuccess", formPostedSuccessfully);
}


$(function() {
});

// vim:set shiftwidth=4:
