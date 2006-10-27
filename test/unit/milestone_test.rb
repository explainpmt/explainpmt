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

class MilestoneTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES

  def setup
    @past_milestone1 = Milestone.find 1
    @past_milestone2 = Milestone.find 2
    @recent_milestone1 = Milestone.find 3
    @recent_milestone2 = Milestone.find 4
    @future_milestone1 = Milestone.find 5
    @future_milestone2 = Milestone.find 6
  end
  
  def test_future_eh
    assert !@past_milestone1.future?
    assert !@past_milestone2.future?
    assert !@recent_milestone1.future?
    assert !@recent_milestone2.future?
    assert @future_milestone1.future?
    assert @future_milestone2.future?
  end
  
  def test_recent_eh
    assert !@past_milestone1.recent?
    assert !@past_milestone2.recent?
    assert @recent_milestone1.recent?
    assert @recent_milestone2.recent?
    assert !@future_milestone1.recent?
    assert !@future_milestone2.recent?
  end
  
  def test_past_eh
    assert @past_milestone1.past?
    assert @past_milestone2.past?
    assert @recent_milestone1.past?
    assert @recent_milestone2.past?
    assert !@future_milestone1.past?
    assert !@future_milestone2.past?
  end
end
