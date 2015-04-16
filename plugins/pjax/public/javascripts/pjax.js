
pjax = {

  states: {},
  current_state: null,
  initial_state: null,

  themes: {},

  load: function() {
    var target = jQuery('#wrap-1');
    var content = jQuery('#content-inner');
    var loadingTarget = jQuery('#content');

    var container = '.pjax-container';
    target.addClass('pjax-container');

    jQuery(document).pjax('a', container);

    jQuery(document).on('pjax:beforeSend', function(event, xhr, settings) {
      var themes = jQuery.map(pjax.themes, function(theme) { return theme.id }).join(',');
      xhr.setRequestHeader('X-PJAX-Themes', themes);
    });

    jQuery(document).on('pjax:send', function(event) {
      /* initial state is only initialized after the first navigation,
       * so we do associate it here */
      if (!pjax.states[jQuery.pjax.state.id])
        pjax.states[jQuery.pjax.state.id] = pjax.initial_state;

      loading_overlay.show(loadingTarget);
    });
    jQuery(document).on('pjax:complete', function(event) {
      loading_overlay.hide(loadingTarget);
    });

    jQuery(document).on('pjax:popstate', function(event) {
      pjax.popstate(event.state, event.direction);
    });

    jQuery(document).on('pjax:timeout', function(event) {
      // Prevent default timeout redirection behavior
      event.preventDefault();
    });

    pjax.patch.document_write();
    //pjax.patch.xhr();
  },

  update: function(state, from_state) {
    if (!from_state)
      from_state = this.current_state || this.initial_state;

    if (state.layout_template != from_state.layout_template) {
      var lt_css = jQuery('head link[href*="designs/templates"]');
      lt_css.attr('href', lt_css.attr('href').replace(/templates\/.+\/stylesheets/, 'templates/'+state.layout_template+'/stylesheets'));
    }

    if (state.theme.id != from_state.theme.id)
      this.update_theme(state, from_state);

    document.body.className = state.body_classes;

    render_all_jquery_ui_widgets();

    userDataCallback(noosfero.user_data);

    // theme's update dependent on content. must be last thing to run
    if (state.theme_update_js)
      jQuery.globalEval(state.theme_update_js);

    pjax.current_state = state;
  },

  update_theme: function(state, from_state) {
    // wait for the new theme css load
    this.loading.show(function() {
      return !pjax.css_loaded('/designs/themes/'+state.theme.id+'/style.css');
    });

    var css = jQuery('head link[href*="designs/themes/'+from_state.theme.id+'/style"]');
    css.attr('href', css.attr('href').replace(/themes\/.+\/style/, 'themes/'+state.theme.id+'/style'));

    jQuery('head link[rel="shortcut icon"]').attr('href', state.theme.favicon);

    jQuery('#theme-header').html(state.theme.header);
    jQuery('#site-title').html(state.theme.site_title);
    jQuery('#navigation ul').html(state.theme.extra_navigation);
    jQuery('#theme-footer').html(state.theme.footer);

    jQuery('head script[src*="designs/themes/'+from_state.theme.id+'/theme.js"]').remove();
    if (state.theme.js_src) {
      var script = document.createElement('script');
      script.type = 'text/javascript', script.src = state.theme.js_src;
      document.head.appendChild(script);
    }
  },

  popstate: function(state, direction) {
    state = pjax.states[state.id];
    var from_state = pjax.states[jQuery.pjax.state.id];
    pjax.update(state, from_state);
  },

  loading: {
    repeatCallback: null,

    show: function(repeatCallback) {
      this.repeatCallback = repeatCallback;
      this.gears().show();
      this.pool();
    },

    pool: function() {
      setTimeout(this.timeout, 50);
    },

    timeout: function() {
      var repeat = pjax.loading.repeatCallback();
      if (repeat)
        pjax.loading.pool();
      else
        pjax.loading.gears().hide();
    },

    gears: function() {
      var gears = jQuery('#pjax-loading-gears');
      if (!gears.length) {
        gears = jQuery('<div>', {
          id: 'pjax-loading-gears',
        });
        gears.appendTo(document.body);
      }

      return gears;
    },
  },

  css_loaded: function(path) {
    var found = false;
    for (index in document.styleSheets) {
      var stylesheet = document.styleSheets[index];
      if (!stylesheet.href)
        continue;

      found = stylesheet.href.indexOf(path) != -1;
      if (found)
        break;
    }
    return found;
  },

  patch: {

    document_write: function () {
      // document.write doesn't work after ready state
      document._write = document.write;
      document.write = function (data) {
        if (document.readyState != 'loading')
          pjax.content.append(data);
        else
          document._write(data);
      };
    },

    xhr: function () {
      XMLHttpRequest = patch(XMLHttpRequest, '_XMLHttpRequest', {
        constructed: function() {
          console.log('here')

          var args = [].slice.call(arguments);
          return new (Function.prototype.bind.apply(_XMLHttpRequest, [{}].concat(args)));
        },
      });
    },

  },
};

