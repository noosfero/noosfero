class FeaturesController < AdminController
  protect 'edit_environment_features', :environment
  helper CustomFieldsHelper

  def index
    @features = Environment.available_features.sort_by{|k,v|v}
  end

  post_only :update
  def update
    if @environment.update(params[:environment])
      session[:notice] = _('Features updated successfully.')
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end

  def manage_fields
    @person_fields = Person.fields
    @enterprise_fields = Enterprise.fields
    @community_fields = Community.fields
  end

  def manage_person_fields
    environment.custom_person_fields = params[:person_fields]
    if environment.save!
      session[:notice] = _('Person fields updated successfully.')
    else
      flash[:error] = _('Person fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_enterprise_fields
    environment.custom_enterprise_fields = params[:enterprise_fields]
    if environment.save!
      session[:notice] = _('Enterprise fields updated successfully.')
    else
      flash[:error] = _('Enterprise fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_community_fields
    environment.custom_community_fields = params[:community_fields]
    if environment.save!
      session[:notice] = _('Community fields updated successfully.')
    else
      flash[:error] = _('Community fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_custom_fields
    custom_field_list = params[:custom_fields] || {}

    custom_fields_to_destroy =
      params[:customized_type].constantize.custom_fields(environment).map(&:id) - custom_field_list.keys.map(&:to_i)
    CustomField.destroy(custom_fields_to_destroy)

    custom_field_list.each_pair do |id, custom_field|
      field = CustomField.find_by(id: id)
      if not field.blank?
        params_to_update = custom_field.except(:format, :extras, :customized_type,:environment)
        field.update_attributes(params_to_update)
      else
        if !custom_field[:extras].nil?
          tmp = []
          custom_field[:extras].each_pair do |k, v|
            tmp << v
          end
          custom_field[:extras] = tmp
        end
        field =  CustomField.new custom_field.except(:environment)
        field.environment=environment
        field.save if field.valid?
      end
    end
    redirect_to :action => 'manage_fields'
  end

  def search_members
    arg = params[:q].downcase
    result = environment.people.where('LOWER(name) LIKE ? OR identifier LIKE ?', "%#{arg}%", "%#{arg}%")
    render :text => prepare_to_token_input(result).to_json
  end

end
