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
      required(labelled_form_field(_('USP number'), text_field_tag('profile_data[usp_id]', '', :id => 'usp_id_field'))) +
      content_tag('div', required(labelled_form_field(_('Birth date (yyyy-mm-dd)'), text_field_tag('birth_date', ''))), :id => 'signup-birth-date', :style => 'display: none') +
      content_tag('div', required(labelled_form_field(_('CPF'), text_field_tag('cpf', ''))), :id => 'signup-cpf', :style => 'display:none') +
      javascript_include_tag('../plugins/stoa/javascripts/jquery.observe_field', '../plugins/stoa/javascripts/signup_complement')
    }
  end

  def account_controller_filters
    block = lambda do
      if request.post?
        if !StoaPlugin::UspUser.matches?(params[:profile_data][:usp_id], params[:confirmation_field], params[params[:confirmation_field]])
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

end
