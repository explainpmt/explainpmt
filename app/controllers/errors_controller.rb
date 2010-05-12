class ErrorsController < ApplicationController
  skip_before_filter :check_authentication
  skip_before_filter :set_selected_project
  skip_before_filter :require_current_project
  skip_before_filter :require_team_membership
end
