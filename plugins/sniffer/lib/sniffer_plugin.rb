class SnifferPlugin < Noosfero::Plugin

  def self.plugin_name
    "Opportunity Sniffer"
  end

  def self.plugin_description
    _("Sniffs product suppliers and consumers near to your enterprise.")
  end

  def stylesheet?
    true
  end

  def control_panel_entries
    [SnifferPlugin::ControlPanel::ConsumerInterests, SnifferPlugin::ControlPanel::OpportunitiesSniffer]
  end

  def self.extra_blocks
    { SnifferPlugin::InterestsBlock => {} }
  end

end
