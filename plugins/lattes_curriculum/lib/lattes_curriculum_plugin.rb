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

  def extra_optional_fields
    if context.profile && context.profile.person? && context.profile.academic_info.nil?
      context.profile.academic_info = AcademicInfo.new
    end

    fields = []

    lattes_url = {
      :name => 'lattes_url',
      :label => 'Lattes URL',
      :object_name => :academic_infos,
      :method => :lattes_url,
      :value => context.profile.nil? ? "" : context.profile.academic_info.lattes_url
    }

    fields << lattes_url

    return fields
  end

  def extra_person_fields
    fields = []

    fields << "lattes_url"

    return fields
  end

  def extra_person_data_params
    {"academic_info_attributes" => context.params[:academic_infos]}
  end

  def profile_tabs
    unless context.profile.academic_info.nil? || context.profile.academic_info.lattes_url.blank?
      href = context.profile.academic_info.lattes_url
      html_parser = Html_parser.new
      {
        :title => _("Lattes"),
        :id => 'lattes_tab',
        :content => lambda{html_parser.get_html(href)},
        :start => false
      }
    end
  end

  def profile_editor_transaction_extras
    if context.profile.person?
      if context.params.has_key?(:academic_infos)
        academic_info_transaction
      end
    end
  end

  protected

  def academic_info_transaction
    AcademicInfo.transaction do
      context.profile.academic_info.update_attributes!(context.params[:academic_infos])
    end
  end

end
