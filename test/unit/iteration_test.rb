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

class IterationTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  def setup
    @project_one = Project.find 1
    @iteration_one = Iteration.find 1
    @iteration_two = Iteration.find 2
    @iteration_four = Iteration.find 4
    @iteration_five = Iteration.find 5
    @iteration_six = Iteration.find 6
  end
  
  def test_stop_date
    assert_equal @iteration_one.start_date + ( @iteration_one.length - 1 ),
      @iteration_one.stop_date
  end

  def test_total_points
    assert_equal 12, @iteration_one.stories.total_points
  end

  def test_remaining_resources
    assert_equal 5, @iteration_one.remaining_resources
  end

  def test_completed_points
    assert_equal 3, @iteration_one.stories.completed_points
  end

  def test_remaining_points
    assert_equal 9, @iteration_one.stories.remaining_points
  end

  def test_iteration_id_of_stories_set_to_null_when_iteration_deleted
    @iteration_one.destroy
    assert_nil Story.find( 1 ).iteration
  end

  def test_iterations_not_allowed_to_overlap_on_same_project
    iteration_two = Iteration.find 2
    [ -1, 0, 13 ].each do |i|
      iteration_two.start_date = @iteration_one.start_date + i
      assert !iteration_two.valid?
      assert iteration_two.errors.on( :start_date )
    end
  end

  def test_iterations_allowed_to_overlap_on_different_project
    iteration_three = Iteration.find 3
    [ -1, 0, 13 ].each do |i|
      iteration_three.start_date = @iteration_one.start_date + i
      assert iteration_three.valid?
      assert_nil iteration_three.errors.on( :start_date )
    end
  end

  def test_iteration_must_belong_to_project
    assert @iteration_one.valid?
    @iteration_one.project = nil
    assert !@iteration_one.valid?
    assert @iteration_one.errors.on( :base )
  end

  def test_current_eh
    assert @iteration_one.current?
    assert !@iteration_two.current?
    assert !@iteration_four.current?
    assert !@iteration_five.current?
    assert !@iteration_six.current?
  end

  def test_current_eh_started_yesterday
    @iteration_one.start_date = Date.today - 1
    assert @iteration_one.current?
  end

  def test_current_eh_ends_today
    @iteration_one.start_date = Date.today - ( @iteration_one.length - 1 )
    assert @iteration_one.current?
  end

  def test_future_eh?
    assert !@iteration_one.future?
    assert @iteration_two.future?
    assert !@iteration_four.future?
    assert @iteration_five.future?
    assert !@iteration_six.future?
  end

  def test_past_eh?
    assert !@iteration_one.past?
    assert !@iteration_two.past?
    assert @iteration_four.past?
    assert !@iteration_five.past?
    assert @iteration_six.past?
  end
  
  def test_no_exception_raised_when_evaluating_stop_date_of_iteration_with_nil_length
    @iteration_one.length = nil
    assert_nothing_raised(TypeError) { @iteration_one.stop_date }
  end
end