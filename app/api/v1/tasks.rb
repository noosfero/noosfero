module Api
  module V1
    class Tasks < Grape::API
      before { authenticate! }

      MAX_PER_PAGE = 50

      resource :tasks do

        paginate max_per_page: MAX_PER_PAGE
        # Collect all tasks that current person has permission
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest articles. If nothing is passed the newest articles are collected
        #   limit            - amount of articles returned. The default value is 20
        #
        # Example Request:
        #  GET host/api/v1/tasks?from=2013-04-04-14:41:43&until=2015-04-04-14:41:43&limit=10&private_token=e96fff37c2238fdab074d1dcea8e6317
        get do
          tasks = Task.to(current_person)
          present_tasks_for_asset(current_person, tasks)
        end

        desc "Return the task id"
        get ':id' do
          task = find_task(current_person, Task.to(current_person), params[:id])
          present_partial task, :with => Entities::Task
        end

        %w[finish cancel].each do |action|
          desc "#{action.capitalize} a task"
          put ":id/#{action}" do
            task = find_task(current_person, Task.to(current_person), params[:id])
            begin
              task.update(params[:task])
              task.send(action, current_person) if (task.status == Task::Status::ACTIVE)
              present_partial task, :with => Entities::Task
            rescue Exception => ex
              render_api_error!(ex.message, 500)
            end
          end
        end
      end

      kinds = %w[community person enterprise]
      kinds.each do |kind|
        resource kind.pluralize.to_sym do
          segment "/:#{kind}_id" do
            resource :tasks do
              get do
                profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                tasks = find_tasks(profile, Task.to(current_person))
                present_partial tasks, :with => Entities::Task
              end

              get ':id' do
                profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                task = find_task(profile, :tasks, params[:id])
                present_partial task, :with => Entities::Task
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
