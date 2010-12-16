class MezuroPlugin::Project < Noosfero::Plugin::ActiveRecord
  has_many :metrics, :as => :metricable

  validates_presence_of :name, :repository_url, :identifier
  validates_format_of :identifier, :with => /^[a-z0-9|\-|\.]*$/, :message => "Identifier can only have a combination of lower case, number, hyphen and dot!"
  validates_uniqueness_of :identifier

  named_scope :with_tab, :conditions => {:with_tab => true}
  named_scope :by_profile, lambda {|profile| {:conditions => {:profile_id => profile.id}}}


  after_create :asynchronous_calculate_metrics

  def calculate_metrics
     begin
      download_source_code
      extractor = MezuroPlugin::AnalizoExtractor.new self
      extractor.perform
     rescue Svn::Error => error
      update_attribute :svn_error, error.error_message
     end
  end

  def asynchronous_calculate_metrics
    Delayed::Job.enqueue MezuroPlugin::CalculateMetricsJob.new(id)
  end

  def download_source_code
    download_prepare
    Svn::Client::Context.new.checkout(repository_url, "#{RAILS_ROOT}/tmp/#{identifier}")
  end

  def download_prepare
    project_path = "#{RAILS_ROOT}/tmp/#{identifier}"
    FileUtils.rm_r project_path if (File.exists? project_path)
  end

  def metrics_calculated?
    return !metrics.empty?
  end

  def total_metrics
    total_metrics = metrics.select do |metric|
      metric.name.start_with?("total")
    end
    return total_metrics.sort_by {|metric| metric.name}
  end

  def statistical_metrics
    statistical_metrics = collect_statistical_metrics

    hash = {}
    statistical_metrics.each do |metric|
      insert_metric_in_hash metric, hash
    end
    hash
  end

  def collect_statistical_metrics
    statistical_metrics = metrics.select do |metric|
      not metric.name.start_with?("total")
    end
    statistical_metrics.sort_by {|metric| metric.name}
  end

  def insert_metric_in_hash metric, hash
    metric_name, metric_statistic = metric.name.split("_")
    unless hash.key?(metric_name)
      hash[metric_name] = {metric_statistic => metric.value}
    else
      hash[metric_name][metric_statistic] = metric.value
    end
  end
end
