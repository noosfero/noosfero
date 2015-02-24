class Noosfero::Plugin::Macro

  attr_accessor :context

  class << self
    # Options
    #
    # [:icon_path]  Determines the path to icon to be used in the button on
    #               tinymce
    # [:title]      Former name of the macro
    # [:skip_dialog]  Skip configuration dialog on tinymce
    # [:js_files]     Javascripts that should be included on tinymce
    # [:css_files     Css files that should be included on tinymce
    # [:generator]    Javascript code that will be loaded when the macro button
    #                 is clicked on tinymce
    # [:params]       Hash of macro fields that the user might configure
    #
    def configuration
      {}
    end

    def plugin
      name.split('::')[0...-1].join('::').constantize
    end

    def identifier
      name.underscore
    end
  end

  def initialize(context=nil)
    self.context = context
  end

  def attributes(macro)
    macro.attributes.to_hash.
      select {|key, value| key[0..10] == 'data-macro-'}.
      inject({}){|result, a| result.merge({a[0][11..-1] => a[1].to_s})}.
      with_indifferent_access
  end

  def convert(macro, source)
    macro_name = macro['data-macro']
    attrs = attributes(macro)

    begin
      content = parse(attrs, macro.inner_html, source)
      macro['class'] = "parsed-macro #{macro_name}"
    rescue Exception => exception
      content = _("Unsupported macro %s!") % macro_name
      macro['class'] = "failed-macro #{macro_name}"
    end

    attrs.each {|key, value| macro.remove_attribute("data-macro-#{key}")}
    content
  end

  # This is the method the macros should override
  def parse(attrs, inner_html, source)
    raise
  end

end
