class ProfileThemesController < ThemesController
  needs_profile

  protect "edit_appearance", :profile

  no_design_blocks

  def target
    @target = profile
  end

  def new
    if !request.xhr?
      id = params[:name] ? params[:name].to_slug : "my-theme"
      t = Theme.new(id, name: params[:name], owner: profile, public: false)
      t.save
      redirect_to action: "index"
    else
      render action: "new", layout: false
    end
  end

  def edit
    @theme = profile.find_theme(params[:id])
    @css_files = @theme.css_files
    @image_files = @theme.image_files
  end

  def add_css
    @theme = profile.find_theme(params[:id])
    if request.xhr?
      render action: "add_css", layout: false
    else
      @theme.add_css(params[:css])
      redirect_to action: "edit", id: @theme.id
    end
  end

  def css_editor
    @theme = profile.find_theme(params[:id])
    @css = params[:css]

    @code = @theme.read_css(@css)
    render action: "css_editor", layout: false
  end

  post_only :update_css
  def update_css
    @theme = profile.find_theme(params[:id])
    @theme.update_css(params[:css], params[:csscode])
    redirect_to action: "edit", id: @theme.id
  end

  def add_image
    @theme = profile.find_theme(params[:id])
    if request.xhr?
      render action: "add_image", layout: false
    else
      @theme.add_image(params[:image].original_filename, params[:image].read)
      redirect_to action: "edit", id: @theme.id
    end
  end

  def start_test
    session[:user_theme] = params[:id]
    redirect_to controller: "content_viewer", profile: profile.identifier, action: "view_page"
  end

  def stop_test
    session[:user_theme] = nil
    redirect_to action: "index"
  end
end
