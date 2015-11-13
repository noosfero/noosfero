module Noosfero
  module API
    module V1
      class Search < Grape::API

        resource :search do
          resource :article do
            get do
              # Security checks
              sanitize_params_hash(params)
              # APIHelpers
              asset = :articles
              context = environment

              profile = environment.profiles.find(params[:profile_id]) if params[:profile_id]
              scope = profile.nil? ? environment.articles.is_public : profile.articles.is_public
              scope = scope.where(:type => params[:type]) if params[:type] && !(params[:type] == 'Article')
              scope = scope.where(:parent_id => params[:parent_id]) if params[:parent_id].present?
              scope = scope.joins(:categories).where(:categories => {:id => params[:category_ids]}) if params[:category_ids].present?
              query = params[:query] || ""
              order = "more_recent"

              options = {:filter => order, :template_id => params[:template_id]}

              paginate_options = params.select{|k,v| [:page, :per_page].include?(k.to_sym)}.symbolize_keys
              paginate_options.each_pair{|k,v| v=v.to_i}
              paginate_options[:page]=1 if !paginate_options.keys.include?(:page)

              search_result = find_by_contents(asset, context, scope, query, paginate_options, options)

              articles = search_result[:results]

              result = present_articles(articles)

              result
            end
          end
        end

      end
    end
  end
end
