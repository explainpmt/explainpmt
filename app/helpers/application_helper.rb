##############################################################################
# eXPlain Project Management Tool
# Copyright (C) 2005  John Wilger <johnwilger@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################


# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  VERSION = 'dev trunk'
  
  # Used to determine if the currently logged in user has administrative
  # privileges
  def is_admin?
    session[:current_user].admin?
  end

  # Returns an array of projects other than the currently active project which
  # the curren tuser has access to
  def other_projects
    can_access = User.find(session[:current_user].id).projects
    can_access.select { |p| p != @project }
  end

  # Returns the title to use for the page's html title tag.
  def page_title
    if @project
      "#{@project.name} &raquo; #{@page_title}"
    else
      @page_title
    end
  end

  # Returns the text of the top menu markup (HTML).
  def top_menu
    xml = Builder::XmlMarkup.new
    xml.ul(:id => 'MainMenu') do
      xml.li do
        if @project
          xml << main_menu_link('Dashboard', :controller => 'dashboard',
                                :action => 'index',
                                :project_id => @project.id)
        else
          xml << main_menu_link('Overview', :controller => 'dashboard',
                                :action => 'index')
        end
      end
      if is_admin?
        xml.li(:class => 'right') do
          xml << main_menu_link('Users', :controller => 'users',
                                :action => 'index') {
            @project.nil? and controller.controller_name == 'users'
          }
        end
      end
        xml.li(:class => 'right') do
          xml << main_menu_link('Projects', :controller => 'projects',
                                :action => 'index')
        end
    end
  end

  # Returns the text of the main menu markup (HTML).
  def main_menu
    xml = Builder::XmlMarkup.new
    xml.ul(:id => 'MainMenu') do
      if @project
        xml.li do
          xml << main_menu_link('Dashboard', :controller => 'dashboard',
                                :action => 'index',
                                :project_id => @project.id)
        end
        xml.li do
          xml << main_menu_link('Iterations', :controller => 'iterations',
                                :action => 'index',
                                :project_id => @project.id)
        end
        xml.li do
          xml << main_menu_link('Backlog', :controller => 'stories',
                                :action => 'index',
                                :project_id => @project.id)
        end
        xml.li do
          xml << main_menu_link('Initiatives', :controller => 'initiatives',
                                :action => 'index',
                                :project_id => @project.id)
        end
        xml.li do
          xml << main_menu_link('Acceptance Tests', :controller => 'acceptancetests',
                                :action => 'index',
                                :project_id => @project.id)
        end
        xml.li do
          xml << main_menu_link('Milestones', :controller => 'milestones',
                                :action => 'index',
                                :project_id => @project.id)
        end
        xml.li do
          xml << main_menu_link('Team', :controller => 'users',
                                :action => 'index',
                                :project_id => @project.id)
        end
      end
    end
  end

  # Returns a link tag with the specified +title+ for use in the site's main
  # menu. +options+ is a hash of the same format as the +options+ hash passed to
  # the ActionView::Helpers::UrlHelper#url_for method. If a block is given, and
  # the block returns an non-false value, the 'current' CSS class will be set on
  # the link. If no block is given, but the controller being linked to is the
  # same as the current controller or the controller set in @selected_main_menu_link, 
  # the CSS class will also be set to current.
  # Otherwise, no CSS class is set.
  def main_menu_link(title, options)
    selected_controller = @selected_main_menu_link ?
                          @selected_main_menu_link : controller.controller_name
    if (block_given? and yield) or
      (!block_given? and selected_controller.to_s == options[:controller].to_s)
      
      html_options = { 'class' => 'current' }
    else
      html_options = {}
    end
    link_to(title,options,html_options)
  end

  # Returns a link tag with the specified +title+ that will invoke a popup
  # window with the supplied +window_title+ and using the javascript window
  # options passed in +window_options+. +options+ is a hash identical to that
  # used by ActionView::Helpers::UrlHelper#url_for. i.e.:
  #   popup_link('Click Me', 'click_me', 'width=400,height=400,scrollbars',
  #              :controller => 'foo', :action => 'index')
  # would produce something like:
  #   <a href="/foo/index" onclick="window.open('/foo/index','click_me',
  #     'width=400,height=400,scrollbars');return false;">Click Me</a>
  def popup_link(title,window_title,window_options,options)
    xml = Builder::XmlMarkup.new
    link = url_for(options)
    xml.a(title, :href => link,
          :onclick => "window.open('#{link}','#{window_title}'," +
                      "'#{window_options}');return false;")
  end

  # Displays a textual representation of +date+ in the long format (i.e.:
  # "Tuesday March 22, 2005")
  def long_date(date)
    "#{Date::DAYNAMES[date.wday]} #{Date::MONTHNAMES[date.mon]} #{date.day}, " +
    "#{date.year}"
  end

  # Displays a textual representation of +date+ in the abbreviated format (i.e.:
  # "Tue Mar 22, 05")
  def short_date(date)
    "#{Date::ABBR_DAYNAMES[date.wday]} #{Date::ABBR_MONTHNAMES[date.mon]} " +
    "#{date.day}, '#{date.year.to_s.slice(-2,2)}"
  end

  # Displays the numeric representation of +date+ (i.e.: "3/22/2005")
  def numeric_date(date)
    "#{date.mon}/#{date.day}/#{date.year}"
  end
  
  def collection_select_with_current(object, method, collection, value_method, text_method, current_value)
  result = "<select name='#{object}[#{method}]'>\n" 
  if current_value == nil 
    result << "<option value=''selected='selected'></option>"
  else
    result << "<option value=''></option>"
  end
  for element in collection
    if current_value == element.send(value_method)
      result << "<option value='#{element.send(value_method)}' selected='selected'>#{element.send(text_method)}</option>\n" 
    else
      result << "<option value='#{element.send(value_method)}'>#{element.send(text_method)}</option>\n" 
    end
  end
  result << "</select>\n" 
  return result
end
  
end
