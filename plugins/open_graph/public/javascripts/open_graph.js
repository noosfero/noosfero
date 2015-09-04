open_graph = {

  track: {

    config: {

      view: {
        form: null,
      },

      init: function(reload) {
        this.view.form = $('#track-form form')
        this.view.form.find('.panel-heading').each(function(i, context) {
          open_graph.track.config.headingToggle(context)
        })
      },

      submit: function() {
        loading_overlay.show($('#track-config'))
        open_graph.track.config.view.form.ajaxSubmit({
          success: function(data) {
            data = $(data)
            // needs update to get ids from accepts_nested_attributes_for
            $('#track-activity').html(data.find('#track-activity').html())
            loading_overlay.hide($('#track-config'))
          },
        })
        return false;
      },

      // trigged on init state and on subcheckboxes change
      headingToggle: function(context, open) {
        var panel = $(context).parents('.panel')
        var panelHeading = panel.find('.panel-heading')
        var panelBody = panel.find('.panel-body')
        var parentCheckbox = panel.find('.config-check')
        var configButton = panel.find('.config-button')
        var input = panel.find('.track-config-toggle')
        var openWas = input.val() == 'true'
        if (open === undefined)
          open = input.val() == 'true' && (panelHeading.hasClass('enable-on-empty') || this.numberChecked(context) > 0)
        // open is defined, that is an user action
        else {
          if (open) {
            if (panelHeading.hasClass('open-on-enable'))
              panelBody.collapse('show')
          } else
            panelBody.collapse('hide')
        }

        configButton.toggle(open)
        parentCheckbox.toggleClass('fa-toggle-on', open)
        parentCheckbox.toggleClass('fa-toggle-off', !open)
        input.prop('value', open)
        if (openWas != open)
          open_graph.track.config.submit()
      },

      // the event of change
      toggleEvent: function(context, event) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        var checkboxes = panelBody.find('input[type=checkbox]')
        var open = panel.find('.track-config-toggle').val() == 'true'
        open = !open;

        checkboxes.prop('checked', open)

        this.headingToggle(context, open)
        return false;
      },

      open: function(context) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        panelBody.collapse('show')
      },

      toggleObjectType: function(checkbox) {
        checkbox = $(checkbox)

        this.headingToggle(checkbox)

        checkbox.siblings("input[name*='[_destroy]']").val(!checkbox.is(':checked'))
        open_graph.track.config.submit()
      },

      numberChecked: function(context) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        var checkboxes = panel.find('.panel-body input[type=checkbox]')
        var profilesInput = panel.find('.panel-body .select-profiles')

        var nObjects = checkboxes.filter(':checked').length
        var nProfiles = profilesInput.length ? profilesInput.tokenfield('getTokens').length : 0;
        var nChecked = nObjects + nProfiles;
        var nTotal = checkboxes.length + nProfiles

        return nChecked
      },

      enterprise: {
        see_all: function(context) {
          var panel = $(context).parents('.panel')
          var panelBody = panel.find('.panel-body')
          noosfero.modal.html(panelBody.html())
        },
      },

      initAutocomplete: function(track, url, items) {
        var selector = '#select-'+track
        var input = $(selector)
        var tokenField = open_graph.autocomplete.init(url, selector, items)

        input.change(open_graph.track.config.submit)
        tokenField
          .on('tokenfield:createdtoken tokenfield:removedtoken', function() {
            open_graph.track.config.headingToggle(this)
          }).on('tokenfield:createtoken tokenfield:removetoken', function(event) {
            input.val()
          }).on('tokenfield:createtoken', function(event) {
            var existingTokens = $(this).tokenfield('getTokens')
            $.each(existingTokens, function(index, token) {
              if (token.value === event.attrs.value)
                event.preventDefault()
            })
          })

        return tokenField;
      },

    },
  },

  autocomplete: {
    bloodhoundOptions: {
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      ajax: {
        beforeSend: function() {
          input.addClass('small-loading')
        },
        complete: function() {
          input.removeClass('small-loading')
        },
      },
    },
    tokenfieldOptions: {

    },
    typeaheadOptions: {
      minLength: 1,
      highlight: true,
    },

    init: function(url, selector, data, options) {
      options = options || {}
      var bloodhoundOptions = $.extend({}, this.bloodhoundOptions, options.bloodhound || {});
      var typeaheadOptions = $.extend({}, this.typeaheadOptions, options.typeahead || {});
      var tokenfieldOptions = $.extend({}, this.tokenfieldOptions, options.tokenfield || {});

      var input = $(selector)
      bloodhoundOptions.remote = {
        url: url,
        replace: function(url, uriEncodedQuery) {
          return $.param.querystring(url, {query:uriEncodedQuery});
        },
      }
      var engine = new Bloodhound(bloodhoundOptions)
      engine.initialize()

      tokenfieldOptions.typeahead = [typeaheadOptions, { displayKey: 'label', source: engine.ttAdapter() }]

      var tokenField = input.tokenfield(tokenfieldOptions)
      input.tokenfield('setTokens', data)

      return input
    },
  },
}

