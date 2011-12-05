class Kalibro::Client::ProjectResultClient

  def initialize
    @port = Kalibro::Client::Port.new('ProjectResult')
  end

  def has_results_for(project_name)
    @port.request(:has_results_for, {:project_name => project_name})[:has_results]
  end

  def has_results_before(project_name, date)
    @port.request(:has_results_before, {:project_name => project_name, :date => date})[:has_results]
  end

  def has_results_after(project_name, date)
    @port.request(:has_results_after, {:project_name => project_name, :date => date})[:has_results]
  end

  def first_result(project_name)
    hash = @port.request(:get_first_result_of, {:project_name => project_name})[:project_result]
    Kalibro::Entities::ProjectResult.from_hash(hash)
  end

  def last_result(project_name)
    hash = @port.request(:get_last_result_of, {:project_name => project_name})[:project_result]
    Kalibro::Entities::ProjectResult.from_hash(hash)
  end

  def first_result_after(project_name, date)
    request_body = {:project_name => project_name, :date => date}
    hash = @port.request(:get_first_result_after, request_body)[:project_result]
    Kalibro::Entities::ProjectResult.from_hash(hash)
  end

  def last_result_before(project_name, date)
    request_body = {:project_name => project_name, :date => date}
    hash = @port.request(:get_last_result_before, request_body)[:project_result]
    Kalibro::Entities::ProjectResult.from_hash(hash)
  end

end