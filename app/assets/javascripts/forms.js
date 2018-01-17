$(document).on('turbolinks:load', function() {
  $('#gender-selector').change(function() {
    if ($('#gender-selector').val() === 'F') {
      $('.womens-points').removeClass('hide');
    } else {
      $('.womens-points').val('').addClass('hide');
    }
  });
}.bind(this));
