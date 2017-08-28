
$(function() {
  $('.quota-status .progressbar').progressbar({
    value: getQuotaProgress()
  });
});

function getQuotaProgress(progressbar) {
  var progressbar = $('.quota-status .progressbar')
  var totalQuota = progressbar.data('total-quota')
  var usedQuota = progressbar.data('used-quota')
  return ((usedQuota / totalQuota) * 100)
}
