module Api
  module V1
    class Scraps < Grape::API::Instance
      resource :profiles do
        post ":profile_id/scraps" do
          profile = environment.profiles.find_by id: params[:profile_id]
          return forbidden! unless profile.allow_post_scrap?(current_person)
          begin
            scrap = Scrap.new(params[:scrap])
            scrap.sender = current_person
	    scrap.receiver = profile
	    scrap.save
            present_partial scrap, with: Entities::Scrap
          rescue ActiveRecord::RecordInvalid
            render_model_errors!(scrap.errors)
          end
        end

        get ":profile_id/scraps/:id/replies" do
          profile = environment.profiles.visible.find_by id: params[:profile_id]
	  scrap = profile.scraps.find(params[:id])
	  present_partial scrap.replies.order(created_at: :desc), with: Entities::Scrap
        end
      end
    end
  end
end
