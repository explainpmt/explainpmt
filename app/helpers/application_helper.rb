module ApplicationHelper
  VERSION = 'dev trunk'
  
  def is_admin?
    current_user.admin
  end

  def other_projects
    can_access = current_user.projects
    can_access.select { |p| p != @project }
  end

  def page_title
    @project ? "#{@project.name} &raquo; #{@page_title}" : @page_title
  end

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
          xml << main_menu_link('Team', :controller => 'users',
                                :action => 'index',
                                :project_id => @project.id)
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
    "#{Date::DAYNAMES[date.wday]} #{Date::MONTHNAMES[date.mon]} #{date.day}, " +
    "#{date.year}"
  end

  def short_date(date)
    "#{Date::ABBR_DAYNAMES[date.wday]} #{Date::ABBR_MONTHNAMES[date.mon]} " +
    "#{date.day}, '#{date.year.to_s.slice(-2,2)}"
  end

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
