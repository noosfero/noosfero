class AdminController < ApplicationController
  require_ssl
  before_filter :login_required
end
