class OrdersCyclePluginCycleController < OrdersPluginAdminController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  protect 'edit_profile', :profile
  before_filter :set_admin

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::DisplayHelper

  def index
    @closed_cycles = search_scope(profile.orders_cycles.closing).all
    if request.xhr?
      render partial: 'results'
    else
      @open_cycles = profile.orders_cycles.opened
    end
  end

  def new
    if request.patch?
      # can't use profile.orders_cycle here
      @cycle = OrdersCyclePlugin::Cycle.find params[:id]

      params[:cycle][:status] = 'orders' if @open = params[:open] == '1'
      @success = @cycle.update params[:cycle]

      if @success
        session[:notice] = t('controllers.myprofile.cycle_controller.cycle_created')
        if params[:sendmail]
          OrdersCyclePlugin::Mailer.delay(run_at: @cycle.start).open_cycle(
            @cycle.profile, @cycle, "#{t'controllers.myprofile.cycle_controller.new_open_cycle'}: #{@cycle.name}", @cycle.opening_message)
        end
      else
        render action: :edit
      end
    else
      count = profile.orders_cycles.maximum(:code) || 1
      @cycle = OrdersCyclePlugin::Cycle.create! profile: profile, status: 'new',
        name: t('controllers.myprofile.cycle_controller.cycle_n_n') % {n: count+1}
    end
  end

  def edit
    # editing an order
    return super if params[:actor_name]

    @cycle = profile.orders_cycles.find params[:id]
    @products = products

    if request.xhr?
      if params[:commit]
        params[:cycle][:status] = 'orders' if @open = params[:open] == '1'
        @success = @cycle.update params[:cycle]

        if params[:sendmail]
          OrdersCyclePlugin::Mailer.delay(run_at: @cycle.start).open_cycle(@cycle.profile,
            @cycle, t('controllers.myprofile.cycle_controller.new_open_cycle')+": "+@cycle.name, @cycle.opening_message)
        end
      end
    end
  end

  def products_load
    @cycle = profile.orders_cycles.find params[:id]
    @products = products

    if @cycle.add_products_job
      render nothing: true
    else
      render partial: 'product_lines'
    end
  end

  def destroy
    @cycle = profile.orders_cycles.find params[:id]
    @cycle.destroy
    redirect_to action: :index
  end

  def step
    @cycle = profile.orders_cycles.find params[:id]
    @cycle.step
    @cycle.save!
    redirect_to action: :edit, id: @cycle.id
  end

  def step_back
    @cycle = profile.orders_cycles.find params[:id]
    @cycle.step_back
    @cycle.save!
    redirect_to action: :edit, id: @cycle.id
  end

  def add_missing_products
    @cycle = profile.orders_cycles.find params[:id]
    @cycle.add_products
    render partial: 'suppliers_plugin/shared/pagereload'
  end

  def report_products
    return super if params[:ids].present?
    @cycle = profile.orders_cycles.find params[:id]
    report_file = report_products_by_supplier @cycle.supplier_products_by_suppliers(@cycle.sales.ordered)

    send_file report_file, type: 'application/xlsx',
      disposition: 'attachment',
      filename: t('controllers.myprofile.admin.products_report') % {
        date: DateTime.now.strftime("%Y-%m-%d"), profile_identifier: profile.identifier, name: @cycle.name_with_code}
  end

  def report_orders
    return super if params[:ids].present?
    @cycle = profile.orders_cycles.find params[:id]
    report_file = report_orders_by_consumer @cycle.sales.ordered

    send_file report_file, type: 'application/xlsx',
      disposition: 'attachment',
      filename: t('controllers.myprofile.admin.orders_report') % {date: DateTime.now.strftime("%Y-%m-%d"), profile_identifier: profile.identifier, name: @cycle.name_with_code}
  end

  def filter
    @cycle = profile.orders_cycles.find params[:owner_id]
    @scope = @cycle

    params[:code].gsub!(/^#{@cycle.code}\./, '') if params[:code].present?
    super
  end

  protected

  attr_accessor :cycle

  extend HMVC::ClassMethods
  hmvc OrdersCyclePlugin, orders_context: OrdersCyclePlugin

  def search_scope scope
    params[:date] ||= {}
    scope = scope.by_year params[:date][:year] if params[:date][:year].present?
    scope = scope.by_month params[:date][:month] if params[:date][:month].present?
    scope = scope.by_status params[:status] if params[:status].present?
    scope
  end

  def set_admin
    @admin = true
  end

  def products
    @cycle.products.unarchived.paginate per_page: 15, page: params["page"]
  end

end
