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
            #FIXME check for permission
            tasks = select_filtered_collection_of(environment, 'tasks', params)
            present tasks, :with => Entities::Task, :fields => params[:fields]
          end

          desc "Return the task id"
          get ':id' do
            task = find_task(environment.tasks, params[:id])
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


        resource :communities do
          segment '/:community_id' do
            resource :tasks do
              get do
                #FIXME check for permission
                community = environment.communities.find(params[:community_id])
                tasks = select_filtered_collection_of(community, 'tasks', params)
                present tasks, :with => Entities::Task, :fields => params[:fields]
              end

              get ':id' do
                community = environment.communities.find(params[:community_id])
                task = find_task(community.tasks, params[:id])
                present task, :with => Entities::Task, :fields => params[:fields]
              end

              # Example Request:
              #  POST api/v1/communites/:community_id/articles?private_token=234298743290432&article[name]=title&article[body]=body
              post do
                community = environment.communities.find(params[:community_id])
#FIXME see the correct permission
                return forbidden! unless current_person.can_post_content?(community)
#FIXME check the task type before create
                klass_type= params[:content_type].nil? ? 'Task' : params[:content_type]
#                return forbidden! unless ARTICLE_TYPES.include?(klass_type)
#
                task = klass_type.constantize.new(params[:task])
                task.requestor = current_person
                task.target = community

                if !task.save
                  render_api_errors!(task.errors.full_messages)
                end
                present task, :with => Entities::Task, :fields => params[:fields]
              end

            end
          end

        end

#         resource :people do
#           segment '/:person_id' do
#             resource :tasks do
#               get do
# #                person = environment.people.find(params[:person_id])
# #                articles = select_filtered_collection_of(person, 'articles', params)
# #                articles = articles.display_filter(current_person, person)
# tasks = Task.all
#                 present tasks, :with => Entities::Task, :fields => params[:fields]
#               end

#               get ':id' do
# #                person = environment.people.find(params[:person_id])
# #                article = find_article(person.articles, params[:id])
# task = Task.first
#                 present task, :with => Entities::Task, :fields => params[:fields]
#               end

#               post do
# #                person = environment.people.find(params[:person_id])
# #                return forbidden! unless current_person.can_post_content?(person)
# #
# #                klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
# #                return forbidden! unless ARTICLE_TYPES.include?(klass_type)
# #
# #                article = klass_type.constantize.new(params[:article])
# #                article.last_changed_by = current_person
# #                article.created_by= current_person
# #                article.profile = person
# #
# #                if !article.save
# #                  render_api_errors!(article.errors.full_messages)
# #                end
# task = Task.first
#                 present task, :with => Entities::Task, :fields => params[:fields]
#               end

#             end
#           end

#         end

#         resource :enterprises do
#           segment '/:enterprise_id' do
#             resource :tasks do
#               get do
# #                enterprise = environment.enterprises.find(params[:enterprise_id])
# #                articles = select_filtered_collection_of(enterprise, 'articles', params)
# #                articles = articles.display_filter(current_person, enterprise)
# tasks = Task.all
#                 present tasks, :with => Entities::Task, :fields => params[:fields]
#               end

#               get ':id' do
# #                enterprise = environment.enterprises.find(params[:enterprise_id])
# #                article = find_article(enterprise.articles, params[:id])
# task = Task.first
#                 present task, :with => Entities::Task, :fields => params[:fields]
#               end

#               post do
# #                enterprise = environment.enterprises.find(params[:enterprise_id])
# #                return forbidden! unless current_person.can_post_content?(enterprise)
# #
# #                klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
# #                return forbidden! unless ARTICLE_TYPES.include?(klass_type)
# #
# #                article = klass_type.constantize.new(params[:article])
# #                article.last_changed_by = current_person
# #                article.created_by= current_person
# #                article.profile = enterprise
# #
# #                if !article.save
# #                  render_api_errors!(article.errors.full_messages)
# #                end
# task = Task.first
#                 present task, :with => Entities::Task, :fields => params[:fields]
#               end

#             end
#           end

#         end


      end
    end
  end
end
