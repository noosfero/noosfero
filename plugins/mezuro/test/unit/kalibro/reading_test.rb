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
    assert_equal @hash[:id].to_i, Kalibro::Reading.new(@hash).id
    assert_equal @hash[:grade].to_f, Kalibro::Reading.new(@hash).grade
  end
  
  should 'convert reading to hash' do
    assert_equal @hash, @reading.to_hash
  end
  
  should 'get reading' do
    Kalibro::Reading.expects(:request).with(:get_reading, {:reading_id => @hash[:id]}).
      returns({:reading => @hash})
    assert_equal @hash[:label], Kalibro::Reading.find(@hash[:id]).label
  end
  
  should 'get reading of a range' do
    range_id = 31
    Kalibro::Reading.expects(:request).with(:reading_of, {:range_id => range_id}).returns({:reading => @hash})
    assert_equal @hash[:label], Kalibro::Reading.reading_of(range_id).label
  end
  
  should 'get readings of a reading group' do
    reading_group_id = 31
    Kalibro::Reading.expects(:request).with(:readings_of, {:group_id => reading_group_id}).returns({:reading => [@hash]})
    assert_equal @hash[:label], Kalibro::Reading.readings_of(reading_group_id).first.label
  end

  should 'return true when reading is saved successfully' do
    id_from_kalibro = 1
    Kalibro::Reading.expects(:request).with(:save_reading, {:group_id => @created_reading.group_id, :reading => @created_reading.to_hash}).returns(:reading_id => id_from_kalibro)
    assert @created_reading.save
    assert_equal id_from_kalibro, @created_reading.id
  end

  should 'return false when reading is not saved successfully' do
    Kalibro::Reading.expects(:request).with(:save_reading, {:group_id => @created_reading.group_id, :reading => @created_reading.to_hash}).raises(Exception.new)
    assert !(@created_reading.save)
    assert_nil @created_reading.id
  end

  should 'destroy reading by id' do
    Kalibro::Reading.expects(:request).with(:delete_reading, {:reading_id => @reading.id})
    @reading.destroy
  end
  
end

