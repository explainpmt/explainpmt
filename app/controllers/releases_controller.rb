class ReleasesController < ApplicationController
  include CrudActions
  
  before_filter :require_current_project
  popups :new, :create, :show, :edit, :update
  
  def mymodel
    Release
  end
  
end
