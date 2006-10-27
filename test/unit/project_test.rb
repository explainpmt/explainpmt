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

class ProjectTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES

  def setup
    @project_one = Project.find 1
    
    @iteration_one = Iteration.find 1
    @iteration_two = Iteration.find 2
    @iteration_four = Iteration.find 4
    @iteration_five = Iteration.find 5
    @iteration_six = Iteration.find 6

    @milestone_one = Milestone.find 1
    @milestone_two = Milestone.find 2
    @milestone_three = Milestone.find 3
    @milestone_four = Milestone.find 4
    @milestone_five = Milestone.find 5
    @milestone_six = Milestone.find 6
    @milestone_seven = Milestone.find 7
  end

  def test_current_iteration_that_starts_today
    assert_equal @iteration_one, @project_one.iterations.current
  end

  def test_current_iteration_that_ends_today
    Iteration.destroy_all 'id != 1' # otherwise others would overlap
    @iteration_one.start_date = Date.today - ( @iteration_one.length - 1 )
    @iteration_one.save!
    assert_equal @iteration_one, @project_one.iterations.current
  end

  def test_current_iteration_that_began_yesterday
    Iteration.destroy_all 'id != 1' # otherwise others would overlap
    @iteration_one.start_date = Date.today - 1
    @iteration_one.save!
    assert_equal @iteration_one, @project_one.iterations.current
  end
  
  def test_past_iterations
    assert_equal [ @iteration_four, @iteration_six ],
      @project_one.iterations.past
  end

  def destroy_past_iterations
    @iteration_four.destroy
    @iteration_six.destroy
  end
  
  def test_past_iterations_with_no_past_iterations
    destroy_past_iterations
    assert @project_one.iterations.past.empty?
  end
  
  def test_previous_iteration
    assert_equal @iteration_four, @project_one.iterations.previous
  end

  def test_previous_iteration_with_no_past_iterations
    destroy_past_iterations
    assert_nil @project_one.iterations.previous
  end

  def test_future_iterations
    assert_equal [ @iteration_two, @iteration_five ],
      @project_one.iterations.future
  end

  def destroy_future_iterations
    @iteration_two.destroy
    @iteration_five.destroy
  end
  
  def test_future_iterations_with_no_future_iterations
    destroy_future_iterations
    assert @project_one.iterations.future.empty?
  end
  
  def test_next_iteration
    assert_equal @iteration_two, @project_one.iterations.next
  end

  def test_next_iteration_with_no_future_iterations
    destroy_future_iterations
    assert_nil @project_one.iterations.next
  end

  def test_future_milestones
    assert_equal [ @milestone_five, @milestone_seven, @milestone_six ],
                 @project_one.milestones.future
  end

  def test_future_milestones_with_no_future_milestones
    @milestone_five.destroy
    @milestone_six.destroy
    @milestone_seven.destroy
    assert @project_one.milestones.future.empty?
  end
  
  def test_recent_milestones
    assert_equal [ @milestone_four, @milestone_three ],
                 @project_one.milestones.recent
  end

  def destroy_recent_milestones
    @milestone_four.destroy
    @milestone_three.destroy
  end
  
  def test_recent_milestones_with_no_recent_milestones
    destroy_recent_milestones
    assert @project_one.milestones.recent.empty?
  end
  
  def test_past_milestones
    assert_equal @project_one.milestones.recent +
      [ @milestone_two, @milestone_one ], @project_one.milestones.past
  end

  def test_past_milestones_with_no_past_milestones
    destroy_recent_milestones
    @milestone_two.destroy
    @milestone_one.destroy
    assert @project_one.milestones.past.empty?
  end
  
  def test_backlog
    num_backlog = @project_one.stories.reject{ |a| a.iteration }.size
    assert_equal num_backlog, @project_one.stories.backlog.size
  end
end
