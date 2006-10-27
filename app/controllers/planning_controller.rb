# All actions on this controller require the user to have administrative
# privileges.
class PlanningController < ApplicationController
  before_filter :require_current_project

  def index
    @stories = @project.backlog
  end
  
end
