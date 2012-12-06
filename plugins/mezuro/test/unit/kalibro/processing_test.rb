require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/processing_fixtures"
#TODO arrumar os testes de unidade
class ProcessingTest < ActiveSupport::TestCase

  def setup
    @hash = ProcessingFixtures.processing_hash
    @processing = ProcessingFixtures.processing
    
    @repository_id = 31
  end

  should 'create project result from hash' do
    assert_equal @hash[:results_root_id], Kalibro::Processing.new(@hash).results_root_id
    assert_equal @hash[:process_time].first[:state], Kalibro::Processing.new(@hash).process_times.first.state
  end

  should 'convert project result to hash' do
    assert_equal @hash, @processing.to_hash
  end

  should 'verify if a repository has a processing' do
    true_repository_id = 31
    false_repository_id = 32
    
    Kalibro::Processing.expects(:request).with(:has_processing, {:repository_id => true_repository_id}).returns({:exists => true})
    Kalibro::Processing.expects(:request).with(:has_processing, {:repository_id => false_repository_id}).returns({:exists => false})
    
    assert Kalibro::Processing.has_processing(true_repository_id)
    assert !Kalibro::Processing.has_processing(false_repository_id)
  end
  
  should 'verify if a repository has a ready processing' do
    true_repository_id = 31
    false_repository_id = 32
    
    Kalibro::Processing.expects(:request).with(:has_ready_processing, {:repository_id => true_repository_id}).returns({:exists => true})
    Kalibro::Processing.expects(:request).with(:has_ready_processing, {:repository_id => false_repository_id}).returns({:exists => false})
    
    assert Kalibro::Processing.has_ready_processing(true_repository_id)
    assert !Kalibro::Processing.has_ready_processing(false_repository_id)
  end
  
  should 'verify if a repository has a processing after a date' do
    true_repository_id = 31
    false_repository_id = 32
    
    Kalibro::Processing.expects(:request).with(:has_processing_after, {:repository_id => true_repository_id, :date => @processing.date}).returns({:exists => true})
    Kalibro::Processing.expects(:request).with(:has_processing_after, {:repository_id => false_repository_id, :date => @processing.date}).returns({:exists => false})
    
    assert Kalibro::Processing.has_processing_after(true_repository_id, @processing.date)
    assert !Kalibro::Processing.has_processing_after(false_repository_id, @processing.date)
  end  
  
  should 'verify if a repository has a processing before a date' do
    true_repository_id = 31
    false_repository_id = 32
    
    Kalibro::Processing.expects(:request).with(:has_processing_before, {:repository_id => true_repository_id, :date => @processing.date}).returns({:exists => true})
    Kalibro::Processing.expects(:request).with(:has_processing_before, {:repository_id => false_repository_id, :date => @processing.date}).returns({:exists => false})
    
    assert Kalibro::Processing.has_processing_before(true_repository_id, @processing.date)
    assert !Kalibro::Processing.has_processing_before(false_repository_id, @processing.date)
  end  
  
  should 'get last processing state of a repository' do
    Kalibro::Processing.expects(:request).with(:last_processing_state, {:repository_id => @repository_id}).returns({:process_state => @processing.state})
    assert_equal @processing.state, Kalibro::Processing.last_processing_state_of(@repository_id)
  end
  
  should 'get last ready processing of a repository' do
    Kalibro::Processing.expects(:request).with(:last_ready_processing, {:repository_id => @repository_id}).returns({:processing => @hash})
    assert_equal @processing.id, Kalibro::Processing.last_ready_processing_of(@repository_id).id
  end

  should 'get first processing of a repository' do
    Kalibro::Processing.expects(:request).with(:first_processing, {:repository_id => @repository_id}).returns({:processing => @hash})
    assert_equal @processing.id, Kalibro::Processing.first_processing_of(@repository_id).id
  end
  
  should 'get last processing of a repository' do
    Kalibro::Processing.expects(:request).with(:last_processing, {:repository_id => @repository_id}).returns({:processing => @hash})
    assert_equal @processing.id, Kalibro::Processing.last_processing_of(@repository_id).id
  end
  
  should 'get first processing after a date of a repository' do
    Kalibro::Processing.expects(:request).with(:first_processing_after, {:repository_id => @repository_id, :date => @processing.date}).returns({:processing => @hash})
    assert_equal @processing.id, Kalibro::Processing.first_processing_after(@repository_id, @processing.date).id
  end
  
  should 'get last processing before a date of a repository' do
    Kalibro::Processing.expects(:request).with(:last_processing_before, {:repository_id => @repository_id, :date => @processing.date}).returns({:processing => @hash})
    assert_equal @processing.id, Kalibro::Processing.last_processing_before(@repository_id, @processing.date).id
  end
  
=begin
  should 'get processing of a repository' do
    Kalibro::Processing.expects(:has_ready_processing).with(@repository.id).returns(true)
    Kalibro::Processing.expects(:last_ready_processing_of).with(@repository.id).returns(@processing)
    assert_equal @processing, @project_content.processing(@repository.id)
  end
  
  should 'get not ready processing of a repository' do
    Kalibro::Processing.expects(:has_ready_processing).with(@repository.id).returns(false)
    Kalibro::Processing.expects(:last_processing_of).with(@repository.id).returns(@processing)
    assert_equal @processing, @project_content.processing(@repository.id)
  end
  
  should 'get processing of a repository after date' do
    Kalibro::Processing.expects(:has_processing_after).with(@repository.id, @date).returns(true)
    Kalibro::Processing.expects(:first_processing_after).with(@repository.id, @date).returns(@processing)
    assert_equal @processing, @project_content.processing_with_date(@repository.id, @date)
  end
  
  should 'get processing of a repository before date' do
    Kalibro::Processing.expects(:has_processing_after).with(@repository.id, @date).returns(false)
    Kalibro::Processing.expects(:has_processing_before).with(@repository.id, @date).returns(true)
    Kalibro::Processing.expects(:last_processing_before).with(@repository.id, @date).returns(@processing)
    assert_equal @processing, @project_content.processing_with_date(@repository.id, @date)
  end

  should 'get module result' do
    @project_content.expects(:processing).with(@repository.id).returns(@processing)
    Kalibro::ModuleResult.expects(:find).with(@processing.results_root_id).returns(@module_result)
    assert_equal @module_result, @project_content.module_result(@repository.id)

  end
  
  should 'get module result with date' do
    @project_content.expects(:processing_with_date).with(@repository.id,@date.to_s).returns(@processing)
    Kalibro::ModuleResult.expects(:find).with(@processing.results_root_id).returns(@module_result)
    assert_equal @module_result, @project_content.module_result(@repository.id, @date.to_s)
  end

  should 'get result history' do
    Kalibro::MetricResult.expects(:history_of).with(@module_result.id).returns([@date_metric_result])
    assert_equal [@date_metric_result], @project_content.result_history(@module_result.id)
  end

  should 'add error to base when the module_result does not exist' do
    Kalibro::MetricResult.expects(:history_of).with(@module_result.id).raises(Kalibro::Errors::RecordNotFound)
    assert_nil @project_content.errors[:base]
    @project_content.result_history(@module_result.id)
    assert_not_nil @project_content.errors[:base]
  end
=end

end
