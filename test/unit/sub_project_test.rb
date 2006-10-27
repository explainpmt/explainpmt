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


require File.dirname(__FILE__) + '/../test_helper'

class SubProjectTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  
  def setup
    @project_one = projects( :first )
    @project_two = projects( :second )
    @sub_project_one = sub_projects( :first )
  end

  test_required_attributes SubProject, :name
  
  def test_name_unique_within_same_project
    new_sub_proj = @sub_project_one.clone
    assert !new_sub_proj.valid?
    assert new_sub_proj.errors.on( :name )
    assert_equal 'has already been taken', new_sub_proj.errors.on( :name )
  end
  
  def test_name_not_unique_across_projects
    new_sub_proj = @sub_project_one.clone
    new_sub_proj.project = @project_two
    assert new_sub_proj.valid?
  end
  
  def test_project_association
    assert_equal @project_one, @sub_project_one.project
  end
end
