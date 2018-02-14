$(document).on('turbolinks:load', function() {
  $(".alert").delay(5000).hide(0);
  checkGender();
  $('#gender-selector').change(function() {
    checkGender();
  });
}.bind(this));

function checkGender() {
  if ($('#gender-selector').val() === 'F') {
    $('.womens-points').removeClass('hide');
  } else {
    $('.womens-points').val('').addClass('hide');
  }
}
