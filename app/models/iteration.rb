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

# An Iteration is a planning unit that identifies a period of time with a
# starting date, a length (in days) and a budget of story points. An iteration
# can have 0 or more Story objects associated with it, and this is how the user
# plans which story cards will be completed in a given iteration.
#
# The following associations are defined for the Iteration class:
#   belongs_to :project
#   has_many :stories
#
# And the following validations are performed on the data:
#   validates_inclusion_of :length, :in => 1..99,
#                          :message => 'must be a number between 1 and 99'
#   validates_inclusion_of :budget, :in => 1..999, :allow_nil => true,
#                          :message => 'must be a number between 1 and 999 ' +
#                                      '(or blank)'
#   validates_presence_of :start_date
#
class Iteration < ActiveRecord::Base
  belongs_to :project
  has_many :stories

  validates_inclusion_of :length, :in => 1..99,
                         :message => 'must be a number between 1 and 99'
  validates_inclusion_of :budget, :in => 1..999, :allow_nil => true,
                         :message => 'must be a number between 1 and 999 ' +
                                     '(or blank)'
  validates_presence_of :start_date

  # The last date of the iteration
  def stop_date
    start_date + length - 1
  end

  # The sum of the points of all Story objects assigned to the iteration
  def total_points
    stories.inject(0) { |res,s| res += s.points }
  end

  # The number of unallocated budget points
  def remaining_resources
    (budget || 0) - total_points
  end

  # The sum of the story points from completed Story objects assigned to the
  # iteration.
  def completed_points
    completed_stories = stories.select { |s| s.status.complete? }
    completed_stories.inject(0) { |res,s| res += s.points }
  end

  # The sum of the story points from incomplete Story objects assigned to the
  # iteration
  def remaining_points
    total_points - completed_points
  end

  def current?
    today = Time.now.at_midnight
    ( start_date.to_time <= today ) and ( stop_date.to_time >= today ) 
  end

  def future?
    tomorrow = Time.now.tomorrow.at_midnight
    start_date.to_time >= tomorrow
  end

  def past?
    today = Time.now.at_midnight
    stop_date.to_time < today
  end

  protected

  # Ensures that all associated Story objects are placed back in the project
  # backlog if the iteration they are assigned to is deleted.
  def after_destroy
    Story.update_all("iteration_id = NULL", ["iteration_id = ?",self.id])
  end

  def validate
    ensure_iteration_belongs_to_project
    ensure_no_overlap unless project.nil?
  end

  def ensure_iteration_belongs_to_project
    if project.nil?
      errors.add_to_base('The iteration is not assigned to a project!')
    end
  end

  def ensure_no_overlap
    found_overlap = false
    overlaps = nil
    set_overlap_found = Proc.new { |i|
      found_overlap = true
      overlaps = i
    }
    project.iterations(true).each do |iteration|
      unless iteration.id == id
        if iteration.stop_date <= stop_date &&
          iteration.stop_date >= start_date
          set_overlap_found.call(iteration)
          break
        elsif iteration.start_date >= start_date &&
          iteration.start_date <= stop_date
          set_overlap_found.call(iteration)
          break
        elsif iteration.start_date >= start_date &&
          iteration.stop_date <= stop_date
          set_overlap_found.call(iteration)
          break
        elsif iteration.start_date <= start_date &&
          iteration.stop_date >= stop_date
          set_overlap_found.call(iteration)
          break
        end
      end
    end
    if found_overlap
      errors.add(:start_date, "causes an overlap with #{overlaps.length}-day " +
                 "iteration starting on " +
                 "#{overlaps.start_date.strftime("%m/%d/%Y")}.")
    end
  end
end
