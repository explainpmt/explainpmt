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

# A User represents an account on the system. Each person that can log into the
# system has an associated User object.
#
# User has the following associations:
#   has_and_belongs_to_many :projects
#   has_many :stories
#
# And the following data validations:
#   validates_presence_of :first_name, :last_name, :email
#   validates_uniqueness_of :username, :email
#   validates_length_of :username, :minimum => 4
#   validates_length_of :password, :minimum => 6
#   validates_confirmation_of :password
#   validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
#
class User < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_many :stories

  validates_presence_of :first_name, :last_name, :email
  validates_uniqueness_of :username, :email
  validates_length_of :username, :minimum => 4
  validates_length_of :password, :minimum => 6
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/

  LastFirst = true

  # Returns the full name of the user. If the <tt>last_first</tt> argument is
  # set to +true+ (or the constant User::LastFirst), the name will be returned
  # as "Doe, John". Otherwise it is returned as "John Doe"
  def full_name(last_first = false)
    if last_first
      "#{last_name}, #{first_name}"
    else
      "#{first_name} #{last_name}"
    end
  end

  # Returns the User object that matches the supplied +username+ and +password+
  # arguments, or returns +nil+ if no match is found.
  def self.authenticate(username, password)
    find_by_username_and_password(username, password)
  end
end
