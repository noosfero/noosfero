class PjaxPlugin < Noosfero::Plugin

  def self.plugin_name
    _('Pjax plugin')
  end

  def self.plugin_description
    _("Use pjax for page's links")
  end

  def stylesheet?
    true
  end

  def js_files
    ['jquery.pjax.js', 'patchwork.js', 'loading-overlay', 'pjax', ].map{ |j| "javascripts/#{j}" }
  end

  def head_ending
    #TODO: add pjax meta
  end

  def body_beginning
    lambda{ render 'pjax_layouts/load_state_script' }
  end

  PjaxCheck = lambda do
    return unless request.headers['X-PJAX']
    # raise makes pjax fallback to a regular request
    raise "Pjax can't be used here" if params[:controller] == 'account'

    @pjax = true
    @pjax_loaded_themes = request.headers['X-PJAX-Themes'].to_s.split(',') || []

    unless self.respond_to? :get_layout_with_pjax
      self.class.send :define_method, :get_layout_with_pjax do
        if @pjax then 'pjax' else get_layout_without_pjax end
      end
      self.class.alias_method_chain :get_layout, :pjax
    end
  end

  def application_controller_filters
    [{
      :type => 'before_filter', :method_name => 'pjax_check',
      :options => {}, :block => PjaxCheck,
    }]
  end

  protected

end
