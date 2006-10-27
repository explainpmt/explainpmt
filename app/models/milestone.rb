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

# A Milestone represents a particular event or date that the project team should
# be aware of but is not a work item or attached to any specific Iteration.
# Examples might include: the planned date for a release, an important meeting,
# a conference, etc.
#
# Milestone has the following associations:
#   belongs_to :project
#
# And the following validations are performed on the data:
#   validates_presence_of :name, :date
#   validates_length_of :name, :maximum => 100
#
class Milestone < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :name, :date
  validates_length_of :name, :maximum => 100
  
  def future?
    date >= Date.today
  end
  
  def recent?
    date < Date.today && date > Date.today - 15
  end
  
  def past?
    date < Date.today
  end
end

