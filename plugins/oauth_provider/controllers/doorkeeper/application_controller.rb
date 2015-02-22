module Doorkeeper
  class ApplicationController < ApplicationController

    include Helpers::Controller
    helper 'doorkeeper/form_errors'

  end
end
