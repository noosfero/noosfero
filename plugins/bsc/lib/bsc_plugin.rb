class BscPlugin < Noosfero::Plugin

  Bsc

  def self.plugin_name
    "Bsc"
  end

  def self.plugin_description
    _("Adds the Bsc feature")
  end

  def admin_panel_links
    [{:title => _('Create Bsc'), :url => {:controller => 'bsc_plugin_admin', :action => 'new'}},
    {:title => _('Validate Enterprises'), :url => {:controller => 'bsc_plugin_admin', :action => 'validate_enterprises'}} ]
  end

  def control_panel_buttons
    buttons = []
    buttons << {:title => _("Manage associated enterprises"), :icon => 'bsc-enterprises', :url => {:controller => 'bsc_plugin_myprofile', :action => 'manage_associated_enterprises'}} if bsc?(context.profile)
    buttons << {:title => _('Transfer ownership'), :icon => 'transfer-enterprise-ownership', :url => {:controller => 'bsc_plugin_myprofile', :action => 'transfer_ownership'}} if context.profile.enterprise?
    buttons << {:title => _("Manage contracts"), :icon => '', :url => {:controller => 'bsc_plugin_myprofile', :action => 'manage_contracts'}} if bsc?(context.profile)
    buttons
  end

  def manage_members_extra_buttons
    {:title => _('Transfer ownership'), :icon => '', :url => {:controller => 'bsc_plugin_myprofile', :action => 'transfer_enterprises_management'}} if context.profile.enterprise?
  end

  def stylesheet?
    true
  end

  def catalog_list_item_extras(product)
    if bsc?(context.profile)
      enterprise = product.enterprise
      if is_member_of_any_bsc?(context.user)
        lambda {link_to(enterprise.short_name, enterprise.url, :class => 'bsc-catalog-enterprise-link')}
      else
        lambda {enterprise.short_name}
      end
    end
  end

  def profile_controller_filters
    if profile 
      special_enterprise = profile.enterprise? && !profile.validated && profile.bsc
      is_member_of_any_bsc = is_member_of_any_bsc?(context.user)
      block = lambda {
        render_access_denied if special_enterprise && !is_member_of_any_bsc
      }

      [{ :type => 'before_filter', :method_name => 'bsc_access', :block => block }]
    else
      []
    end
  end

  def content_viewer_controller_filters
    if profile
      special_enterprise = profile.enterprise? && !profile.validated && profile.bsc
      is_member_of_any_bsc = is_member_of_any_bsc?(context.user)
      block = lambda {
        render_access_denied if special_enterprise && !is_member_of_any_bsc
      }

      [{ :type => 'before_filter', :method_name => 'bsc_access', :block => block }]
    else
      []
    end
  end

  def profile_editor_controller_filters
    if context.user
      is_not_admin = !context.environment.admins.include?(context.user)
      [{  :type => 'before_filter',
          :method_name => 'bsc_destroy_access',
          :options => {:only => :destroy_profile},
          :block => lambda { render_access_denied  if is_not_admin } }]
    else
      []
    end
  end

  def manage_products_controller_filters
    if bsc?(profile)
      [{  :type => 'before_filter',
          :method_name => 'manage_products_bsc_destroy_access',
          :options => {:only => :destroy},
          :block => lambda { render_access_denied } }]
    else
      []
    end
  end

  def asset_product_properties(product)
    properties = []
    properties << { :name => _('Bsc'), :content => lambda { link_to(product.bsc.name, product.bsc.url) } } if product.bsc
    if product.enterprise.validated || is_member_of_any_bsc?(context.user)
      content = lambda { link_to_homepage(product.enterprise.name, product.enterprise.identifier) }
    else
      content = lambda { product.enterprise.name }
    end
    properties << { :name => c_('Supplier'), :content => content }
  end

  def profile_tabs
    if bsc?(context.profile)
      { :title => _("Contact"),
        :id => 'bsc-contact',
        :content => lambda { render :partial => 'profile_tab' },
        :start => true }
    end
  end

  private

  def bsc?(profile)
    profile.kind_of?(BscPlugin::Bsc)
  end

  def is_member_of_any_bsc?(user)
    BscPlugin::Bsc.all.any? { |bsc| bsc.members.include?(user) }
  end

  def profile
    context.environment.profiles.find_by_identifier(context.params[:profile])
  end

end
