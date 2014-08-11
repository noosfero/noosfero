class TemplatesController < AdminController
  protect 'manage_environment_templates', :environment

  def create_person_template
    if request.post?
      begin
        identifier = params[:name].to_slug
        password = Digest::MD5.hexdigest(rand.to_s)
        template = User.new(:login => identifier, :email => identifier+'@templates.noo', :password => password, :password_confirmation => password, :person_data => {:name => params[:name], :is_template => true})
        template.save!
        session[:notice] = _('New template created')
        redirect_to :action => 'index'
      rescue
        @error = _('Name has already been taken')
      end
    end
  end

  def create_community_template
    if request.post?
      begin
        create_organization_template(Community)
        session[:notice] = _('New template created')
        redirect_to :action => 'index'
      rescue
        @error = _('Name has already been taken')
      end
    end
  end

  def create_enterprise_template
    if request.post?
      begin
        create_organization_template(Enterprise)
        session[:notice] = _('New template created')
        redirect_to :action => 'index'
      rescue
        @error = _('Name has already been taken')
      end
    end
  end

  def set_community_as_default
    set_as_default(Community.find(params[:template_id]))
    redirect_to :action => 'index'
  end

  def set_person_as_default
    set_as_default(Person.find(params[:template_id]))
    redirect_to :action => 'index'
  end

  def set_enterprise_as_default
    set_as_default(Enterprise.find(params[:template_id]))
    redirect_to :action => 'index'
  end

  private

  def set_as_default(obj)
    return nil if obj.nil?
    case obj.class.name
      when 'Community' then
        environment.community_default_template = obj
        environment.save!
      when 'Person' then
        environment.person_default_template = obj
        environment.save!
      when 'Enterprise' then
        environment.enterprise_default_template = obj
        environment.save!
      else
        nil
    end
  end

  def create_organization_template(klass)
    identifier = params[:name].to_slug
    template = klass.new(:name => params[:name], :identifier => identifier, :is_template => true)
    template.save!
  end

end

