class BscPluginMyprofileController < MyProfileController

  include BscPlugin::BscHelper

  def manage_associated_enterprises
    @associated_enterprises = profile.enterprises
    @pending_enterprises = profile.enterprise_requests.pending.map(&:enterprise)
  end

  def search_enterprise
    render :text => environment.enterprises.where("type <> 'BscPlugin::Bsc' AND (LOWER(name) LIKE ? OR LOWER(identifier) LIKE ?) AND (identifier NOT LIKE ?)", "%#{params[:q]}%", "%#{params[:q]}%", "%_template").
      select { |enterprise| enterprise.bsc.nil? && !profile.already_requested?(enterprise)}.
      map {|enterprise| {:id => enterprise.id, :name => enterprise.name} }.
      to_json
  end

  def save_associations
      enterprises = [Enterprise.find(params[:q].split(','))].flatten
      to_remove = profile.enterprises - enterprises
      to_add = enterprises - profile.enterprises

      to_remove.each do |enterprise|
        enterprise.bsc = nil
        enterprise.save!
        profile.enterprises.delete(enterprise)
      end

      to_add.each do |enterprise|
        if enterprise.enabled
          BscPlugin::AssociateEnterprise.create!(:requestor => user, :target => enterprise, :bsc => profile)
        else
          enterprise.bsc = profile
          enterprise.save!
          profile.enterprises << enterprise
        end
      end

      session[:notice] = _('This Bsc associations were saved successfully.')
    begin
      redirect_to :controller => 'profile_editor'
    rescue Exception => ex
      session[:notice] = _('This Bsc associations couldn\'t be saved.')
      logger.info ex
      redirect_to :action => 'manage_associated_enterprises'
    end
  end

  def similar_enterprises
    name = params[:name]
    city = params[:city]

    result = []
    if !name.blank?
      enterprises = (profile.environment.enterprises - profile.enterprises).select { |enterprise| enterprise.bsc_id.nil? && enterprise.city == city && enterprise.name.downcase.include?(name.downcase)}
      result = enterprises.inject(result) {|result, enterprise| result << [enterprise.id, enterprise.name]}
    end
    render :text => result.to_json
  end

  def transfer_ownership
    role = Profile::Roles.admin(profile.environment.id)
    @roles = [role]
    if request.post?
      person = Person.find(params['q_'+role.key])

      profile.admins.map { |admin| profile.remove_admin(admin) }
      profile.add_admin(person)

      BscPlugin::Mailer.deliver_admin_notification(person, profile)

      session[:notice] = _('Enterprise ownership transferred.')
      redirect_to :controller => 'profile_editor'
    end
  end

  def create_enterprise
    @create_enterprise = CreateEnterprise.new(params[:create_enterprise])
    @create_enterprise.requestor = user
    @create_enterprise.target = environment
    @create_enterprise.bsc_id = profile.id
    @create_enterprise.enabled = true
    @create_enterprise.validated = false
    if request.post? && @create_enterprise.valid?
      @create_enterprise.perform
      session[:notice] = _('Enterprise was created in association with %s.') % profile.name
      redirect_to :controller => 'profile_editor', :profile => @create_enterprise.identifier
    end
  end

  def manage_contracts
    self.class.no_design_blocks
    @sorting = params[:sorting] || 'created_at asc'
    sorted_by = @sorting.split(' ').first
    sort_direction = @sorting.split(' ').last
    @status = params[:status] || BscPlugin::Contract::Status.types.map { |s| s.to_s }
    @contracts =  profile.contracts.
      status(@status).
      sorted_by(sorted_by, sort_direction).
      paginate(:per_page => contracts_per_page, :page => params[:page])
  end

  def new_contract
    if !request.post?
      @contract = BscPlugin::Contract.new
    else
      @contract = BscPlugin::Contract.new(params[:contract])
      @contract.bsc = profile
      sales = params[:sales] ? params[:sales].map {|key, value| value} : []
      sales.reject! {|sale| sale[:product_id].blank?}

      if @contract.save!
        enterprises_ids = params[:enterprises] || ''
        enterprises_ids.split(',').each { |id| @contract.enterprises << Enterprise.find(id) }
        @failed_sales = @contract.save_sales(sales)

        if @failed_sales.blank?
          session[:notice] = _('Contract created.')
          redirect_to :action => 'manage_contracts'
        else
          session[:notice] = _('Contract created but some products could not be added.')
          redirect_to :action => 'edit_contract', :contract_id => @contract.id
        end
      end
    end
  end

  def view_contract
    begin
      @contract = BscPlugin::Contract.find(params[:contract_id])
    rescue
      session[:notice] = _('Contract doesn\'t exists! Maybe it was already removed.')
      redirect_to :action => 'manage_contracts'
    end
  end

  def edit_contract
    begin
      @contract = BscPlugin::Contract.find(params[:contract_id])
    rescue
      session[:notice] = _('Could not edit such contract.')
      redirect_to :action => 'manage_contracts'
    end
    if request.post? && @contract.update_attributes(params[:contract])

      # updating associated enterprises
      enterprises_ids = params[:enterprises] || ''
      enterprises = [Enterprise.find(enterprises_ids.split(','))].flatten
      to_remove = @contract.enterprises - enterprises
      to_add = enterprises - @contract.enterprises
      to_remove.each { |enterprise| @contract.enterprises.delete(enterprise)}
      to_add.each { |enterprise| @contract.enterprises << enterprise }

      # updating sales
      sales = params[:sales] ? params[:sales].map {|key, value| value} : []
      sales.reject! {|sale| sale[:product_id].blank?}
      products = [Product.find(sales.map { |sale| sale[:product_id] })].flatten
      to_remove = @contract.products - products
      to_keep = sales.select { |sale| @contract.products.include?(Product.find(sale[:product_id])) }

      to_keep.each do |sale_attrs|
        sale = @contract.sales.find_by_product_id(sale_attrs[:product_id])
        sale.update_attributes!(sale_attrs)
        sales.delete(sale_attrs)
      end

      to_remove.each { |product| @contract.sales.find_by_product_id(product.id).destroy }
      @failed_sales = @contract.save_sales(sales)

      if @failed_sales.blank?
        session[:notice] = _('Contract edited.')
        redirect_to :action => 'manage_contracts'
      else
        session[:notice] = _('Contract edited but some products could not be added.')
        redirect_to :action => 'edit_contract', :contract_id => @contract.id
      end
    end
  end

  def destroy_contract
    begin
      contract = BscPlugin::Contract.find(params[:contract_id])
      contract.destroy
      session[:notice] = _('Contract removed.')
    rescue
      session[:notice] = _('Contract could not be removed. Sorry! ^^')
    end
    redirect_to :action => 'manage_contracts'
  end

  def search_contract_enterprises
    render :text => profile.enterprises.
      where("(LOWER(name) LIKE ? OR LOWER(identifier) LIKE ?)", "%#{params[:enterprises]}%", "%#{params[:enterprises]}%").
      map {|enterprise| {:id => enterprise.id, :name => enterprise.short_name(60)} }.
      to_json
  end

  def search_sale_product
    query = params[:sales].map {|key, value| value}[0][:product_id]
    enterprises = (params[:enterprises] || []).split(',')
    enterprises = enterprises.blank? ? -1 : enterprises
    added_products = (params[:added_products] || []).split(',')
    added_products = added_products.blank? ? -1 : added_products
    render :text => Product.
      where("LOWER(name) LIKE ? AND profile_id IN (?) AND id NOT IN (?)", "%#{query}%", enterprises, added_products).
      map {|product| { :id => product.id,
                       :name => short_text(product_display_name(product), 60),
                       :sale_id => params[:sale_id],
                       :product_price => product.price || 0 }}.
      to_json
  end

  private

  def contracts_per_page
    15
  end
end
