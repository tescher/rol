function loadModalDialog(divSelector, remoteUrl, afterLoadCallback) {
    $.get(remoteUrl, function(data) {
        $(divSelector).html(data);
        $(divSelector).modal();
        $("form").on("ajax:complete ajaxSuccess", function(e, data, status, xhr) {
          formPostedSuccessfully(divSelector, afterLoadCallback, e, data, status, xhr);
        });
        if (typeof afterLoadCallback !== "undefined") {
          afterLoadCallback(divSelector);
        }
    });
    return false;
}

function checkoutVolunteer(volunteerName, checkoutPath) {
  if (confirm("Are you sure you would like to checkout " + volunteerName + "?")) {
    window.location = checkoutPath;
  }
}

function formPostedSuccessfully(divSelector, afterLoadCallback, e, data, status, xhr) {
  // Special logic for the check-in form.
  if ($(e.target).data("check-in-form") == true) {
    if (data.responseText == "success") {
      $(divSelector).modal("hide");
      location.reload();
    } else {
      hookupTimepicker(divSelector);
    }
  }

  // Replace the content and reinitialize the listener.
  $(divSelector).html(data.responseText);
  $("form").on("ajax:complete ajaxSuccess", function(e, data, status, xhr) {
    formPostedSuccessfully(divSelector, afterLoadCallback, e, data, status, xhr);
  });
  if (typeof afterLoadCallback !== "undefined") {
    afterLoadCallback(divSelector);
  }
}

function launchVolunteerSignup(divSelector, url) {
  window.open(url);
}

// Called from the new voluneer sign-up window after a new volunteer has successfully
// signed up.  This allows the newly signed up volunteer to finally check in.
function continueNewVolunteerCheckin(checkinUrl) {
  console.log(checkinUrl);
  loadModalDialog("#modalDialog", checkinUrl, hookupTimepicker);
}

function hookupTimepicker(divSelector) {
    $("#check_in_form_check_in_time").datetimepicker({ format: 'h:mm A' });
}
