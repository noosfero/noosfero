module TinymceHelper
  include MacrosHelper

  def tinymce_js
    output = tinymce_assets
    macro_files = include_macro_js_files
    output += macro_files unless macro_files.nil?
    output.html_safe
  end

  def tinymce_editor options = {}
    tinymce base_options(options)
  end

  private

  def menubar mode
    if mode =='restricted' || mode == 'simple'
      return false
    end
    return 'edit insert view tools'
  end

  def toolbar1 mode
    if mode == 'restricted'
      return "bold italic underline | link"
    end
    return "fullscreen | insertfile undo redo | copy paste | bold italic underline strikethrough removeformat backcolor | styleselect fontselect fontsizeselect | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image | hilitecolor"
  end

  def toolbar2 mode
    if mode.blank?
      toolbar2 = 'print preview code media | table'
      toolbar2 += ' | macros'
      macros_with_buttons.each do |macro|
        toolbar2 += " #{macro.identifier}"
      end
      return toolbar2
    else
      false
    end
  end

  def base_options options = {}
    options.merge!(:document_base_url => top_url,
      :content_css => "/stylesheets/tinymce.css,#{macro_css_files}",
      :language => tinymce_language,
      :selector => '.' + current_editor(options[:mode]),
      :menubar => menubar(options[:mode]),
      :toolbar => [toolbar1(options[:mode]), toolbar2(options[:mode])],
      :font_formats => 'Arial=arial,helvetica,sans-serif;Courier New=courier new,courier,monospace;AkrutiKndPadmini=Akpdmi-n',
      :setup => macros_setup)
  end

end
