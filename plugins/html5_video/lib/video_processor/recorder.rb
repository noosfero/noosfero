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
      `DISABLE_SPRING=1 rails runner -e #{RAILS_ENV} "\
       env = Environment.find(#{env_id}); \
       file = env.articles.find(#{video_id}); \
       video = FilePresenter.for(file); \
       video.web_versions = #{videos.to_s.gsub('"', "'")}; \
       video.original_video = #{info.to_s.gsub('"', "'")}.except :output; \
       video.save"`
    end

    def register_previews(env_id, previews, video_id)
      previews = previews.is_a?(Symbol) ? ":#{previews}" : previews
      save_hash(env_id, video_id, :previews, previews)
    end

    def register_results(env_id, responses, video_id)
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

       save_hash(env_id, video_id, :web_versions, videos)
    end

    def register_errors(env_id, video_id, error)
      videos = { OGV: { tiny: {}, nice: {} }, WEBM: { tiny: {}, nice: {} } }
      [:OGV, :WEBM].product([:nice, :tiny]).each do |format, size|
        videos[format][size][:status] = 'error'
        videos[format][size][:error] = error
      end

      `DISABLE_SPRING=1 rails runner -e #{RAILS_ENV} "\
       env = Environment.find(#{env_id}); \
       file = env.articles.find(#{video_id}); \
       video = FilePresenter.for(file); \
       video.web_versions = #{videos.to_s.gsub('"', "'")}; \
       video.previews = :fail; \
       video.save"`
    end

    private

    def save_hash(env_id, video_id, attr, hash)
      `DISABLE_SPRING=1 rails runner -e #{RAILS_ENV} "\
       env = Environment.find(#{env_id}); \
       file = env.articles.find(#{video_id}); \
       video = FilePresenter.for(file); \
       video.#{attr} = #{hash.to_s.gsub('"', "'")}; \
       video.save"`
    end
  end
end
