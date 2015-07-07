require_dependency 'person'

class StoaPlugin < Noosfero::Plugin

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
    proc {
      content_tag(:div, labelled_form_field(_('USP number'), text_field(:profile_data, :usp_id, :id => 'usp_id_field')) +
      content_tag(:small, _('The usp id grants you special powers in the network. Don\'t forget to fill it with a valid number if you have one.'), :id => 'usp-id-balloon') +
      content_tag('p', _("Either this usp number is being used by another user or is not valid"), :id => 'usp-id-invalid') +
      content_tag('p', _('Checking usp number...'), :id => 'usp-id-checking'), :id => 'signup-usp-id') +
      content_tag('div', required(labelled_form_field(_('Birth date (yyyy-mm-dd)'), text_field_tag('birth_date', ''))) +
      content_tag(:small, _('Confirm your birth date. Pay attention to the format: yyyy-mm-dd.'), :id => 'usp-birth-date-balloon'), :id => 'signup-birth-date', :style => 'display: none') +
      content_tag('div', required(labelled_form_field(_('CPF'), text_field_tag('cpf', ''))) +
      content_tag(:small, _('Confirm your CPF number.'), :id => 'usp-cpf-balloon'), :id => 'signup-cpf', :style => 'display: none') +
      javascript_include_tag('../plugins/stoa/javascripts/jquery.observe_field', '../plugins/stoa/javascripts/signup_complement')
    }
  end

  def profile_info_extra_contents
    if context.profile.person?
      usp_id = context.profile.usp_id
      lambda {
        content_tag('div', labelled_form_field(_('USP number'), text_field_tag('profile_data[usp_id]', usp_id, :id => 'usp_id_field', :disabled => usp_id.present?)) +
        content_tag(:small, _('The usp id grants you special powers in the network. Don\'t forget to fill it if you have one.')) +
        content_tag('div', labelled_check_box(c_('Public'), '', '', false, :disabled => true, :title => _('This field must be private'), :class => 'disabled'), :class => 'field-privacy-selector'), :class => 'field-with-privacy-selector') +
        content_tag('div', required(labelled_form_field(_('Birth date (yyyy-mm-dd)'), text_field_tag('birth_date', ''))), :id => 'signup-birth-date', :style => 'display: none') +
        content_tag('div', required(labelled_form_field(_('CPF'), text_field_tag('cpf', ''))), :id => 'signup-cpf', :style => 'display:none') +
        javascript_include_tag('../plugins/stoa/javascripts/jquery.observe_field', '../plugins/stoa/javascripts/signup_complement')
      }
    end
  end

  def login_extra_contents
    proc {
      content_tag('div', labelled_form_field(_('USP number / Username'), text_field_tag('usp_id_login', '', :id => 'stoa_field_login')) +
      labelled_form_field(c_('Password'), password_field_tag('password', '', :id => 'stoa_field_password')), :id => 'stoa-login-fields')
    }
  end

  def alternative_authentication
    person = Person.find_by_usp_id(context.params[:usp_id_login])
    if person
      user = User.authenticate(person.user.login, context.params[:password])
    else
      user = User.authenticate(context.params[:usp_id_login], context.params[:password])
    end
    user
  end

  def account_controller_filters
    block = proc do
      params[:profile_data] ||= {}
      params[:profile_data][:invitation_code] = params[:invitation_code]
      invitation = Task.pending.find(:first, :conditions => {:code => params[:invitation_code]})
      if request.post?
        if !invitation && !StoaPlugin::UspUser.matches?(params[:profile_data][:usp_id], params[:confirmation_field], params[params[:confirmation_field]])
          # `self` below is evaluated in the context of account_controller
          @person = Person.new(:environment => self.environment)
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
    block = proc do
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
      :block => proc {render_access_denied if !user || user.usp_id.blank?} }]
  end

  def control_panel_buttons
    { :title => c_('Invite friends'),
      :icon => 'invite-friends',
      :url => {:controller => 'invite',
               :action => 'invite_friends'} } if context.send(:user) && context.send(:user).usp_id.present?
  end

  def remove_invite_friends_button
    true
  end

  def change_password_fields
    {:field => :usp_id, :name => _('USP Number'), :model => 'person'}
  end

  def search_friend_fields
    [{:field => :usp_id, :name => _('USP Number')}]
  end

end
