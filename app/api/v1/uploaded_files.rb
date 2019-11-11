module Api
  module V1
    class UploadedFiles < Grape::API::Instance
      resource :profiles do
        segment "/:id" do
          resource :uploaded_files do
            post do
              authenticate!
              profile = environment.profiles.visible.find(params[:id])

              return forbidden! unless current_person.can_post_content?(profile)

              data = {
                uploaded_data: params[:file],
                profile: profile,
                author: current_person,
              }

              article = UploadedFile.new(data)
              begin
		article.save!
                present_partial article, with: Entities::Article
              rescue ActiveRecord::RecordInvalid
                render_model_errors!(article.errors)
              end
            end
          end
        end
      end
    end
  end
end
