require 'RMagick'

# Works for ffmpeg version 2.8.6-1~bpo8 shiped by Debian Jessie Backports
# https://packages.debian.org/jessie-backports/ffmpeg
# Add this line to your /etc/apt/sources.list:
# deb http://http.debian.net/debian jessie-backports main
# then: aptitude install ffmpeg
class VideoProcessor::Ffmpeg

  def _(str)
    str
  end

  def run(*parameters)
    parameters = parameters.flatten
    cmd = ['ffmpeg'] + parameters.map do |p|
      p.kind_of?(Symbol) ? '-'+p.to_s : p.to_s
    end
    io = IO.popen({'LANG'=>'C.UTF-8'}, cmd, err: [:child, :out])
    output = io.read
    io.close
    response = {
      error: { :code => 0, :message => '' },
      parameters: parameters,
      output: output
    }
    if $?.exitstatus != 0 then
      if $?.exitstatus == 127 then
        throw 'There is no FFmpeg installed!'
      end
      response[:error][:code] = -1
      response[:error][:message] = _('Unknow error')
      if match = /\n\s*([^\n]*): No such file or directory\s*\n/i.match(output)
        response[:error][:code] = 1
        response[:error][:message] = _('No such file or directory "%s".') % match[1]
      elsif output =~ /At least one output file must be specified/i
        response[:error][:code] = 2
        response[:error][:message] = _('No output defined.')
      elsif match = /\n\s*Unknown encoder[\s']+([^\s']+)/i.match(output)
        response[:error][:code] = 3
        response[:error][:message] = _('Unknown encoder "%s".') % match[1]
      elsif output =~ /\n\s*Error while opening encoder for output/i
        response[:error][:code] = 4
        response[:error][:message] = _('Error while opening encoder for output - maybe incorrect parameters such as bit rate, frame rate, width or height.')
      elsif match = /\n\s*Could not open '([^\s']+)/i.match(output)
        response[:error][:code] = 5
        response[:error][:message] = _('Could not open "%s".') % match[1]
      elsif match = /\n\s*Unsupported codec (.*) for (.*) stream (.*)/i.match(output)
        response[:error][:code] = 6
        response[:error][:message] = _('Unsupported codec %{codec} for %{act} stream %{id}.') %
                                      { :codec=>match[1], :act=>match[2], :id=>match[3] }
      elsif output =~ /Unable to find a suitable output format/i
        response[:error][:code] = 7
        response[:error][:message] = _('Unable to find a suitable output format for %{file}.') %
                                      { :file=>parameters[-1] }
      elsif output =~ /Invalid data found when processing input/i
        response[:error][:code] = 8
        response[:error][:message] = _('Invalid data found when processing input.')
      end
    end
    return response
  end

  def register_information
    response = self.run(:formats)[:output]
    @@version = /^\s*FFmpeg version ([0-9.]+)/i.match(response)[1]
    @@formats = {}
    response.split('--')[-1].strip.split("\n").each do |line|
      if pieces = / (.)(.) ([^\s]+)\s+([^\s].*)/.match(line)
        @@formats[pieces[3].to_sym] = {
          demux: ( pieces[1] == 'D' ),
          mux:   ( pieces[2] == 'E' ),
          description: pieces[4].strip
        }
      end
    end
    response = self.run(:codecs)[:output]
    @@codecs = {}
    response.split('--')[-1].strip.split("\n").each do |line|
      if pieces = / (.)(.)(.)(.)(.)(.) ([^\s]+)\s+([^\s].*)/.match(line)
        @@codecs[pieces[7].to_sym] = {
          decode:           ( pieces[1] == 'D' ),
          encode:           ( pieces[2] == 'E' ),
          draw_horiz_band:  ( pieces[4] == 'S' ),
          direct_rendering: ( pieces[5] == 'D' ),
          wf_trunc:         ( pieces[6] == 'T' ),
          type: (
            if    pieces[3] == 'V'; :video
            elsif pieces[3] == 'A'; :audio
            elsif pieces[3] == 'S'; :subtitle
            else :unknown; end
          ),
          description:      pieces[8].strip
        }
      end
    end
    {
      version: @@version,
      formats: @@formats,
      codecs:  @@codecs
    }
  end

  def timestr_to_secs str
    return nil if ! /^[0-9]{2}:[0-9]{2}:[0-9]{2}$/.match str
    t = str.split(':').map(&:to_i)
    t[0]*60*60 + t[1]*60 + t[2]
  end

  def get_stream_info(stream_str)
    stream_info = { :type => 'undefined' }
    stream_info[:type] = 'video' if / Video:/.match(stream_str)
    stream_info[:type] = 'audio' if / Audio:/.match(stream_str)
    {
      id:        [ /^\s*Stream ([^:(]+)/             ],
      codec:     [ / (?:Audio|Video):\s*([^,\s]+)/x  ],
      bitrate:   [ / ([0-9]+) kb\/s\b/      , :to_i  ],
      frequency: [ / ([0-9]+) Hz\b/         , :to_i  ],
      channels:  [ / ([0-9]+) channels\b/   , :to_i  ],
      framerate: [ / ([0-9.]+) (fps|tbr)\b/ , :to_f  ],
      size:      [ / ([0-9]+x[0-9]+)[, ]/            ],
    }.each do |att, params|
      re = params[0]
      method = params[1] || :strip
      if match = re.match(stream_str) then
        stream_info[att] = match[1].send(method)
      end
    end
    if stream_info[:size]
      size_array = stream_info[:size].split('x').map{|s| s.to_i}
      stream_info[:size] = { :w=>size_array[0], :h=>size_array[1] }
    end
    stream_info
  end

  def webdir_for_original_video(video)
    webdir = File.dirname(video) +'/web'
    Dir.mkdir(webdir) if ! File.exist?(webdir)
    webdir
  end

  def valid_abrate_for_web(info)
    return 0 if info.audio_stream.empty?
    if brate = info.audio_stream[0][:bitrate]
      brate = 8 if brate < 8
      (brate>128)? 128 : brate
    else
      48
    end
  end

  def valid_vbrate_for_web(info)
    if brate = info.video_stream[0][:bitrate] || info[:global_bitrate]
      brate = 128 if brate < 128
      (brate>1024)? 1024 : brate
    else
      400
    end
  end

  def valid_size_for_web(info)
    orig_size = info.video_stream[0][:size]
    if info.video_stream[0][:size][:w] > 640
      h = 640.0 / (orig_size[:w].to_f/orig_size[:h].to_f)
      { :w=>640, :h=>h.to_i }
    else
      { :w=>orig_size[:w].to_i, :h=>orig_size[:h].to_i }
    end
  end

  def validate_conversion_conf_for_web(conf, file_type)
    conf = conf.clone
    if conf[:abrate].nil? || conf[:vbrate].nil? || conf[:size].nil?
      info = get_video_info(conf[:in])
      if info[:error][:code] == 0
        conf[:abrate] ||= valid_abrate_for_web info
        conf[:vbrate] ||= valid_vbrate_for_web info
        conf[:size] ||= valid_size_for_web info
      end
    end
    result_dir = webdir_for_original_video conf[:in]
    size_str = "#{conf[:size][:w]}x#{conf[:size][:h]}"
    unless conf[:file_name]
      conf[:file_name] = "#{size_str}_#{conf[:vbrate]}.#{file_type}"
    end
    conf[:out] = result_dir+'/'+conf[:file_name]
    conf
  end

  public

  def get_video_info(file)
    response = self.run :i, file
    if response[:error][:code] == 2
      # No output is not an error on this context
      response[:error][:code] = 0
      response[:error][:message] = _('Success.')
    end
    response[:metadata] = {}
    {
      author:  /\n\s*author[\t ]*:([^\n]*)\n/i,
      title:   /\n\s*title[\t ]*:([^\n]*)\n/i,
      comment: /\n\s*comment[\t ]*:([^\n]*)\n/i
    }.each do |att, re|
      if match = re.match(response[:output]) then
        response[:metadata][att] = match[1].strip
      end
    end
    {
      type:           /\nInput #0, ([a-z0-9]+), from/,
      duration:       /\n\s*Duration:[\t ]*([0-9:]+)[^\n]* bitrate:/,
      global_bitrate: /\n\s*Duration:[^\n]* bitrate:[\t ]*([0-9]+)/
    }.each do |att, re|
      if match = re.match(response[:output]) then
        response[att] = match[1].strip
      end
    end
    response[:duration] = timestr_to_secs response[:duration]
    response[:global_bitrate] = response[:global_bitrate].to_i
    response[:streams] = []
    response[:output].split("\n").grep(/^\s*Stream /).each do |stream|
      response[:streams] << get_stream_info(stream)
    end
    def response.video_stream
      self[:streams].select {|s| s[:type] == 'video' }
    end
    def response.audio_stream
      self[:streams].select {|s| s[:type] == 'audio' }
    end
    return response
  end

  def convert2ogv(conf)
    conf[:type] = :OGV
    conf[:vbrate] ||= 600
    parameters = [ :i, conf[:in], :y, :'b:v', "#{conf[:vbrate]}k",
                   :f, 'ogg', :acodec, 'libvorbis', :vcodec, 'libtheora'
                 ]
    parameters << :s << "#{conf[:size][:w]}x#{conf[:size][:h]}" if conf[:size]
    parameters << :'b:a' << "#{conf[:abrate]}k" if conf[:abrate]
    # Vorbis dá pau com -ar 8000Hz ???
    parameters << :r << conf[:fps]           if conf[:fps]
    parameters << conf[:out]
    response = self.run parameters
    response[:conf] = conf
    response
  end

  def convert2mp4(conf)
    conf[:type] = :MP4
    conf[:vbrate] ||= 600
    parameters = [ :i, conf[:in], :y, :'b:v', "#{conf[:vbrate]}k",
                   :preset, 'slow', :f, 'mp4', :acodec, 'aac', :vcodec, 'libx264',
                   :strict, '-2'
                 ]
    parameters << :s << "#{conf[:size][:w]}x#{conf[:size][:h]}" if conf[:size]
    parameters << :'b:a' << "#{conf[:abrate]}k" if conf[:abrate]
    parameters << :r << conf[:fps]           if conf[:fps]
    parameters << conf[:out]
    response = self.run parameters
    response[:conf] = conf
    response
  end

  def convert2webm(conf)
    conf[:type] = :WEBM
    conf[:vbrate] ||= 600
    parameters = [ :i, conf[:in], :y, :'b:v', "#{conf[:vbrate]}k",
                   :f, 'webm', :acodec, 'libvorbis', :vcodec, 'libvpx'
                 ]
    parameters << :s << "#{conf[:size][:w]}x#{conf[:size][:h]}" if conf[:size]
    parameters << :'b:a' << "#{conf[:abrate]}k" if conf[:abrate]
    parameters << :r << conf[:fps]           if conf[:fps]
    parameters << conf[:out]
    response = self.run parameters
    response[:conf] = conf
    response
  end

  def make_ogv_for_web(conf)
    conf = validate_conversion_conf_for_web conf, :ogv
    convert2ogv(conf)
  end

  def make_mp4_for_web(conf)
    conf = validate_conversion_conf_for_web conf, :mp4
    convert2mp4(conf)
  end

  def make_webm_for_web(conf)
    conf = validate_conversion_conf_for_web conf, :webm
    convert2webm(conf)
  end

  # video_thumbnail creates 2 preview images on the sub directory web
  # from the video file parent dir. This preview images are six concatenated
  # frames in one image each. The frames have fixed dimension. The bigger
  # preview has frames with in 160x120, and smaller has frames whit in 107x80.
  # Use this helper only on the original movie to have only one "web" sub-dir.
  def video_thumbnail(video)
    result_dir = webdir_for_original_video video
    info  = get_video_info(video)
    if info[:duration] < 15
      pos = 1
      duration = info[:duration] - 2
      frate = ( 7.0 / duration ).ceil
    else
      pos = ( info[:duration] / 2.5 ).ceil
      duration = 7
      frate = 1
    end
    response = self.run :i, video, :ss, pos, :t, duration, :r, frate,
                        :s, '320x240', result_dir+'/f%d.png'
    img_names = [ '/preview_160x120.jpg', '/preview_107x80.jpg' ]
    if response[:error][:code] == 0
      imgs = (2..7).map { |num|
        img = result_dir+"/f#{num}.png"
        File.exists?(img) ? img : nil
      }.compact
      if imgs.size != 6
        Rails.logger.error "Problem to create thumbs for video #{video} ???"
      end
      imgs = Magick::ImageList.new *imgs
      imgs.montage{
        self.geometry='160x120+0+0'
        self.tile="1x#{imgs.size}"
        self.frame = "0x0+0+0"
      }.write result_dir+img_names[0]
      imgs.montage{
        self.geometry='107x80+0+0'
        self.tile="1x#{imgs.size}"
        self.frame = "0x0+0+0"
      }.write result_dir+img_names[1]
    end

    f_num = 1
    while File.exists? result_dir+"/f#{f_num}.png" do
      File.delete result_dir+"/f#{f_num}.png"
      f_num += 1
    end

    if response[:error][:code] == 0
      return { big: '/web'+img_names[0], thumb: '/web'+img_names[1] }
    else
      return response
    end
  end

  def version
    @@version ||= register_information[:version]
  end

  def formats
    @@formats ||= register_information[:formats]
  end

  def codecs
    @@codecs ||= register_information[:codecs]
  end

end
