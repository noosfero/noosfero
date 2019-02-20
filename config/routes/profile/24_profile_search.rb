Noosfero::Application.routes.draw do
  scope :profile do
    scope ':profile', profile: /[^\/]+/ do
      match 'search', to: 'profile_search#index', via: [:get, :post], as: :profile_search
    end
  end
end
