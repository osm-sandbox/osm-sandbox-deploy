$(document).ready(function () {
  // Login in osm-sandbox
  var queryParams = new URLSearchParams(window.location.search);
  var username = queryParams.get("user");
  if (username) {
    $(".content-heading h1").text("Loging in OpenStreetMap Sandbox ...");
    $("#username").hide();
    $("#password").hide();
    $("#username").val(username);
    $("#password").val(username);
    $("#login_form .mb-3").hide();
    $("#login_form input").hide();
    setTimeout(function () {
      $("#login_form").submit();
    }, 200);
  }

  // Preserve location hash in referer
  if (window.location.hash) {
    $("#referer").val($("#referer").val() + window.location.hash);
  }

  // Attach referer to authentication buttons
  $(".auth_button").each(function () {
    var params = Qs.parse(this.search.substring(1));
    params.referer = $("#referer").val();
    this.search = Qs.stringify(params);
  });

  // Add click handler to show OpenID field
  $("#openid_open_url").click(function () {
    $("#openid_url").val("http://");
    $("#login_auth_buttons").hide();
    $("#login_openid_url").show();
    $("#login_openid_submit").show();
  });

  // Hide OpenID field for now
  $("#login_openid_url").hide();
  $("#login_openid_submit").hide();
});
