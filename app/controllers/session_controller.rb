=begin License
  eXPlain Project Management Tool
  Copyright (C) 2005  John Wilger <johnwilger@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
=end LICENSE

class SessionController < ApplicationController
  layout nil

  # Displays the login form.
  def login
  end

  # Attempts to authenticate the user based on the 'username' and 'password'
  # request parameters. If successful, and the session contains a value for
  # 'return-to', the user will be redirected to that path. If the session does
  # not contain 'return-to', the user is redirected to the DashboardController.
  # If authentication is not successful, the user is directed back to the login
  # page, and an error message is displayed.
  def authenticate
    if @session[:current_user] = User.authenticate(@params['username'],
                                                   @params['password'])
      if @session[:return_to]
        redirect_to_path @session[:return_to]
        @session[:return_to] = nil
      else
        redirect_to :controller => 'dashboard', :action => 'index'
      end
    else
      flash[:error] = "You entered an invalid username and/or password."
      redirect_to :controller => 'session', :action => 'login'
    end
  end

  # Resets the user's session and redirects to the login page.
  def logout
    session[ :current_user ] = nil
    flash[:status] = "You have been logged out."
    redirect_to :controller => 'session', :action => 'login'
  end
end
