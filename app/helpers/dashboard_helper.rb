module DashboardHelper
  def milestones_calendar(days_to_render=14)
    title_prefix = 'Upcoming Milestones'
    @calendar_title = current_project ? title_prefix : title_prefix.gsub(':', ' (all projects):')
    milestones = (current_project ? current_project.milestones : current_user.milestones).select { |m|
      m.date >= Date.today && m.date < Date.today + days_to_render
    }

    @days = Array.new(days_to_render) {|index|
      current_day = Date.today + index
      {:date => current_day,
        :name => Date::DAYNAMES[current_day.wday],
        :milestones => milestones.select { |m| m.date == current_day }}
    }
    render :partial => 'milestones/calendar'
  end
end
