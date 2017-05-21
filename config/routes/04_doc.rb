Noosfero::Application.routes.draw do

  # online documentation
  match 'doc', to: 'doc#index', as: :doc, via: :all
  match 'doc/:section', to: 'doc#section', as: :doc_section, via: :all
  match 'doc/:section/:topic', to: 'doc#topic', as: :doc_topic, via: :all

end
