class LattesCurriculumPlugin < Noosfero::Plugin

  def self.plugin_name
    "LattesCurriculumPlugin"
  end

  def self.plugin_description
    _("A plugin that imports the lattes curriculum into the users profiles")
  end

  def js_files
    ["singup_complement.js"]
  end

  def stylesheet?
    true
  end

  def signup_extra_contents
    lambda {
      content_tag(:div, labelled_form_field(_('URL Lattes'), text_field(:profile_data, :lattes_url, :id => 'lattes_id_field')) +
      content_tag(:small, _('The Lattes url is the link for your own curriculum so it\'ll be shown on your profile.'), 
        :class => 'signup-form', :id => 'lattes-id-balloon'), :id => 'signup-lattes-id') 
    }
  end

  def profile_info_extra_contents
    if context.profile.person?
      lattes_url = context.profile.lattes_url
      lambda {
        content_tag('div', labelled_form_field(_('URL Lattes'), text_field_tag('profile_data[lattes_url]', lattes_url, :id => 'lattes_url_field', :disabled => false)) +
        content_tag(:small, _('The url lattes is the link for your lattes curriculum.')))
      }
    end
  end

  def profile_tabs
    unless context.profile.lattes_url.nil?    
      href = context.profile.lattes_url
      html_parser = Html_parser.new
      { 
        :title => _("Lattes"), 
        :id => 'lattes_tab', 
        :content => lambda{html_parser.get_html(href)}, 
        :start => false 
      }
    end
  end
end
