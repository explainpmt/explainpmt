module ApplicationHelper
  
  def admin_content(&block)
    yield if is_admin?
  end
  
  def collection_content(collection, &block)
    yield collection if collection and collection.size > 0
  end
  
  def empty_collection_content(collection, &block)
    yield if collection.size == 0
  end
  
  def link_to_new_story
    link_to_remote('Create Story Card', :url => new_project_story_path(@project), :method => :get)
  end
  
  def link_to_new_acceptancetest
    link_to_remote('New Acceptance Test', :url => new_project_acceptancetest_path(@project), :method => :get)
  end
  
  def link_to_story_with_sc(story)
    link_to("SC#{story.scid}", project_story_path(@project, story)) + '(' + truncate(story.title, 30) + ')'
  end
  
  def link_to_story(story)
    link_to(story.title, project_story_path(@project, story))
  end

  def link_to_edit_story(story, options={})
    link_to_remote(options[:value] || story.title, :url => edit_project_story_path(@project, story), :method => :get)
  end
  
  def link_to_iteration(iteration)
    link_to iteration.name, project_iteration_path(@project, iteration)
  end
  
  def milestones_calendar
    days_to_render = 14
    title_prefix = 'Upcoming Milestones:'
    @calendar_title = @project ? title_prefix : title_prefix.gsub(':', ' (all projects):')
    milestones = (@project ? @project.milestones : current_user.milestones).select { |m|
      m.date >= Date.today && m.date < Date.today + days_to_render
    }  
    
    @days = Array.new(days_to_render) {|index|
      current_day = Date.today + index
      {:date => current_day,
        :name => Date::DAYNAMES[current_day.wday],
        :milestones => milestones.select { |m| m.date == current_day }}
    }
    
    render :partial => 'milestones/milestones_calendar'
  end
  
  def link_to_show_milestone(milestone, options={})
    link_to_remote(options[:value] || milestone.name, :url => project_milestone_path(milestone.project, milestone), :method => :get)
  end
  
  def story_select_list_for(stories)
    options = ""
    stories.each do |i|
      options << "<option value='#{i.id}'>SC#{i.scid}  (#{truncate(i.title,30)})</option>"
    end
    options
  end
  
  def iteration_select_list_for(iterations)
    options = "<option vlaue='0'>Not Assigned</option>"
    iterations.unshift(iterations.current) if iterations.current
    iterations.delete_at(0)
    iterations.reverse_each do |i|
      options << "<option value='#{i.id}'>#{i.name}</option>"
    end  
    options
  end
  
  def link_to_edit_acceptancetest(acceptancetest, options={})
    link_to_remote(options[:value] || acceptancetest.name, :url => edit_project_acceptancetest_path(@project, acceptancetest), :method => :get)
  end
  
  def link_to_delete_acceptancetest(acceptancetest)
    link_to "Delete", project_acceptancetest_path(@project, acceptancetest), :method => :delete, :confirm => "Are you sure you want to delete?"
  end
  
  def link_to_clone_acceptancetest(acceptancetest)
    link_to_remote("Clone", :url => clone_acceptance_project_acceptancetest_path(@project, acceptancetest), :method => :get) unless acceptancetest.story_id.blank?
  end
  
  def link_to_acceptancetest(acceptancetest, options={})
    link_to_remote(options[:value] || acceptancetest.name, :url => project_acceptancetest_path(@project, acceptancetest), :method => :get)
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
  
  VERSION = 'dev trunk'
  
  def is_admin?
    current_user.admin
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
