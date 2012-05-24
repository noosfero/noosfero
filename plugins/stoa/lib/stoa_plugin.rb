require_dependency 'person'
require_dependency 'ext/person'

class StoaPlugin < Noosfero::Plugin

  Person.human_names[:usp_id] = _('USP number')

  def self.plugin_name
    "Stoa"
  end

  def self.plugin_description
    _("Add Stoa features")
  end

  def stylesheet?
    true
  end

  def signup_extra_contents
    lambda {
      labelled_form_field(_('USP number'), text_field_tag('profile_data[usp_id]', '', :id => 'usp_id_field')) +
      content_tag(:small, _('The usp id grants you special powers in the network. Don\'t forget to fill it if you have one.'), :id => 'usp-id-balloon') +
      content_tag('div', required(labelled_form_field(_('Birth date (yyyy-mm-dd)'), text_field_tag('birth_date', ''))), :id => 'signup-birth-date', :style => 'display: none') +
      content_tag('div', required(labelled_form_field(_('CPF'), text_field_tag('cpf', ''))), :id => 'signup-cpf', :style => 'display:none') +
      javascript_include_tag('../plugins/stoa/javascripts/jquery.observe_field', '../plugins/stoa/javascripts/signup_complement')
    }
  end

  def profile_info_extra_contents
    lambda {
      labelled_form_field(_('USP number'), text_field_tag('profile_data[usp_id]', '', :id => 'usp_id_field')) +
      content_tag(:small, _('The usp id grants you special powers in the network. Don\'t forget to fill it if you have one.')) +
      content_tag('div', required(labelled_form_field(_('Birth date (yyyy-mm-dd)'), text_field_tag('birth_date', ''))), :id => 'signup-birth-date', :style => 'display: none') +
      content_tag('div', required(labelled_form_field(_('CPF'), text_field_tag('cpf', ''))), :id => 'signup-cpf', :style => 'display:none') +
      javascript_include_tag('../plugins/stoa/javascripts/jquery.observe_field', '../plugins/stoa/javascripts/signup_complement')
    } if context.profile.person? && context.profile.usp_id.blank?
  end

  def account_controller_filters
    block = lambda do
      params[:profile_data] ||= {}
      params[:profile_data][:invitation_code] = params[:invitation_code]
      if request.post?
        if !params[:invitation_code] && !StoaPlugin::UspUser.matches?(params[:profile_data][:usp_id], params[:confirmation_field], params[params[:confirmation_field]])
          @person = Person.new
          @person.errors.add(:usp_id, _(' validation failed'))
          render :action => :signup
        end
      end
    end

    [{ :type => 'before_filter',
      :method_name => 'validate_usp_id',
      :options => {:only => 'signup'},
      :block => block }]
  end

  def profile_editor_controller_filters
    block = lambda do
      if request.post?
        if !params[:profile_data][:usp_id].blank? && !StoaPlugin::UspUser.matches?(params[:profile_data][:usp_id], params[:confirmation_field], params[params[:confirmation_field]])
          @profile_data = profile
          @profile_data.attributes = params[:profile_data]
          @profile_data.valid?
          @profile_data.errors.add(:usp_id, _(' validation failed'))
          @profile_data.usp_id = nil
          @possible_domains = profile.possible_domains
          render :action => :edit
        end
      end
    end

    [{ :type => 'before_filter',
      :method_name => 'validate_usp_id',
      :options => {:only => 'edit'},
      :block => block }]
  end

  def invite_controller_filters
    [{ :type => 'before_filter',
      :method_name => 'check_usp_id_existence',
      :block => lambda {render_access_denied if profile.usp_id.blank?} }]
  end

  def control_panel_buttons
    { :title => _('Invite friends'),
      :icon => 'invite-friends',
      :url => {:controller => 'invite',
               :action => 'select_address_book'} } if !context.profile.usp_id.blank?
  end

  def remove_invite_friends_button
    true
  end

end
