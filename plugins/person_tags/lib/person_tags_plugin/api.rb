class PersonTagsPlugin::API < Grape::API
  resource :people do
    get ':id/tags' do
      person = environment.people.visible.find_by(id: params[:id])
      return not_found! if person.blank?
      present person.interest_list
    end
  end
end
