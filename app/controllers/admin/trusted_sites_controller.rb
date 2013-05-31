class TrustedSitesController < AdminController
  protect 'manage_environment_trusted_sites', :environment

  def index
    @sites = environment.trusted_sites_for_iframe
  end

  def new
    @site = ""
  end

  def create
    if add_trusted_site(params[:site])
      session[:notice] = _('New trusted site added.')
      redirect_to :action => 'index'
    else
      session[:notice] = _('Failed to add trusted site.')
      render :action => 'new'
    end
  end

  def edit
    if is_trusted_site? params[:site]
      @site = params[:site]
    else
      session[:notice] = _('Trusted site was not found')
      redirect_to :action => 'index'
    end
  end

  def update
    site = params[:site]
    orig_site = params[:orig_site]
    if rename_trusted_site(orig_site, site)
      redirect_to :action => 'edit', :site => @site
    else
      session[:notice] = _('Failed to edit trusted site.')
      render :action => 'edit'
    end
  end

  def destroy
    if delete_trusted_site(params[:site])
      session[:notice] = _('Trusted site removed')
    else
      session[:notice] = _('Trusted site could not be removed')
    end
    redirect_to :action => 'index'
  end

  protected
  def add_trusted_site (site)
    trusted_sites = environment.trusted_sites_for_iframe
    trusted_sites << site
    environment.trusted_sites_for_iframe = trusted_sites
    environment.save
  end

  def rename_trusted_site(orig_site, site)
    trusted_sites = environment.trusted_sites_for_iframe
    i = trusted_sites.index orig_site
    if i.nil?
      return false
    else
      trusted_sites[i] = site
      environment.trusted_sites_for_iframe = trusted_sites
      environment.save
    end
  end


  def delete_trusted_site (site)
    trusted_sites = environment.trusted_sites_for_iframe
    trusted_sites.delete site
    environment.trusted_sites_for_iframe = trusted_sites
    environment.save
  end

  def is_trusted_site? (site)
    environment.trusted_sites_for_iframe.include? site
  end
end
