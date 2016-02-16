require_relative '../test_helper'

class ProfileDesignControllerTest < ActionController::TestCase

  def setup
    @controller = ProfileDesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    user = create_user('testinguser')
    login_as(user.login)
    @profile = user.person
    @environment = @profile.environment

    @environment.enabled_plugins = ['VideoPlugin']
    @environment.save!

    VideoBlock.delete_all
    @box1 = Box.create!(:owner => @profile)
    @profile.boxes = [@box1]

    @block = VideoBlock.new
    @block.box = @box1
    @block.save!

    @profile.blocks<<@block
    @profile.save!
  end

  attr_accessor :profile, :block

  should 'display video-block-data class in profile block edition' do
    block.url='youtube.com/?v=XXXXX'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :div, :attributes => {:class => 'video-block-data'}
  end

  should "display iframe tag in profile block edition on youtube url's" do
    block.url='youtube.com/?v=XXXXX'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'iframe'
  end

  should "the width in iframe tag be defined on youtube url's" do
    block.url='youtube.com/?v=XXXXX'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'iframe', :attributes => {:width => '400px'}
  end

  should "display iframe tag in profile block edition on vimeo url's" do
    block.url='http://vimeo.com/98979'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'iframe'
  end

  should "the width in iframe tag be defined on vimeo url's" do
    block.url='http://vimeo.com/98979'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'iframe', :attributes => {:width => '400px'}
  end

  should "display video tag in profile block edition for any video url" do
    block.url='http://www.vmsd.com/98979.mp4'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'video'
  end

  should "the width in video tag be defined for any video url" do
    block.url='http://www.vmsd.com/98979.mp4'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'video', :attributes => {:width => '400px'}
  end

  should 'the heigth in iframe tag be defined' do
    block.url='youtube.com/?v=XXXXX'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'iframe', :attributes => {:height => '315px'}
  end

  should 'display youtube videos' do
    block.url='youtube.com/?v=XXXXX'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'div', :attributes => {:class => 'video-block-data'}, :descendant => { :tag => 'div', :attributes => {:class => 'youtube'} }
  end

  should 'display vimeo videos' do
    block.url='http://vimeo.com/98979'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'div', :attributes => {:class => 'video-block-data'}, :descendant => { :tag => 'div', :attributes => {:class => 'vimeo'} }
  end

  should 'display other videos' do
    block.url='http://www.vmsd.com/98979.mp4'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'div', :attributes => {:class => 'video-block-data'}, :descendant => { :tag => 'div', :attributes => {:class => 'video'} }
  end

  should 'display a messagem to register a new url' do
    block.url='http://www.vmsd.com/test.pdf'
    block.save
    get :index, :profile => profile.identifier

    assert_tag :tag => 'div', :attributes => {:class => 'video-block-data'}, :descendant => { :tag => 'span', :attributes => {:class => 'alert-block'} }
  end


end
