Noosfero::Application.routes.draw do

  unless Noosfero.compiling_assets? || Noosfero.loading_schema?
    mount Api::App => '/api'
  end
end
