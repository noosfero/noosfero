require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_group_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_group_content_fixtures"

class ReadingGroupContentTest < ActiveSupport::TestCase

  def setup
    @reading_group_content = ReadingGroupContentFixtures.reading_group_content
    @reading_group = ReadingGroupFixtures.reading_group
    @reading = ReadingFixtures.reading
  end

  should 'provide proper short description' do
    assert_equal 'Mezuro reading group', MezuroPlugin::ReadingGroupContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Set of thresholds to interpret metric results', MezuroPlugin::ReadingGroupContent.description
  end

  should 'have an html view' do
    assert_not_nil @reading_group_content.to_html
  end

  should 'get reading_group from service' do
    Kalibro::ReadingGroup.expects(:find).with(@reading_group.id).returns(@reading_group)
    assert_equal @reading_group, @reading_group_content.reading_group
  end

  should 'add error to base when the reading_group does not exist' do
    Kalibro::ReadingGroup.expects(:find).with(@reading_group.id).raises(Kalibro::Errors::RecordNotFound)
    assert_nil @reading_group_content.errors[:base]
    @reading_group_content.reading_group
    assert_not_nil @reading_group_content.errors[:base]
  end

  should 'get readings of the reading_group from service' do
    Kalibro::Reading.expects(:readings_of).with(@reading_group.id).returns([@reading])
    assert_equal [@reading], @reading_group_content.readings
  end
  
  should 'add error to base when getting the readings of a reading_group that does not exist' do
    Kalibro::Reading.expects(:readings_of).with(@reading_group.id).raises(Kalibro::Errors::RecordNotFound)
    assert_nil @reading_group_content.errors[:base]
    @reading_group_content.readings
    assert_not_nil @reading_group_content.errors[:base]
  end

end
