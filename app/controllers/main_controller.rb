class MainController < ApplicationController
  before_filter :check_authentication
  def dashboard
  end
end
