class Kalibro::Processing < Kalibro::Model

  attr_accessor :id, :date, :state, :error, :process_times, :results_root_id

  def self.has_processing(repository_id)
    request('Processing', :has_processing, {:repository_id => repository_id})[:exists]
  end
  
  def self.has_ready_processing(repository_id)
    request('Processing', :has_ready_processing, {:repository_id => repository_id})[:exists]
  end
  
  def self.has_processing_after(repository_id, date)
    request('Processing', :has_processing_after, {:repository_id => repository_id, :date => date})[:exists]
  end

  def self.has_processing_before(repository_id, date)
    request('Processing', :has_processing_before, {:repository_id => repository_id, :date => date})[:exists]
  end

  def self.last_processing_state_of(repository_id)
    request('Processing', :last_processing_state, {:repository_id => repository_id})[:process_state]
  end
  
  def self.last_ready_processing_of(repository_id)
    new request('Processing', :last_ready_processing, {:repository_id => repository_id})[:processing]
  end

  def self.first_processing_of(repository_id)
    new request('Processing', :first_processing, {:repository_id => repository_id})[:processing]
  end

  def self.last_processing_of(repository_id)
    new request('Processing', :last_processing, {:repository_id => repository_id})[:processing]
  end

  def self.first_processing_after(repository_id, date)
    new request('Processing', :first_processing_after, {:repository_id => repository_id, :date => date})[:processing]
  end

  def self.last_processing_before(repository_id, date)
    new request('Processing', :last_processing_before, {:repository_id => repository_id, :date => date})[:processing]
  end

  def date=(value)
    @date = value.is_a?(String) ? DateTime.parse(value) : value
  end

end
