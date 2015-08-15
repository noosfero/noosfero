class SiteTourPlugin::TourBlock < Block

  settings_items :actions, :type => Array, :default => [{:group_name => 'tour_plugin', :selector => '.site-tour-plugin_tour-block .tour-button', :description => _('Click to start tour!')}]
  settings_items :group_triggers, :type => Array, :default => []
  settings_items :display_button, :type => :boolean, :default => true

  attr_accessible :actions, :display_button, :group_triggers

  before_save do |block|
    block.actions.reject! {|i| i[:group_name].blank? && i[:selector].blank? && i[:description].blank?}
    block.group_triggers.reject! {|i| i[:group_name].blank? && i[:selector].blank?}
  end

  def self.description
    _('Site Tour Block')
  end

  def help
    _('Configure a step-by-step tour.')
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/tour', :locals => {:block => block}
    end
  end

end
