$(function() {
  $('.quota-status .progressbar').progressbar({
    value: getQuotaProgress()
  });

  $('#control-panel-filter').on('input', function(){
    var filter = $(this).val();
    if(filter == '')
      $('.control-panel .entry').show();
    else{
      $('.control-panel .entry').each(function(){
        if($(this).data('keywords').indexOf(filter) !== -1)
          $(this).show();
        else
          $(this).hide();
      });
    }

    $('.section').each(function(){
      if($('a:visible', this).length > 0)
        $('h2', this).show();
      else
        $('h2', this).hide();
    });

    if($('.control-panel .entry:visible').length > 0)
      $('.control-panel .no-results').hide();
    else
      $('.control-panel .no-results').show();
  });
});

function getQuotaProgress(progressbar) {
  var progressbar = $('.quota-status .progressbar')
  var totalQuota = progressbar.data('total-quota')
  var usedQuota = progressbar.data('used-quota')
  return ((usedQuota / totalQuota) * 100)
}
