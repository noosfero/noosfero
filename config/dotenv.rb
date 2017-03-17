begin
  require 'dotenv'

  # Load custom variables for the deploy
  Dotenv.load '.env.custom'

  # Load environment specific .env files
  Dotenv.load ".env.#{ENV['RAILS_ENV']}"

  # The regular .env is required and overwrites everything that is not already set
  Dotenv.load! '.env'

rescue LoadError
  # put dotenv on config/Gemfile to use it
end
