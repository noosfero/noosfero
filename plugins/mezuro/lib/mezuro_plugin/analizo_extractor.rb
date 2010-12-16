class MezuroPlugin::AnalizoExtractor < Noosfero::Plugin::ActiveRecord
  attr_reader :string_output, :hash_output

  def initialize project
    @project = project
  end

  def perform
    run_analizo
    create_hash
    save_metrics
  end

  def run_analizo
    project_path = "#{RAILS_ROOT}/tmp/#{@project.identifier}"
    @string_output = `analizo metrics #{project_path}`
  end

  def create_hash
    @hash_output = {}
    first_line = true

    @string_output.lines.each do |line|
      if line =~ /---/
        if first_line
          first_line = false
        else
          break
        end
      end

      if line =~ /(\S+): (~|(\d+)(\.\d+)?).*/
        @hash_output[$1.to_sym] = $2
      end
    end
  end

  def save_metrics
    @hash_output.each do | key, value |
      MezuroPlugin::Metric.create(:name => key.to_s, :value => value.to_f, :metricable => @project)
    end
  end
end
