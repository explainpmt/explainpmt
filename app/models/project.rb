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

# A Project is the hub which connects User, Milestone, Iteration, and Story
# objects (and any other information in the system). With the exception of User
# objects, everything else _must_ be associated with a project; and when a
# project is deleted, everything associated with the project (except the User
# accounts) should be deleted as well.
#
# Project has the following associations:
#   has_many :iterations, :order => 'start_date ASC', :dependent => true
#   has_many :milestones, :order => 'date ASC', :dependent => true
#   has_many :stories, :dependent => true
#   has_many :backlog, :class_name => 'Story',
#            :conditions => "iteration_id IS NULL"
#   has_and_belongs_to_many :users, :order => 'last_name ASC, first_name ASC'
#
# And the following data validations:
#   validates_presence_of :name
#   validates_uniqueness_of :name
#   validates_length_of :name, :maximum => 100
#
class Project < ActiveRecord::Base
  has_many :iterations, :order => 'start_date ASC', :dependent => true
  has_many :milestones, :order => 'date ASC', :dependent => true
  has_many :stories, :dependent => true
  has_many :backlog, :class_name => 'Story',
           :conditions => "iteration_id IS NULL"
  has_and_belongs_to_many :users, :order => 'last_name ASC, first_name ASC'
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 100

  def past_iterations( reload = false )
    today = Time.now
    @past_iterations = nil if reload
    @past_iterations ||= iterations( reload ).select do |i|
      ( i.start_date + i.length ).to_time <= today.at_midnight
    end
    @past_iterations.reverse
  end

  # Returns an Array of all associated iterations that start after today
  def future_iterations( reload = false )
    today = Time.now
    @future_iterations = nil if reload
    @future_iterations ||= iterations( reload ).select do |i|
      i.start_date.to_time > today
    end
  end

  # Returns the current iteration (if there is one)
  def current_iteration( reload = false )
    today = Time.now
    @current_iteration = nil if reload
    @current_iteration ||= iterations( reload ).detect do |i|
      ( i.start_date.to_time <= today.at_midnight ) and
      ( ( i.start_date + i.length ).to_time >= today.tomorrow.at_midnight )
    end
  end

  # Returns the last iteration to have ended or nil
  def previous_iteration(reload = false)
    past_iterations(reload).first
  end

  # Returns the next scheduled iteration or nil
  def next_iteration(reload = false)
    future_iterations(reload).first
  end
  
  def future_milestones(reload = false)
    milestones(reload).select { |m| m.future? }
  end
  
  def recent_milestones(reload = false)
    milestones(reload).reverse.select { |m| m.recent? }
  end
  
  def past_milestones(reload = false)
    milestones(reload).reverse.select { |m| m.past? }
  end
end

