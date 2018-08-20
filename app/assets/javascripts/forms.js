$(document).on('turbolinks:load', function() {
  $(".alert").delay(2000).slideUp(300);
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
