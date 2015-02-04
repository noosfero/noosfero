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
    begin
      community = environment.communities.find(params[:template_id])
    rescue ActiveRecord::RecordNotFound
      message = _('Community not found. The template could no be changed.')
      community = nil
    end

    message = _('%s defined as default') % community.name if set_as_default(community)
    session[:notice] = message

    redirect_to :action => 'index'
  end

  def set_person_as_default
    begin
      person = environment.people.find(params[:template_id])
    rescue ActiveRecord::RecordNotFound
      message = _('Person not found. The template could no be changed.')
      person = nil
    end

    message = _('%s defined as default') % person.name if set_as_default(person)
    session[:notice] = message

    redirect_to :action => 'index'
  end

  def set_enterprise_as_default
    begin
      enterprise = environment.enterprises.find(params[:template_id])
    rescue ActiveRecord::RecordNotFound
      message = _('Enterprise not found. The template could no be changed.')
      enterprise = nil
    end

    message = _('%s defined as default') % enterprise.name if set_as_default(enterprise)
    session[:notice] = message

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

