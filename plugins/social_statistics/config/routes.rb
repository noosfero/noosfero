Noosfero::Application.routes.draw do

  begin
    mount Blazer::Engine, at: "stats"
  rescue NameError
  end

end
