Noosfero::Application.routes.draw do
  scope '/national_regions' do
    get :cities, controller: :national_regions
    get :states, controller: :national_regions
  end
end
