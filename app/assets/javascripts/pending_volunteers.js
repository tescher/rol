
// Called from a link after a new volunteer successfully signs up. This allows
// the person to now check-in. This assumes that the sign up page was launched
// from the check-in flow.
function continueCheckinAfterSignup(checkinUrl) {
  if (typeof window.opener === "undefined") {
    alert("Sorry, something unexpected happened.  Please continue by searching for yourself.");
    window.close();
    return false;
  }

  window.opener.continueNewVolunteerCheckin(checkinUrl);
  window.close();
  return false;
}
