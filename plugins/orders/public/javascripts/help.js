// see also: HelpHelper methods

help = {
  selector: '.hideable-help',
  link_selector: '.hideable-help-link',

  cookie: {
    key: function(text) {
      return 'hide-help-'+text.hashCode()
    },
    get: function(text) {
      var hide = jQuery.cookie(this.key(text))
      return hide == 'true' ? true : false
    },
    set: function(text, hide) {
      hide = hide ? 'true' : 'false';
      return jQuery.cookie(this.key(text), hide)
    }
  },

  apply_all: function() {
    jQuery(this.selector).each(function (i, container) {
      container = jQuery(container)
      var hide = help.cookie.get(container.text())
      container.toggle(!hide)
      var link = container.siblings(this.link_selector)
      help.apply(link)
    });
  },

  apply: function(link) {
    link = jQuery(link)
    var container = link.siblings(this.selector)

    var isShown = container.is(':visible')
    link.text(link.attr(isShown ? 'data-hide' : 'data-show'))
    container.toggle(isShown);
  },

  toggle: function(link) {
    link = jQuery(link)
    var container = link.siblings(this.selector)

    container.toggle()
    var hide = !container.is(':visible')

    help.cookie.set(container.text(), hide)
    this.apply(link)
  },

};

jQuery(document).ready(function() {
  help.apply_all()
});

String.prototype.hashCode = function() {
  var hash = 0, i, chr, len;
  if (this.length == 0) return hash;
  for (i = 0, len = this.length; i < len; i++) {
    chr   = this.charCodeAt(i);
    hash  = ((hash << 5) - hash) + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return hash;
};
