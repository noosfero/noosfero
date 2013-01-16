require "test_helper"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_group_fixtures"

class ReadingGroupTest < ActiveSupport::TestCase

  def setup  
    @hash = ReadingGroupFixtures.reading_group_hash
    @reading_group = ReadingGroupFixtures.reading_group
    @created_reading_group = ReadingGroupFixtures.created_reading_group
  end

  should 'create reading group from hash' do
    assert_equal @hash[:name], Kalibro::ReadingGroup.new(@hash).name
    assert_equal @hash[:id].to_i, Kalibro::ReadingGroup.new(@hash).id
  end
  
  should 'convert reading group to hash' do
    assert_equal @hash, @reading_group.to_hash
  end
  
  should 'verify existence of reading group' do
    fake_id = 0
    Kalibro::ReadingGroup.expects(:request).with(:reading_group_exists, {:group_id => fake_id}).returns({:exists => false})
    Kalibro::ReadingGroup.expects(:request).with(:reading_group_exists, {:group_id => @hash[:id].to_i}).returns({:exists => true})
    assert !Kalibro::ReadingGroup.exists?(fake_id)
    assert Kalibro::ReadingGroup.exists?(@hash[:id].to_i)
  end
  
  should 'get reading group' do
    Kalibro::ReadingGroup.expects(:request).with(:reading_group_exists, {:group_id => @hash[:id]}).returns({:exists => true})
    Kalibro::ReadingGroup.expects(:request).with(:get_reading_group, {:group_id => @hash[:id]}).
      returns({:reading_group => @hash})
    assert_equal @hash[:name], Kalibro::ReadingGroup.find(@hash[:id]).name
  end

  should 'get all reading groups when there is only one reading group' do
    Kalibro::ReadingGroup.expects(:request).with(:all_reading_groups).returns({:reading_group => @hash})
    assert_equal @hash[:name], Kalibro::ReadingGroup.all.first.name
  end
  
  should 'get all reading groups when there are many reading groups' do
    Kalibro::ReadingGroup.expects(:request).with(:all_reading_groups).returns({:reading_group => [@hash, @hash]})
    reading_groups = Kalibro::ReadingGroup.all
    assert_equal @hash[:name], reading_groups.first.name
    assert_equal @hash[:name], reading_groups.last.name
  end

  should 'return empty when there are no reading groups' do
    Kalibro::ReadingGroup.expects(:request).with(:all_reading_groups).returns({:reading_group => nil})
    assert_equal [], Kalibro::ReadingGroup.all
  end
  
  should 'get reading group of a metric configuration' do
    id = 31
    Kalibro::ReadingGroup.expects(:request).with(:reading_group_of, {:metric_configuration_id => id}).returns({:reading_group => @hash})
    assert_equal @hash[:name], Kalibro::ReadingGroup.reading_group_of(id).name
  end

  should 'return true when reading group is saved successfully' do
    id_from_kalibro = 1
    Kalibro::ReadingGroup.expects(:request).with(:save_reading_group, {:reading_group => @created_reading_group.to_hash}).returns(:reading_group_id => id_from_kalibro)
    assert @created_reading_group.save
    assert_equal id_from_kalibro, @created_reading_group.id
  end

  should 'return false when reading group is not saved successfully' do
    Kalibro::ReadingGroup.expects(:request).with(:save_reading_group, {:reading_group => @created_reading_group.to_hash}).raises(Exception.new)
    assert !(@created_reading_group.save)
    assert_nil @created_reading_group.id
  end

  should 'destroy reading group by id' do
    Kalibro::ReadingGroup.expects(:request).with(:delete_reading_group, {:group_id => @reading_group.id})
    @reading_group.destroy
  end
  
end

