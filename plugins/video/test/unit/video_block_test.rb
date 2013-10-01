require File.dirname(__FILE__) + '/../test_helper'
class VideoBlockTest < ActiveSupport::TestCase

  ### Tests for YouTube

  should "is_valid_source return true when the url contains http://youtube.com" do
    block = VideoBlock.new
    block.url = "http://youtube.com/?v=XXXXX"
    assert block.is_valid_source?
  end
  
  should "is_valid_source return true when the url contains https://youtube.com" do
    block = VideoBlock.new
    block.url = "https://youtube.com/?v=XXXXX"
    assert block.is_valid_source?
  end
  
  should "is_valid_source return true when the url contains https://www.youtube.com" do
    block = VideoBlock.new
    block.url = "https://www.youtube.com/?v=XXXXX"
    assert block.is_valid_source?
  end
  
  should "is_valid_source return true when the url contains www.youtube.com" do
    block = VideoBlock.new
    block.url = "www.youtube.com/?v=XXXXX"
    assert block.is_valid_source?
  end

  should "is_valid_source return true when the url contains youtube.com" do
    block = VideoBlock.new
    block.url = "youtube.com/?v=XXXXX"
    assert block.is_valid_source?
  end

  should "is_valid_source return false when the url not contains youtube video ID" do
    block = VideoBlock.new
    block.url = "youtube.com/"
    assert !block.is_valid_source?
  end

  should "is_valid_source return false when the url contains empty youtube video ID" do
    block = VideoBlock.new
    block.url = "youtube.com/?v="
    assert !block.is_valid_source?
  end

  should "is_valid_source return false when the url contains an invalid youtube link" do
    block = VideoBlock.new
    block.url = "http://www.yt.com/?v=XXXXX"
    assert !block.is_valid_source?
  end
   
  #### Tests for Vimeo Videos
  
  should "is_valid_source return true when the url contains http://vimeo.com" do
    block = VideoBlock.new
    block.url = "http://vimeo.com/98979"
    assert block.is_valid_source?
  end
  
  should "is_valid_source return true when the url contains https://vimeo.com" do
    block = VideoBlock.new
    block.url = "https://vimeo.com/989798"
    assert block.is_valid_source?
  end
  
  should "is_valid_source return true when the url contains https://www.vimeo.com" do
    block = VideoBlock.new
    block.url = "https://www.vimeo.com/98987"
    assert block.is_valid_source?
  end
  
  should "is_valid_source return true when the url contains www.vimeo.com" do
    block = VideoBlock.new
    block.url = "www.vimeo.com/989798"
    assert block.is_valid_source?
  end

  should "is_valid_source return true when the url contains vimeo.com" do
    block = VideoBlock.new
    block.url = "vimeo.com/09898"
    assert block.is_valid_source?
  end

  should "is_valid_source return false when the url not contains vimeo video ID" do
    block = VideoBlock.new
    block.url = "vimeo.com/home"
    assert !block.is_valid_source?
  end

  should "is_valid_source return false when the url contains empty vimeo video ID" do
    block = VideoBlock.new
    block.url = "vimeo.com/"
    assert !block.is_valid_source?
  end

  should "is_valid_source return false when the url contains an invalid vimeo link" do
    block = VideoBlock.new
    block.url = "http://www.vmsd.com/98979"
    assert !block.is_valid_source?
  end
end
