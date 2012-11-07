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
  end
  
  should 'convert reading group to hash' do
    assert_equal @hash, @reading_group.to_hash
  end
  
  should 'verify existence of reading group' do
    Kalibro::ReadingGroup.expects(:request).with("ReadingGroup", :reading_group_exists, {:group_id => @hash[:id]}).returns({:exists => true})
    assert Kalibro::ReadingGroup.exists?(@hash[:id])
  end
  
  should 'get reading group' do
    Kalibro::ReadingGroup.expects(:request).with("ReadingGroup", :get_reading_group, {:group_id => @hash[:id]}).
      returns({:reading_group => @hash})
    assert_equal @hash[:name], Kalibro::ReadingGroup.find(@hash[:id]).name
  end

  should 'get all reading groups' do
    Kalibro::ReadingGroup.expects(:request).with("ReadingGroup", :all_reading_groups).returns({:reading_group => [@hash]})
    assert_equal @hash[:name], Kalibro::ReadingGroup.all.first.name
  end
  
  should 'get reading group of a metric configuration' do
    id = 31
    Kalibro::ReadingGroup.expects(:request).with("ReadingGroup", :reading_group_of, {:metric_configuration_id => id}).returns({:reading_group => @hash})
    assert_equal @hash[:name], Kalibro::ReadingGroup.reading_group_of(id).name
  end

  should 'return true when reading group is saved successfully' do
    id_from_kalibro = 1
    Kalibro::ReadingGroup.expects(:request).with("ReadingGroup", :save_reading_group, {:reading_group => @created_reading_group.to_hash}).returns(:reading_group_id => id_from_kalibro)
    assert @created_reading_group.save
    assert_equal id_from_kalibro, @created_reading_group.id
  end

  should 'return false when reading group is not saved successfully' do
    Kalibro::ReadingGroup.expects(:request).with("ReadingGroup", :save_reading_group, {:reading_group => @created_reading_group.to_hash}).raises(Exception.new)
    assert !(@created_reading_group.save)
    assert_nil @created_reading_group.id
  end

  should 'destroy reading group by id' do
    Kalibro::ReadingGroup.expects(:request).with("ReadingGroup", :delete_reading_group, {:group_id => @reading_group.id})
    @reading_group.destroy
  end
  
end

