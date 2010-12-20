class AuditsController < ApplicationController
  
  def index
    @audits = Audit.scoped
  end
  
end