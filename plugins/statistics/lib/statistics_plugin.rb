require_dependency File.dirname(__FILE__) + '/statistics_block'

class StatisticsPlugin < Noosfero::Plugin

  def self.plugin_name
    "Statistics Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a block where you can see statistics of it's context.")
  end

  def self.extra_blocks
    {
      StatisticsBlock => {}
    }
  end

end
