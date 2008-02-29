module ApplicationHelper
  include AcceptancetestsHelper
  include DashboardsHelper
  include InitiativesHelper
  include IterationsHelper
  include MilestonesHelper
  include ProjectsHelper
  include ReleasesHelper
  include StoriesHelper
  include TasksHelper
  include UsersHelper

  def admin_content(&block)
    yield if is_admin?
  end

  def collection_content(collection, &block)
    yield collection if collection and collection.size > 0
  end

  def empty_collection_content(collection, &block)
    yield if collection.size == 0
  end

  def column_content_for(cols, column, &block)
    yield unless cols.include?(column)
  end

  def owner_select_list
    options = "<option value=''></option>"
    @project.users.each do |u|
      options << "<option value='#{u.id}'>#{u.full_name}</option"
    end
    options
  end
  
  def error_container(error)
    "<div id='SystemError'>#{error}</div>"
  end

  VERSION = 'dev trunk'

  def is_admin?
    current_user && current_user.admin
  end

  def other_projects
    current_user.projects.select { |p| p != @project }
  end

  def page_title
    @project ? "#{@project.name} &raquo; #{@page_title}" : @page_title
  end

  def top_menu
    xml = Builder::XmlMarkup.new
    xml.ul(:id => 'MainMenu') do
      xml.li do
        if @project
          xml << main_menu_link('Dashboard', project_dashboard_path(@project))
        else
          xml << main_menu_link('Overview', dashboards_path)
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

  def main_menu
    xml = Builder::XmlMarkup.new
    xml.ul(:id => 'MainMenu') do
      if @project
        xml.li do
          xml << main_menu_link('Dashboard', project_dashboard_path(@project))
        end
        xml.li do
          xml << main_menu_link('Releases', :controller => 'releases',
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
          xml << main_menu_link('Team', team_project_path(@project))
        end
        xml.li do
          xml << main_menu_link('Stats', :controller => 'stats',
            :action => 'index',
            :project_id => @project.id)
        end
      end
    end
  end

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

  def popup_link(title,window_title,window_options,options)
    xml = Builder::XmlMarkup.new
    link = url_for(options)
    xml.a(title, :href => link,
      :onclick => "window.open('#{link}','#{window_title}'," +
        "'#{window_options}');return false;")
  end

  def long_date(date)
    date.strftime('%A %B %d %Y')
  end

  def short_date(date)
    date.strftime('%a %b %d, %y')
  end

  def numeric_date(date)
    date.strftime('%m/%d/%Y')
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
