class MezuroPlugin::Metric < Noosfero::Plugin::ActiveRecord
  validates_presence_of :name, :metricable_id, :metricable_type

  belongs_to :metricable, :polymorphic => true
  before_save :round_value

  def initialize params
    params[:value] = nil if params[:value] == '~'
    super params
  end

  def round_value
    if self.value
      multiplied = self.value * 100
      rounded = multiplied.round
      self.value = rounded / 100.0
    end
  end
end
