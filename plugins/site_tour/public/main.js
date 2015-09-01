var siteTourPlugin = (function() {

  var actions = [];
  var groupTriggers = [];
  var userData = {};
  var intro;
  var options = {};

  function hasMark(name) {
    return jQuery.cookie("_noosfero_.sitetour." + name) ||
      jQuery.inArray(name, userData.site_tour_plugin_actions)>=0;
  }

  function mark(name) {
    jQuery.cookie("_noosfero_.sitetour." + name, 1, {expires: 365});
    if(userData.login) {
      jQuery.post('/plugin/site_tour/public/mark_action', {action_name: name}, function(data) { });
    }
  }

  function clearAll() {
    jQuery('.site-tour-plugin').removeAttr('data-intro data-intro-name data-step');
  }

  function configureIntro(force, actions) {
    clearAll();
    for(var i=0; i<actions.length; i++) {
      var action = actions[i];

      if(force || !hasMark(action.name)) {
        var el = jQuery(action.selector).filter(function() {
          return jQuery(this).is(":visible") && jQuery(this).css('visibility') != 'hidden';
        });
        el.addClass('site-tour-plugin');
        el.attr('data-intro', action.text);
        el.attr('data-intro-name', action.name);
        if(action.step) {
          el.attr('data-step', action.step);
        }
      }
    }
  }

  function actionsOnload() {
    var groups = jQuery.map(groupTriggers, function(g) { return g.name; });
    return jQuery.grep(actions, function(n, i) { return jQuery.inArray(n.name, groups); });
  }

  function actionsByGroup(group) {
    return jQuery.grep(actions, function(n, i) { return n.name===group });
  }

  function forceParam() {
    return jQuery.deparam.querystring()['siteTourPlugin']==='force';
  }

  return {
    setOption: function(key, value) {
      options[key] = value;
    },
    add: function (name, selector, text, step) {
      actions.push({name: name, selector: selector, text: text, step: step});
    },
    addGroupTrigger: function(name, selector, ev) {
      groupTriggers.push({name: name, selector: selector, event: ev});
      plugin = this;
      var handler = function() {
        configureIntro(forceParam(), actionsByGroup(name));
        intro.start();
        jQuery(document).off(ev, selector, handler);
      };
      jQuery(document).on(ev, selector, handler);
    },
    start: function(data, force) {
      force = typeof force !== 'undefined' ? force : false || forceParam();
      userData = data;

      intro = introJs();
      intro.setOption('tooltipPosition', 'auto');
      intro.setOption('showStepNumbers', 'false');
      intro.setOptions(options);
      intro.onafterchange(function(targetElement) {
        var name = jQuery(targetElement).attr('data-intro-name');
        mark(name);
      });
      configureIntro(force, actionsOnload());
      intro.start();
    },
    force: function() {
      this.start({}, true);
    }
  }
})();

jQuery( document ).ready(function( $ ) {
  $(window).bind('userDataLoaded', function(event, data) {
    siteTourPlugin.start(data);
  });
});
