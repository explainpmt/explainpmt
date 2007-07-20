class MilestonesController < ApplicationController
  include CrudActions
  
  before_filter :require_current_project, :except => [:milestones_calendar]
  popups :new, :create, :show, :edit, :update
  
  def mymodel
    Milestone
  end
  
  def index
    @page_title = "Milestones"
    if params['show_all'] == '1'
      @past_milestones = 'all_past'
      @past_link_opts = [ 'show only recent', { :controller => 'milestones',
                                                :action => 'index',
                                                :project_id => @project.id } ]
      @past_title = "All Past Milestones"
    else
      @past_milestones = 'recent'
      @past_link_opts = [ 'show all', { :controller => 'milestones',
                                        :action => 'index', 
                                        :project_id => @project.id,
                                        :show_all => '1' } ]
      @past_title = "Recent Milestones"
    end
  end
  
  def milestones_calendar
    @calendar_title = 'Upcoming Milestones:'
    milestones = @project ? @project.milestones : current_user.milestones
    milestones = milestones.select { |m|
      m.date >= Date.today && m.date < Date.today + 14
    }  
    days = []
    14.times do |i|
      current_day = Date.today + i
      days << {
        :date => current_day,
        :name => Date::DAYNAMES[current_day.wday],
        :milestones => milestones.select { |m| m.date == current_day }
      }
    end
    @days = days
    render :partial => 'milestones_calendar'
  end
  
  def list
    case params['include']
    when 'future'
      @milestones = @project.milestones.future
    when 'recent'
      @milestones = @project.milestones.recent
    when 'all_past'
      @milestones = @project.milestones.past
    else
      @milestones = []
    end
    unless @milestones.empty?
      render :partial => 'list'
    else
      render :text => '<p>Nothing to show.</p>'
    end
  end
end