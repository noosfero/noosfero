Noosfero::Application.routes.draw do

  unless ( File.basename($0) == "rake" && ARGV.include?("db:schema:load") )
    mount Api::App => '/api'
  end
end
