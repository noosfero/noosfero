module Noosfero
  module API
    module V1
      class Tasks < Grape::API
#        before { authenticate! }

#        ARTICLE_TYPES = Article.descendants.map{|a| a.to_s}

        resource :tasks do

          # Collect tasks
          #
          # Parameters:
          #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
          #   oldest           - Collect the oldest articles. If nothing is passed the newest articles are collected
          #   limit            - amount of articles returned. The default value is 20
          #
          # Example Request:
          #  GET host/api/v1/tasks?from=2013-04-04-14:41:43&until=2015-04-04-14:41:43&limit=10&private_token=e96fff37c2238fdab074d1dcea8e6317
          get do
            tasks = select_filtered_collection_of(environment, 'tasks', params)
            tasks = tasks.select {|t| current_person.has_permission?(t.permission, environment)}
            present tasks, :with => Entities::Task, :fields => params[:fields]
          end

          desc "Return the task id"
          get ':id' do
            task = find_task(environment, params[:id])
            present task, :with => Entities::Task, :fields => params[:fields]
          end
        end

        kinds = %w[community person enterprise]
        kinds.each do |kind|
          resource kind.pluralize.to_sym do
            segment "/:#{kind}_id" do
              resource :tasks do
                get do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present_tasks(profile)
                end

                get ':id' do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present_task(profile)
                end

                post do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  post_task(profile, params)
                end
              end
            end
          end
        end
      end
    end
  end
end
