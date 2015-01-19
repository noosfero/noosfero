class VotePluginAdminController < PluginAdminController

  def index
    settings = params[:settings]
    settings ||= {}
    settings.each do |k, v|
      settings[k] = settings[k].map{|v| v.to_i }.reject{|v| v==0} if k.start_with?('enable_vote')
    end

    @settings = Noosfero::Plugin::Settings.new(environment, VotePlugin, settings)
    if request.post?
      @settings.save!
      session[:notice] = 'Settings succefully saved.'
      redirect_to :action => 'index'
    end
  end

end
