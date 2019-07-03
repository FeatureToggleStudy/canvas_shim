$(window).on("load", function(event) {
  var initialVal = $('#account_settings_score_threshold').val();
  $('#edit_school_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var passThreshDisabled = $('#account_settings_score_threshold').prop('disabled');
    $('#account_settings_score_threshold').prop('disabled', !passThreshDisabled);
    $("#threshold_edited").remove();
    $(this).append("<input type='hidden' id='threshold_edited' name='threshold_edited' value=" + passThreshDisabled + " />")
    if ($('#account_settings_score_threshold').prop('disabled')) {
      $('#account_settings_score_threshold').val(initialVal);
    }
  });

  var initialUnitVal = $('#account_settings_unit_score_threshold').val();
  $('#edit_school_unit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var unitPassThreshDisabled = $('#account_settings_unit_score_threshold').prop('disabled');
    $('#account_settings_unit_score_threshold').prop('disabled', !unitPassThreshDisabled);
    $("#unit_threshold_edited").remove();
    $(this).append("<input type='hidden' id='unit_threshold_edited' name='unit_threshold_edited' value=" + unitPassThreshDisabled + " />")
    if ($('#account_settings_unit_score_threshold').prop('disabled')) {
      $('#account_settings_unit_score_threshold').val(initialUnitVal);
    }
  });
});
