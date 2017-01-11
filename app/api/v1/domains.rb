module Api
  module V1
    class Domains < Grape::API

      resource :domains do

        desc "Return all domains information"
        get '/' do
          present Domain.all, with: Entities::Domain, :current_person => current_person
        end

        get ':id' do
          local_domain = nil
          if (params[:id] == "context")
            local_domain = Domain.by_context(request.host)
          else
            local_domain = Domain.find(params[:id])
          end
          return not_found! unless local_domain.present?
          present_partial local_domain, with: Entities::Domain, :current_person => current_person
        end

      end

    end
  end
end
