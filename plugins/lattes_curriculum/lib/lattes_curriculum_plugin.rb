class LattesCurriculumPlugin < Noosfero::Plugin

  def self.plugin_name
    "Lattes Curriculum Plugin"
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

  def profile_tabs
    if show_lattes_tab?
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

  def profile_editor_controller_filters
    validate_lattes_url_block = proc do
      if request.post?
        if !params[:academic_infos].blank?
          @profile_data = profile

          academic_infos = {"academic_info_attributes" => params[:academic_infos]}

          params_profile_data = params[:profile_data]
          params_profile_data = params_profile_data.merge(academic_infos)

          @profile_data.attributes = params_profile_data
          @profile_data.valid?

          @possible_domains = profile.possible_domains

          unless AcademicInfo.matches?(params[:academic_infos])
            @profile_data.errors.add(:lattes_url, _(' Invalid lattes url'))
            render :action => :edit, :profile => profile.identifier
          end
        end
      end
    end

    create_academic_info_block = proc do
      if profile && profile.person? && profile.academic_info.nil?
        profile.academic_info = AcademicInfo.new
      end
    end

    [{:type => 'before_filter',
      :method_name => 'validate_lattes_url',
      :options => {:only => 'edit'},
      :block => validate_lattes_url_block },
    {:type => 'before_filter',
      :method_name => 'create_academic_info',
      :options => {:only => 'edit'},
      :block => create_academic_info_block }]
  end

  def account_controller_filters
    validate_lattes_url_block = proc do
      if request.post?
        params[:profile_data] ||= {}
        params[:profile_data][:academic_info_attributes] = params[:academic_infos]

        if !params[:academic_infos].blank? && !AcademicInfo.matches?(params[:academic_infos])
          @person = Person.new(params[:profile_data])
          @person.environment = environment
          @user = User.new(params[:user])
          @person.errors.add(:lattes_url, _(' Invalid lattes url'))
          render :action => :signup
        end
      end
    end

    create_academic_info_block = proc do
      if profile && profile.person? && profile.academic_info.nil?
        profile.academic_info = AcademicInfo.new
      end
    end

    [{:type => 'before_filter',
      :method_name => 'validate_lattes_url',
      :options => {:only => 'signup'},
      :block => validate_lattes_url_block },
    {:type => 'before_filter',
      :method_name => 'create_academic_info',
      :options => {:only => 'edit'},
      :block => create_academic_info_block }]
  end

  protected

  def academic_info_transaction
    AcademicInfo.transaction do
      context.profile.academic_info.update!(context.params[:academic_infos])
    end
  end

  def show_lattes_tab?
    return context.profile.person? && !context.profile.academic_info.nil? && !context.profile.academic_info.lattes_url.blank? && context.profile.public_fields.include?("lattes_url")
  end
end
