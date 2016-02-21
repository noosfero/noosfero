class NewsletterPluginAdminController < PluginAdminController

  def index
    @newsletter = NewsletterPlugin::Newsletter.where(environment_id: environment.id).first_or_initialize

    if request.post?
      # token input gives the param as a comma separated string
      params[:newsletter][:blog_ids] = (params[:newsletter][:blog_ids] || '').split(',')

      params[:newsletter][:person_id] = user.id

      file = params[:file]
      if file && file[:recipients].present?
        @newsletter.import_recipients(file[:recipients], file[:name], file[:email], file[:headers].present?)
      end

      if !@newsletter.errors.any? && @newsletter.update_attributes(params[:newsletter])
        if params['visualize']
          @message = @newsletter.body
          render :file => 'mailing/sender/notification', :layout => false
        else
          session[:notice] = _('Newsletter updated.')
        end
      else
        session[:notice] = _('Newsletter could not be saved.')
      end
    end

    @blogs = Blog.includes(:profile).where id: @newsletter.blog_ids
  end

  #TODO: Make this query faster
  def search_profiles
    profiles = environment.profiles
    blogs = Blog.joins(:profile).where(profiles: {environment_id: environment.id})

    found_profiles = find_by_contents(:profiles, environment, profiles, params['q'], {:page => 1})[:results]
    found_blogs = find_by_contents(:blogs, environment, blogs, params['q'], {:page => 1})[:results]

    results = (found_blogs + found_profiles.map(&:blogs).flatten).uniq
    render :text => results.map { |blog| {:id => blog.id, :name => _("%s in %s") % [blog.name, blog.profile.name]} }.to_json
  end

  def recipients
    @additional_recipients = NewsletterPlugin::Newsletter.where(environment_id: environment.id).first_or_initialize.additional_recipients
  end

end
