class WelcomeController < ApplicationController
  def index
    flash[:notice] = "Welcome to EnrollBU"
  end
end
