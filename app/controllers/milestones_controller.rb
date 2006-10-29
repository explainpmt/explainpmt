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


class MilestonesController < WizardController
  before_filter :require_current_project, :except => [:milestones_calendar]
  popups :new, :create, :show, :edit, :update
  
  def mymodel
    Milestone
  end
  
  # Lists the milestones for the project.
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
  
  # Renders the partial template for the milestones calendar component.
  def milestones_calendar
    @calendar_title = 'Upcoming Milestones:'
    if @project
      milestones = @project.milestones
    else
      milestones = session[:current_user].projects.collect{|p| p.milestones}
      @calendar_title.gsub!(':', ' (all projects):')
    end
    milestones = milestones.flatten.select { |m|
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
  
  # Renders the partial template for the list component. Requires the parameter
  # 'include' to be set to one of 'future', 'recent', or 'all_past'
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