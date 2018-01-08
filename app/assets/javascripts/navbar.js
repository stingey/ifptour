$(document).on("scroll", function () {
  if ($(document).scrollTop() > 22) {
    $('.navbar-main').addClass('fix');
    $('.navbar-filler').show();
  } else {
    $('.navbar-filler').hide();
    $('.navbar-main').removeClass('fix');
  }
}.bind(this));
