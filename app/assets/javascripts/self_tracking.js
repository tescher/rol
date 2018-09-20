function loadModalDialog(divSelector, remoteUrl, afterLoadCallback) {
  $.get(remoteUrl, function(data) {
	$(divSelector).html(data);
	$(divSelector).modal();
	$(divSelector).on('shown.bs.modal', function() {
	  $(this).find('[autofocus]').focus();
	});
	$("form").on("ajax:complete ajaxSuccess", function(e, data, status, xhr) {
	  formPostedSuccessfully(divSelector, afterLoadCallback, e, data, status, xhr);
	});
	if (typeof afterLoadCallback !== "undefined") {
	  afterLoadCallback(divSelector);
	}
	$(divSelector).find('[autofocus]').focus();
  });
  return false;
}

function formPostedSuccessfully(divSelector, afterLoadCallback, e, data, status, xhr) {
  // Special logic for the check-in form.
  if (($(e.target).data("check-in-form") == true) || ($(e.target).data("check-out-form") == true)) {
	if (data.responseText == "success") {
	  $(divSelector).modal("hide");
	  window.location.reload(true);
	}
  }

  // Replace the content and reinitialize the listener.
  $(divSelector).html(data.responseText);
  $("form").on("ajax:complete ajaxSuccess", function(e, data, status, xhr) {
	formPostedSuccessfully(divSelector, afterLoadCallback, e, data, status, xhr);
  });
  $(divSelector).find('[autofocus]').focus();
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
  loadModalDialog("#modalDialog", checkinUrl, hookupTimepicker);
}

function hookupTimepicker(divSelector) {
  var defaultDate = moment.tz(new Date(), jstz.determine().name());
  $("[id$='_time']").datetimepicker({
      format: 'h:mm A',
      defaultDate: defaultDate
      });
  $("[id$='_time']").on("dp.show", function(e) {
	// Change the period button (AM/PM) to btn-default style instead of the btn-primary default that it uses.
	$(e.currentTarget.form).find("button[data-action='togglePeriod']").removeClass("btn-primary").addClass("btn-default");
  });
}
