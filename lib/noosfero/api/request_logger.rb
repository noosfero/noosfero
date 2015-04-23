module Noosfero
  module API
    class RequestLogger < GrapeLogging::Middleware::RequestLogger

      protected

      def parameters(response, duration)
        {
          path: request.path,
          params: request.params.except('password'),
          method: request.request_method,
          total: (duration * 1000).round(2),
          db: request.env[:db_duration].round(2),
        }
      end
    end
  end
end
