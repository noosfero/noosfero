module VideoProcessor
  module Recorder

    RAILS_ENV = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'

    def register_conversion_start(env_id, video_info, video_id)
      videos = { OGV: { tiny: {}, nice: {} }, WEBM: { tiny: {}, nice: {} } }
      [:OGV, :WEBM].product([:nice, :tiny]).each do |format, size|
        videos[format][size][:status] = 'started'
      end

      info = video_info.clone
      info.delete :output
      `rails runner -e #{RAILS_ENV} "env = Environment.find(#{env_id}); \
       file = env.articles.find(#{video_id}); \
       video = FilePresenter.for(file); \
       video.web_versions = #{videos.to_s.gsub('"', "'")}; \
       video.original_video = #{info.to_s.gsub('"', "'")}.except :output; \
       video.save"`
    end

    def register_results(env_id, previews, responses, video_id)
      videos = { OGV: { tiny: {}, nice: {} }, WEBM: { tiny: {}, nice: {} } }
      responses.each do |format, sizes|
        sizes.each do |size, result|
          next if result.nil?
          conf = responses[format][size][:conf]

          if result[:error][:code] == 0
            conf[:path] = conf[:out].sub /^.*(\/articles)/, '\1'
            conf.delete :in
            conf.delete :out
            videos[format][size].merge! conf
            videos[format][size][:status] = 'done'
          else
            videos[format][size].merge! conf
            videos[format][size][:status] = 'error converting'
            videos[format][size][:error] = result[:error]
          end
        end
      end

      `rails runner -e #{RAILS_ENV} "env = Environment.find(#{env_id}); \
       file = env.articles.find(#{video_id}); \
       video = FilePresenter.for(file); \
       video.web_versions = #{videos.to_s.gsub('"', "'")}; \
       video.previews = #{previews.to_s.gsub('"', "'")}; \
       video.save"`
    end

    def register_errors(env_id, video_id, error)
      videos = { OGV: { tiny: {}, nice: {} }, WEBM: { tiny: {}, nice: {} } }
      [:OGV, :WEBM].product([:nice, :tiny]).each do |format, size|
        videos[format][size][:status] = 'error reading'
        videos[format][size][:error] = error
      end

      `rails runner -e #{RAILS_ENV} "env = Environment.find(#{env_id}); \
       file = env.articles.find(#{video_id}); \
       video = FilePresenter.for(file); \
       video.web_versions = #{videos.to_s.gsub('"', "'")}; \
       video.previews = :fail; \
       video.save"`
    end

  end
end
