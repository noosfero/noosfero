module NoosferoHttpCaching

  def self.included(c)
    c.send(:after_filter, :noosfero_set_cache)
  end

  def noosfero_set_cache
    return if logged_in?
    n = nil
    if profile
      unless request.path =~ /^\/myprofile/
        n = environment.profile_cache_in_minutes
      end
    else
      if request.path == '/'
        n = environment.home_cache_in_minutes
      else
        if params[:controller] != 'account' && request.path !~ /^\/admin/
          n = environment.general_cache_in_minutes
        end
      end
    end
    if n
      expires_in n.minutes, :private => false, :public => true
    end
  end

end

if Rails.env != 'development'
  ActionController::Base.send(:include, NoosferoHttpCaching)
end
