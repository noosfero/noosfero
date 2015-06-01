module Noosfero
  module API
    class RequestLogger < GrapeLogging::Middleware::RequestLogger

      protected

      def parameters(response, duration)
        {
          path: request.path,
          params: request.params.to_hash.except('password'),
          method: request.request_method,
        }
      end
    end
  end
end
