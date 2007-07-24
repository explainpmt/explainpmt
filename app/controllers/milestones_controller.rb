class MilestonesController < ApplicationController
  include CrudActions
  
  before_filter :require_current_project, :except => [:milestones_calendar]
  popups :new, :create, :show, :edit, :update
  
  def mymodel
    Milestone
  end
  
  def index
    @page_title = "Milestones"
    @future = @project.milestones.future
    @recent = @project.milestones.recent
  end

  def show_all
    render :update do |page|
      page.replace_html 'recent', :partial => 'list', :locals => {:milestones => @project.milestones.past, :table_id => 'past_milestones'}
      page.replace_html 'recent_title', "All Milesones <small>(#{link_to_remote 'show recent', :url => {:action => 'show_recent', :controller => 'milestones', :project_id => @project.id}})</small>"
    end
  end
  
  def show_recent
    render :update do |page|
      page.replace_html 'recent', :partial => 'list', :locals => {:milestones => @project.milestones.recent, :table_id => 'recent_milestones'}
      page.replace_html 'recent_title', "Recent Milesones <small>(#{link_to_remote 'show all', :url => {:action => 'show_all', :controller => 'milestones', :project_id => @project.id}})</small>"
    end
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
    
    render :partial => 'milestones_calendar'
  end
  
  def list
    milestones_to_show = params[:include]
    @milestones = []
    @milestones = @project.milestones.future if milestones_to_show == 'future'
    @milestones = @project.milestones.recent  if milestones_to_show == 'recent'
    @milestones = @project.milestones.past  if milestones_to_show == 'all_past'
    unless @milestones.empty?
      render :partial => 'list'
    else
      render :text => '<p>Nothing to show.</p>'
    end
  end
end