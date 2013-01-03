require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/processing_fixtures"
class ProcessingTest < ActiveSupport::TestCase

  def setup
    @hash = ProcessingFixtures.processing_hash
    @processing = ProcessingFixtures.processing
    
    @repository_id = 31
  end

  should 'create processing from hash' do
    processing = Kalibro::Processing.new(@hash)
    assert_equal @hash[:results_root_id].to_i, processing.results_root_id
    assert_equal @hash[:process_time].first[:state], processing.process_times.first.state
    assert_equal @hash[:id].to_i, processing.id
  end

  should 'convert processing to hash' do
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
  
end
