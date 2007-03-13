class InitiativesController < ApplicationController
  include CrudActions
  
  before_filter :require_current_project
  popups :new, :create, :edit, :update, :show
    
  def mymodel
    Initiative
  end
end
