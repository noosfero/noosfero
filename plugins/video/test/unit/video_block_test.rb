require_relative '../test_helper'
class VideoBlockTest < ActiveSupport::TestCase

  ### Tests for YouTube

  should "is_youtube return true when the url contains http://youtube.com" do
    block = VideoBlock.new
    block.url = "http://youtube.com/?v=XXXXX"
    assert block.is_youtube?
  end

  should "is_youtube return true when the url contains https://youtube.com" do
    block = VideoBlock.new
    block.url = "https://youtube.com/?v=XXXXX"
    assert block.is_youtube?
  end

  should "is_youtube return true when the url contains https://www.youtube.com" do
    block = VideoBlock.new
    block.url = "https://www.youtube.com/?v=XXXXX"
    assert block.is_youtube?
  end

  should "is_youtube return true when the url contains www.youtube.com" do
    block = VideoBlock.new
    block.url = "www.youtube.com/?v=XXXXX"
    assert block.is_youtube?
  end

  should "is_youtube return true when the url contains youtube.com" do
    block = VideoBlock.new
    block.url = "youtube.com/?v=XXXXX"
    assert block.is_youtube?
  end

  should "is_youtube return false when the url not contains youtube video ID" do
    block = VideoBlock.new
    block.url = "youtube.com/"
    assert !block.is_youtube?
  end

  should "is_youtube return false when the url contains empty youtube video ID" do
    block = VideoBlock.new
    block.url = "youtube.com/?v="
    assert !block.is_youtube?
  end

  should "is_youtube return false when the url contains an invalid youtube link" do
    block = VideoBlock.new
    block.url = "http://www.yt.com/?v=XXXXX"
    assert !block.is_youtube?
  end

  should "format embed video for youtube videos" do
    block = VideoBlock.new
    block.url = "youtube.com/?v=XXXXX"
    assert_match /\/\/www.youtube-nocookie.com\/embed/, block.format_embed_video_url_for_youtube
  end

  should "format embed video return nil if is not a youtube url" do
    block = VideoBlock.new
    block.url = "http://www.yt.com/?v=XXXXX"
    assert_nil block.format_embed_video_url_for_youtube
  end

  should "extract youtube id from youtube video url's if it's a valid youtube full url" do
    block = VideoBlock.new
    id = 'oi43jre2d2'
    block.url = "youtube.com/?v=#{id}"
    assert_equal id, block.send('extract_youtube_id')
  end

  should "extract youtube id from youtube video url's if it has underline and hyphen" do
    block = VideoBlock.new
    id = 'oi43_re-d2'
    block.url = "youtube.com/?v=#{id}"
    assert_equal id, block.send('extract_youtube_id')
  end

  should "extract youtube id from youtube video url's if it's a valid youtube short url" do
    block = VideoBlock.new
    id = 'oi43jre2d2'
    block.url = "youtu.be/#{id}"
    assert_equal id, block.send('extract_youtube_id')
  end

  should "extract_youtube_id return nil if the url it's not a valid youtube url" do
    block = VideoBlock.new
    block.url = "http://www.yt.com/?v=XXXXX"
    assert_nil block.send('extract_youtube_id')
  end

  should "extract_youtube_id return nil if youtue url there is no id" do
    block = VideoBlock.new
    block.url = "youtube.com/"
    assert_nil block.send('extract_youtube_id')
  end

  #### Tests for Vimeo Videos

  should "is_vimeo return true when the url contains http://vimeo.com" do
    block = VideoBlock.new
    block.url = "http://vimeo.com/98979"
    assert block.is_vimeo?
  end

  should "is_vimeo return true when the url contains https://vimeo.com" do
    block = VideoBlock.new
    block.url = "https://vimeo.com/989798"
    assert block.is_vimeo?
  end

  should "is_vimeo return true when the url contains https://www.vimeo.com" do
    block = VideoBlock.new
    block.url = "https://www.vimeo.com/98987"
    assert block.is_vimeo?
  end

  should "is_vimeo return true when the url contains www.vimeo.com" do
    block = VideoBlock.new
    block.url = "www.vimeo.com/989798"
    assert block.is_vimeo?
  end

  should "is_vimeo return true when the url contains vimeo.com" do
    block = VideoBlock.new
    block.url = "vimeo.com/09898"
    assert block.is_vimeo?
  end

  should "is_vimeo return false when the url not contains vimeo video ID" do
    block = VideoBlock.new
    block.url = "vimeo.com/home"
    assert !block.is_vimeo?
  end

  should "is_vimeo return false when the url contains empty vimeo video ID" do
    block = VideoBlock.new
    block.url = "vimeo.com/"
    assert !block.is_vimeo?
  end

  should "is_vimeo return false when the url contains an invalid vimeo link" do
    block = VideoBlock.new
    block.url = "http://www.vmsd.com/98979"
    assert !block.is_vimeo?
  end

  should "format embed video for vimeo videos" do
    block = VideoBlock.new
    block.url = "vimeo.com/09898"
    assert_match /\/\/player.vimeo.com\/video\/[[:digit:]]+/, block.format_embed_video_url_for_vimeo
  end

  should "format embed video return nil if is not a vimeo url" do
    block = VideoBlock.new
    block.url = "http://www.yt.com/?v=XXXXX"
    assert_nil block.format_embed_video_url_for_vimeo
  end

  should "extract vimeo id from vimeo video url's if it's a valid vimeo url" do
    block = VideoBlock.new
    id = '23048239432'
    block.url = "vimeo.com/#{id}"
    assert_equal id, block.send('extract_vimeo_id')
  end

  should "extract_vimeo_id return nil if the url it's not a valid vimeo url" do
    block = VideoBlock.new
    block.url = "http://www.yt.com/XXXXX"
    assert_nil block.send('extract_vimeo_id')
  end

  should "extract_vimeo_id return nil if vimeo url there is no id" do
    block = VideoBlock.new
    block.url = "vimeo.com/"
    assert_nil block.send('extract_youtube_id')
  end

  # Other video formats
  should "is_video return true if url ends with mp4" do
    block = VideoBlock.new
    block.url = "http://www.vmsd.com/98979.mp4"
    assert block.is_video_file?
  end

  should "is_video return true if url ends with ogg" do
    block = VideoBlock.new
    block.url = "http://www.vmsd.com/98979.ogg"
    assert block.is_video_file?
  end

  should "is_video return true if url ends with ogv" do
    block = VideoBlock.new
    block.url = "http://www.vmsd.com/98979.ogv"
    assert block.is_video_file?
  end

  should "is_video return true if url ends with webm" do
    block = VideoBlock.new
    block.url = "http://www.vmsd.com/98979.webm"
    assert block.is_video_file?
  end

  should "is_video return false if url ends without mp4, ogg, ogv, webm" do
    block = VideoBlock.new
    block.url = "http://www.vmsd.com/98979.mp4r"
    assert !block.is_video_file?
    block.url = "http://www.vmsd.com/98979.oggr"
    assert !block.is_video_file?
    block.url = "http://www.vmsd.com/98979.ogvr"
    assert !block.is_video_file?
    block.url = "http://www.vmsd.com/98979.webmr"
    assert !block.is_video_file?
  end

  should 'display video block partial' do
    block = VideoBlock.new
    self.expects(:render).with(:file => 'video_block', :locals => {
        :block => block
    })
    instance_eval(& block.content)
  end

end
