redirection_after_login = {

  view: {
    select: function() {
      return $('#profile_data_redirection_after_login')
    },
    customUrl: function() {
      return $('#profile_data_custom_url_redirection')
    },
  },

  toggleCustomUrl: function() {
    var view = redirection_after_login.view
    var formGroup = view.customUrl().parents('.form-group')
    formGroup.toggle(view.select().val() == 'custom_url')
  },

};

$(document).ready(function() {
  redirection_after_login.toggleCustomUrl()
  $(redirection_after_login.view.select()).on('change keyup', redirection_after_login.toggleCustomUrl)
})

