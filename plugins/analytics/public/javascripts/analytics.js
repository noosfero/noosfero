analytics = {
  requestId: '',

  timeOnPage: {
    updateInterval: 0,
    baseUrl: '',

    report: function() {
      $.ajax(analytics.timeOnPage.baseUrl+'/report', {
        type: 'POST', data: {id: analytics.requestId},
        success: function(data) {

          analytics.timeOnPage.poll()
        },
      })
    },

    poll: function() {
      if (analytics.timeOnPage.updateInterval)
        setTimeout(analytics.timeOnPage.report, analytics.timeOnPage.updateInterval)
    },
  },

  init: function() {
    analytics.timeOnPage.poll()
  },

  pageLoad: function() {
    $.ajax(analytics.timeOnPage.baseUrl+'/page_load', {
      type: 'POST', data: {id: analytics.requestId},
      success: function(data) {
      },
    });
  }

};

$(document).ready(analytics.pageLoad)

