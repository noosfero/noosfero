require "test_helper"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_fixtures"

class ReadingTest < ActiveSupport::TestCase

  def setup  
    @hash = ReadingFixtures.reading_hash
    @reading = ReadingFixtures.reading
    @created_reading = ReadingFixtures.created_reading
  end

  should 'create reading from hash' do
    assert_equal @hash[:label], Kalibro::Reading.new(@hash).label
  end
  
  should 'convert reading to hash' do
    assert_equal @hash, @reading.to_hash
  end
  
  should 'get reading' do
    Kalibro::Reading.expects(:request).with("Reading", :get_reading, {:reading_id => @hash[:id]}).
      returns({:reading => @hash})
    assert_equal @hash[:label], Kalibro::Reading.find(@hash[:id]).label
  end
  
  should 'get reading of a range' do
    range_id = 31
    Kalibro::Reading.expects(:request).with("Reading", :reading_of, {:range_id => range_id}).returns({:reading => @hash})
    assert_equal @hash[:label], Kalibro::Reading.reading_of(range_id).label
  end
  
  should 'get readings of a reading group' do
    reading_group_id = 31
    Kalibro::Reading.expects(:request).with("Reading", :readings_of, {:group_id => reading_group_id}).returns({:reading => [@hash]})
    assert_equal @hash[:label], Kalibro::Reading.readings_of(reading_group_id).first.label
  end

  should 'return true when reading is saved successfully' do
    id_from_kalibro = 1
    Kalibro::Reading.expects(:request).with("Reading", :save_reading, {:reading => @created_reading.to_hash}).returns(id_from_kalibro)
    assert @created_reading.save
    assert_equal id_from_kalibro, @created_reading.id
  end

  should 'return false when reading is not saved successfully' do
    Kalibro::Reading.expects(:request).with("Reading", :save_reading, {:reading => @created_reading.to_hash}).raises(Exception.new)
    assert !(@created_reading.save)
    assert_nil @created_reading.id
  end

  should 'destroy reading by id' do
    Kalibro::Reading.expects(:request).with("Reading", :delete_reading, {:reading_id => @reading.id})
    @reading.destroy
  end
  
end

