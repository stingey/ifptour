$(document).on('turbolinks:load', function () {
  $('#RankingClassSelector').change(function () {
    let rank = $('#RankingClassSelector').val();
    let term = $('#term').val();
    let url = window.location.href;
    let controller
    if (url.indexOf('/singles') >= 0) {
      controller = 'singles';
    } else if (url.indexOf('/doubles') >= 0) {
      controller = 'doubles';
    } else if (url.indexOf('/womens_singles') >= 0) {
      controller = 'womens_singles';
    } else if (url.indexOf('/womens_doubles') >= 0) {
      controller = 'womens_doubles';
    }
    window.location = `${controller}?=&rank_class=${rank}&term=${term}`
  });
}.bind(this));
