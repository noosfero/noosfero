Noosfero::Application.routes.draw do
  scope :myprofile do
    scope ':profile', profile: /[^\/]+/ do
      resources :mailconf, only: [:index] do
        collection do
	  match 'check_mail_enabled', to: 'mailconf#check_mail_enabled', via: [:get, :post]
	  match 'enable', to: 'mailconf#enable', via: [:get, :post]
	  match 'disable', to: 'mailconf#disable', via: [:get, :post]
        end
    
      end
    end
  end

end
