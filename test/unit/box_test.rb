require File.dirname(__FILE__) + '/../test_helper'

class BoxTest < ActiveSupport::TestCase
  should 'retrieve environment based on owner' do
    profile = fast_create(Profile)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => 'Profile')
    assert_equal profile.environment, box.environment

    box = fast_create(Box, :owner_id => Environment.default.id, :owner_type => 'Environment')
    assert_equal Environment.default, box.environment
  end

  should 'list allowed blocks for center box' do
    blocks = Box.new(:position => 1).acceptable_blocks

    assert !blocks.include?('block')
    assert !blocks.include?('disabled-enterprise-message-block')
    assert !blocks.include?('featured-products-block')
    assert !blocks.include?('products-block')
    assert !blocks.include?('profile-info-block')
    assert !blocks.include?('profile-list-block')
    assert !blocks.include?('profile-search-block')
    assert !blocks.include?('slideshow-block')
    assert !blocks.include?('location-block')

    assert blocks.include?('article-block')
    assert blocks.include?('blog-archives-block')
    assert blocks.include?('categories-block')
    assert blocks.include?('communities-block')
    assert blocks.include?('enterprises-block')
    assert blocks.include?('environment-statistics-block')
    assert blocks.include?('fans-block')
    assert blocks.include?('favorite-enterprises-block')
    assert blocks.include?('feed-reader-block')
    assert blocks.include?('friends-block')
    assert blocks.include?('highlights-block')
    assert blocks.include?('link-list-block')
    assert blocks.include?('login-block')
    assert blocks.include?('main-block')
    assert blocks.include?('members-block')
    assert blocks.include?('my-network-block')
    assert blocks.include?('people-block')
    assert blocks.include?('profile-image-block')
    assert blocks.include?('raw-html-block')
    assert blocks.include?('recent-documents-block')
    assert blocks.include?('sellers-search-block')
    assert blocks.include?('tags-block')
  end

  should 'list allowed blocks for box at position 2' do
    blocks = Box.new(:position => 2).acceptable_blocks

    assert !blocks.include?('main-block')
    assert !blocks.include?('block')
    assert !blocks.include?('profile-list-block')

    assert blocks.include?('article-block')
    assert blocks.include?('blog-archives-block')
    assert blocks.include?('categories-block')
    assert blocks.include?('communities-block')
    assert blocks.include?('disabled-enterprise-message-block')
    assert blocks.include?('enterprises-block')
    assert blocks.include?('environment-statistics-block')
    assert blocks.include?('fans-block')
    assert blocks.include?('favorite-enterprises-block')
    assert blocks.include?('featured-products-block')
    assert blocks.include?('feed-reader-block')
    assert blocks.include?('friends-block')
    assert blocks.include?('highlights-block')
    assert blocks.include?('link-list-block')
    assert blocks.include?('location-block')
    assert blocks.include?('login-block')
    assert blocks.include?('members-block')
    assert blocks.include?('my-network-block')
    assert blocks.include?('people-block')
    assert blocks.include?('products-block')
    assert blocks.include?('profile-image-block')
    assert blocks.include?('profile-info-block')
    assert blocks.include?('profile-search-block')
    assert blocks.include?('raw-html-block')
    assert blocks.include?('recent-documents-block')
    assert blocks.include?('sellers-search-block')
    assert blocks.include?('slideshow-block')
    assert blocks.include?('tags-block')
  end

end
