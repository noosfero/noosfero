require File.dirname(__FILE__) + '/../../test_helper'

class TrackHelperTest < ActiveSupport::TestCase

  include CommunityTrackPlugin::TrackHelper
  include NoosferoTestHelper
  include ActionView::Helpers::TextHelper

  def setup
    @track = CommunityTrackPlugin::Track.new
  end

  should 'return css class for track with category' do
    category = fast_create(Category, :name => 'education')
    @track.categories << category
    assert_equal 'category_education', category_class(@track)
  end

  should 'return default css class for a track without category' do
    assert_equal 'category_not_defined', category_class(@track)
  end

  should 'return css class for first category that the class belongs' do
    category1 = fast_create(Category, :name => 'education')
    @track.categories << category1
    category2 = fast_create(Category, :name => 'tech')
    @track.categories << category2
    assert_equal 'category_education', category_class(@track)
  end

  should 'return css class with category name properly formated' do
    category = fast_create(Category, :name => 'not defined')
    @track.categories << category
    assert_equal 'category_not-defined', category_class(@track)
  end

  should 'return lead for track removing html tags' do
    @track.abstract = "display <div>pure text</div>"
    assert_equal "display pure text", track_card_lead(@track)
  end

  should 'limit lead char length' do
    @track.abstract = ""
    400.times { @track.abstract += "a" }
    assert_equal 306, track_card_lead(@track).length
  end

  should 'display a shorter lead if track has a image' do
    @track.abstract = ""
    @track.image = Image.new
    400.times { @track.abstract += "a" }
    assert_equal 186, track_card_lead(@track).length
  end

  should 'return category color if its defined' do
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb')
    @track.categories << category1
    assert_equal 'background-color: #fbfbfb;', track_color_style(@track)
  end

  should 'return category color for track name' do
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb')
    @track.categories << category1
    assert_equal 'color: #fbfbfb;', track_name_color_style(@track)
  end

end
