class ApplicationController < ActionController::Base
  stale_when_importmap_changes

  before_action :authenticate_user!
end
