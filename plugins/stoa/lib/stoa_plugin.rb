require_dependency 'person'

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
      labelled_form_field(_('Select a confirmation data'), select_tag('confirmation_field',
        options_for_select([['CPF','cpf'], [_('Mother\'s name'), 'mother'], [_('Birth date (yyyy-mm-dd)'), 'birth']])
      )) +
      required(labelled_form_field(_('Confirmation value'), text_field_tag('confirmation_value', '', :placeholder=>_('Confirmation value')))) +
      javascript_tag(<<-EOF
        jQuery("#usp_id_field").change(function(){
          var me=this;
          jQuery(this).addClass('checking').removeClass('validated');
          jQuery.getJSON('#{url_for(:controller => 'stoa_plugin', :action => 'check_usp_id')}?usp_id='+this.value,
            function(data){
              if(data.exists) jQuery(me).removeClass('checking').addClass('validated');
              else jQuery(me).removeClass('checking').addClass('invalid');
              if(data.error) displayValidationUspIdError(data.error);
            }
          );
        });

        function displayValidationUspIdError(error){
          jQuery.colorbox({html: '<h2>'+error.message+'</h2>'+error.backtrace.join("<br />"),
                           height: "80%",
                           width:  "70%" });
        }
        EOF
      )
    }
  end

  def account_controller_filters
    block = lambda do
      if request.post?
        if !StoaPlugin::UspUser.matches?(params[:profile_data][:usp_id], params[:confirmation_field], params[:confirmation_value])
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
