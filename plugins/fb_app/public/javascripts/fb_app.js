fb_app = {
  current_url: '',

  locales: {

  },

  config: {
    url_prefix: '',
    save_auth_url: '',
    show_login_url: '',

    init: function() {

    },

  },

  timeline: {
    appId: '',
    app_scope: 'publish_actions',

    loading: function() {
      jQuery('#fb-app-connect-status').empty().addClass('loading').height(150)
    },

    connect: function() {
      this.loading();
      fb_app.fb.scope = this.app_scope
      fb_app.fb.connect(function (response) {
        fb_app.auth.receive(response)
      });
    },

    disconnect: function() {
      // 'not_authorized' is used to disconnect from facebook
      jQuery('#fb-app-modal-wrap #fb-app-modal-intro').html(
          fb_app.locales.confirm_disconnect
        )
      jQuery('#fb-app-modal-wrap .modal-button-no')
        .html(fb_app.locales.cancel_button)
        .attr('onClick', 'noosfero.modal.close(); return false')
      jQuery('#fb-app-modal-wrap .modal-button-yes')
        .html(fb_app.locales.confirm_disconnect_button)
        .attr('onClick', 'fb_app.timeline.disconnect_confirmed();noosfero.modal.close(); return false')
      noosfero.modal.html(jQuery('#fb-app-modal-wrap').html())
    },

    disconnect_confirmed: function() {
      this.loading();
      fb_app.auth.receive({status: 'not_authorized'})
    },

    connect_to_another: function() {
      this.disconnect();
      fb_app.fb.connect_to_another(this.connect)
    },
  },

  page_tab: {
    appId: '',
    nextUrl: '',

    init: function() {
      FB.Canvas.scrollTo(0,140);
      // While Braulio doesnt make the catalog-options-bar work in a product page, I'll hide it. User will have to go back to the catalog to see this bar, provisorily...
      jQuery('#product-page').prev('form').hide();
    },

    config: {

      init: function() {
        this.change_type($('select#page_tab_config_type'))

      },

      edit: function(button) {
        var page_tab = button.parents('.page-tab')
        page_tab.find('form').toggle(400)
      },

      remove: function(button, url) {
        var page_tab = button.parents('.page-tab')
        var name = page_tab.find('#page_tab_name').val()
        //jQuery('#fb-app-modal-catalog-name').text(name)
        jQuery('#fb-app-modal-wrap #fb-app-modal-intro').html(
          fb_app.locales.confirm_removal
        )
        jQuery('#fb-app-modal-wrap .modal-button-no')
          .html(fb_app.locales.cancel_button)
          .attr('onClick', 'noosfero.modal.close(); return false')
        jQuery('#fb-app-modal-wrap .modal-button-yes')
          .html(fb_app.locales.confirm_removal_button)
          .attr('onClick', 'fb_app.page_tab.config.remove_confirmed(this);noosfero.modal.close(); return false')
          .attr('target_url',url)
          .attr('target_id','#'+page_tab.attr('id'))
        noosfero.modal.html(jQuery('#fb-app-modal-wrap').html())
      },

      remove_confirmed: function(el) {
        el = jQuery(el)
        jQuery.post(el.attr('target_url'), function() {
          var page_tab = jQuery(el.attr('target_id'))
          page_tab.remove()
        })
      },

      close: function(pageId) {
        noosfero.modal.close()
        jQuery('#content').html('').addClass('loading')
        fb_app.fb.redirect_to_tab(pageId, fb_app.page_tab.appId)
      },

      validate: function(form) {
        for (var i=0; tinymce.editors[i]; i++) {
          var editor = tinymce.editors[i]
          var textarea = editor.getElement()
          textarea.value = editor.getContent()
        }

        if (form.find('#page_tab_title').val().trim()=='') {
          noosfero.modal.html('<div id="fb-app-error">'+fb_app.locales.error_empty_title+'</div>')
          return false
        } else {
          var selected_type = form.find('#page_tab_config_type').val()
          var sub_option = form.find('.config-type-'+selected_type+' input')
          if (sub_option.length > 0 && sub_option.val().trim()=='') {
            noosfero.modal.html('<div id="fb-app-error">'+fb_app.locales.error_empty_settings+'</div>')
            return false
          }
        }
        return true
      },

      add: function (form) {
        if (!this.validate(form))
          return false
        // this checks if the user is using FB as a page and offer a switch
        FB.login(function(response) {
          if (response.status != 'connected') return
          var nextUrl = fb_app.page_tab.nextUrl + '?' + form.serialize()
          window.location.href = fb_app.fb.add_tab_url(fb_app.page_tab.appId, nextUrl)
        })
        return false
      },

      save: function(form) {
        if (!this.validate(form))
          return false
        jQuery(form).ajaxSubmit({
          dataType: 'script',
        })
        return false
      },

      change_type: function(select) {
        select = jQuery(select)
        var page_tab = select.parents('.page-tab')
        var config_selector = '.config-type-'+select.val()
        var config = page_tab.find(config_selector)
        var to_show = config
        var to_hide = page_tab.find('.config-type:not('+config_selector+')')

        to_show.show().
          find('input').prop('disabled', false)
        to_show.find('.tokenfield').removeClass('disabled')
        to_hide.hide().
          find('input').prop('disabled', true)
      },

      profile: {

        onchange: function(input) {
          if (input.val())
            input.removeAttr('placeholder')
          else
            input.attr('placeholder', input.attr('data-placeholder'))
        },
      },
    },

  },

  auth: {
    status: 'not_authorized',

    load: function (html) {
      jQuery('#fb-app-settings').html(html)
    },
    loadLogin: function (html) {
      if (this.status == 'not_authorized')
        jQuery('#fb-app-connect').html(html).removeClass('loading')
      else
        jQuery('#fb-app-login').html(html)
    },

    receive: function(response) {
      fb_app.fb.authResponse = response
      fb_app.auth.save(response)
      jQuery('html,body').animate({ scrollTop: jQuery('#fb-app-settings').offset().top-100 }, 400)
    },

    transformParams: function(response) {
      var authResponse = response.authResponse
      if (!authResponse)
        return {auth: {status: response.status}}
      else
        return {
          auth: {
            status: response.status,
            access_token: authResponse.accessToken,
            expires_in: authResponse.expiresIn,
            signed_request: authResponse.signedRequest,
            provider_user_id: authResponse.userID,
          }
        }
    },

    showLogin: function(response) {
      jQuery.get(fb_app.config.show_login_url, this.transformParams(response), this.loadLogin)
    },

    save: function(response) {
      jQuery.post(fb_app.config.save_auth_url, this.transformParams(response), this.load)
    },
  },


  // interface to facebook's SDK
  fb: {
    appId: '',
    scope: '',
    inited: false,
    initCode: null,

    prepareAsyncInit: function(appId, asyncInitCode) {
      this.id = appId
      this.initCode = asyncInitCode

      window.fbAsyncInit = function() {
        FB.init({
          appId: appId,
          cookie: true,
          xfbml: true,
          status: true,
        })

        // automatic iframe's resize
        // FIXME: move to page tab embed code
        fb_app.fb.size_change()
        jQuery(document).on('DOMNodeInserted', fb_app.fb.size_change)

        if (asyncInitCode)
          jQuery.globalEval(asyncInitCode)

        fb_app.fb.inited = true
      }
    },

    init: function() {
      // the SDK is loaded on views/fb_app_plugin/_load.html.slim and then call window.fbAsyncInit
    },

    size_change: function() {
      FB.Canvas.setSize({height: jQuery('body').height()+100})
    },

    redirect_to_tab: function(pageId, appId) {
      window.location.href = 'https://facebook.com/' + pageId + '?sk=app_' + appId
    },

    add_tab_url: function (appId, nextUrl) {
      return 'https://www.facebook.com/dialog/pagetab?' + jQuery.param({app_id: appId, next: nextUrl})
    },

    connect: function(callback) {
      FB.login(function(response) {
        if (callback) callback(response)
      }, {scope: fb_app.fb.scope})
    },

    connect_to_another: function(callback) {
      this.logout(this.connect(callback))
    },

    logout: function(callback) {
      // this checks if the user is using FB as a page and offer a switch
      FB.login(function(response) {
        FB.logout(function(response) {
          if (callback) callback(response)
        })
      })
    },

    // not to be used
    delete: function(callback) {
      FB.api("/me/permissions", "DELETE", function(response) {
        if (callback) callback(response)
      })
    },

    checkLoginStatus: function() {
      FB.getLoginStatus(function(response) {
        // don't do nothing, this is just to fetch auth after init
      })
    },

  },

}


